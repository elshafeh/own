clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_group{1}(2:22);

% suj_list                                    = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for sb = 18:length(suj_list)
    
    suj                                     = suj_list{sb};
    
    for cond_main                           = {'fDIS','DIS'}
        
        for ext_name                        = {'BroadAudSep5perc.1t20Hz.m200p800msCov','BroadAudSep5perc.50t110Hz.m200p800msCov','BroadAudSep5perc.1t110Hz.m200p800msCov'}
            
            dir_data                        = '/Volumes/hesham_megabup/pat22_fieldtrip_data/';
            
            fname_in                        = [dir_data suj '.' cond_main{:} '.' ext_name{:} '.mat'];
            
            fprintf('Loading %s\n',fname_in);
            load(fname_in)
            
            list_ix_cue                         = {0:2,0:2,0:2};
            list_ix_tar                         = {1:4,1:4,1:4};
            list_ix_dis                         = {1:2,1,2};
            list_ix_name                        = {'','1','2'};
            
            for ncue = 1:length(list_ix_name)
                
                cfg                             = [];
                cfg.trials                      = h_chooseTrial(virtsens,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
                sub_virtsens                    = ft_selectdata(cfg,virtsens);
                
                fname_out                       = ['../data/dis_virt_data/' suj '.' list_ix_name{ncue} cond_main{:} '.' ext_name{:}];
                
                name_parts                      = strsplit(ext_name{:},'.');
                name_parts                      = strsplit(name_parts{2},'t');
                freq_low                        = str2double(name_parts{1});
                freq_high                       = strsplit(name_parts{2},'Hz');
                freq_high                       = str2double(freq_high{1});

                freq                            = in_function_computeTFR(sub_virtsens,fname_out,'wavelet','pow', ... 
                    'no',7,4,-1:0.01:1,freq_low:freq_high,'yes'); %% !!
                
            end
        end
    end
end
%                 cfg                             = [];
%                 cfg.method                      = 'mtmfft';
%                 cfg.output                      = 'pow';
%                 cfg.taper                       = 'hanning';
%                 cfg.foi                         = 1:20;
%                 cfg.tapsmofrq                   = 0.1;
%                 freq                            = ft_freqanalysis(cfg,sub_virtsens);
%                 freq                            = rmfield(freq,'cfg');
%                 name_ext_tfr                    = [cfg.method upper(cfg.output)];
%                 name_ext_time                   = 'm3000p3000';
%                 name_ext_freq                   = [num2str(round(cfg.foi(1))) 't' num2str(round(cfg.foi(end))) 'Hz'];
%                 name_ext_trials                 = 'AvgTrialsMinEvokedOnlyMotor';