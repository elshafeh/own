clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
       
        list_cue = {'V','N'};
        list_dis = {'DIS','fDIS'};
        
        for ncue = 1:length(list_cue)
            for ndis = 1:length(list_dis)
                
                suj                     = suj_list{sb};
                
                ext_name1               = '1t20Hz';
                ext_name2               = '.broadAuditoryAreas.50t120Hz.m200p800msCov.waveletPOW.50t119Hz.m1000p1000.KeepTrials.mat';
                
                fname_in                = ['../data/' suj '/field/' suj '.' list_cue{ncue} list_dis{ndis} ext_name2];
                
                fprintf('\nLoading %50s \n',fname_in);
                load(fname_in)
                
                freq                    = ft_freqdescriptives([],freq);
                tmp{ndis}               = freq; clear freq;
                
            end
           
            allsuj_data{ngroup}{sb,ncue}            = tmp{1};
            
            %             allsuj_data{ngroup}{sb,ncue}.powspctrm  = (tmp{1}.powspctrm - tmp{2}.powspctrm)./tmp{2}.powspctrm; clear tmp
            
            allsuj_data{ngroup}{sb,ncue}.powspctrm  = tmp{1}.powspctrm - tmp{2}.powspctrm; clear tmp
            
            cfg                                     = [];
            cfg.baseline                            = [-0.3 -0.1];
            cfg.baselinetype                        = 'relchange';
            allsuj_data{ngroup}{sb,ncue}            = ft_freqbaseline(cfg,allsuj_data{ngroup}{sb,ncue});
            
            
        end
    end
end

clearvars -except allsuj_data list*

for ngroup = 1:length(allsuj_data)
    for ncue = 1:size(allsuj_data{ngroup},2)
        
        grand_data{ngroup,ncue} = ft_freqgrandaverage([],allsuj_data{ngroup}{:,ncue});
        
    end
end

clearvars -except allsuj_data list* grand_data ;

for ngroup = 1:size(grand_data,1)
    
    figure;
    hold on;
    
    list_label = {};
    
    for ncue = 1:size(grand_data,2)
        
        cfg             = [];
        cfg.frequency   = [60 100];
        cfg.avgoverfreq = 'yes';
        dat_to_plot     = ft_selectdata(cfg,grand_data{ngroup,ncue});
        
        for nchan       = 1:length(dat_to_plot.label)
            
            plot(dat_to_plot.time,squeeze(dat_to_plot.powspctrm),'LineWidth',2)
            list_label{end+1} = [list_cue{ncue} '.' dat_to_plot.label{nchan}];
            xlim([-0.1 0.6]);
            
        end
    end
    
    legend(list_label);
    
end
