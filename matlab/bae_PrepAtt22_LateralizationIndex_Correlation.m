clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        ext_name1               = '1t20Hz';
        ext_name2               = 'broadAreas.1t20Hz.m800p2000msCov.waveletPOW.1t19Hz.m3000p3000.KeepTrialsMinEvoked10MStep80Slct';
        
        fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.' ext_name2 '.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        lmt1            = find(round(freq.time,3) == round(-0.6,3));
        lmt2            = find(round(freq.time,3) == round(-0.2,3));
        
        bsl             = mean(freq.powspctrm(:,:,:,lmt1:lmt2),4);
        bsl             = repmat(bsl,[1 1 1 size(freq.powspctrm,4)]);
        
        freq.powspctrm  = freq.powspctrm ./ bsl ; clear bsl ;
        
        load(['../data/' suj '/field/' suj '.CnD.AgeContrast80Slct.RLNRNL.mat']);
        
        [~,~,strl_rt]      = h_new_behav_eval(suj);
        strl_rt            = strl_rt(sort([trial_array{:}]));
        
        freq               = rmfield(freq,'cumtapcnt');

        list_ix_cue        = {2,1,0};
        list_ix_tar        = {1:4,1:4,1:4};
        list_ix_dis        = {0,0,0};
        list_ix            = {'R','L','N'};
                
        for cnd = 1:length(list_ix_cue)
            
            cfg                         = [];
            cfg.trials                  = h_chooseTrial(freq,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd});
            cfg.channel                 = [7 8];
            new_freq                    = ft_selectdata(cfg,freq);
            new_freq                    = ft_freqdescriptives([],new_freq);
            
            audL                        = new_freq.powspctrm(1,:,:);
            audR                        = new_freq.powspctrm(2,:,:);
            lIdx                        = (audR-audL) ./ ((audR+audL)/2);
            
            allsuj_data{ngroup}{sb,cnd}             = new_freq;
            allsuj_data{ngroup}{sb,cnd}.label       = {'LatIndex'};
            allsuj_data{ngroup}{sb,cnd}.powspctrm   = lIdx;
            
            clear lIdx audR audL
            
        end
        
        clc;
    end
end

clearvars -except allsuj_data list_ix