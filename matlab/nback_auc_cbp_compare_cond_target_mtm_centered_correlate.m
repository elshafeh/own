clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                            = [1:33 35:36 38:44 46:51];
allpeaks                            = [];

for nsuj = 1:length(suj_list)
    load(['J:/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                = apeak; clear apeak;
    allpeaks(nsuj,2)                = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)  	= nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
    
    list_cond                       = {'1back','2Back'};
    list_color                      = 'gb';
        
    for nback = 1:length(list_cond)
        
        list_lock                   = {'istarget'}; % isfirst istarget
        list_name                   = {'beta peak'}; % alpha beta
        
        pow                         = [];
        
        if strcmp(list_name{1},'alpha peak')
            list_peak               = allpeaks(nsuj,1);
            list_width           	= 1;
        elseif strcmp(list_name{1},'beta peak')
            list_peak             	= allpeaks(nsuj,2);
            list_width             	= 2;
        end
        
        xi                          = round(list_peak(1) - list_width(1));
        yi                          = round(list_peak(1) + list_width(1));
        list_freq                   = xi:yi; clear xi yi;
        
        for nlock = 1:length(list_lock)
            for nfreq = 1:length(list_freq)
                
                file_list         	= dir(['J:/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.sess*.' ...
                    list_cond{nback} '.' num2str(list_freq(nfreq)) 'Hz.' list_lock{nlock} '.bsl.dwn70.excl.auc.mat']);
                
                tmp              	= [];
                
                if isempty(file_list)
                    error('file not found!');
                end
                
                for nf = 1:length(file_list)
                    fname         	= [file_list(nf).folder filesep file_list(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    tmp           	= [tmp;scores]; clear scores;
                end
                
                pow(nlock,nfreq,:) 	= nanmean(tmp,1); clear tmp;
                
            end
        end
        
        list_final                  = {[list_name{1} ' ' list_lock{1}]};
        
        avg                         = [];
        avg.label                   = list_final;
        avg.avg                     = squeeze(nanmean(pow,2))'; clear pow;
        avg.dimord                  = 'chan_time';
        avg.time                    = -1.5:0.02:2;
        
        alldata{nsuj,nback}         = avg; clear avg;
        
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
    
    list_behav                      = {'rt','correct'}; %'match hit','nomatch hit',

    fprintf('\n');
    
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

nb_suj                 	= size(alldata,1);
[design,neighbours]  	= h_create_design_neighbours(nb_suj,alldata{1,1},'gfp','t');
cfg.neighbours       	= neighbours;

list_corr               = {'Spearman'};

for nback = 1:size(alldata,2)
    for nbehav = 1:size(allbehav,3)
        for ncorr = 1:length(list_corr)
            
            cfg.type                                        = list_corr{ncorr};
            cfg.design(1,1:nb_suj)                          = [allbehav{:,nback,nbehav}];
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
z_limit                                     = [0.45 0.65];
plimit                                      = 0.12;

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
                
                title([list_name{1} ' ' list_cond{nback} ' w ' upper(list_behav{nbehav}) ' p = ' num2str(round(min(ix),3)) ...
                    ' ' list_corr{ncorr}(1:2) ' r = ' num2str(round(min(iy),1))]);
                set(gca,'FontSize',10,'FontName', 'Calibri');
                vline([0 0.6],'--k');
                hline(0.5,'--k');
                xticks([0:0.4:2]);
                ylabel(list_lock{:});
                
                
                
            end
        end
    end
end

keep alldata allbehav list* stat min_p p_val