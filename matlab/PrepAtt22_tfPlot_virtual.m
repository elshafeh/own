clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_cue = {'MinEvokedAvgTrials.mat','eEvokedAvgTrials.mat','avgPeTfrAvgTrials.mat'};
        
        for ncue = 1:length(list_cue)
            
            suj                 = suj_list{sb};
            
            ext_virt            = '.BroadAud5perc.1t110Hz.m2000p800msCov.waveletPOW.1t109Hz.m2000p2000.';
            dir_data            = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/'];
            
            fname_in            = [dir_data suj '.nDT'  ext_virt list_cue{ncue}];
            
            fprintf('Loading %s\n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            cfg                                 = [];
            cfg.baseline                        = [-1.6 -1.4];
            cfg.baselinetype                    = 'relchange';
            freq                                = ft_freqbaseline(cfg,freq);
            
            allsuj_activation{ngroup}{sb,ncue}  = freq; clear freq
            
        end
        
        ncue                                                = 4;
        allsuj_activation{ngroup}{sb,ncue}                  = allsuj_activation{ngroup}{sb,1};
        allsuj_activation{ngroup}{sb,ncue}.powspctrm        = allsuj_activation{ngroup}{sb,2}.powspctrm - allsuj_activation{ngroup}{sb,1}.powspctrm;
        
    end
end

clearvars -except allsuj_* list_* lst*;

i = 0 ;

for ngroup = 1:length(allsuj_activation)
    for ncue = 1:size(allsuj_activation{ngroup},2)
        
        grand_average           = ft_freqgrandaverage([],allsuj_activation{ngroup}{:,ncue});
        
        for nchan = 1:length(grand_average.label);
            
            subplot_row         = 4;
            subplot_col         = 6;
            
            i                   = i + 1 ;
            subplot(subplot_row,subplot_col,i)
            
            %             if ncue < 3
            %                 zlim            = 0.05;
            %             else
            %                 zlim            = 2.5;
            %             end
            
            zlim                = 0.1;
            
            cfg                 = [];
            cfg.channel         = nchan;
            cfg.xlim            = [-0.2 0.6];
            cfg.parameter       = 'powspctrm';
            cfg.colorbar        = 'yes';
            
            cfg.zlim            = [-zlim zlim];
            
            ft_singleplotTFR(cfg,grand_average);
            title(''); % [list_cue{ncue} ' ' grand_average.label{nchan}]);
            vline(0,'--k');
            
        end
    end
end