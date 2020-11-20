clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_group{1}          = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        cond_main               = 'CnD';
        list_cue                = {''};
        
        for ncue = 1:length(list_cue)
            
            ext_name                = 'MaxAudVizMotor.BigCov.VirtTimeCourse.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked';
            
            dir_data                = '../data/paper_data/';
            
            fname_in                = [dir_data suj '.' list_cue{ncue} cond_main '.' ext_name '.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            freq    = h_transform_freq(freq,{1:2,3:4},{'visual','auditory'});

            
            %             for nchan = 1:length(freq.label)
            %                 where_under = strfind(freq.label{nchan},'_');
            %                 freq.label{nchan}(where_under) = ' ';
            %             end
            
            [tmp{1},tmp{2}]                         = h_prepareBaseline(freq,[-0.6 -0.2],[1 20],[-0.2 2],'no');
            
            allsuj_activation{ngroup}{sb,ncue}      = tmp{1};
            allsuj_baselineRep{ngroup}{sb,ncue}     = tmp{2};
            
        end
        
    end
end

clearvars -except allsuj_* list_cue;

for ngroup = 1:length(allsuj_activation)
    
    nsuj                    = size(allsuj_activation{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'virt','t'); clc;
    
    for ncue = 1:size(allsuj_activation{ngroup},2)
        
        cfg                     = [];
        cfg.clusterstatistic    = 'maxsum';
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        
        cfg.correctm            = 'cluster';
        cfg.neighbours          = neighbours;
        
        %         cfg.channel             = [3 4];
        %         cfg.latency             = [0.6 1];
        %         cfg.avgovertime         = 'yes';
        %         cfg.frequency           = [60 100];
        %         cfg.avgoverfreq         = 'yes';

        cfg.clusteralpha        = 0.05;
        cfg.alpha               = 0.025;
        cfg.minnbchan           = 0;
        cfg.tail                = 0;
        cfg.clustertail         = 0;
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        stat{ngroup,ncue}      = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        stat{ngroup,ncue}      = rmfield(stat{ngroup,ncue},'cfg');
    end
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue),p_val{ngroup,ncue}]      = h_pValSort(stat{ngroup,ncue});
    end
end

p_limit = 0.2;

figure;
i = 0;

for ngroup = 1:size(stat,1)
    for nchan = 1:length(stat{ngroup,ncue}.label)
        for ncue = 1:size(stat,2)
            
            
            stat_to_plot       = stat{ngroup,ncue};
            stat_to_plot.mask  = stat_to_plot.prob < p_limit;
            
            i = i + 1;
            
            subplot(1,2,i)
            
            [x_ax,y_ax,z_ax]                = size(stat_to_plot.stat);
            
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
                cfg.zlim            = [-5 5];
                
                ft_singleplotTFR(cfg,stat_to_plot);
                
            end
            
            title([list_cue{ncue} 'CnD ' stat_to_plot.label{nchan} ' p = ' num2str(min_p(ngroup,ncue))])
            
            colormap('jet')
            
        end
    end
end