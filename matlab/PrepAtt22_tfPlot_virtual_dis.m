clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_dis = {'fDIS','DIS'};
        list_cue = {'MinEvokedAvgTrials.mat','eEvokedAvgTrials.mat','avgPeTfrAvgTrials.mat'};
        
        for ncue = 1:length(list_cue)
            
            for cnd_dis = 1:length(list_dis)
                
                suj                 = suj_list{sb};
                
                ext_virt            = '.BroadAud5perc.1t110Hz.m200p400msCov.waveletPOW.1t109Hz.m200p600.';
                dir_data            = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/'];
                
                fname_in            = [dir_data suj '.' list_dis{cnd_dis} ext_virt list_cue{ncue}];
                
                fprintf('Loading %s\n',fname_in);
                load(fname_in)
                
                if isfield(freq,'check_trialinfo')
                    freq = rmfield(freq,'check_trialinfo');
                end
                
                tmp{cnd_dis}        = freq; clear freq;
                
            end
            
            allsuj_activation{ngroup}{sb,ncue}              = tmp{2};
            act                                             = tmp{2}.powspctrm;
            bsl                                             = tmp{1}.powspctrm;
            
            allsuj_activation{ngroup}{sb,ncue}.powspctrm    = (act-bsl)/3e21; % (act-bsl)./bsl;  % clear act bsl tmp;
            
        end
    end
end

clearvars -except allsuj_* list_* lst*;

i = 0 ;

for ngroup = 1:length(allsuj_activation)
    for ncue = 1:size(allsuj_activation{ngroup},2)
        
        grand_average           = ft_freqgrandaverage([],allsuj_activation{ngroup}{:,ncue});
        
        for nchan = 1:length(grand_average.label);
            
            subplot_row         = 3;
            subplot_col         = 6;
            
            i                   = i + 1 ;
            subplot(subplot_row,subplot_col,i)
            
            cfg                 = [];
            cfg.channel         = nchan;
            cfg.xlim            = [-0.1 0.4];
            cfg.ylim            = [3 109];
            cfg.parameter       = 'powspctrm';
            cfg.colorbar        = 'yes';
            
            if ncue < 3
                zlim            = 0.5;
            else
                zlim            = 5;
            end
            
            %             zlim                = 2;
            cfg.zlim            = [-zlim zlim];
            ft_singleplotTFR(cfg,grand_average);
            title(''); % [list_cue{ncue} ' ' grand_average.label{nchan}]);
            
        end
    end
end


%             list_ix            = {''};
%             list_grp           = {'AllYun'};
%
%             title(s2plot.label{nchan})
%
%             i                               = i + 1 ;
%             subplot(subplot_row,subplot_col,i)
%             data = squeeze(mean(s2plot.stat(nchan,:,:),2)) .* squeeze(mean(s2plot.mask(nchan,:,:),2));
%             plot(s2plot.time,data,'LineWidth',2);
%             xlim([s2plot.time(1) s2plot.time(end)])
%             ylim([0 3])
%             title('Avg Over Frequency','FontSize',14);
%
%             i                               = i + 1 ;
%             subplot(subplot_row,subplot_col,i)
%             data = squeeze(mean(s2plot.stat(nchan,:,:),3)) .* squeeze(mean(s2plot.mask(nchan,:,:),3));
%             plot(s2plot.freq,data,'LineWidth',2);
%             xlim([s2plot.freq(1) s2plot.freq(end)])
%             ylim([0 1.5])
%             title('Avg Over Time','FontSize',14);