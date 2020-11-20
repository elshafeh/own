clear ; clc ;

addpath(genpath('../fieldtrip-20151124/'));
addpath('DrosteEffect-BrewerMap-b6a6efc/');

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);
% load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
% suj_group      = suj_group(3);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_dis = {'fDIS','DIS'};
        list_cue = {'MinEvokedAvgTrials.mat'};
        
        for ncue = 1:length(list_cue)
            for cnd_dis = 1:length(list_dis)
                
                suj                 = suj_list{sb};
                
                ext_virt            = '.broadAudSchTPJMniPF.1t110Hz.m200p800msCov.waveletPOW.25t120Hz.m200p600.';
                dir_data            = '../data/post_ol_conn_data/';
                
                fname_in            = [dir_data suj '.' list_dis{cnd_dis} ext_virt list_cue{ncue}];
                
                fprintf('Loading %s\n',fname_in);
                load(fname_in)
                
                if isfield(freq,'check_trialinfo')
                    freq = rmfield(freq,'check_trialinfo');
                end
                
                allsuj_activation{ngroup}{sb,ncue,cnd_dis}            = freq; clear freq;
                
            end
        end
    end
end

clearvars -except allsuj_* list_* lst*;

for ngroup = 1:length(allsuj_activation)
    
    nsuj                    = size(allsuj_activation{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'virt','t'); clc;
    
    for ncue = 1:size(allsuj_activation{ngroup},2)
        
        cfg                     = [];
        cfg.clusterstatistic    = 'maxsum';
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        
        cfg.correctm            = 'cluster';
        
        cfg.frequency           = [60 100];
        cfg.avgoverfreq         = 'yes';
        
        %         cfg.latency             = [0.1 0.3];
        %         cfg.avgovertime         = 'yes';

        cfg.clusteralpha        = 0.05;
        
        cfg.alpha               = 0.025;
        
        cfg.neighbours          = neighbours;
        cfg.minnbchan           = 0;
        
        cfg.tail                = 1; !
        cfg.clustertail         = 1; !
        
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        stat{ngroup,ncue}      = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue,2},allsuj_activation{ngroup}{:,ncue,1});
        stat{ngroup,ncue}      = rmfield(stat{ngroup,ncue},'cfg');
    end
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue),p_val{ngroup,ncue}] = h_pValSort(stat{ngroup,ncue});
    end
end

i = 0 ;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        stat_to_plot          = stat{ngroup,ncue};
        stat_to_plot.mask     = stat_to_plot.prob < 0.12;
        
        for nchan = 1:length(stat_to_plot.label);
            
            subplot_row         = 3;
            subplot_col         = 4;
            
            i                   = i + 1 ;
            subplot(subplot_row,subplot_col,i)
            
            [x_ax,y_ax,z_ax]    = size(stat_to_plot.stat);
            
            if y_ax == 1
                
                plot(stat_to_plot.time,squeeze(stat_to_plot.mask(nchan,:,:) .* stat_to_plot.stat(nchan,:,:)));
                ylim([-3 3]);
                xlim([stat_to_plot.time(1) stat_to_plot.time(end)])
                
            elseif z_ax == 1
                
                plot(stat_to_plot.freq,squeeze(stat_to_plot.mask(nchan,:,:) .* stat_to_plot.stat(nchan,:,:)));
                ylim([-3 3]);
                xlim([stat_to_plot.freq(1) stat_to_plot.freq(end)])
                
            else
                
                cfg                 = [];
                cfg.channel         = nchan;
                cfg.parameter       = 'stat';
                cfg.maskparameter   = 'mask';
                cfg.maskstyle       = 'outline';
                cfg.maskalpha       = 0.6;
                cfg.zlim            = [-5 5];
                cfg.colorbar        = 'no';
                ft_singleplotTFR(cfg,stat_to_plot);
                
                colormap(brewermap(256, '*RdYlBu'));
                
            end
            
            title([list_cue{ncue} ' ' stat_to_plot.label{nchan}]);
            
        end
    end
end

%
% list_ix            = {''};
% list_grp           = {'AllYun'};
%
% title(s2plot.label{nchan})
%
% i                               = i + 1 ;
% subplot(subplot_row,subplot_col,i)
% data = squeeze(mean(s2plot.stat(nchan,:,:),2)) .* squeeze(mean(s2plot.mask(nchan,:,:),2));
% plot(s2plot.time,data,'LineWidth',2);
% xlim([s2plot.time(1) s2plot.time(end)])
% ylim([0 3])
% title('Avg Over Frequency','FontSize',14);
%
% i                               = i + 1 ;
% subplot(subplot_row,subplot_col,i)
% data = squeeze(mean(s2plot.stat(nchan,:,:),3)) .* squeeze(mean(s2plot.mask(nchan,:,:),3));
% plot(s2plot.freq,data,'LineWidth',2);
% xlim([s2plot.freq(1) s2plot.freq(end)])
% ylim([0 1.5])
% title('Avg Over Time','FontSize',14);