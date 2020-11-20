clear ; close all;

if isunix
    project_dir = '/project/3015079.01/data/';
else
    project_dir = 'P:/3015079.01/data/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for ns = 1:length(suj_list)
    
    sujName                = suj_list{ns};
    
    fname                  = [project_dir sujName '/tf/' sujName '.cuelock.itc.5binned.withEvoked.withIncorrect.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    list_legend            = {};
    
    for nb = 1:length(phase_lock)
        
        freq                = phase_lock{nb};
        freq                = rmfield(freq,'rayleigh');
        freq                = rmfield(freq,'p');
        freq                = rmfield(freq,'sig');
        freq                = rmfield(freq,'mask');
        freq                = rmfield(freq,'mean_rt');
        freq                = rmfield(freq,'med_rt');
        freq                = rmfield(freq,'index');
        freq                = rmfield(freq,'perc_corr');
        
        alldata{ns,nb}      = freq; clear freq;
        
    end
    
end

keep alldata

list_test                       = [1 2; 1 3; 1 4; 1 5; 2 3; 2 4; 2 5; 3 4; 3 5; 4 5];
list_name                       = {};
i                               = 0;

for ntest = 1:size(list_test,1)
    
    nsuj                        = size(alldata,1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;
    
    cfg                         = [];
    cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                    = 1;cfg.ivar = 2;
    cfg.tail                    = 0;cfg.clustertail  = 0;
    cfg.neighbours              = neighbours;
    
    
    cfg.clusteralpha            = 0.05; % !!
    cfg.minnbchan               = 3; % !!
    
    cfg.alpha                   = 0.025;
    
    cfg.numrandomization        = 1000;
    cfg.design                  = design;
    
    list_time                   = [0 6];%[0.5 1.5; 2 3; 3.5 4.5];
    
    for ntime = 1:size(list_time,1)
        
        i                       = i +1;
        
        ix1                     = list_test(ntest,1);
        ix2                     = list_test(ntest,2);
        
        cfg.latency             = list_time(ntime,:);
        
        list_name{i}            = ['RT bin' num2str(ix1) ' versus RT bin' num2str(ix2) ' window' num2str(ntime)];
        stat{i}                 = ft_freqstatistics(cfg, alldata{:,ix1},alldata{:,ix2});
        
    end
    
end

% save(['../data/stat/bil.itc.bin.stat' num2str(cfg.minnbchan) 'min.mat'],'stat','list_name','-v7.3');
% load(['../data/stat/bil.itc.bin.stat4min.mat']);

keep stat alldata list_name

for ntest = 1:length(stat)
    [min_p(ntest), p_val{ntest}]   = h_pValSort(stat{ntest});
end

p_limit                 = 0.05;

nrow                    = 4;
ncol                    = 4;
i                       = 0;
z_limit                 = [0 1];

for ntest = 1:length(stat)
    if min_p(ntest) < p_limit
        
        stoplot         = h_plotStat(stat{ntest},10e-26,p_limit,'stat');
        
        cfg             = [];
        cfg.layout      = 'CTF275.lay';
        cfg.marker      = 'off';
        cfg.comment     = 'no';
        cfg.colorbar    = 'no';
        cfg.colormap    = brewermap(256, '*RdBu');
        cfg.zlim        = 'maxabs';
        
        i               = i + 1;
        subplot(nrow,ncol,i)
        ft_topoplotTFR(cfg,stoplot);
        title(list_name{ntest});
        
    end
end
        
%         i = i +1;
%         subplot(nrow,ncol,i)
%         cfg             = [];
%         cfg.zlim        = z_limit;
%         cfg.colormap    = brewermap(256, '*RdBu');
%         ft_singleplotTFR(cfg,stoplot);
%         title('');
%
%         i = i +1;
%         subplot(nrow,ncol,i)
%         plot_y          = nanmean(squeeze(nanmean(stoplot.powspctrm,3)),1);
%         plot(stoplot.freq,plot_y,'-k','LineWidth',2);
%         xlim(stoplot.freq([1 end]));
%         xticks([1 2 3 4 5 6 8 10]);
%         ylim([0 0.2])
%         yticks([0 0.2]);
%         grid on;
%         vline(find(plot_y == max(plot_y)),'--r');
%         xlabel('Frequency');
%
%         i = i +1;
%         subplot(nrow,ncol,i)
%         plot_y          = nanmean(squeeze(nanmean(stoplot.powspctrm,2)),1);
%
%         plot(stoplot.time,plot_y,'-k','LineWidth',2);
%         xlim(stoplot.time([1 end]));
%         xticks([0 1.5 3 4.5 stoplot.time(end)]);
%         ylim([0 1])
%         yticks([0 1]);
%         xlabel('Time');
%         grid on;
%
%
%     end
% end