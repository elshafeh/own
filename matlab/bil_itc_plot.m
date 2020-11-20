clear ; close all;

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for ns = 1:length(suj_list)
    
    sujName                                         = suj_list{ns};
    list_cnd                                        = {'alltrials.allchan','alltrials.allchan.minevoked'};
    
    for nc = 1:length(list_cnd)
        
        fname                                       = [project_dir 'data/' sujName '/tf/' sujName '.cuelock.itc.comb.' list_cnd{nc} '.mat'];
        fprintf('\nloading %s',fname);
        load(fname);
        
        alldata{ns,nc}                              = phase_lock ; clear phase_lock;
        
    end
end

keep alldata list_cnd;

list_cnd                    = {'with evoked','minus evoked'};

list_time                   = [0 1.5; 1.5 3; 3 4.5; 4.5 6];

list_ticks{1}              	= {'1st cue','1st gabor'};
list_ticks{2}              	= {'1st gabor','2nd cue'};
list_ticks{3}              	= {'2nd cue','2nd gabor'};
list_ticks{4}              	= {'2nd gabor',''};

figure;
nrow                        = size(list_time,1);
ncol                        = size(alldata,2);
i                           = 0;

for nt = 1:size(list_time,1)
    for nc = 1:size(alldata,2)
        
        i = i + 1;
        subplot(nrow,ncol,i)
        cfg                 = [];
        cfg.channel         = {'MLO21', 'MLO22', 'MLO31', 'MLO32', 'MLO41', 'MLO42'', MRO21', 'MRO22'};
        cfg.zlim            = 'zeromax';
        cfg.xlim            = list_time(nt,:);
        cfg.ylim            = [1 8];
        cfg.layout          = 'CTF275.lay';
        cfg.colormap        = brewermap(256, '*RdBu');
        ft_singleplotTFR(cfg,ft_freqgrandaverage([],alldata{:,nc}));title(list_cnd{nc});
        
        xticks(list_time(nt,:));
        xticklabels(list_ticks{nt});
        
    end
end

figure;
nrow                        = size(list_time,1);
ncol                        = size(alldata,2);
i                           = 0;

for nt = 1:size(list_time,1)
    for nc = 1:size(alldata,2)
        
        i = i + 1;
        subplot(nrow,ncol,i)
        cfg                 = [];
        cfg.layout          = 'CTF275.lay';
        cfg.marker          = 'off';
        cfg.colormap        = brewermap(256, '*RdBu');
        cfg.colorbar        = 'yes';
        cfg.comment         = 'no';
        cfg.xlim            = list_time(nt,:);
        cfg.ylim            = [3 5];
        cfg.zlim            = 'zeromax';
        
        ft_topoplotTFR(cfg, ft_freqgrandaverage([],alldata{:,nc}));title(list_cnd{nc});
        
    end
end

figure;

for nc = 1:size(alldata,2)

    mtrx_data   = [];
    
    for ns = 1:size(alldata,1)
        cfg                 = [];
        cfg.channel         = {'MLO21', 'MLO22', 'MLO31', 'MLO32', 'MLO41', 'MLO42'', MRO21', 'MRO22'};
        cfg.frequency       = [1 8];
        cfg.avgoverchan     = 'yes';
        cfg.avgoverfreq     = 'yes';
        tmp                 = ft_selectdata(cfg,alldata{ns,nc});
        mtrx_data(ns,:)     = tmp.powspctrm; clear tmp;
        
    end
    
    subplot(2,1,nc)
    
    mean_data           = mean(mtrx_data,1);
    bounds              = std(mtrx_data, [], 1);
    bounds_sem          = bounds ./ sqrt(size(mtrx_data,1));
    
    x_axs               = alldata{1}.time;
    boundedline(x_axs, mean_data, bounds_sem,'-k','alpha'); % alpha makes bounds transparent
    
    title(list_cnd{nc});
    
    xticks([0 1.5 3 4.5]);
    xticklabels({'1st cue','1st gabor','2nd cue','2nd gabor'});
    vline([0 1.5 3 4.5],'--r');
    
    xlim([-0.1 6.5]);
    
    list_ylim           = [0.07 0.7; 0.025 0.034];
    ylim(list_ylim(nc,:));
    yticks(list_ylim(nc,:));
    
end

figure;

for nc = 1:size(alldata,2)

    mtrx_data   = [];
    
    for ns = 1:size(alldata,1)
        cfg                 = [];
        cfg.channel         = {'MLO21', 'MLO22', 'MLO31', 'MLO32', 'MLO41', 'MLO42'', MRO21', 'MRO22'};
        cfg.avgoverchan     = 'yes';
        cfg.avgovertime     = 'yes';
        tmp                 = ft_selectdata(cfg,alldata{ns,nc});
        mtrx_data(ns,:)     = tmp.powspctrm; clear tmp;
        
    end
    
    subplot(1,2,nc)
    
    mean_data           = mean(mtrx_data,1);
    bounds              = std(mtrx_data, [], 1);
    bounds_sem          = bounds ./ sqrt(size(mtrx_data,1));
    
    x_axs               = alldata{1,nc}.freq;
    boundedline(x_axs, mean_data, bounds_sem,'-k','alpha'); % alpha makes bounds transparent
    
    title(list_cnd{nc});
    
    xticks([1 2 3 4 5 6 7 8]);
    xlim([1 8]);
    
    list_ylim           = [0.15 0.4; 0.024 0.035];
    ylim(list_ylim(nc,:));
    yticks(list_ylim(nc,:));
    
    find_mx             = find(mean_data == max(mean_data));
    vline(x_axs(find_mx),'--k');
    
end