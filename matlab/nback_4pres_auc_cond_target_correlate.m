clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                          	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_nback                      = [0 1];
    list_color                      = 'rgb';
    list_cond                       = {'1back','2back'};
    
    for nback = 1:length(list_cond)
        
        list_lock                   = {'istarget'};
        avg_data                    = [];
        i                           = 0;
        
        for nlock = 1:length(list_lock)
            
            flist                   = dir(['J:/nback/stim_category/sub' num2str(suj_list(nsuj)) '.sess*.' ...
                list_cond{nback} '.' list_lock{nlock} '.bsl.dwn70.excl.auc.mat']);
            tmp                     = [];
            
            for nf = 1:length(flist)
                fname               = [flist(nf).folder filesep flist(nf).name];
                fprintf('loading %s\n',fname);
                load(fname);
                tmp                 = [tmp;scores]; clear scores;
            end
            
            avg_data(nlock,:)       = mean(tmp,1); clear tmp;
            
        end
        
        avg                       	= [];
        avg.time               		= time_axis;
        avg.label                   = list_lock;
        avg.avg                   	= avg_data; clear avg_data;
        avg.dimord              	= 'chan_time';
        
        alldata{nsuj,nback}      	= avg; clear avg pow;
        
    end
    
    behav_struct = h_nbk_exctract_behav(suj_list(nsuj));
    % - % - make sure you got these right
    if size(alldata,2) < 3
        behav_struct = behav_struct(:,2:3);
    end
    
    for nback = 1:length(behav_struct)
        allbehav{nsuj,nback,1}      = [behav_struct(nback).rt];
        allbehav{nsuj,nback,2}      = [behav_struct(nback).correct];
    end
    
    list_behav                      = {'rt','correct'};
    
end

keep alldata allbehav list*

%%

cfg                     = [];
cfg.method              = 'montecarlo';
cfg.latency             = [-0.1 1];
cfg.statistic           = 'ft_statfun_correlationT';
cfg.clusterstatistics   = 'maxsum';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;
cfg.ivar                = 1;

list_corr               = {'Spearman'};

for nback = 1:size(alldata,2)
    for nbehav = 1:size(allbehav,3)
        for ncorr = 1:length(list_corr)
            
            nb_suj                                          = size(alldata,1);
            cfg.type                                        = list_corr{ncorr};
            cfg.design(1,1:nb_suj)                          = [allbehav{:,nback,nbehav}];
            
            nbsuj                                           = size(alldata,1);
            [~,neighbours]                                  = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
            cfg.neighbours                                  = neighbours;
            
            stat{nback,nbehav,ncorr}                        = ft_timelockstatistics(cfg, alldata{:,nback});
            
        end
    end
end

keep alldata allbehav list* stat

for nback = 1:size(stat,1)
    for nbehav = 1:size(stat,2)
        for ncorr = 1:size(stat,3)
            [min_p(nback,nbehav,ncorr),p_val{nback,nbehav,ncorr}]                	= h_pValSort(stat{nback,nbehav,ncorr});
        end
    end
end

keep alldata allbehav list* stat min_p p_val

%%

i                                           = 0;
nrow                                        = 2;
ncol                                        = 2;
z_limit                                     = [0.47 0.8];
plimit                                      = 0.11;

for nback = 1:size(stat,1)
    for nbehav = 1:size(stat,2)
        for ncorr = 1:size(stat,3)
            
            statplot                        = stat{nback,nbehav,ncorr};
            statplot.mask               	= statplot.prob < plimit;
            
            for nchan = 1:length(statplot.label)
                
                tmp                     	= statplot.mask(nchan,:,:) .* statplot.rho(nchan,:,:);
                iy                        	= unique(tmp);
                iy                       	= iy(iy~=0);
                
                tmp                         = statplot.mask(nchan,:,:) .* statplot.prob(nchan,:,:);
                ix                          = unique(tmp);
                ix                          = ix(ix~=0);
                
                i                           = i + 1;
                subplot(nrow,ncol,i)
                
                cfg                         = [];
                cfg.channel                 = statplot.label{nchan};
                cfg.p_threshold             = plimit;
                cfg.z_limit                 = z_limit;
                cfg.time_limit              = statplot.time([1 end]);
                list_color                  = 'gb';
                cfg.color                   = list_color(nback);
                h_plotSingleERFstat_selectChannel(cfg,statplot,squeeze(alldata(:,nback)));
                
                nme_chan                    = strsplit(statplot.label{nchan},'.');
                
                
                
                title([list_cond{nback} ' w ' upper(list_behav{nbehav}) ' p = ' num2str(round(min(ix),3)) ...
                    ' ' list_corr{ncorr}(1:2) ' r = ' num2str(round(min(iy),1))]);
                set(gca,'FontSize',10,'FontName', 'Calibri');
                vline([0 0.6],'--k');
                hline(0.5,'--k');
                xticks([0:0.4:2]);
                
            end
        end
    end
end

keep alldata allbehav list* stat min_p p_val