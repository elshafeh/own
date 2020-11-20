clear;close all;

suj_list                            = [1:33 35:36 38:44 46:51];
alldata                         	= [];

for nsuj = 1:length(suj_list)
    
    sub_carr                     	= [];
    i                            	= 0;
    list_cond                       = {'0back','1back','2back'};
    
    for ncond = 1:length(list_cond)
        
        fname_list              	= dir(['J:/temp/nback/data/stim_category/sub' num2str(suj_list(nsuj)) '.sess*.' ...
                list_cond{ncond} '.istarget.bsl.dwn70.excl.auc.mat']);
        
        for nfile = 1:length(fname_list)
            i                    	= i+1;
            fprintf('loading %50s\n',[fname_list(nfile).folder filesep fname_list(nfile).name]);
            load([fname_list(nfile).folder filesep fname_list(nfile).name]);
            sub_carr(i,:)       	= scores; clear scores
            
        end
        
    end
    
    avg                             = [];
    avg.label                       = {'stim category'};
    avg.avg                         = squeeze(mean(sub_carr,1)); clear sub_carr;
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
plimit                              = 0.05;

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
            xticks([0:0.4:2]);
            xlim([-0.1 2]);
            hline(0.5,'-k');vline(0,'-k');
            ax = gca();ax.TickDir  = 'out';box off;
            
            title(stat{nsuj}.label{nchan});
            
        end
    end
end