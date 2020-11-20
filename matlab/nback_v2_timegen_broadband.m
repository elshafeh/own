clear ; close all;

suj_list    = [1:33 35:36 38:44 46:51];

for ntest = 1:length(suj_list)
    
    suj_name                                    = ['sub' num2str(suj_list(ntest))];
    list_lock                                   = {'target'};
    
    for nback = [0 1 2]
        for nlock = 1:length(list_lock)
            
            i                                   = 0;
            
            for nsess = 1:2
                
                ext_lock                        = list_lock{nlock};
                fname                           = ['J:/nback/timegen_per_target/' suj_name '.sess' num2str(nsess) ...
                    '.' num2str(nback) 'back.dwn70.excl.' ext_lock '.auc.timegen.mat'];
                
                if exist(fname)
                    i                        	= i +1;
                    fprintf('Loading %s\n',fname);
                    load(fname);
                    tmp(i,:,:)                  = scores; clear scores;
                end
            end
            
            pow(nlock,:,:)                      = squeeze(mean(tmp,1)); clear tmp;
        end
        
        freq                                  	= [];
        freq.dimord                          	= 'chan_freq_time';
        freq.label                            	= list_lock;
        freq.freq                              	= time_axis;
        freq.time                             	= time_axis;
        freq.powspctrm                         	= pow;
        
        alldata{ntest,nback+1}                  = freq; clear pow ;
        
    end
end

keep alldata ns pow time_axis ext_lock

list_cond                                       = {'0back','1back','2back'};

list_test                                       = [2 3];
i                                               = 0;

for ntest = 1:size(list_test,1)
    
    cfg                                         = [];
    cfg.statistic                               = 'ft_statfun_depsamplesT';
    cfg.method                                  = 'montecarlo';
    cfg.correctm                                = 'cluster';
    cfg.clusteralpha                            = 0.05;
    
    cfg.latency                                 = [-0.1 1];
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
    
    for nchan = 1:length(alldata{1,1}.label)
        
        cfg.channel                             = nchan;
        i                                       = i + 1;
        stat{i}                                 = ft_freqstatistics(cfg, alldata{:,list_test(ntest,1)}, alldata{:,list_test(ntest,2)});
        
        [min_p(i),p_val{i}]                     = h_pValSort(stat{i});
        
        if isfield(stat{i},'negdistribution')
            stat{i}                             = rmfield(stat{i},'negdistribution');
        end
        if isfield(stat{i},'posdistribution')
            stat{i}                             = rmfield(stat{i},'posdistribution');
        end
        
        list_test_name{i}                       = [list_cond{list_test(ntest,1)} ' v ' list_cond{list_test(ntest,2)} ' ' stat{i}.label{1}];
        
    end
end

keep alldata list_* stat min_p p_val run_test ext_fix

save('../data/stat/nbac_timegen_broadband_target_stim.mat','list_test','list_cond','list_test_name');

%%

i                                         	= 0;
nrow                                    	= 2;
ncol                                     	= 2;

plimit                                      = 0.05/3;

for ntest = [1]
    for nchan = 1:length(stat{ntest}.label)

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
            
            title([list_test_name{ntest} ' p = ' num2str(round(min_p(ntest),3))]);
            
            c = colorbar;
            c.Ticks = cfg.zlim;
            
            ylabel('Training Time');
            xlabel('Testing Time');
            
            xticks([-0.5 0 0.2 0.4 0.6 0.8 1]);
            yticks([-0.5 0 0.2 0.4 0.6 0.8 1]);
            
            vline(0,'-k');
            hline(0,'-k');
            
            set(gca,'FontSize',10,'FontName', 'Calibri','FontWeight','normal');
            
            
        end
    end
end