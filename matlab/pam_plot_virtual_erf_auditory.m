clear;

for nsuj = 2:21
    
    sujname                     = ['yc' num2str(nsuj)];
    
    fname                       = ['~/Dropbox/project_me/data/pam/virt/' sujname '.CnD.virtualelectrode.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    all_code                    = data.trialinfo - 1000;
    target_code                 = mod(all_code,10); % target
    
    list_target                 = [1 3; 2 4];
    list_name                   = {'left' 'right'};
    
    for ntarget = [1 2]
        
        list_type               = {'atlas' 'loc'};
        list_side               = 'LR';
        
        for ntype = [1 2]
            for nhemi = [1 2]
            
                cfg             = [];
                cfg.trials      = find(ismember(target_code,list_target(ntarget,:)));
                cfg.channel     = {['aud*' list_type{ntype} '*' list_side(nhemi) '*']};
                avg            	= ft_timelockanalysis(cfg,data);
                
                
                avg.avg      	= abs(avg.avg);
                
                ix1            	= nearest(avg.time,-0.1);
                ix2           	= nearest(avg.time,0);
                bsl           	= mean(avg.avg(:,ix1:ix2),2);
                act           	= avg.avg;
                
                avg.avg        	= act - bsl;
                alldata{nsuj-1,ntype,ntarget,nhemi}  	= avg; clear avg;
                
            end
        end
        
    end
    
end

keep alldata list*

%%

clc;

nrow                        = 2;
ncol                        = 2;
i                           = 0;

list_color                	= 'br';

for ntype = [1 2]
    
    for ntarget = [1 2]
        
        i = i + 1;
        subplot(nrow,ncol,i)
        hold on;
        
        for nhemi = [1 2]
        
            mtrx_data               = [];
            
            for nsuj = 1:size(alldata,1)
                flg                 = alldata{nsuj,ntype,ntarget,nhemi};
                mtrx_data(nsuj,:)  	= mean(flg.avg,1);
            end
            
            time_axis               = alldata{1}.time;
            
            % Use the standard deviation over trials as error bounds:
            mean_data               = nanmean(mtrx_data,1);
            bounds                  = nanstd(mtrx_data, [], 1);
            bounds_sem              = bounds ./ sqrt(size(mtrx_data,1));
            
            boundedline(time_axis, mean_data, bounds_sem,['-' list_color(nhemi)],'alpha'); % alpha makes bounds transparent
            
        end
        
        legend([list_side(1) ' AcX'], '', [list_side(2) ' AcX'], '');
        
        xlim([1 2]);
        
        y_lim                       = [-1e10 3e11];
        
        ylim(y_lim);
        yticks(y_lim);
        
        xticks([0 0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8 2]);
        xticklabels({'cue' '0.2' '0.4' '0.6' '0.8' '1' 'target' '1.4' '1.6' '1.8' '2'});
        
        vline([0 1.2],'--k');
        hline(0,'--k');
                
        title([list_type{ntype} ' ' list_name{ntarget} ' target']);
        
        set(gca,'FontSize',16)
        
            
    end
    
    
end