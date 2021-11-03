clear;clc;

i                               = 0;

list_behav                      = {'accuracy' 'rt' };

for nbehav = 1:length(list_behav)
    
    suj_list                	= [1:33 35:36 38:44 46:51];
    all_rho                     = [];
    
    for nsuj = 1:length(suj_list)
        
        sujname             	= ['sub' num2str(suj_list(nsuj))];
        ext_behav            	= list_behav{nbehav};
        
        fname_in             	= ['~/Dropbox/project_me/data/nback/singletrial/sub' num2str(suj_list(nsuj)) '.singletrial.trialinfo.mat'];
        fprintf('loading %s\n',fname_in);
        load(fname_in)
        
        dir_files             	= '~/Dropbox/project_me/data/nback/';
        flist               	= dir([dir_files 'auc/' sujname '.decoding.stim*.nodemean.leaveone.mat']);
        
        for nstim = 1:length(flist)
            
            % load decoding output
            fname            	= [flist(nstim).folder filesep flist(nstim).name];
            fprintf('loading %s\n',fname);
            load(fname);
            
            % transpose matrices
            y_array           	= y_array';
            yproba_array       	= yproba_array';
            e_array          	= e_array';
            auc_array           = auc_array';
            
            if strcmp(ext_behav,'accuracy')
                
                find_stim     	= find(trialinfo(:,2) == 2); % focus target
                find_resp     	= find(rem(trialinfo(:,4),2) ~= 0); % focus on correct/incorrect
                flg_trials    	= intersect(find_stim,find_resp);
                
            elseif strcmp(ext_behav,'rt')
                
                flg_trials    	= find(trialinfo(:,5) ~= 0 & rem(trialinfo(:,4),2) ~= 0);
                
            end
            
            t1                  = nearest(time_axis,0.08);
            t2                  = nearest(time_axis,0.28);
            tmp                 = yproba_array(flg_trials,t1:t2);
            data                = [];
            
            % find max instead of mean
            for ntrial = 1:size(tmp,1)
                data            = [data;max(tmp(ntrial,:))];
            end
            
            if strcmp(ext_behav,'accuracy')
                
                behav                   = trialinfo(flg_trials,4);
                behav(behav == 1 | behav == 3)  = 1;
                behav(behav == 2 | behav == 4)  = 0;
                
            elseif strcmp(ext_behav,'rt')
                
                behav                   = trialinfo(flg_trials,5)/1000;
                
            end
            
            if strcmp(ext_behav,'accuracy')
                [rho,p]      	= corr(data,behav , 'type', 'Spearman');
            elseif strcmp(ext_behav,'rt')
                [rho,p]      	= corr(data,behav , 'type', 'Pearson');
            end
            
            rho                 = .5.*log((1+rho)./(1-rho));
            
            all_rho(nsuj,nstim)     = rho; clear rho;
            
        end
        
    end
    
    x                   = mean(all_rho,2);
    y                   = ones(length(x),1);
    
    [h,p,ci,stats]      = ttest(x);
    
    i                   = i + 1;
    subplot(2,2,i);
    hold on;
    scatter(y,x);
    plot(0.8:0.1:1.2,[0 0 0 0 0 ],'--r');
    
    ylim([-0.2 0.2]);
    yticks([-0.1 0 0.1]);
    
    xlim([0 2]);
    xticks(1);
    xticklabels({'r coefficients'});
    
    grid;
    
    title([ext_behav ' t = ' num2str(round(stats.tstat,2)) ' p = ' num2str(round(p,2))]);
    set(gca,'FontSize',18,'FontName', 'Calibri','FontWeight','normal');

end