clear ; clc ;

global ft_default
ft_default.spmversion = 'spm12';

[~,allsuj,~]    = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{2}    = allsuj(2:15,1);
suj_group{1}    = allsuj(2:15,2);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                                         = suj_list{sb};
        ext_name                                    = 'CnD.AV.1t20Hz.M.1t40Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked.mat';
        list_cue                                    = {''};
        
        for ncue = 1:length(list_cue)
            
            fname_in                                = ['/Volumes/heshamshung/Fieldtripping_data_backup/ageing_data/' suj '.' list_cue{ncue} ext_name];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            cfg                                     = [];
            cfg.baseline                            = [-0.6 -0.2];
            cfg.baselinetype                        = 'relchange';
            freq                                    = ft_freqbaseline(cfg,freq);
            
            bn_width                                = 1;
            list_iaf                                = ageingrev_infunc_iaf(freq);
            data                                    = ageingrev_infunc_adjustiaf(freq,list_iaf,bn_width);
            
            data                                    = h_transform_data(data,{[1 2],[3 4],[5 6]},{'vis','aud','mot'});
            
            ix1                                     = find(round(data.time{1},2) == 0.6);
            ix2                                     = find(round(data.time{1},2) == 1);
            
            data                                    = mean(data.trial{1}(:,ix1:ix2),2);
            
            save(['../../data/virt_data/' suj '.virt4corr.mat'],'data');

        end
    end
end