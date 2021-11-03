clear;clc;

suj_list                	= [1:33 35:36 38:44 46:51];
% suj_list                	= [1:15 17:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname             	= ['sub' num2str(suj_list(nsuj))];
    
    fname_in             	= ['~/Dropbox/project_me/data/nback/singletrial/sub' num2str(suj_list(nsuj)) '.singletrial.trialinfo.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    list_behav              = {'fast' 'slow'};
    
    rt_vector               = [trialinfo(:,4) trialinfo(:,5) trialinfo(:,6)];
    rt_vector               = rt_vector(rem(rt_vector(:,1),2) ~= 0,:); % exclude incorrect
    rt_vector               = rt_vector(rt_vector(:,2) ~= 0,:); % exclude no rt
    
    % normalize RTs
    rt_vector(:,2)          = rt_vector(:,2)/1000;
    rt_vector(:,2)          = rt_vector(:,2) ./ mean(rt_vector(:,2));
    
    find_trials{1}          = rt_vector(rt_vector(:,2) < mean(rt_vector(:,2)),3);
    find_trials{2}          = rt_vector(rt_vector(:,2) > mean(rt_vector(:,2)),3);
    
    auc_carrier             = [];
    
    list_stim               = [1 2 3 4 5 7 8 9];
    
    for nstim = 1:length(list_stim)
        
        % load decoding output
        dir_files          	= '~/Dropbox/project_me/data/nback/';
        fname            	= [dir_files 'auc/' sujname '.decoding.stim' num2str(list_stim(nstim)) '.nodemean.leaveone.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        % transpose matrices
        y_array           	= y_array';
        yproba_array       	= yproba_array';
        
        e_array          	= e_array';
        auc_array           = auc_array';
        
        for nbehav = 1:length(list_behav)
            
            AUC_bin_test    = [];
            idx_trials     	= find_trials{nbehav};
            
            for ntime = 1:size(y_array,2)
                
                yproba_array_test     	= yproba_array(idx_trials,ntime);
                
                if min(unique(y_array(:,ntime))) == 1
                    yarray_test        	= y_array(idx_trials,ntime) - 1;
                else
                    yarray_test       	= y_array(idx_trials,ntime);
                end
                
                try
                    [~,~,~,AUC_bin_test(ntime)]	= perfcurve(yarray_test,yproba_array_test,1);
                catch
                    AUC_bin_test(ntime) = NaN;
                end
                
                clear yarray_test yproba_array_test
                
            end
            
            auc_carrier(nstim,nbehav,:)     = AUC_bin_test;clear AUC_bin_test;
      
            
        end
    end
    
    for nbehav = [1 2]
        
        avg              	= [];
        avg.label        	= {'auc'};
        avg.time          	= time_axis;
        avg.avg            	= nanmean(squeeze(auc_carrier(:,nbehav,:)),1);
        avg.dimord        	= 'chan_time';
        
        alldata{nsuj,nbehav}    = avg; clear avg; 
        
    end

    
end

%%

keep alldata list_*

nbsuj                    	= size(alldata,1);
[design,neighbours]       	= h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                         = [];
cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
cfg.uvar                    = 1;cfg.ivar = 2;
cfg.tail                    = 0;cfg.clustertail  = 0;
cfg.neighbours              = neighbours;
cfg.channel                 = 1;

cfg.latency                 = [0 1];
cfg.clusteralpha            = 0.05; % !!
cfg.minnbchan               = 0; % !!
cfg.alpha                   = 0.025;

cfg.numrandomization        = 1000;
cfg.design                  = design;

for ntest = 1
    
    stat{ntest}            	= ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});
    [min_p(ntest),p_val{ntest}]	= h_pValSort(stat{ntest});
    
end

%%

clc;

nrow                       	= 1;
ncol                      	= 1;
i                          	= 0;
plimit                   	= 0.05;

for ntest = 1:length(stat)
    
    nwstat                	= stat{ntest};
    nwstat.mask             = nwstat.prob < plimit;
    
    cfg                     = [];
    cfg.channel             = 1;
    cfg.time_limit          = [-0.1 1];
    
    cfg.color           	= {'-b' '-r'};
    
    cfg.z_limit             = [0 0.3];
    
    cfg.linewidth           = 5;
    cfg.lineshape           = '-r';
    
    i = i+1;
    subplot(nrow,ncol,i);
    h_plotSingleERFstat_selectChannel_nobox(cfg,nwstat,alldata);
    
    ylabel(['p = ' num2str(round(min_p(ntest),3))])
    
    vline(0,'-k');
    hline(0.06,'-k');
    
    legend({list_behav{1} '' list_behav{2} ''})
    
    set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
    
    
end