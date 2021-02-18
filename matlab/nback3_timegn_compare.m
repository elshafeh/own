clear ; close all; clc; global ft_default
ft_default.spmversion = 'spm12';

suj_list           	= [1:33 35:36 38:44 46:51]';
trialcount      	= [];

for nsuj = 1:length(suj_list)
    
    subjectname                                	= ['sub' num2str(suj_list(nsuj))];
    
    list_band                                 	= {'alpha' 'beta'};
    list_bin                                    = {'3binsb1' '3binsb3'};
    list_decode                               	= 'first'; %'target'; %'stim*'; % 
    
    nb_files                                    = 0;
    
    for nband = 1:length(list_band)
        for nbin = 1:length(list_bin)
            
            flist                               = dir(['~/Dropbox/project_me/data/nback/bin_decode/auc/' subjectname ...
                '.' list_band{nband} '.' list_bin{nbin} '.4binningdecoding.nodemean.decoding.' list_decode '.auc.timegen.mat']);
            
            if length(flist) ~= 0
                nb_files                    	= nb_files + 1; clear flist;
            end
            
        end
    end
    
    suj_list(nsuj,2)                            = nb_files;
    
end

suj_list                                        = suj_list(suj_list(:,2) == length(list_band)*length(list_bin),1);

keep suj_list list_*

%%

for nsuj = 1:length(suj_list)
    
    subjectname                                	= ['sub' num2str(suj_list(nsuj))];
    
    for nband = 1:length(list_band)
        for nbin = 1:length(list_bin)
            
            flist                               = dir(['~/Dropbox/project_me/data/nback/bin_decode/auc/' subjectname ...
                '.' list_band{nband} '.' list_bin{nbin} '.4binningdecoding.nodemean.decoding.' list_decode '.auc.timegen.mat']);
            
            for nf = 1:length(flist)
                fname                           = [flist(nf).folder filesep flist(nf).name];
                fprintf('loading %s\n',fname);
                load(fname);
                pow(nf,:,:)                     = scores; clear scores;
            end
            
            freq                             	= [];
            freq.powspctrm                   	= mean(pow,1);
            freq.time                           = time_axis;
            freq.freq                           = time_axis;
            freq.dimord                         = 'chan_freq_time';
            freq.label                          = {['decoding ' list_decode]};
            alldata{nsuj,nband,nbin}            = freq; clear freq ;
            
        end
    end
end

%%

keep alldata list_band

nsuj                                = size(alldata,1);
[design,neighbours]                 = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;

for nband = 1:size(alldata,2)
    
    cfg                             = [];
    cfg.clusterstatistic            = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                    = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                        = 1;cfg.ivar = 2;
    cfg.tail                        = 0;cfg.clustertail  = 0;
    
    cfg.latency                     = [0 1];
    cfg.frequency                   = cfg.latency;
    
    cfg.clusteralpha                = 0.05; % !!
    cfg.alpha                       = 0.025;
    
    cfg.numrandomization            = 1000;
    cfg.design                      = design;
    
    allstat{nband}                  = ft_freqstatistics(cfg, alldata{:,nband,1}, alldata{:,nband,2});
    [min_p(nband), p_val{nband}]  	= h_pValSort(allstat{nband});
    
end

keep alldata list_band min_p p_val allstat

%%

figure;
nrow                                = 2;
ncol                                = 1;
i                                   = 0;
zlimit                              = [0.4 0.8; 0.45 0.6];

for nband = 1:length(allstat)
    
    stat                            = allstat{nband};
    stat.mask                       = stat.prob < 0.2;
    
    for nchan = 1:length(stat.label)
        
        ix                          = min(min(stat.prob(nchan,:,:)));
        
        cfg                         = [];
        cfg.colormap                = brewermap(256, '*RdBu');
        cfg.channel                 = nchan;
        cfg.parameter               = 'stat';
        cfg.maskparameter           = 'mask';
        cfg.maskstyle               = 'outline';
        cfg.figure                  = 0;
        cfg.zlim                    = [-5 5];
        cfg.colorbar                ='no';
        
        i = i+1;
        subplot(nrow,ncol,i);
        ft_singleplotTFR(cfg,stat);
        
        
        ylabel({stat.label{nchan}, ['p= ' num2str(round(ix,3))]});
        title(list_band{nband});
        
        set(gca,'FontSize',14,'FontName', 'Calibri');
        
    end
end