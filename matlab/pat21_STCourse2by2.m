clear;clc;dleiftrip_addpath;close all;

load ../data/yctot/postConn&MotorExtWav.mat ; clear allsuj note ext;

load ../data/yctot/Virtual4Anova.mat; virt = source_avg(:,:,:,:,:) ; clear source_avg
load ../data/yctot/TfRes4Anova.mat; tres = source_avg ; clear source_avg

for sb = 1:14
    for chn = 1:34
        for f = 1:size(tres,4)
            for t = size(tres,5)
                tres(sb,5,chn,f,t) = mean([tres(sb,1,chn,f,t) tres(sb,2,chn,f,t)]);
            end
        end
    end
end

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

cnd_inter = [1 2 ; 1 3; 2 3;5 3];

calc_list  = {'virt','tres'};

for cnd_calc = 1:2
    
    for cnd_compare = 1:4
        
        ix_chn = 0 ;
        
        for chn = 1:6
            
            ix_chn = ix_chn + 1;
            
            fprintf('Anova channel %2d\n',chn)
            
            for f = 1:length(frq_list)
                
                ix_t    = 0 ;
                
                for t = 1:10
                    
                    ix_t = ix_t + 1;
                    
                    cnd1 = cnd_inter(cnd_compare,1);
                    cnd2 = cnd_inter(cnd_compare,2);
                    
                    avg1 = squeeze(source_avg(:,cnd1,chn,f,t,cnd_calc));
                    avg2 = squeeze(source_avg(:,cnd2,chn,f,t,cnd_calc));
                    
                    p = permutation_test([avg1 avg2],1000);
                    
                    permData(cnd_calc,cnd_compare,chn,f,t) = p ; 
                    
                    clear p 
                    
                end
            end
            
        end
    end
end

clearvars -except source_avg *_list permData cnd_inter ;

cnd_effect = {'Cue'};
calc_list  = {'virt','tres'};

for cnd_calc = 1:2
    
    for cnd_compare = 1:4
        
        for f = 1:size(permData,4)-1
            
            for chn = 1:size(permData,3)
                
                zizi = squeeze(permData(cnd_calc,cnd_compare,chn,f,:));
                pipi = zizi<0.05;
                wiwi = find(pipi==1);
                titi = find(wiwi<4);
                
                lim_y1 = -0.3 ;
                lim_y2 =  0.3 ;
                
                if ~isempty(wiwi)
                    if isempty(titi)
                        
                        figure;
                        hold on
                        
                        for z = 1:length(wiwi)
                            rectangle('Position',[tm_list(wiwi(z))  lim_y1 0.2 abs(lim_y1)+abs(lim_y2)],'FaceColor',[0.7 0.7 0.7]);
                        end
                        
                        cnd_list = {'R','L','N','','V'};
                        
                        % sb,cond,chan,freq,time,calc
                        
                        x = squeeze(mean(source_avg(:,cnd_inter(cnd_compare,1),chn,f,1:10,cnd_calc),1));
                        z = squeeze(mean(source_avg(:,cnd_inter(cnd_compare,2),chn,f,1:10,cnd_calc),1));
                        
                        y = tm_list(1:10);
                        
                        plot(y,[x z])
                        ylim([lim_y1 lim_y2])
                        xlim([-0.6 1.2]);
                        title([calc_list{cnd_calc}  ' ' num2str(frq_list(f)) 'Hz']);
                        
                        chn_tit = {[cnd_list{cnd_inter(cnd_compare,1)} ' ' chn_list{chn}],[cnd_list{cnd_inter(cnd_compare,2)} ' ' chn_list{chn}]};
                        
                        legend(chn_tit)
                        
                        clear nw_nw_list
                        
                    end
                end
                
            end
        end
    end
end