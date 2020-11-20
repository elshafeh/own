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

for nm = 1:length(data_sub)
    
    list_name               = {};
    data_bin                = [];
    
    test_results            = [];
    
    for ns = 1:size(data_sub{nm},1)
        
        data_bin(ns,1,:)    = data_sub{nm}{ns,2}.perc_corr;
        data_bin(ns,2,:)    = data_sub{nm}{ns,2}.perc_conf;
        
    end
    
    i                       = 0;
    list_test               = {};
    
    for irow = 1:6
        for icol = 1:6
            
            if irow ~= icol
                
                for nv = 1:2
                    
                    x                           = data_bin(:,nv,irow);
                    y                           = data_bin(:,nv,icol);
                    
                    [h,p]                       = ttest(x,y);
                    
                    list_vct                    = {'corr','conf'};
                    
                    if p < 0.1
                        
                        i                       = i +1;
                        
                        test_results(i,1)       = h; 
                        test_results(i,2)       = p; 
                        
                        list_test{i}            = [list_modality{nm} ' ' list_vct{nv} ' B' num2str(irow)   ' v B' num2str(icol)];
                        
                        clear x y h p
                        
                    end
                    
                end
                
            end
            
        end
    end
    
end

clearvars -except data_* list_* test_results