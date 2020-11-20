clear ; close all;

suj_list    = [1:33 35:36 38:44 46:51];

for ntest = 1:length(suj_list)
    
    suj_name                                    = ['sub' num2str(suj_list(ntest))];
    
    list_lock                                   = {'all'};
    list_cond                                   = {'0back','1back'};
    
    for nback = 1:length(list_cond)
        for nlock = 1:length(list_lock)
            
            i                                   = i +1;
            ext_lock                            = list_lock{nlock};
            fname                               = ['P:/3015079.01/nback/sens_level_auc/cond/' suj_name '.sess' num2str(nback) ...
                '.decoding.' list_cond{nback} '.lockedon.' ext_lock '.dwn70.bsl.excl.auc.timegen.mat'];
            fprintf('Loading %s\n',fname);
            load(fname);
            pow(nlock,:,:)                      = scores; clear scores;
            
        end
        
        freq                                  	= [];
        freq.dimord                          	= 'chan_freq_time';
        freq.label                            	= list_lock;
        freq.freq                              	= time_axis;
        freq.time                             	= time_axis;
        freq.powspctrm                         	= pow;
        alldata{ntest,nback}                    = freq; clear pow ;
    end
    
    alldata{ntest,3}                            = alldata{ntest,1};
    alldata{ntest,3}.powspctrm(:)            	= 0.5;
    
end

keep alldata ns pow time_axis ext_lock

cfg                                         = [];
cfg.statistic                               = 'ft_statfun_depsamplesT';
cfg.method                                  = 'montecarlo';
cfg.correctm                                = 'cluster';
cfg.clusteralpha                            = 0.05;

% cfg.latency                                 = [0 2];
% cfg.frequency                               = cfg.latency;

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

list_test                                   = [1 3; 2 3; 1 2];

for nt = 1:3
    stat{nt}                                = ft_freqstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
end

for ntest = 1:length(stat)
    [min_p(ntest),p_val{ntest}]                	= h_pValSort(stat{ntest});
    if isfield(stat{ntest},'negdistribution')
        stat{ntest}                            = rmfield(stat{ntest},'negdistribution');
    end
    if isfield(stat{ntest},'posdistribution')
        stat{ntest}                         	= rmfield(stat{ntest},'posdistribution');
    end
end

i                                         	= 0;
nrow                                    	= 2;
ncol                                     	= 2;

plimit                                      = 0.1;

for nchan = 1:length(stat{1}.label)
    for ntest = 3%1:length(stat)
        
        stat{ntest}.mask                    = stat{ntest}.prob < plimit;
        
        tmp                               	= stat{ntest}.mask(nchan,:,:) .* stat{ntest}.stat(nchan,:,:);
        ix                                	= unique(tmp);
        ix                                	= ix(ix~=0);
        
        if ~isempty(ix)
            
            i                           	= i + 1;
            
            cfg                          	= [];
            cfg.colormap                	= brewermap(256, '*RdBu');
            cfg.channel                 	= nchan;
            cfg.parameter               	= 'stat';
            cfg.maskparameter             	= 'mask';
            cfg.maskstyle               	= 'outline';
            cfg.zlim                      	= [-5 5];
            cfg.colorbar                  	='yes';
            
            nme                           	= stat{ntest}.label{nchan};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,stat{ntest});
            
            list_condition                	= {'0and2 vs chance','1and2 vs chance','0and2 vs 1and2'};
            
            title('');
            
            c = colorbar;
            c.Ticks = cfg.zlim;
            
            ylabel({list_condition{ntest},'Training Time'});
            xlabel('Testing Time');
            
            vline(0,'-k');
            hline(0,'-k');
            
            set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');
            
            
        end
    end
end