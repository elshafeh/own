clear;close all;

suj_list                        	= [1:33 35:36 38:44 46:51];
alldata                             = [];

for nsuj = 1:length(suj_list)
    
    file_list                       = dir(['J:/temp/nback/data/stim_ag_all/sub' num2str(suj_list(nsuj)) ... 
        '.sess*.stim*.against.all.bsl.dwn70.auc.mat']);
    tmp                             = [];
    
    for nf = 1:length(file_list)
        fname                       = [file_list(nf).folder filesep file_list(nf).name];
        fprintf('loading %s\n',fname);
        load(fname);
        tmp(nf,:)                   = scores; clear scores;
    end
    
    avg                             = [];
    avg.label                       = {'stim identity'};
    avg.avg                         = squeeze(nanmean(tmp,1)); clear pow;
    avg.dimord                      = 'chan_time';
    avg.time                        = time_axis;
    
    alldata{nsuj,1}                 = avg;
    alldata{nsuj,2}                 = alldata{nsuj,1};
    alldata{nsuj,2}.avg(:)       	= 0.5;
    
end

keep alldata

cfg                                 = [];
cfg.statistic                       = 'ft_statfun_depsamplesT';
cfg.method                          = 'montecarlo';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05;
cfg.latency                         = [-0.1 2];
cfg.clusterstatistic                = 'maxsum';
cfg.minnbchan                       = 0;
cfg.tail                            = 0;
cfg.clustertail                     = 0;
cfg.alpha                           = 0.025;
cfg.numrandomization                = 2000;
cfg.uvar                            = 1;
cfg.ivar                            = 2;

nbsuj                               = size(alldata,1);
[design,neighbours]                 = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg.design                          = design;
cfg.neighbours                      = neighbours;

list_test                           = [1 2];

for nt = 1:size(list_test,1)
    stat{nt}                        = ft_timelockstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
end

for nsuj = 1:length(stat)
    [min_p(nsuj),p_val{nsuj}]        	= h_pValSort(stat{nsuj});
    stat{nsuj}                        = rmfield(stat{nsuj},'negdistribution');
    stat{nsuj}                        = rmfield(stat{nsuj},'posdistribution');
    stat{nsuj}                        = rmfield(stat{nsuj},'cfg');
end

i                                  	= 0;
nrow                                = 2;
ncol                                = 2;
z_limit                             = [0.48 0.8];
plimit                              = 0.01;

n_plot                              = [1 3 5];

for nsuj = 1:length(stat)
    
    stat{nsuj}.mask                   = stat{nsuj}.prob < plimit;
    
    for nchan = 1:length(stat{nsuj}.label)
        
        tmp                         = stat{nsuj}.mask(nchan,:,:) .* stat{nsuj}.prob(nchan,:,:);
        ix                          = unique(tmp);
        ix                          = ix(ix~=0);
        
        if ~isempty(ix)
            
            i = i + 1;
            subplot(nrow,ncol,i)
            
            cfg                     = [];
            cfg.channel             = stat{nsuj}.label{nchan};
            cfg.p_threshold        	= plimit;
            
            
            cfg.z_limit             = z_limit;
            cfg.time_limit          = stat{nsuj}.time([1 end]);
            
            ix1                     = list_test(nsuj,1);
            ix2                     = list_test(nsuj,2);
            
            cfg.color            	= 'ky';
            
            h_plotSingleERFstat_selectChannel(cfg,stat{nsuj},squeeze(alldata(:,[ix1 ix2])));
            
            legend({stat{nsuj}.label{nchan},'chance'});

            ylim([z_limit]);
            yticks([z_limit]);
            xticks([0:0.2:1]);
            xlim([-0.1 1]);
            hline(0.5,'-k');vline(0,'-k');
            ax = gca();ax.TickDir  = 'out';box off;
            
            title(stat{nsuj}.label{nchan});
            
        end
    end
end


for nt = 1:length(stat)
    [min_p(nt),p_val{nt}]        	= h_pValSort(stat{nt});
end