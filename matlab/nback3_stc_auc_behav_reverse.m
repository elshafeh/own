clear;clc;

suj_list                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname                 = ['sub' num2str(suj_list(nsuj))];
    
    ext_behav            	= 'accuracy';
    fname_in             	= ['~/Dropbox/project_me/data/nback/singletrial/sub' num2str(suj_list(nsuj)) '.singletrial.trialinfo.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    list_stim               = [2 3 4 5 7 8 9]; % [1 2 3 4 5 6 7 8 9 10]; %    
    rho_sub                 = [];
    
    for nstim = 1:length(list_stim)
        
        % get behavioral data
        if strcmp(ext_behav,'accuracy')
            flg_trials          = find(trialinfo(:,4) ~= 0);
            behav               = trialinfo(flg_trials,4);
            behav(behav == 1 | behav == 3)  = 1;
            behav(behav == 2 | behav == 4)  = 0;
        elseif strcmp(ext_behav,'rt')
            flg_trials          = find(trialinfo(:,5) ~= 0 & rem(trialinfo(:,4),2) ~= 0);
            behav               = trialinfo(flg_trials,5)/1000;
            behav               = behav ./ mean(behav);
        end
        
        try
            
            % load decoding output
            dir_files   	= '~/Dropbox/project_me/data/nback/';
            fname        	= [dir_files 'auc/' sujname '.decoding.stim' num2str(list_stim(nstim)) '.nodemean.leaveone.mat'];
            fprintf('loading %s\n',fname);
            load(fname,'y_array','yproba_array','time_axis');
            
            % transpose matrices
            y_array      	= y_array';
            yproba_array  	= yproba_array';
            
            y_array        	= y_array(flg_trials,:);
            yproba_array   	= yproba_array(flg_trials,:);
            
            auc_all        	= h_calc_auc(y_array,yproba_array,1:size(y_array,1));
            
            auc_diff      	= [];
            bad_trials   	= [];
            
            for ntrial = 1:size(y_array,1)
                
                disp([sujname ' Stim' num2str(list_stim(nstim)) ': trial ' num2str(ntrial) ' / ' num2str(size(y_array,1))]);
                
                index_trials        = 1:size(y_array,1);
                index_trials(index_trials == ntrial) = [];
                
                try
                    tmp_auc             = h_calc_auc(y_array,yproba_array,index_trials);
                    tmp_diff            = auc_all - tmp_auc;
                    auc_diff(ntrial,:)  = tmp_diff;
                catch
                    warning('trial will be excluded');
                    auc_diff(ntrial,:)  = nan(1,length(time_axis));
                    bad_trials          = [bad_trials;ntrial];
                end
                
                clear tmp_diff tmp_auc
                
            end
            
            % remove bad trials
            bad_trials              = unique(bad_trials);
            auc_diff(bad_trials,:,:)	= [];
            behav(bad_trials)       = [];
            
            [rho,p]                 = corr(auc_diff,behav , 'type', 'Pearson');
            rho                     = .5.*log((1+rho)./(1-rho)); clear auc_diff;
            rho_sub                 = [rho_sub;rho']; clear rho;
            
        catch
            warning('stim will be excluded');
            bad_stim        = [bad_stim;nstim];
        end
        
    end
    
    avg                     = [];
    avg.avg                 = nanmean(rho_sub,1);
    avg.time                = time_axis;
    avg.label               = {['decoding stim e ' ext_behav]};
    avg.dimord              = 'chan_time';
    
    alldata{nsuj,1}         = avg; clear avg;
    
    alldata{nsuj,2}         = alldata{nsuj,1};
    alldata{nsuj,2}.avg(:)	= 0;
    
    
end

keep all*

%%

nsuj                       	= size(alldata,1);
[design,neighbours]      	= h_create_design_neighbours(nsuj,alldata{1},'gfp','t'); clc;

cfg                         = [];
cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
cfg.uvar                    = 1;cfg.ivar = 2;
cfg.tail                    = 0;cfg.clustertail  = 0;
cfg.neighbours              = neighbours;
cfg.channel                 = 1;
cfg.latency                 = [0 0.6];
cfg.clusteralpha            = 0.05; % !!
cfg.minnbchan               = 0; % !!
cfg.alpha                   = 0.025;

cfg.numrandomization        = 1000;
cfg.design                  = design;

stat                        = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});
[min_p , p_val]             = h_pValSort(stat);

%%

clc;

nrow                     	= 1;
ncol                     	= 1;
i                         	= 0;

plimit                    	= 0.3;

stat.mask                   = stat.prob < plimit;

for nchan = 1:length(stat.label)
    
    vct                     = stat.prob(nchan,:);
    min_p                   = min(vct);
    
    cfg                     = [];
    cfg.channel             = nchan;
    cfg.time_limit          = [-0.1 1]; % stat.time([1 end]);
    cfg.z_limit           	= [-0.1 0.05];
    cfg.color           	= {'-k' '-k'};
    cfg.lineshape           = '-x';
    cfg.linewidth           = 2;
    
    i = i+1;
    subplot(nrow,ncol,i);
    h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
    
    ylabel({stat.label{nchan}, ['p= ' num2str(round(min_p,3))]})
    
    vline(0,'--k');
    hline(0,'--k');
    
    set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
    
    
end