clear; clc;

suj_list                        = [1:33 35:36 38:44 46:51];
ext_erf                         = 'allstim';
ext_decode                      = 'stim';


for nsuj = 1:length(suj_list)
    
    sujname                  	= ['sub' num2str(suj_list(nsuj))];
    
    dir_data                    = '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in                    = [ dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.trialinfo.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    for nstim = [1 2 3 4 5 6 7 8 9]
        
        % load decoding output
        dir_data                = '~/Dropbox/project_me/data/nback/auc/';
        fname                	= [dir_data sujname '.decoding.stim' num2str(nstim) '.nodemean.leaveone.mat'];
        fprintf('loading %s\n',fname);
        load(fname,'y_array','yproba_array','time_axis','e_array');
        
        % transpose matrices
        y_array               	= y_array';
        yproba_array           	= yproba_array';
        e_array                	= e_array';
        measure              	= 'yproba'; % auc yproba
        
        idx_trials          	= find(trialinfo(:,3) ~= 10); % 1:size(yproba_array,1);
        
        AUC_bin_test         	= [];
        disp('computing AUC');
        
        for ntime = 1:size(y_array,2)
            
            if strcmp(measure,'yproba')
                
                yproba_array_test     	= yproba_array(idx_trials,ntime);
                
                if min(unique(y_array(:,ntime))) == 1
                    yarray_test        	= y_array(idx_trials,ntime) - 1;
                else
                    yarray_test       	= y_array(idx_trials,ntime);
                end
                
                [~,~,~,AUC_bin_test(ntime)]	= perfcurve(yarray_test,yproba_array_test,1);
                
            elseif strcmp(measure,'auc')
                AUC_bin_test(ntime)     = mean(e_array(idx_trials,ntime));
            end
        end
        
        avg                   	= [];
        avg.avg               	= AUC_bin_test;
        avg.time              	= time_axis;
        avg.label             	= {['decoding ' ext_decode]};
        avg.dimord            	= 'chan_time';
        
        tmp{nstim}           	= avg; clear avg;
        
    end
    
    alldata{nsuj,1}          	= ft_timelockgrandaverage([],tmp{:}); clear tmp;
    
    alldata{nsuj,2}          	= alldata{nsuj,1};
    
    chance_level                = round(0.5/9,2); %0.5/9; % 
    alldata{nsuj,2}.avg(:)      = chance_level;
    
    
end

keep alldata chance_level

%%

nbsuj                          	= size(alldata,1);
[design,neighbours]           	= h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                          	= [];
cfg.latency                  	= [-0.1 2];
cfg.statistic                 	= 'ft_statfun_depsamplesT';
cfg.method                    	= 'montecarlo';
cfg.correctm                  	= 'cluster';
cfg.clusteralpha              	= 0.05;
cfg.clusterstatistic         	= 'maxsum';
cfg.minnbchan                	= 0;

cfg.tail                    	= 0;
cfg.clustertail                 = 0;
cfg.alpha                   	= 0.025;
cfg.numrandomization          	= 1000;
cfg.uvar                      	= 1;
cfg.ivar                      	= 2;
cfg.neighbours                	= neighbours;
cfg.design                    	= design;
stat                         	= ft_timelockstatistics(cfg,alldata{:,1},alldata{:,2});
[min_p,p_val]                   = h_pValSort(stat);clc;

%%

clc;close all;

cfg                             = [];
cfg.channel                     = 1;
cfg.time_limit              	= [-0.1 1]; % stat.time([1 end]);
cfg.color                       = [0 0 0; 0.5 0.5 0.5];
cfg.z_limit                     = [0.04 0.2];
cfg.linewidth                   = 10;
cfg.lineshape                   = '-r';
i = i + 1;
subplot(2,2,1)
h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);

hline(chance_level,'-k');
vline(0,'-k');
set(gca,'FontSize',20,'FontName', 'Calibri','FontWeight','normal');