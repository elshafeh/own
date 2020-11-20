clear ; clc;

addpath(genpath('kakearney-boundedline'));

load ../data/goodsubjects-07-Oct-2019.mat;

i                                           = 0;

for nm = 1:length(list_modality)
    
    list_suj                                = goodsubjects{nm};
    
    for ns = 1:length(list_suj)
        
        suj                                 = list_suj{ns};
        modality                            = list_modality{nm};
        
        fname                               = ['../data/' suj '_sfn.erf_' modality '_maxchan.mat'];
        load(fname);
        
        fname                               = ['../data/' suj '_sfn.fft_' modality '.mat'];
        
        fprintf('loading %s\n',fname);
        load(fname);
        
        cfg                                 = [];
        cfg.channel                         = max_chan; % avg over max chan
        freq                                = ft_selectdata(cfg,freq);
        
        cfg.trials                          = find(freq.trialinfo(:,3) == 1); % avg over trials
        
        cfg.avgoverchan                     = 'yes';
        cfg.avgoverrpt                      = 'yes';
        
        dataplot                            = ft_selectdata(cfg,freq);
        dataplot.label                      = {'chanavg'};
        
        cfg                                 = [];
        cfg.method                          = 'maxabs' ;
        cfg.foi                             = [7 15];
        alpha                               = alpha_peak(cfg,dataplot);
       
        dataplot                            = rmfield(dataplot,'cfg');
        
        bn_width                            = 1;
        nb_bin                              = 6;
        
        [bin_summary]                       = h_preparebins(freq,alpha(1),6,bn_width);
        
        data_sub{nm}{ns,1}                  = dataplot;
        data_sub{nm}{ns,2}                  = alpha;
        data_sub{nm}{ns,3}                  = bin_summary;
        
        for nb = 1:size(bin_summary.bins,2)
            
            i                               = i + 1;
            
            data_table(i).suj               = suj;
            data_table(i).mod               = modality;
            data_table(i).bin               = ['B' num2str(nb)];
            
            lm1                             = find(freq.freq == alpha(1)-bn_width);
            lm2                             = find(freq.freq == alpha(1)+bn_width);
            
            data_table(i).pow               = mean(mean(mean(freq.powspctrm(bin_summary.bins(:,nb),:,lm1:lm2))));
            
            data_table(i).cor               = bin_summary.perc_corr(nb);
            data_table(i).con               = bin_summary.perc_conf(nb);
            data_table(i).rt                = bin_summary.med_rt(nb);
            
        end
        
        clear dataplot alpha freq;
        
        fprintf('\n');clc;
        
    end
end

clearvars -except data_* list_modality; close all;

list_color                  = 'gb';
ix                          = 0;
list_ylim                   = [0.65 1;0.3 1;1 2]; % [0.65 0.95;0.3 0.8;1 2];

for nm = 1:length(data_sub)
    
    data_bin                = [];
    
    for ns = 1:size(data_sub{nm},1)
        
        data_bin(ns,1,:)    = data_sub{nm}{ns,3}.perc_corr;
        data_bin(ns,2,:)    = data_sub{nm}{ns,3}.perc_conf;
        data_bin(ns,3,:)    = data_sub{nm}{ns,3}.med_rt;
        
    end
    
    list_name               = {};
    
    for nb = 1:size(data_bin,3)
        list_name{nb}       = ['B' num2str(nb)];
    end
    
    for nv = 1:3
        
        ix                  = ix+1;
        subplot(2,3,ix)
        
        vct_to_plot         = squeeze(data_bin(:,nv,:));
        nb_suj              = size(vct_to_plot,1);
        
        mean_to_plot        = mean(vct_to_plot,1);
        sem_to_plot         = std(vct_to_plot,[],1)/sqrt(nb_suj); % calculate sem
        
        hold on
        
        bar(mean_to_plot);
        
        er                  = errorbar(mean_to_plot,sem_to_plot,'LineWidth',1,'LineStyle','none');
        er.Color            = [0 0 0];
        er.LineStyle        = 'none';
                
        xticks(0:length(list_name)+1)
        xticklabels([{''} list_name {''}]);
        xlim([0 length(list_name)+1]);
        
        ylim(list_ylim(nv,:));
        
    end
    
end

writetable(struct2table(data_table),'../data/ade_meg2R_bins.txt');