clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    dir_data                            = '~/Dropbox/project_me/data/bil/decode/';
    
    frequency_list                      = {'beta'}; % 'theta' 'alpha' 'gamma' 
    decoding_list                       = {'frequency'}; %  'orientation'
    
    list_bin                            = [1 5];
    name_bin                            = {'Bin1' 'Bin5'};
    
    for nfreq = 1:length(frequency_list)
        for nbin = 1:length(name_bin)
            
            ext_name                    = '.all.bsl.timegen.mat';
            
            pow                         = [];
            
            for ndeco = 1:length(decoding_list)
                
                flist_1               	= dir([dir_data subjectName '.1stgab.decodinggabor.' frequency_list{nfreq} ...
                    '.band.preCue2.window.bin' num2str(list_bin(nbin)) '.' decoding_list{ndeco}  ext_name]);
                
                flist                   = [flist_1]; clear flist_* %;flist_2];
                
                tmp                     = [];
                
                for nf = 1:length(flist)
                    fname               = [flist(nf).folder filesep flist(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    tmp(nf,:,:)     	= scores;clear scores;
                end
                
                pow(ndeco,:,:)          = squeeze(mean(tmp,1)); clear tmp;
                
            end
            
            freq                        = [];
            freq.powspctrm              = [];
            freq.powspctrm              =  pow; clear pow;
            
            freq.label                  = decoding_list;
            freq.dimord                 = 'chan_freq_time';
            freq.time                   = time_axis;
            freq.freq                   = time_axis;
            
            alldata{nsuj,nfreq,nbin}  	= freq; clear freq;
            
        end
    end
end

keep alldata *_list name_bin

%%

% compute anova
nsuj                                = size(alldata,1);
[design,neighbours]                 = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;

for nfreq = 1:size(alldata,2)
    
    cfg                             = [];
    cfg.clusterstatistic            = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                    = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                        = 1;cfg.ivar = 2;
    cfg.tail                        = 0;cfg.clustertail  = 0;
    cfg.neighbours                  = neighbours;
    
    cfg.latency                     = [0 3];
    cfg.frequency                   = cfg.latency;
    
    cfg.clusteralpha                = 0.05; % !!
    cfg.minnbchan                   = 0; % !!
    cfg.alpha                       = 0.025;
    
    cfg.numrandomization            = 1000;
    cfg.design                      = design;
    
    for nchan = 1:length(alldata{1}.label)
        cfg.channel                 = nchan;
        allstat{nfreq,nchan}        = ft_freqstatistics(cfg, alldata{:,nfreq,1}, alldata{:,nfreq,2});
    end
    
end

%%

keep alldata *_list allstat name_bin

for dim_x = 1:size(allstat,1)
    for dim_y = 1:size(allstat,2)   
        [min_p(dim_x,dim_y), p_val{dim_x,dim_y}]            = h_pValSort(allstat{dim_x,dim_y});
    end
end

%%

figure;
nrow                                = 2;
ncol                                = 2;
i                                   = 0;
zlimit                              = [0.4 0.8; 0.45 0.6];

for dim_x = 1:size(allstat,1)
    for dim_y = 1:size(allstat,2)
        
        stat                        = allstat{dim_x,dim_y};
        stat.mask                   = stat.prob < 0.15;
        
        for nchan = 1:length(stat.label)
            
            flg                     = length(unique(stat.mask(nchan,:)));
            
            if flg > 1
                
                ix                  = min(min(stat.prob(nchan,:,:)));
                
                cfg                 = [];
                cfg.colormap        = brewermap(256, '*RdBu');
                cfg.channel         = nchan;
                cfg.parameter       = 'stat';
                cfg.maskparameter 	= 'mask';
                cfg.maskstyle     	= 'outline';
                cfg.zlim           	= [-5 5];
                cfg.colorbar       	='no';
                
                i = i+1;
                subplot(nrow,ncol,i);
                ft_singleplotTFR(cfg,stat);
                
                
                ylabel({stat.label{nchan}, ['p= ' num2str(round(ix,3))]});
                title(frequency_list{dim_x});
                
                vct_plt     = [0 0.1 0.2 0.3 0.4 0.5 1.5 3];
                vline(vct_plt(1:end-1),'--k');
                hline(vct_plt(1:end-1),'--k');
                
                xticklabels({'1st G' '0.1' '0.2' '0.3' '0.4' '0.5' '2nd Cue' '2nd G'});
                yticklabels({'1st G' '0.1' '0.2' '0.3' '0.4' '0.5' '2nd Cue' '2nd G'});
                
                xticks(vct_plt);
                yticks(vct_plt);
                
                set(gca,'FontSize',10,'FontName', 'Calibri');
                
            end
        end
    end
end