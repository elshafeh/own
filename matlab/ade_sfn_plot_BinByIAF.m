clear ; clc;

addpath(genpath('kakearney-boundedline'));

load ../data/goodsubjects-07-Oct-2019.mat;

i                                           = 0;

for nm = 1:length(list_modality)
    
    list_suj                                    = goodsubjects{nm};
    
    for ns = 1:length(list_suj)
        
        suj                                     = list_suj{ns};
        modality                                = list_modality{nm};
        
        fname                                   = ['../data/' suj '_sfn.erf_' modality '_maxchan.mat'];
        load(fname);
        fname                                   = ['../data/' suj '_sfn.fft_' modality '.mat'];
        
        fprintf('loading %s\n',fname);
        load(fname);

        cfg                                     = [];
        cfg.channel                             = max_chan;
        cfg.avgoverchan                         = 'yes';
        cfg.frequency                           = [7 15];
        freq                                    = ft_selectdata(cfg,freq);
        freq.label                              = {'avg chan'};
        
        all_peak                                = [];
        
        for ntrial = 1:length(freq.trialinfo)
            data                                = squeeze(freq.powspctrm(ntrial,:,:));
            [peak_val peak_freq]                = max(abs(data));
            all_peak                            = [all_peak;freq.freq(peak_freq)]; clear data peak_*
        end
        
        new_freq                                = freq;
        new_freq.powspctrm                      = all_peak; clear all_peak;
        new_freq.freq                           = 10;
        
        nb_bin                                  = 6;
        bn_width                                = 0;
        
        [bin_summary]                           = h_preparebins(new_freq,10,nb_bin,bn_width);
        
        data_sub{nm}{ns,1}                      = new_freq;
        data_sub{nm}{ns,2}                      = bin_summary;
        data_sub{nm}{ns,3}                      = [];
        
        for nb = 1:size(bin_summary.bins,2)
            
            i                                   = i + 1;
            
            data_table(i).suj                   = suj;
            data_table(i).mod                   = modality;
            data_table(i).bin                   = ['B' num2str(nb)];
            data_table(i).iaf                   = mean(new_freq.powspctrm(bin_summary.bins(:,nb),:,:));
            data_table(i).cor                   = bin_summary.perc_corr(nb);
            data_table(i).con                   = bin_summary.perc_conf(nb);
            data_table(i).rt                    = bin_summary.med_rt(nb);
            
            data_sub{nm}{ns,3}                  = [data_sub{nm}{ns,3} data_table(i).iaf];
            
        end
        
        clear dataplot alpha freq;
        
        fprintf('\n');
        clear bins;
        
    end
end

clearvars -except data_* list_*

list_color                  = 'gb';
ix                          = 0;
list_ylim                   = [7 15;0.65 1;0.3 1;1 2]; % [7 15;0.65 0.95;0.3 0.8;1 2];

for nm = 1:length(data_sub)
    
    list_name               = {};
    data_bin                = [];
    
    for ns = 1:size(data_sub{nm},1)
        
        data_bin(ns,1,:)    = data_sub{nm}{ns,3};
        data_bin(ns,2,:)    = data_sub{nm}{ns,2}.perc_corr;
        data_bin(ns,3,:)    = data_sub{nm}{ns,2}.perc_conf;
        data_bin(ns,4,:)    = data_sub{nm}{ns,2}.med_rt;
        
    end
    
    for nb = 1:size(data_bin,3)
        list_name{nb}       = ['B' num2str(nb)];
    end
    
    for nv = 2:4
        
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
        
        %errorbar(mean_to_plot,sem_to_plot,'-s','MarkerSize',10,'MarkerEdgeColor',list_color(nm),'MarkerFaceColor',list_color(nm))
        
        xticks(0:length(list_name)+1)
        xticklabels([{''} list_name {''}]);
        xlim([0 length(list_name)+1]);
        
        ylim(list_ylim(nv,:));
        
    end
end

writetable(struct2table(data_table),'../data/ade_meg2R_iaf.txt');