% Power estimation -- FFT
% (based on channels with maxmimum amplitude of localizer trials)

% Additya-17th September,2019

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

list_chan                                           = 'LR' ;

%% Power calculation

for nsub = 1:length(sj_list)
    
    for nses = 1:length(mod)
        
        for nhemi = 1:2
            
            dir_data                                = ['/project/3015039.04/data/' sj_list{nsub} '/erf/'];
            fname                                   = [dir_data sj_list{nsub} '_localizer_timelock_planar_comb_' ...
                mod{nses} '_' list_chan(nhemi) 'hemi_maxchan' '.mat'];
            
            fprintf('Loading %s \n',fname);
            load(fname);
            all_chans(:,nhemi)                      = max_chan ;
            
            clear fname ;
        end
        
        all_chans                                   = [all_chans(:,1) ; all_chans(:,2)];
        
        
        dir_data                                    = ['/project/3015039.04/data/' sj_list{nsub} '/preprocessed/'];
        fname                                       = ([dir_data sj_list{nsub} '_secondreject_postica_' mod{nses} '.mat']) ;
        fprintf('Loading %s\n',fname);
        load(fname);
        
        % define prestimulus window of -0.5s to 0s
        cfg                                         = [];
        cfg.latency                                 = [-0.5 0];
        prestim_data                                = ft_selectdata(cfg, secondreject_postica);
        latency                                     = cfg.latency ;
        
        clear secondreject_postica cfg ;
        
        cfg                                         = [] ;
        cfg.output                                  = 'pow';
        cfg.method                                  = 'mtmfft';
        cfg.channel                                 = all_chans ;
        cfg.keeptrials                              = 'yes';
        cfg.taper                                   = 'hanning';
        cfg.pad                                     = 3 ;              % padding zeros at the beginning and end of each trial
        cfg.foi                                     = 1:1/cfg.pad:25;
        cfg.tapsmofrq                               = 0 ;
        cfg.keeptrials                              = 'yes';
        
        freq                                        = ft_freqanalysis(cfg,prestim_data);
        
        freq                                        = rmfield(freq,'cfg');

        
        dir_data                                    = ['../data/' sj_list{nsub} '/tf/'];
        fname                                       = [dir_data sj_list{nsub} '_prestim_pow_' cfg.method  '_-' ...
            num2str(abs(latency(1)*1000)) 'ms-' num2str(latency(2)) 'ms_' mod{nses} '.mat'];
        
        fprintf('Saving prestim pow at max ERF amp. chans: -0.5s to 0 s: %s\n',fname);
        
        save(fname,'freq','-v7.3');
        
        clear cfg fname all_chans ;
        
    end
end




% cfg                                         = [];
% cfg.method                                  = 'maxabs' ;
% cfg.channel                                 = allmax_chan{:};
% cfg.foi                                     = [7 15] ;                  % range for peak alpha detection (+- 1 Hz)
% 
% alpha                                       = alpha_peak(cfg,freq);
% 
% dir_data                                    = ['../data/' sj_list{nsub} '/tf/'];
% fname                                       = [dir_data sj_list{nsub} '_alphapeak_' cfg.method '_' mod{nses} '.mat'];
% 
% fprintf('Saving Alpha peak frequency and power as: %s\n',fname); save(fname,'alpha','-v7.3');
% 
% clear fname ;

% 
% for nses = 1:length(mod)
%     
%     for nsub = 1:length(sj_list)
%         dir_data                                = ['../data/' sj_list{nsub} '/tf/'];
%         fname                                   = ([dir_data sj_list{nsub} '_trialpow_lowtohigh_' mod{nses} '.mat']) ;
%         fprintf('Loading %s\n',fname);
%         load(fname);
%         
%         trialpow{nses,nsub}                     = trialpow_lowtohigh ;
%         
%         clear trialpow_lowtohigh ;
%         clear fname ;
%     end
%     
%     dir_data                                    = ['../data/'];
%     fname                                       = [dir_data 'allsub_trialpow_' mod{nses} '.mat'];
%     
%     fprintf('Saving trials sorted from low to high power based on peak alpha freq as: %s\n',fname);
%     save(fname,'trialpow','-v7.3');
%     
%     clear fname ;
%     
% end