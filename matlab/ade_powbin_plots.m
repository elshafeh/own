%% Power bin plots with behavioral responses

%%
clear ; clc ; clearvars ;

% adding Fieldtrip path
fieldtrip_path                                      = '/project/3015039.04/fieldtrip-20190618';
addpath(fieldtrip_path); ft_defaults ;

%% Subject details
mod                                                 = input('Enter modality {aud/vis}: ');
if strcmp(mod{:},'aud')
    sj_list                                         = input('Enter subject list for AUDITORY - {sub00x...}: ');
    
else if strcmp(mod{:},'vis')
        sj_list                                     = input('Enter subject list for VISUAL - {sub00x...}: '); % sj_list={'sub004','sub006','sub007','sub008','sub009','sub010','sub012','sub013'};
    end
end

%% Correct and confident response count

for nsub = 1:length(sj_list)
    for nses = 1:length(mod)
        
        dir_data                                    = ['../data/' sj_list{nsub} '/tf/'];
        fname                                       = [dir_data sj_list{nsub} '_prestim_pow_maxampchans_mtmfft_500ms-0ms_' mod{nses} '.mat'];
        
        fprintf('Loading prestimulus power- from -0.5s to 0 s: %s\n',fname);
        load (fname) ;
        
        dir_data                                    = ['../data/' sj_list{nsub} '/tf/'];
        fname                                       = [dir_data sj_list{nsub} '_bins_lowtohighpow_' mod{nses} '.mat'];
        
        fprintf('Loading bins- from low to high power- based on alpha peak %s\n',fname);
        load (fname);
        
        % counts- correct and confident responses per bin
        response_count                              = ade_corrconf_powbincalc(bins,freq);
        
        dir_data                                    = ['../data/' sj_list{nsub} '/'];
        fname                                       = [dir_data sj_list{nsub} '_behavcount_' mod{nses} '.mat'];
        
        fprintf('Saving correct and confident response count %s\n',fname);
        save(fname,'response_count');
        
        clear response_count bins freq ;
        
    end
end

%% Plots
for nsub = 1:length(sj_list)
    for nses = 1:length(mod)
        
        dir_data                                    = ['../data/' sj_list{nsub} '/'];
        fname                                       = [dir_data sj_list{nsub} '_behavcount_' mod{nses} '.mat'];
        fprintf('Loading responses %s\n',fname);
        load (fname);
        
        dir_data                                    = ['../data/' sj_list{nsub} '/tf/'];
        fname                                       = [dir_data sj_list{nsub} '_alphapeak_maxabs_' mod{nses} '.mat'];
        fprintf('Loading peak alpha freqs %s\n',fname);
        load (fname);
        
        
        responses{nsub,nses}                        = response_count ;
        
        alpha_peak{nsub,nses}                       = alpha;
        
    end
    
    clear response_count alpha ;
end