%% incorporated into ade_chanselect.m
% Selects 10 MEG channels with maximum amplitude in localizer ERFs (in each hemisphere)

clear ;

list_chan                           = 'LR';
time_window                         = [0.1 0.2]; % 100 milliseconds to 200 milliseconds

%% Maximum amplitude channels in each hemisphere

list_modality                       = {'aud','vis'};

for nm = 1:2
    
    % load planar combined data

    list_file                       = dir(['../data/*/erf/*_localizer_timelock_planar_comb_*' list_modality{nm} '*']);
 
    for ns = 1:length(list_file)
        
        fname                       = [list_file(ns).folder '/' list_file(ns).name];
        fprintf('Loading %s \n',fname);
        load(fname);
        
        % Selecting maximum amplitude channels
        for nhemi   = 1:2
            
            cfg                                         = [];
            cfg.latency                                 = time_window;
            cfg.avgovertime                             = 'yes';
            
            if strcmp(list_modality{nm},'aud')
                cfg.channel                             = {['M*' list_chan(nhemi) '*T*'],['M*' list_chan(nhemi) '*P*']};
            elseif strcmp(list_modality{nm},'vis')
                cfg.channel                             = {['M*' list_chan(nhemi) '*O*'],['M*' list_chan(nhemi) '*P*']};
            end
            
            data_avg                                    = ft_selectdata(cfg,localizer_timelock_planar_comb);
            
            vctr                                        = [[1:length(data_avg.avg)]' data_avg.avg];
            vctr_sort                                   = sortrows(vctr,2,'descend'); % sort from high to low
            
            lmt                                         = 10; % number of channels to take
            
            max_chan                                    = data_avg.label(vctr_sort(1:lmt,1));
            
            fname_out                                   = [fname(1:end-4) '_' list_chan(nhemi) 'hemi.mat'];
            save(fname_out,'max_chan');
            
            clear max_chan
            
            
        end
        
        fprintf('\n');
        
    end
end