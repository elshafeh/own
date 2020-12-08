% Plots ERF over each hemisphere - based on max chans - GRAND AVERAGE FOR EACH MODALITY AND HEMI
% SUBJECT SHOULD CONTAIN DATA FROM MODALITIES

clear ; clc;

addpath(genpath('kakearney-boundedline'));

load ../data/goodsubjects-07-Oct-2019.mat;

for nm = 1:length(list_modality)
    
    list_suj            = goodsubjects{nm};
    
    for ns = 1:length(list_suj)
        
        suj                                 = list_suj{ns};
        modality                            = list_modality{nm};
        
        fprintf('handling mod %2d out of %2d sub %2d out of %d\n\n', ...
            nm,length(list_modality),ns,length(list_suj));
        
        fname                               = ['../data/' suj '_sfn.erf_' modality '.mat'];
        
        if exist(fname)
            fprintf('loading %s\n',fname);
            load(fname);
        else
            localizer_timelock_planar_comb  = h_createplanarERF(suj,modality);
            save(fname,'localizer_timelock_planar_comb','-v7.3');
        end
        
        [max_chan]                          = h_maxchanslct(localizer_timelock_planar_comb,modality,[0.1 0.2],10);
        
        fname_out                           = [fname(1:end-4) '_maxchan.mat'];
        save(fname_out,'max_chan');
        
        % (1) is avg channels and (2) is whole channel
        
        cfg                                 = [];
        cfg.channel                         = max_chan;
        cfg.avgoverchan                     = 'yes';
        data_sub{nm}{ns,1}                  = ft_selectdata(cfg,localizer_timelock_planar_comb);
        data_sub{nm}{ns,1}.label            = {'chanavg'};
        
        data_sub{nm}{ns,2}                  = localizer_timelock_planar_comb;
        
        fprintf('\n');
        clc;
        
        clear localizer_timelock_planar_comb;
        
    end
    
end

clearvars -except data_sub list_modality; close all;

ix                                      = 0;
list_color                              = 'gb';

for nm = 1:2
    
    gavg                                = ft_timelockgrandaverage([],data_sub{nm}{:,2});
    
    ix                                  = ix+1;
    subplot(2,2,ix)
    
    cfg                                 = [];
    cfg.layout                          = 'CTF275_helmet.mat';
    cfg.ylim                            = 'maxabs';
    cfg.marker                          = 'off';
    cfg.comment                         = 'no';
    cfg.colormap                        = brewermap(256,'Reds');
    cfg.colorbar                        = 'yes';
    cfg.xlim                            = [0.1 0.2];
    ft_topoplotER(cfg, gavg);
    
    ix                                  = ix+1;
    subplot(2,2,ix)
    hold on
    
    mtrx_data                           = [];
    
    for ns = 1:size(data_sub{nm},1)
        mtrx_data(ns,:)                 = data_sub{nm}{ns,1}.avg;
    end
    
    % Use the standard deviation over trials as error bounds:
    mean_data                           = mean(mtrx_data,1);
    bounds                              = std(mtrx_data, [], 1);
    bounds_sem                          = bounds ./ sqrt(size(mtrx_data,1));
    
    time_axs                            = data_sub{nm}{1,1}.time;
    
    plot(time_axs, mtrx_data, 'Color', [0.8 0.8 0.8]);
    boundedline(time_axs, mean_data, bounds_sem,['-' list_color(nm)],'alpha'); % alpha makes bounds transparent
    
    % Add all our previous improvements:
    xlabel('Time (s)');
    ylabel('Magnetic gradient (fT)');
    ax                  = gca();
    ax.XAxisLocation    = 'origin';
    ax.YAxisLocation    = 'origin';
    ax.TickDir          = 'out';
    box off;
    ax.XLabel.Position(2) = -60;
    
    if nm == 1
        ylim([0 2.5e-13])
    else
        ylim([0 4.5e-13])
    end
    
    xlim([-0.1 1]);
    
    vline(0.1,'--k');
    vline(0.2,'--k');
    
end