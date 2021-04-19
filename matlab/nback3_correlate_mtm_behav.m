clear;clc;

allbehav                            = [];

for nsuj = [1:33 35:36 38:44 46:51]
    
    dir_data                        = '~/Dropbox/project_me/data/nback/trialinfo/';
    fname                           = [dir_data 'sub' num2str(nsuj) '.trialinfo.mat'];
    load(fname);
    
    flg_nback_stim                  = find(trialinfo(:,2) == 2);
    sub_info                        = trialinfo(flg_nback_stim,[4 5 6]);
    
    sub_info_correct                = sub_info(sub_info(:,1) == 1 | sub_info(:,1) == 3,:); % remove incorrect trials for RT analyses
    sub_info_correct                = sub_info_correct(sub_info_correct(:,2) ~= 0,:); % remove zeros
    
    median_rt                       = median(sub_info_correct(:,2));
    perc_correct                    = length(sub_info_correct) ./ length(sub_info);

    
    allbehav                        = [allbehav;median_rt perc_correct];
    
    
end

suj_list                            = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_stim                       = {'first' 'target'};
    
    for nstim = 1:length(list_stim)
        
        dir_data                	= '~/Dropbox/project_me/data/nback/corr/mtm/';
        fname_in                 	= [dir_data 'sub' num2str(suj_list(nsuj)) '.allback.allbehav.' list_stim{nstim} '.mtm.mat'];
        
        fprintf('loading %s\n',fname_in);
        load(fname_in);
        
        alldata{nsuj,nstim}       	= freq_comb; clear freq_comb;
        
    end
    
end

%%

keep alldata allbehav list_*

nbsuj                               = size(alldata,1);
[~,neighbours]                      = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                                 = [];
cfg.method                          = 'montecarlo';
cfg.frequency                       = [1 35];
cfg.latency                         = [-0.5 1];

cfg.statistic                       = 'ft_statfun_correlationT';
cfg.type                            = 'Spearman';
cfg.clusterstatistics               = 'maxsum';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05;
cfg.tail                            = 0;
cfg.clustertail                     = 0;
cfg.alpha                           = 0.025;
cfg.numrandomization                = 1000;
cfg.minnbchan                       = 3;
cfg.neighbours                      = neighbours;
cfg.ivar                            = 1;

for nbehav = 1:size(allbehav,2)
    for nstim = 1:size(alldata,2)
        
        cfg.design(1,1:nbsuj)       = [allbehav(:,nbehav)];
        stat{nbehav,nstim}       	= ft_freqstatistics(cfg, alldata{:,nstim});
        [min_p(nbehav,nstim),p_val{nbehav,nstim}]	= h_pValSort(stat{nbehav,nstim});
        
    end
end

%%

keep alldata allbehav stat min_p p_val list_*

plimit                              = 0.2;
i                                   = 0;

list_behav                          = {'rt' 'accuracy'};

for nbehav = 1:size(stat,1)
    for nstim = 1:size(stat,2)
        if min_p(nbehav,nstim) < plimit
            
            cfg                     = [];
            cfg.layout             	= 'neuromag306cmb.lay';
            cfg.zlim                = [-3 3];
            cfg.colormap         	= brewermap(256,'*RdBu');
            cfg.plimit           	= plimit;
            cfg.vline               = 0;
            cfg.sign                = [-1 1];
            cfg.test_name           = [list_stim{nstim} ' with ' list_behav{nbehav}];
            h_plotstat_3d(cfg,stat{nbehav,nstim});
            
        end
    end
end