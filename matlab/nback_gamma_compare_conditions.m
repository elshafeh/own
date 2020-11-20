clear ;

suj_list    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    for nsess = [1 2]
        
        dirdata            	= 'J:/temp/nback/data/gamma/';
        fname_in          	= [dirdata 'sub' num2str(suj_list(nsuj)) '.sess' num2str(nsess) '.sensor.gamma.alltrials.mat'];
        fprintf('loading %s\n',fname_in);
        tic;load(fname_in);toc;
        tmp{nsess}         	= ft_combineplanar([],freq);
    end
    
    freq                   	= ft_appendfreq([],tmp{:});
    
    for nback = [1 2 3]
        
        cfg                 = [];
        cfg.trials          = find(freq.trialinfo(:,1) == nback+3);
        freq_slct           = ft_selectdata(cfg,freq);
        
        freq_slct           = ft_freqdescriptives([],freq_slct);
        
        cfg                 = [];
        cfg.baseline        = [-0.2 -0.1];
        cfg.baselinetype    = 'absolute';
        freq_slct           = ft_freqbaseline(cfg,freq_slct);
        
        alldata{nsuj,nback}	= freq_slct; clear freq_slct;
        
    end
end

keep alldata

list_cond                   = {'0back','1back','2back'};
list_test                   = [1 2; 1 3; 2 3];

for ntest = 1:3
    
    nb_suj                  	= size(alldata,1);
    [design,neighbours]      	= h_create_design_neighbours(nb_suj,alldata{1,1},'elekta','t');
    
    cfg                         = [];
    cfg.statistic               = 'ft_statfun_depsamplesT';
    cfg.method                  = 'montecarlo';
    cfg.correctm                = 'cluster';
    cfg.clusteralpha            = 0.05;
    cfg.clusterstatistic        = 'maxsum';
    cfg.minnbchan               = 2;
    cfg.tail                    = 0;
    cfg.clustertail             = 0;
    cfg.alpha                   = 0.025;
    cfg.numrandomization        = 1000;
    cfg.uvar                    = 1;
    cfg.ivar                    = 2;
    cfg.neighbours              = neighbours;
    cfg.design                  = design;
    
    ix1                         = list_test(ntest,1);
    ix2                         = list_test(ntest,2);

    stat{ntest}               	= ft_freqstatistics(cfg, alldata{:,ix1}, alldata{:,ix2});
    [min_p(ntest),p_val{ntest}]	= h_pValSort(stat{ntest});
    
    list_test_name{ntest}   	= [list_cond{ix1} ' v ' list_cond{ix2}];
    
end

figure;
nrow    = 2;
ncol    = 2;
i       = 0;

for ntest = 1:length(stat)
    
    stat2plot                       = h_plotStat(stat{ntest},10-20,0.1,'stat');
    
    cfg                             = [];
    cfg.layout                      = 'neuromag306cmb.lay';
    cfg.comment                     = 'no';
    cfg.marker                      = 'off';
    cfg.zlim                        = [-3 3];
    cfg.colormap                  	= brewermap(256, '*RdBu');
    i                               = i +1;
    subplot(nrow,ncol,i)
    ft_topoplotTFR(cfg,stat2plot);
    title(list_test_name{ntest});
    
end