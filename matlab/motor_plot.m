clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));


[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);
lst_group           = {'allyoung'};

for nf = 1
    
    for ngroup = 1:length(lst_group)
        
        suj_list = suj_group{ngroup};
        
        for sb = 1:length(suj_list)
            
            suj                     = suj_list{sb};
            cond_main               = 'CnD';
            
            frq_list                = {'1t20Hz'};
            
            ext_name1               = frq_list{nf};
            
            if strcmp(ext_name1,'20t50Hz')
                ext_name2               = '20t48Hz';
            elseif strcmp(ext_name1,'1t20Hz')
                ext_name2               = '1t19Hz';
            elseif strcmp(ext_name1,'50t120Hz')
                ext_name2               = '50t118Hz';
            end
            
            fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.MotoROIs.' ext_name1 '.m800p2000msCov.waveletPOW.' ext_name2 '.m3000p3000.KeepTrials.mat'];
            
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            list_ix_cue        = {0:2};
            list_ix_tar        = {1:4};
            list_ix_dis        = {0};
            list_ix            = {''};
            
            for cnd = 1:length(list_ix_cue)
                
                cfg                         = [];
                cfg.trials                  = h_chooseTrial(freq,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd});
                new_freq                    = ft_selectdata(cfg,freq); clear freq ;
                new_freq                    = ft_freqdescriptives([],new_freq);
                
                cfg                          = [];
                cfg.baseline                 = [-0.6 -0.2];
                cfg.baselinetype             = 'relchange';
                new_freq                     = ft_freqbaseline(cfg, new_freq);
                
                
                for nchan = 1:length(new_freq.label)
                    allsuj_data{ngroup}{sb,cnd,nchan}            = new_freq;
                    allsuj_data{ngroup}{sb,cnd,nchan}.powspctrm  = new_freq.powspctrm(nchan,:,:);
                    allsuj_data{ngroup}{sb,cnd,nchan}.label      = new_freq.label(nchan);
                end
                
                clear new_freq cfg
                
            end
        end
    end
    
    %     big_freq{nf} = allsuj_data; clear allsuj_data ;
    
end

clearvars -except allsuj_data big_freq

% for ngroup = 1:length(allsuj_data})
%     for sb = 1:size(big_freq{1}{1},1)
%         for cnd = 1:size(big_freq{1}{1},2)
%             for nchan = 1:size(big_freq{1}{1},3)
%                 
%                 cfg             = [];
%                 cfg.parameter   = 'powspctrm';
%                 cfg.appendim    = 'freq';
%                 
%                 allsuj_data{ngroup}{sb,cnd,nchan} = ft_appendfreq(cfg,big_freq{1}{ngroup}{sb,cnd,nchan}) ;
%                 
%             end
%         end
%     end
% end

clearvars -except allsuj_data big_freq

for ngroup = 1:length(allsuj_data)
    for cnd = 1:size(allsuj_data{ngroup},2)
        for nchan = 1:size(allsuj_data{ngroup},3)
            
            grand_average{ngroup,cnd,nchan} = ft_freqgrandaverage([],allsuj_data{ngroup}{:,cnd,nchan});
            
        end
    end
end

clearvars -except allsuj_data big_freq grand_average

save('../data_fieldtrip/allyoungcontrolCnDRama3CovFreqAppend.mat','grand_average');

for ngroup = 1:size(grand_average,1)
    
    i = 0;
    
    for ncue = 1:size(grand_average,2)
        
        
        for nchan = 1:size(grand_average,3)
   
            i = i + 1;
            
            subplot(3,2,i)
            zlim        = 0.2;
            
            cfg         = [];
            cfg.xlim    = [-0.2 1.8];
            cfg.ylim    = [7 15];
            cfg.zlim    = [-zlim zlim];
            ft_singleplotTFR(cfg,grand_average{ngroup,ncue,nchan});
            
            vline(0,'--k')
            vline(1.2,'--k')
            
            set(gca,'fontsize', 18)

            
            
            
        end
    end
end
