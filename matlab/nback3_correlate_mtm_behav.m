clear;clc;

allbehav                            = [];

for nbehav = [1:33 35:36 38:44 46:51]
    
    dir_data                        = '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in                        = [ dir_data 'sub' num2str(nbehav) '.singletrial.trialinfo.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    correct_trials                  = find(rem(trialinfo(:,4),2) ~= 0);
    perc_correct                    = length(correct_trials) ./ length(trialinfo);
    
    correct_trials_with_rt          = find(rem(trialinfo(:,4),2) ~= 0 & trialinfo(:,5) ~= 0);
    rt_vector                       = trialinfo(correct_trials_with_rt,5) ./ 1000;
    rt_vector                       = rt_vector/mean(rt_vector);
    mean_rt                         = mean(rt_vector);
    
    allbehav                        = [allbehav;perc_correct mean_rt];
    
end

suj_list                            = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_stim                       = {'first' 'target'};
    baseline_correct                = 'average'; % none average time freq
    
    freq_bounds                     = [5 30];
    time_bounds                     = [-0.5 1];
    
    % load in 0back data for baseline correction
    dir_data                        = '~/Dropbox/project_me/data/nback/0back/mtm/';
    fname_in                        = [dir_data 'sub' num2str(suj_list(nsuj)) '.0back.avgtrial.mtm.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    freq_comb                       = h_selectfreq(freq_comb,freq_bounds,time_bounds);
    t1                              = nearest(freq_comb.time,-0.4);
    t2                              = nearest(freq_comb.time,-0.2);
    zero_bsl                        = nanmean(freq_comb.powspctrm(:,:,t1:t2),3); clear freq_comb;
    
    for nstim = 1:length(list_stim)
        
        dir_data                    = '~/Dropbox/project_me/data/nback/corr/mtm/';
        fname_in                    = [dir_data 'sub' num2str(suj_list(nsuj)) '.allback.allbehav.' list_stim{nstim} '.mtm.mat'];
        
        fprintf('loading %s\n',fname_in);
        load(fname_in);
        
        freq_comb                 	= h_selectfreq(freq_comb,freq_bounds,time_bounds);
        
        % - % baseline correction
        if strcmp(baseline_correct,'freq')
            bsl                     = nanmean(freq_comb.powspctrm,2);
            freq_comb.powspctrm     = (freq_comb.powspctrm) ./ bsl ; clear bsl;
        end
        
        % - % baseline correction
        if strcmp(baseline_correct,'zero')
            freq_comb.powspctrm     = (freq_comb.powspctrm) ./ zero_bsl;
        end
        
        % - % baseline correction
        if strcmp(baseline_correct,'average')
            t1                    	= nearest(freq_comb.time,-0.4);
            t2                   	= nearest(freq_comb.time,-0.2);
            bsl                  	= nanmean(freq_comb.powspctrm(:,:,t1:t2),3);
            freq_comb.powspctrm     = (freq_comb.powspctrm) ./ bsl; clear bsl;
        end
        
        alldata{nsuj,nstim}         = freq_comb; clear freq_comb;
        
    end
    
end

%%

keep alldata allbehav list_*

nbsuj                               = size(alldata,1);
[~,neighbours]                      = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');


for nbehav = 1:size(allbehav,2)
    for nstim = 1:size(alldata,2)
        
        cfg                      	= [];
        
        if strcmp(list_stim{nstim},'first')
            cfg.latency          	= [-0.01 1];
        else
            cfg.latency         	= [-0.01 0.6];
        end
        
        cfg.method               	= 'montecarlo';
        cfg.statistic            	= 'ft_statfun_correlationT';
        cfg.type                	= 'Pearson';
        cfg.clusterstatistics     	= 'maxsum';
        cfg.correctm             	= 'cluster';
        cfg.clusteralpha          	= 0.05;
        cfg.tail                 	= 0;
        cfg.clustertail          	= 0;
        cfg.alpha                	= 0.025;
        cfg.numrandomization       	= 1000;
        cfg.minnbchan              	= 3;
        cfg.neighbours          	= neighbours;
        cfg.ivar                	= 1;
        
        
        cfg.design(1,1:nbsuj)       = [allbehav(:,nbehav)];
        stat{nbehav,nstim}       	= ft_freqstatistics(cfg, alldata{:,nstim});
        [min_p(nbehav,nstim),p_val{nbehav,nstim}]	= h_pValSort(stat{nbehav,nstim});
        
    end
end

%%

keep alldata allbehav stat min_p p_val list_*

close all;

plimit                              = 0.15;
i                                   = 0;

list_behav                          = {'accuracy' 'reaction time'};

for nbehav = 1:size(stat,1)
    for nstim = 1:size(stat,2)
        if min_p(nbehav,nstim) < plimit
            
            cfg                     = [];
            cfg.layout             	= 'neuromag306cmb_helmet.mat'; %'neuromag306cmb.lay';
            cfg.colormap         	= brewermap(256,'*RdBu');
            cfg.plimit           	= plimit;
            
            cfg.sign                = [-1 1];
            cfg.test_name           = [list_stim{nstim} ' with ' list_behav{nbehav}];
            cfg.fontsize         	= 16;
            cfg.vline               = [0 0.5];
            
            cfg.hline               = [7 15];
            cfg.zlim                = [-2 2];
            
            h_plotstat_3d(cfg,stat{nbehav,nstim});
            
        end
    end
end