%% Selects 10 MEG channels with max amp. in localizer ERFs (in each hemisphere)
% Additya- 13th September

%%
clear ; clc ; clearvars ;

% adding Fieldtrip path
fieldtrip_path                                     = '/project/3015039.04/fieldtrip-20190618';
addpath(fieldtrip_path); ft_defaults ;

mod                                                = input('Enter modality {aud/vis}: ');
if strcmp(mod{:},'aud')
    sj_list                                        = input('Enter subject list for AUDITORY - {sub00x...}: ');
else if strcmp(mod{:},'vis')
        sj_list                                    = input('Enter subject list for VISUAL - {sub00x...}: ');
    end
end

% aud subs  = {'sub004','sub006','sub007','sub008','sub009','sub010','sub012','sub013','sub015','sub016','sub018'};
% vis subs  = {'sub004','sub005','sub006','sub007','sub008','sub010','sub012','sub013','sub015','sub017'};

list_chan                                          = 'LR';
time_window                                        = [0.1 0.2]; % 100 milliseconds to 200 milliseconds

%% Maximum amp. channels in each hemisphere

% load planar combined data
for nsub = 1:length(sj_list)
    nses = 1 ;
    dir_data                                       = ['../data/' sj_list{nsub} '/erf/'];
    fname                                          = [dir_data sj_list{nsub} '_localizer_timelock_planar_comb_' mod{nses} '.mat'];
    
    fprintf('Loading %s \n',fname);
    load(fname);
    
    % Selecting maximum amplitude channels
    for nhemi   = 1:2
        cfg                                        = [];
        cfg.latency                                = time_window;
        cfg.avgovertime                            = 'yes';
        
        if strcmp(mod{nses},'aud')
            cfg.channel                            = {['M*' list_chan(nhemi) '*T*'],['M*' list_chan(nhemi) '*P*']};
        else if strcmp(mod{nses},'vis')
                cfg.channel                        = {['M*' list_chan(nhemi) '*O*'],['M*' list_chan(nhemi) '*P*']};
            end
        end
        
        data_avg                                   = ft_selectdata(cfg,localizer_timelock_planar_comb);
        
        vctr                                       = [[1:length(data_avg.avg)]' data_avg.avg];
        vctr_sort                                  = sortrows(vctr,2,'descend'); % sort from high to low
        
        lmt                                        = 10; % number of channels to take
        
        max_chan                                   = data_avg.label(vctr_sort(1:lmt,1));
        
        fname_out                                  = [fname(1:end-4) '_' list_chan(nhemi) 'hemi_maxchan.mat'];
        save(fname_out,'max_chan');
        
        clear max_chan ;
    end
    
    clear localizer_timelock_planar_comb ;
    
end
