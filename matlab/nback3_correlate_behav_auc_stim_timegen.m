
clear;clc;

allbehav                   	= [];

for nbehav = [1:33 35:36 38:44 46:51]
    
    dir_data                = '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in             	= [ dir_data 'sub' num2str(nbehav) '.singletrial.trialinfo.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    correct_trials          = find(rem(trialinfo(:,4),2) ~= 0);
    perc_correct            = length(correct_trials) ./ length(trialinfo);
    
    correct_trials_with_rt	= find(rem(trialinfo(:,4),2) ~= 0 & trialinfo(:,5) ~= 0);
    rt_vector               = trialinfo(correct_trials_with_rt,5) ./ 1000;
    rt_vector               = rt_vector/mean(rt_vector);
    mean_rt                 = mean(rt_vector);
    
    allbehav                = [allbehav;perc_correct mean_rt];
    
end

keep allbehav

suj_list  	= [1:33 35:36 38:44 46:51];

for nbehav = 1:length(suj_list)
    
    sujname               	= ['sub' num2str(suj_list(nbehav))];
    
    dir_data                = '~/Dropbox/project_me/data/nback/behav_timegen/';
    
    list_stim               = [2 3 4 5 7 8 9];
    pow                     = [];

    for nstim = 1:length(list_stim)
        
        fname_in          	= [dir_data 'sub' num2str(suj_list(nbehav)) '.all.decoding.stim' num2str(list_stim(nstim)) '.nodemean.auc.timegen.mat'];
        fprintf('loading %s\n',fname_in);
        load(fname_in);
        pow(nstim,:,:)      = scores; clear scores;
        
    end
    
    freq                    = [];
    freq.freq               = time_axis;
    freq.time               = time_axis;
    freq.dimord             = 'chan_freq_time';
    freq.label              = {'decoding stim'};
    freq.powspctrm          = mean(pow,1);
    
    alldata{nbehav,1}         = freq; clear freq;
    
end

%%

keep alldata allbehav

cfg                         = [];
cfg.method                  = 'montecarlo';

cfg.frequency               = [0 0.5];
cfg.latency                 = [0 1];

cfg.statistic               = 'ft_statfun_correlationT';
cfg.clusterstatistics       = 'maxsum';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.alpha                   = 0.025;
cfg.numrandomization        = 1000;
cfg.ivar                    = 1;

list_corr                   = {'Spearman' 'Pearson'};
list_behav                  = {'accuracy' 'reaction time'};

for nbehav = [1 2]
    for ncorr = [1 2]
        
        nb_suj           	= size(alldata,1);
        cfg.type            = list_corr{ncorr};
        cfg.design(1,1:nb_suj)	= [allbehav(:,nbehav)];
        
        [~,neighbours]  	= h_create_design_neighbours(nbehav,alldata{1,1},'gfp','t');
        cfg.neighbours    	= neighbours;
        
        stat{nbehav,ncorr}         = ft_freqstatistics(cfg, alldata{:});
        [min_p(nbehav,ncorr),p_val{nbehav,ncorr}]   	= h_pValSort(stat{nbehav,ncorr});
        
    end
end

%%

keep alldata allbehav stat min_p p_val list_*

nrow                                = 2;
ncol                                = 2;
i                                   = 0;

plimit                              = 0.05/2;

for nbehav = [1 2]
    for ncorr = [1 2]
        
        statplot                   	= stat{nbehav,ncorr};
        statplot.mask             	= statplot.prob < plimit;
        
        cfg                         = [];
        cfg.colormap                = brewermap(256, '*RdBu');
        cfg.channel                 = 1;
        cfg.parameter               = 'stat';
        cfg.maskparameter           = 'mask';
        cfg.maskstyle               = 'opacity';
        cfg.maskalpha               = 0.3;
        cfg.zlim                    = [-3 3];
        cfg.colorbar                ='no';
        cfg.figure                  = 0;
        
        i = i+1;
        subplot(nrow,ncol,i);
        ft_singleplotTFR(cfg,statplot);
        title({[statplot.label{1} ' with ' list_behav{nbehav}] , ['p = ' num2str(round(min_p(nbehav,ncorr),3)) ' ' list_corr{ncorr}]});
        
        xlabel('Testing time');
        ylabel('Training Time');
        
        set(gca,'FontSize',16,'FontName', 'Calibri');
        
        
    end
end