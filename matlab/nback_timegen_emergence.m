clear ; close all;

suj_list    = [1:33 35:36 38:44 46:51];

for ns = 1:length(suj_list)
    
    suj_name                                    = ['sub' num2str(suj_list(ns))];
    
    for nback = [0 1 2]
        for nstim = 1:10
            i                                   = 0;
            for nsess = 1:2
                
                fname                           = ['K:/nback/timegen/' suj_name '.sess' num2str(nsess) '.stim' num2str(nstim) '.' num2str(nback) 'back.dwn60.auc.timegen.mat'];
                
                if exist(fname)
                    i                               = i +1;
                    fprintf('Loading %s\n',fname);
                    load(fname);
                    
                    %                     scores                      = h_timegen_cut(scores);
                    tmp(i,:,:)                  = scores; clear scores;
                end
                
            end
            
            pow(nstim,:,:)                      = squeeze(mean(tmp,1)); clear tmp;
            
        end
        
        freq                                  	= [];
        freq.dimord                          	= 'chan_freq_time';
        freq.label                            	= {'timegen'}; %{'stim1','stim2','stim3','stim4','stim5','stim6','stim7','stim8','stim9','stim10'};
        freq.freq                              	= time_axis;
        freq.time                             	= time_axis;
        freq.powspctrm                         	= mean(pow,1) ;
        
        alldata{ns,nback+1}                  	= freq; clear pow ;
        
    end
    
    alldata{ns,4}                               = alldata{ns,1};
    alldata{ns,4}.powspctrm(:)                 	= 0.5;
    
end

keep alldata ns pow time_axis

cfg                                         = [];
cfg.statistic                               = 'ft_statfun_depsamplesT';
cfg.method                                  = 'montecarlo';
cfg.correctm                                = 'cluster';
cfg.clusteralpha                            = 0.05;

cfg.latency                                 = [0 2];
cfg.frequency                               = cfg.latency;

cfg.clusterstatistic                        = 'maxsum';
cfg.minnbchan                               = 0;
cfg.tail                                    = 0;
cfg.clustertail                             = 0;
cfg.alpha                                   = 0.025;
cfg.numrandomization                        = 1000;
cfg.uvar                                    = 1;
cfg.ivar                                    = 2;

nbsuj                                       = size(alldata,1);
[design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg.design                                  = design;
cfg.neighbours                              = neighbours;

for nt = 1:3
    stat{nt}                                = ft_freqstatistics(cfg, alldata{:,nt}, alldata{:,4});
end

for ns = 1:length(stat)
    [min_p(ns),p_val{ns}]                	= h_pValSort(stat{ns});
    if isfield(stat{ns},'negdistribution')
    stat{ns}                              	= rmfield(stat{ns},'negdistribution');
    end
    if isfield(stat{ns},'posdistribution')
    stat{ns}                              	= rmfield(stat{ns},'posdistribution');
    end
end

i                                           = 0;
nrow                                        = 2;
ncol                                        = 2;

plimit                                      = 0.05/3;

for ns = 1:length(stat)
    
    
    stat{ns}.mask                           	= stat{ns}.prob < plimit;
    
    for nc = 1:length(stat{ns}.label)
        
        tmp                                     = stat{ns}.mask(nc,:,:) .* stat{ns}.stat(nc,:,:);
        ix                                      = unique(tmp);
        ix                                      = ix(ix~=0);
        
        if ~isempty(ix)
            
            i                                   = i + 1;
            
            cfg                                 = [];
            cfg.colormap                        = brewermap(256, '*RdBu');
            cfg.channel                         = nc;
            cfg.parameter                       = 'stat';
            cfg.maskparameter                   = 'mask';
            cfg.maskstyle                       = 'outline';%'opacity';%
            cfg.zlim                            = [-5 5];%[min(min_p) plimit];
            cfg.colorbar                        ='yes';
            
            nme                                 = stat{ns}.label{nc};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,stat{ns});
            
            list_condition                   	= {'0Back','1Back','2Back'};
            
            title(list_condition{ns});
            
            c = colorbar;
            c.Ticks = cfg.zlim;
            
            ylabel('Time');
            xlabel('Time');
            
            yticks([0 0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8 2]);
            xticks([0 0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8 2]);

            set(gca,'FontSize',16,'FontName', 'Calibri');
            
            
        end
    end
end