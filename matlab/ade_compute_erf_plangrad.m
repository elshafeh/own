% Event related fields, MEG planar gradient,combine planar gradient, plotting
% Additya- 4th September,2019
%%
clear ; clc ; clearvars ;

% adding Fieldtrip path
fieldtrip_path                                 = '/project/3015039.04/fieldtrip-20190618';
addpath(fieldtrip_path); ft_defaults ;

sj_list                                        = {'sub017'};
md_list                                        = {'aud'};

%% Erf and planar gradient
for nsuj = 1:length(sj_list)
    for nmod = 1:length(md_list)
        
        % loading second rejection data
        dir_data                                   = ['../data/' sj_list{nsuj} '/preprocessed/'];
        fname                                      = [dir_data sj_list{nsuj} '_secondreject_postica_' md_list{nmod} '.mat'];
        fprintf('loading %s \n',fname);  load(fname);
        
        cfg                                        = [];
        cfg.demean                                 = 'yes';
        cfg.baselinewindow                         = [-0.2 0]; % baseline correction
        cfg.lpfilter                               = 'yes'; % low pass filter
        cfg.lpfreq                                 = 30;
        dataFilt                                   = ft_preprocessing(cfg,secondreject_postica);
        
        % ERF - All trials
        erf_alltrials                              = ft_timelockanalysis([],dataFilt);
        
        dir_data                                   = ['../data/' sj_list{nsuj} '/erf/'];
        fname                                      = [dir_data sj_list{nsuj} '_erf_alltrials_' md_list{nmod} '.mat'];
        fprintf('saving %s \n',fname); save(fname,'erf_alltrials','-v7.3');
        
        clear secondreject_postica; clear erf_alltrials ;
        
        % Selecting localizer trials
        trials                                     = dataFilt.trialinfo(:,3) ; % extracts trial noise from .trialinfo
        trials                                     = num2str(trials);
        localizer_trials                           = find(trials == '0'); % finds true index of localizer trials
        localizer_trials                           = localizer_trials';% 1xN form for input to cfg for ft_selectdata
        
        % selecting localizer data
        cfg                                        = [];
        cfg.channel                                = 'MEG';
        cfg.trials                                 = localizer_trials;
        localizer_data                             = ft_selectdata(cfg,dataFilt) ;
        
        % ERF- Localizer
        erf_localizer                              = ft_timelockanalysis([],localizer_data);
        
        dir_data                                   = ['../data/' sj_list{nsuj} '/erf/'];
        fname                                      = [dir_data sj_list{nsuj} '_erf_localizer_' md_list{nmod} '.mat'];
        fprintf('saving %s \n',fname); save(fname,'erf_localizer','-v7.3');
        
        % Planar gradient
        cfg                                        = [];
        cfg.feedback                               = 'yes';
        cfg.method                                 = 'template';
        cfg.neighbours                             = ft_prepare_neighbours(cfg, erf_localizer);
        close all ;
        
        cfg.planarmethod                           = 'sincos';
        localizer_timelock_planar                  = ft_megplanar(cfg, erf_localizer);
        
        dir_data                                   = ['../data/' sj_list{nsuj} '/erf/'];
        fname                                      = [dir_data sj_list{nsuj} '_localizer_timelock_planar_' md_list{nmod} '.mat'];
        fprintf('saving %s \n',fname);
        save(fname,'localizer_timelock_planar','-v7.3');
        
        clear fname ; clear erf_localizer ;
        
        % Combine planar gradient
        cfg                                        = [];
        localizer_timelock_planar_comb             = ft_combineplanar(cfg,localizer_timelock_planar);
        
        dir_data                                   = ['../data/' sj_list{nsuj} '/erf/'];
        fname                                      = [dir_data sj_list{nsuj} '_localizer_timelock_planar_comb_' md_list{nmod} '.mat'];
        fprintf('saving %s \n',fname);
        save(fname,'localizer_timelock_planar_comb','-v7.3');
        
        clear secondreject_postica dataFilt erf_localizer localizer_data localizer_trials ...
            fname dir_data fname localizer_timelock_planar_comb localizer_timelock_planar ;
        
    end
end

%% Plots

% loading planar combined data
for nsub = 1:length(sj_list)
    for nses = 1:length(md_list)
        
        dir_data                        = ['../data/' sj_list{nsub} '/erf/'];
        fname                           = [dir_data sj_list{nsub} '_localizer_timelock_planar_comb_' md_list{nses} '.mat'];
        
        fprintf('Loading %s \n',fname);
        load(fname);
        
        data_plots{nsub}                = localizer_timelock_planar_comb;
        
        clear localizer_timelock_planar_comb ;
        
    end
end

i    = 0 ;
figure
subplot(2,4,size((data_plots)',1))

% plotting
for nsub = 1:size((data_plots)',1)
    for nses = 1:length(md_list)
        
        cfg                                         = [];
        cfg.layout                                  = 'CTF275_helmet.mat';
        cfg.xlim                                    = [0 0.2];
        cfg.ylim                                    = [-1e-13 1.5e-13];
        cfg.zlim                                    = 'maxabs' ;
        cfg.marker                                  = 'off';
        cfg.comment                                 = 'no';
        cfg.colorbar                                = 'no';
        
        i                                           = i +1;
        
%         subplot(2,4,i)
        ft_topoplotER(cfg, data_plots{nsub});
        
        title([sj_list{nsub} ' ' md_list{nses}]);
        sgtitle([md_list{nses} '-Localizer ERFs'])
    end
end
