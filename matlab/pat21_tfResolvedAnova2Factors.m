clear;clc;dleiftrip_addpath;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    cond = {'RCnD','LCnD','NCnD'};
    suj = ['yc' num2str(suj_list(sb))] ;
    
    for c = 1:3
        
        fname_in = [suj '.' cond{c} '.tfResolved.9&13Hz.m700p1200ms.mat'];
        fprintf('Loading %50s \n',fname_in);
        load(['../data/' suj '/source/' fname_in])
        
        lm1 = find(round(tResolvedAvg.time,2) == -0.6);
        lm2 = find(round(tResolvedAvg.time,2) == -0.2);
        
        bsl = mean(tResolvedAvg.pow(:,:,lm1:lm2),3);
        
        load ../data/template/source_struct_template_MNIpos.mat
        
        for t = 1:20
            tResolvedAvg.pow(:,:,t) = (tResolvedAvg.pow(:,:,t) - bsl) ./ bsl ;
        end
        
        source_avg{sb,c} = tResolvedAvg.pow;
        
        clear tResolvedAvg
        
    end
    
end

clearvars -except source_avg ; clc ;

load ../data/yctot/ArsenalIndex.mat;

roi_list = unique(indx_tot(:,2));

for f = 1:2
    
    for b_chn = 1:3
        
        ix_t = 0 ;
        
        for t = 1:20;
            
            ix_t = ix_t + 1;
            
            Y   = [];  S = [];
            F1  = []; F2 = [];
            
            chn_fac = [1 2; 3 4; 5 6];
            
            for cnd = 1:3
                for bc = 1:2
                    for sb = 1:14
                        
                        ix  = find(indx_tot(:,2)==roi_list(chn_fac(b_chn,bc)));
                        ix  = indx_tot(ix,1);
                        avg = squeeze(source_avg{sb,cnd}(ix,f,t));
                        
                        Y   =   [Y; nanmean(nanmean(avg))];
                        S   =   [S;sb];
                        F1  =   [F1;cnd];
                        F2  =   [F2;bc];
                        
                    end
                end
            end
            
            res                          =   PrepAtt2_rm_anova(Y,S,F1,F2,{'Cue','Cx'});
            anovaF1(b_chn,f,ix_t)        =   res{2,6};
            anovaF2(b_chn,f,ix_t)        =   res{3,6};
            anovaIn(b_chn,f,ix_t)        =   res{4,6};
            
            clear Y S F1 F2
            
        end
        
    end
end

clearvars -except anova*

chn_list = {'Occ','HG','STG'};
frq_list = {'low','high'};
tm_list  = -0.7:0.1:1.2;

for f=1:2   
    figure;
    for chn = 1:3
        
        subplot(3,1,chn);
        
        hold on
        
        for t = 1:20
            
            X   = tm_list;
            Y1  = squeeze(anovaF1(chn,f,:));
            Y2  = squeeze(anovaF2(chn,f,:));
            Y3  = squeeze(anovaIn(chn,f,:));
            
            plot(X,Y1,'b');
            plot(X,Y2,'r');
            plot(X,Y3,'g');
            ylim([0 0.05]);
            xlim([-0.7 1.2]);
            vline(0,'--k');
            title([chn_list{chn} ' ' frq_list{f}]);
            
        end
    end
end