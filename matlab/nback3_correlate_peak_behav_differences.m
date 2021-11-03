clear;clc;

allbehav                            = [];

for nbehav = [1:33 35:36 38:44 46:51]
    
    dir_data                        = '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in                        = [ dir_data 'sub' num2str(nbehav) '.singletrial.trialinfo.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    biginfo                         = trialinfo; clear trialinfo;
    
    for nback = [5 6]
        
        trialinfo                	= biginfo(biginfo(:,1) == nback,:);
        
        correct_trials             	= find(rem(trialinfo(:,4),2) ~= 0);
        perc_correct               	= length(correct_trials) ./ length(trialinfo);
        
        correct_trials_with_rt     	= find(rem(trialinfo(:,4),2) ~= 0 & trialinfo(:,5) ~= 0);
        rt_vector                  	= trialinfo(correct_trials_with_rt,5) ./ 1000;
        rt_vector                	= rt_vector/mean(rt_vector);
        mean_rt                    	= mean(rt_vector);
        
        tmp_correct(nback-4)     	= 	perc_correct;
        tmp_rt(nback-4)             = 	mean_rt;
        
    end
    
    allbehav                        = [allbehav; diff(tmp_correct) diff(tmp_rt)]; clear tmp_*
    
end

suj_list                            = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    dir_data                        = '~/Dropbox/project_me/data/nback/peak/';
    fname_in                    	= [dir_data 'sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.restrict.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1)         	= apeak;
    allbetapeaks(nsuj,1)        	= bpeak;
        
end

mean_beta_peak                     	= round(nanmedian(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))  	= mean_beta_peak;

keep all*

[rho_alpha_acc,p_alpha_acc]         = corr(allbehav(:,1),allalphapeaks, 'type', 'Spearman');
[rho_alpha_rt,p_alpha_rt]           = corr(allbehav(:,2),allalphapeaks, 'type', 'Spearman');

[rho_beta_acc,p_beta_acc]           = corr(allbehav(:,1),allbetapeaks, 'type', 'Spearman');
[rho_beta_rt,p_beta_rt]             = corr(allbehav(:,2),allbetapeaks, 'type', 'Spearman');


DataTable                           = [allbehav(:,1) allbetapeaks];
corrplot(DataTable,'type','Spearman','testR','on')