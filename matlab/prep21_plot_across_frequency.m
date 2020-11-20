clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
suj_group       = suj_group(1:2);

% suj_group{1} = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        ext_name2               = 'AV.1t20Hz.M.1t40Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked'; %AllYc4Roisexplor.1t20Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked';

        list_ix                 = {'R','L','N'};
        
        for ncue = 1:length(list_ix)
            
            fname_in                = ['../data/ageing_data/' suj '.' list_ix{ncue} cond_main '.' ext_name2 '.mat'];
            
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            %             for nchan = 1:length(freq.label)
            %                 freq.label{nchan} = [freq.label{nchan}(1:3) '_' freq.label{nchan}(end)];
            %             end
            
            cfg                                     = [];
            
            % --- %
            cfg.baseline                            = [-0.6 -0.2];
            % --- %
            
            cfg.baselinetype                        = 'relchange';
            freq                                    = ft_freqbaseline(cfg,freq);
            
            allsuj_data{ngroup}{sb,ncue}            = freq;
            %             allsuj_data{ngroup}{sb,ncue}.suj        = suj;
            
            
            clear new_freq cfg
            
        end
    end
end

clearvars -except allsuj_data list_ix

for ngroup = 1:length(allsuj_data)
    for ncue = 1:size(allsuj_data{ngroup},2)
        
        grand_average{ngroup,ncue}              = ft_freqgrandaverage([],allsuj_data{ngroup}{:,ncue});
        cfg                                     = [];
        cfg.latency                             = [0.6 1];
        cfg.avgovertime                         = 'yes';
        grand_average{ngroup,ncue}              = ft_selectdata(cfg,grand_average{ngroup,ncue});
        
    end
end

clearvars -except allsuj_data list_ix grand_average

figure;
i = 0;

for nchan = [3 4]
    
    for ngroup = 1:size(grand_average,1)
        
        i = i +1;
        subplot(2,2,i);
        hold on;
        
        for ncue = 1:size(grand_average,2)
            
            data = squeeze(grand_average{ngroup,ncue}.powspctrm(nchan,:,:));
            plot(round(grand_average{ngroup,ncue}.freq),data,'LineWidth',2); xlim([7 15]); ylim([-0.2 0.2]);
            
        end
        
        list_group   ={'old','young'};
        
        title([grand_average{ngroup,ncue}.label{nchan} ' ' list_group{ngroup}]);
        legend(list_ix);
        
    end
end