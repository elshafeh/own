clear ; clc;

addpath(genpath('kakearney-boundedline'));

load ../data/goodsubjects-07-Oct-2019.mat;

for nm = 1:length(list_modality)
    
    list_suj                                = goodsubjects{nm};
    
    for ns = 1:length(list_suj)
        
        suj                                 = list_suj{ns};
        modality                            = list_modality{nm};
        
        load(['../data/' suj '_sfn.erf_' modality '_maxchan.mat']);
        fname                               = ['../data/' suj '_sfn.fft_' modality '.mat'];
        
        fprintf('loading %s\n',fname);
        load(fname);
        
        cfg                                 = [];
        cfg.channel                         = max_chan; % avg over max chan
        freq                                = ft_selectdata(cfg,freq);
        
        cfg                                 = [];
        cfg.trials                          = find(freq.trialinfo(:,3) == 1); % avg over trials
        
        cfg.avgoverchan                     = 'yes';
        cfg.avgoverrpt                      = 'yes';
        
        dataplot                            = ft_selectdata(cfg,freq);
        dataplot.label                      = {'chanavg'};
        dataplot                            = rmfield(dataplot,'cfg');
        
        fname                               = ['../data/' suj '_sfn.fft_' modality '.peak.mat'];
        load(fname);
        
        bn_width                            = 1;
        [bin_summary]                       = h_preparebins(freq,alpha(1),6,bn_width);
        
        data_sub{nm}{ns,1}                  = dataplot;
        data_sub{nm}{ns,2}                  = alpha;
        
        clear dataplot alpha freq;
        
        fprintf('\n');clc;
        
    end
end

clearvars -except data_* list_modality;

% plot spectrum

list_color                  = 'gb';
ix                          = 0;

for nm = 1:length(data_sub)
    
    ix                      = ix+1;
    subplot(1,2,ix)
    hold on;
    
    mtrx_data               = [];
    
    for ns = 1:size(data_sub{nm},1)
        mtrx_data(ns,:)     = data_sub{nm}{ns,1}.powspctrm;
    end
    
    mean_data               = mean(mtrx_data,1);
    bounds                  = std(mtrx_data, [], 1);
    bounds_sem              = bounds ./ sqrt(size(mtrx_data,1));
    
    find_mx                 = find(mean_data == max(mean_data));
    
    time_axs                = data_sub{nm}{ns,1}.freq;
    
    plot(time_axs, mtrx_data, 'Color', [0.8 0.8 0.8]);
    boundedline(time_axs, mean_data, bounds_sem,['-' list_color(nm)],'alpha'); % alpha makes bounds transparent
    
    xlabel('Frequency (Hz)');
    ylabel('Power');
    ax                  = gca();
    ax.XAxisLocation    = 'origin';
    ax.YAxisLocation    = 'origin';
    ax.TickDir          = 'out';
    box off;
    ax.XLabel.Position(2) = -60;
    
    disp(time_axs(find_mx));
    
    vline(time_axs(find_mx),'--k');
    
    ylim([0 0.25e-26]);
    xlim([5 25]);
    
end