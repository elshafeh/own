clear;clc;

suj_list                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname                 = ['sub' num2str(suj_list(nsuj))];
    
    dir_files            	= '~/Dropbox/project_me/data/nback/';
    ext_decode          	= 'stim';
    
    %     fname                   = [dir_files 'trialinfo/' sujname '.flowinfo.mat'];
    
    fname                   = [dir_files 'trialinfo/' sujname '.trialinfo.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    cfg                     = [];
    cfg.stim_focus        	= 'all';
    cfg.outliers            = 'remove';
    cfg.incorrect        	= 'remove';
    cfg.zeros               = 'remove';
    cfg.equalize            = 'no';
    [index_trials]          = func_load_split(cfg,trialinfo);
    
    list_stim               = [1 2 3 4 5 6 7 8 9];
    
    for nstim = 1:length(list_stim)
        
        % load decoding output
        dir_files          	= '~/Dropbox/project_me/data/nback/';
        fname            	= [dir_files 'auc/' sujname '.decoding.stim' num2str(list_stim(nstim)) '.nodemean.leaveone.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        % transpose matrices
        y_array            	= y_array';
        yproba_array      	= yproba_array';
        e_array          	= e_array';
        yhat_array          = yhat_array';
        
        measure           	= 'yproba'; % auc yproba
        
        for nbin = [1 2]
            
            idx_trials   	= index_trials{nbin};
            AUC_bin_test   	= [];
            
            disp('computing AUC');
            
            for ntime = 1:size(y_array,2)
                
                if strcmp(measure,'yproba')
                    
                    yproba_array_test     	= yproba_array(idx_trials,ntime);
                    
                    if min(unique(y_array(:,ntime))) == 1
                        yarray_test        	= y_array(idx_trials,ntime) - 1;
                    else
                        yarray_test       	= y_array(idx_trials,ntime);
                    end
                    
                    try 
                        [~,~,~,AUC_bin_test(ntime)]	= perfcurve(yarray_test,yproba_array_test,1);
                    catch
                        AUC_bin_test(ntime)         = NaN;
                    end
                        
                elseif strcmp(measure,'auc')
                    AUC_bin_test(ntime)     = mean(e_array(idx_trials,ntime));
                elseif strcmp(measure,'confidence')
                    AUC_bin_test(ntime)     = mean(yhat_array(idx_trials,ntime));
                end
            end
            
            avg                             = [];
            avg.avg                         = AUC_bin_test;
            avg.time                        = time_axis;
            avg.label                       = {['decoding ' ext_decode]};
            avg.dimord                      = 'chan_time';
            
            alldata{nsuj,nbin,nstim}        = avg; clear avg;
            
        end
    end
    
end

%%

keep alldata list_* ext_decode

for nsuj = 1:size(alldata,1)
    for nbin = 1:size(alldata,2)
        
        tmp         = [];
        i           = 0;
        
        for nstim = 1:size(alldata,3)
            if ~isempty(alldata{nsuj,nbin,nstim})
                tmp     = [tmp; alldata{nsuj,nbin,nstim}.avg];
                i       = nstim;
            end
        end
                
        newdata{nsuj,nbin}          = alldata{nsuj,nbin,1};
        newdata{nsuj,nbin}.avg      = nanmean(tmp,1); clear tmp;
        
        
        clear tmp;
        
    end
end

alldata                         = newdata;

%%

keep alldata list_* ext_decode

nsuj                            = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nsuj,alldata{1},'gfp','t'); clc;


cfg                             = [];
cfg.clusterstatistic            = 'maxsum';cfg.method = 'montecarlo';
cfg.correctm                    = 'cluster';cfg.statistic = 'depsamplesT';
cfg.uvar                        = 1;cfg.ivar = 2;
cfg.tail                        = 0;cfg.clustertail  = 0;
cfg.neighbours                  = neighbours;
cfg.channel                     = 1;

cfg.latency                     = [-0.1 1];
cfg.clusteralpha                = 0.05; % !!
cfg.minnbchan                   = 0; % !!
cfg.alpha                       = 0.025;

cfg.numrandomization            = 1000;
cfg.design                      = design;

allstat{1}                      = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});

keep alldata list_* allstat ext_decode


%%

clc; close all;

nrow                         	= 1;
ncol                          	= 1;
i                             	= 0;
plimit                       	= 0.3;

for nband = 1:size(allstat,1)
    
    stat                        = allstat{nband,1};
    stat.mask                   = stat.prob < plimit;
    
    for nchan = 1:length(stat.label)
        
        vct                     = stat.prob(nchan,:);
        min_p                   = min(vct);
        
        cfg                     = [];
        cfg.channel             = nchan;
        cfg.time_limit          = stat.time([1 end]);
        
        cfg.color            	= [83 51 137; 197 94 32]; % [58 161 122; 47 123 182];
        cfg.color             	= cfg.color ./ 256;
        
        cfg.z_limit             = [0 0.2];%[0.1 0.5]; %
       
        cfg.linewidth           = 2;
        cfg.lineshape           = '-x';
        
        i = i+1;
        subplot(nrow,ncol,i);
        h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
        
        ylabel({stat.label{nchan}, ['p = ' num2str(round(min_p,3))]})
        
        vline(0,'--k');
        
        if strcmp(ext_decode,'condition')
            hline(0.35,'--k');
        elseif strcmp(ext_decode,'target')
            hline(0.35,'--k');
        elseif strcmp(ext_decode,'first')
            hline(0.17,'--k');
        elseif strcmp(ext_decode,'stim')
            hline(0.07,'--k');
        end
        
        legend({'1back' '' '2back' ''});
        
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
        
    end
end