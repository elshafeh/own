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

for cnd_calc = 1:2
    
    ix_chn = 0 ;
    ixix   = 0 ;
    
    for chn = [1:2:6 31:2:34]
        
        ix_chn = ix_chn + 1;
        
        ixix = ixix + 1 ;
        
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
                        
                        anovaData(sb,cnd,ixix,f,t,cnd_calc) = avg;
                        
                        avg = squeeze(source_avg(sb,cnd,chn+1,f,t,cnd_calc));
                        Y   =   [Y; nanmean(nanmean(avg))];
                        S   =   [S;sb];
                        F1  =   [F1;cnd];
                        F2  =   [F2;2];
                        
                        anovaData(sb,cnd,ixix+1,f,t,cnd_calc) = avg;
                        
                    end
                    
                end
                
                res                                             =   PrepAtt2_rm_anova(Y,S,F1,F2,{'Cue','Acx'});
                anovaResults(ix_chn,f,ix_t,1,cnd_calc)          =   res{2,6};
                anovaResults(ix_chn,f,ix_t,2,cnd_calc)          =   res{3,6};
                anovaResults(ix_chn,f,ix_t,3,cnd_calc)          =   res{4,6};
                
                clear Y
                
            end
        end
        
        ixix = ixix + 1;
        
    end
end

clearvars -except source_avg anov* *list

cnd_effect = {'Cue','Acx','Inter'};
calc_list  = {'virt','tres'};

for cnd_calc = 1
    
    for p = 3
        
        for f = 2 % 1:size(anovaResults,2)-1
            
            ii = 0 ;
            
            for chn = 1:size(anovaResults,1)
                
                ii = ii + 1;
                
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
                            rectangle('Position',[tm_list(wiwi(z))  lim_y1 0.2 abs(lim_y1)+abs(lim_y2)],'FaceColor',[0.7 0.7 0.7]);
                        end
                        
                        cnd_list = {'R','L','N'};
                        
                        iha = 0 ;
                        
                        for cnd = 1:3
                            
                            x = squeeze(mean(anovaData(:,cnd,ii:ii+1,f,:,cnd_calc),1));
                            y = tm_list(1:10);
                            
                            plot(y,x)                           
                            ylim([lim_y1 lim_y2])
                            xlim([-0.6 1.2]);
                            title([calc_list{cnd_calc}  ' ' num2str(frq_list(f)) 'Hz ' cnd_effect{p}]);
                            
                            iha = iha +1 ;
                            nw_nw_list{iha} = [cnd_list{cnd} ' ' chn_list{ii}];
                            
                            iha = iha +1 ;
                            nw_nw_list{iha} = [cnd_list{cnd} ' ' chn_list{ii+1}];
                            
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

% for f = 6:size(anovaResults,2)
%
%     figure;
%
%     for chn = 1:size(anovaResults,1)
%
%         subplot(2,1,chn)
%
%         hold on
%
%         for eff = 1:3
%             plot_x              = tm_list(1:8);
%             plot_y              = squeeze(anovaResults(chn,f,:,eff));
%             plot(plot_x,plot_y); ylim([0 0.06]); xlim([-0.6 2]);
%         end
%
%         legend({'Cue','Hemi','Int'});
%
%         chn_list = {'HG','STG'};
%
%         title([chn_list{chn} ',' num2str(frq_list(f)) 'Hz']);
%
%         vline(0,'--k');
%         vline(1.2,'--k');
%         hline(0.05,'-k');
%
%     end
%
% end

% frq_list = 5:15;
% tm_list  = -0.6:0.2:2;
%
% cnd_list = {'RCue','LCue','NCue'};
%
% frq     = 11    ; f     = find(frq_list==frq);
% time1   = 0.6   ; t1    = find(round(tm_list,2)==round(time1,2));
% time2   = 0.8   ; t2    = find(round(tm_list,2)==round(time2,2));
%
% nw_anovaData = squeeze(mean(anovaData,1));
%
% toplot = zeros(3,2);
%
% for cnd = 1:3
%
%     toplot(cnd,1) = mean(nw_anovaData(cnd,1,f,t1:t2),4);
%     toplot(cnd,2) = mean(nw_anovaData(cnd,2,f,t1:t2),4);
%
% end
%
% figure ; hold on ;
%
% plot(toplot(1,:),'b')
% plot(toplot(2,:),'r')
% plot(toplot(3,:),'g')
%
% set(gca,'Xtick',0:1:5)
% xlim([0 3])
% ylim([-0.2 0.1])
% set(gca,'Xtick',0:3,'XTickLabel', {'','LeftAcx','RightAcx',''})
% legend({'RCue','LCue','NCue'}, 'Location', 'Northeast')