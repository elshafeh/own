clear;clc;dleiftrip_addpath;close all;

load ../data/yctot/postConn&MotorExtWav.mat ; clear allsuj note ext;

load ../data/yctot/Virtual4Anova.mat; virt = source_avg(:,1:3,:,:,:) ; clear source_avg
load ../data/yctot/TfRes4Anova.mat; tres = source_avg ; clear source_avg

source_avg = cat(6,virt,tres); clear virt tres;

frq_list    = [6 9 12 15];
tm_list     = -0.6:0.2:2;
chn_list    = template.label;

% sb,cond,chan,freq,time,calc

for cnd_calc = 1:2
    
    for sb = 1:14
        
        for cnd = 1:3
            
            for chn = 1:34
                
                tmp = squeeze(source_avg(sb,cnd,chn,:,:,cnd_calc)) ;
                
                t1 = find(round(tm_list,2) == -0.6);
                t2 = find(round(tm_list,2) == -0.2);
                
                bsl_prt         = repmat(mean(tmp(:,t1:t2),2),1,size(tmp,2));
                
                tmp = (tmp-bsl_prt) ./ bsl_prt;
                
                source_avg(sb,cnd,chn,:,:,cnd_calc) = tmp;
                
                clear tmp t1 t2 bsl_prt
                
            end
            
        end
        
    end
    
end

clearvars -except source_avg *_list

chn_list = [chn_list(1:6);chn_list(31:34)];

% chn_list = [chn_list(1:6)];

for cnd_calc = 1:2
    
    ix_chn = 0 ;
    
    for chn = [1:6 31:34]
        
        ix_chn = ix_chn + 1;
        
        fprintf('Anova channel %2d\n',chn)
        
        for f = 1:length(frq_list)
            
            ix_t    = 0 ;
            
            for t = 1:10
                
                ix_t = ix_t + 1;
                
                Y   = [];  S = [];
                F1  = []; F2 = [];
                
                for cnd = 1:3
                    
                    for sb = 1:14
                        
                        avg = squeeze(source_avg(sb,cnd,chn,f,t,cnd_calc));
                        
                        Y   =   [Y; nanmean(nanmean(avg))];
                        S   =   [S;sb];
                        F1  =   [F1;cnd];
                        F2  =   [F2;1];
                        
                        anovaData(sb,cnd,ix_chn,f,t,cnd_calc) = nanmean(nanmean(avg));
                        
                    end
                    
                end
                
                res                                             =   PrepAtt2_rm_anova(Y,S,F1,F2,{'Cue','n'});
                anovaResults(ix_chn,f,ix_t,1,cnd_calc)          =   res{2,6};
                
                clear Y
                
            end
        end
        
    end
end

clearvars -except source_avg anov* *list

cnd_effect = {'Cue'};
calc_list  = {'virt','tres'};

for cnd_calc = 1:2
    
    for p = 1
        
        for f = 4 %:3 % 1:size(anovaResults,2)
            
            ii = 0 ;
            
            for chn = 1:2 % size(anovaResults,1)
                
                ii = ii + 1;
                
                % ix_chn,f,ix_t,1,cnd_calc
                
                zizi = squeeze(anovaResults(chn,f,:,p,cnd_calc));
                pipi = zizi<0.1;
                wiwi = find(pipi==1);
                titi = find(wiwi<1);
                
                lim_y1 = -0.3 ;
                lim_y2 =  0.3 ;
                
                if ~isempty(wiwi)
                    if isempty(titi)
                        
                        figure;
                        hold on
                        
                        for z = 1:length(wiwi)
                            if zizi(wiwi) < 0.05
                                rectangle('Position',[tm_list(wiwi(z))  lim_y1 0.2 abs(lim_y1)+abs(lim_y2)],'FaceColor',[0.7 0.7 0.7]);
                            end
                        end
                        
                        cnd_list = {'R','L','N'};
                        
                        iha = 0 ;
                        nw_nw_list = {};
                        
                        clr_list = 'brg' ; 
                        
                        for cnd = 1:3
                            
                            %(sb,cnd,ix_chn,f,t,cnd_calc)
                            
                            x = anovaData(:,cnd,chn,f,:,cnd_calc);
                            x = mean(x,1);
                            x = squeeze(x);
                            y = tm_list(1:10);
                            
                            
                            plot(y,x,clr_list(cnd))
                            
                            
                            ylim([lim_y1 lim_y2])
                            xlim([-0.6 1.2]);
                            title([calc_list{cnd_calc}  ' ' num2str(frq_list(f)) 'Hz ' cnd_effect{p} ' min-p = ' num2str(min(zizi))]);
                            
                            iha = iha +1 ;
                            nw_nw_list{iha} = [cnd_list{cnd} ' ' chn_list{chn}];
                            
                        end
                        
                        legend(nw_nw_list)
                        
                        clear nw_nw_list
                        
                    end
                end
                
                ii = ii + 1;
                
            end
            
        end
        
    end
    
end