clear; clc;

suj_list                        = [1:33 35:36 38:44 46:51];
ext_erf                         = 'allstim';
ext_decode                      = 'stim';


for nsuj = 1:length(suj_list)
    
    sujname                  	= ['sub' num2str(suj_list(nsuj))];
    
    for nstim = [1 2 3 4 5 6 7 8 9]
        
        % load decoding output
        
        dir_files           	= '~/Dropbox/project_me/data/nback/auc/';
        fname                	= [dir_files sujname '.decoding.stim' num2str(nstim) '.nodemean.leaveone.mat'];
        fprintf('loading %s\n',fname);
        load(fname,'y_array','yproba_array','time_axis','e_array');
        
        % transpose matrices
        y_array               	= y_array';
        yproba_array           	= yproba_array';
        e_array                	= e_array';
        measure              	= 'yproba'; % auc yproba
        
        idx_trials          	= 1:size(yproba_array,1);
        
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
        
        alldata{nsuj,nstim,1}   = avg; clear avg;
        
        alldata{nsuj,nstim,2}   = alldata{nsuj,nstim,1};
        alldata{nsuj,nstim,2}.avg(:)      = 0.065;
        
    end
    
end

keep alldata

%%

nbsuj                               = size(alldata,1);
[design,neighbours]                 = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

for nstim = 1:size(alldata,2)
    
    cfg                          	= [];
    cfg.latency                  	= [-0.1 1];
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
    allstat{nstim}                 	= ft_timelockstatistics(cfg,alldata{:,nstim,1},alldata{:,nstim,2});
    [min_p(nstim),~]             	= h_pValSort(allstat{nstim});clc;
    
end

%%

clc;

for nstim = 1:length(allstat)
    
    stat                            = allstat{nstim};
    stat.mask                       = stat.prob < 0.05;
    
    cfg                             = [];
    cfg.channel                     = 1;
    cfg.time_limit              	= stat.time([1 end]);
    cfg.color                       = [0 0 0; 0.5 0.5 0.5];
    cfg.z_limit                     = [0 0.4];
    cfg.linewidth                   = 10;
    cfg.lineshape                   = '-r';
    
    subplot(3,3,nstim)
    
    h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata(:,nstim,:));
    
    hline(0.065,'-k');
    vline(0,'-k');
    
    title(['stim ' num2str(nstim)]);
    
    set(gca,'FontSize',20,'FontName', 'Calibri','FontWeight','normal');
        
end