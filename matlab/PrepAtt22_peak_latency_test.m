clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
suj_group      = suj_group(1:2);

fOUT = '../documents/4R/ageing_all_roi_latency_test.txt';

fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','MOD','HEMI','LATENCY');

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                                 = suj_list{sb};
        
        dir_data                            = '../data/ageing_data/';
        
        fname_in                            = [dir_data suj '.CnD.AV.1t20Hz.M.1t40Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked.mat'];
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        cfg                                 = [];
        cfg.baseline                        = [-0.6 -0.2];
        cfg.baselinetype                    = 'relchange';
        freq                                = ft_freqbaseline(cfg,freq);
        
        cfg                                 = [];
        cfg.latency                         = [0.6 1];
        freq                                = ft_selectdata(cfg,freq);
        
        %     lmt1                                = find(round(freq.time,3) == round(0.6,3));
        %     lmt2                                = find(round(freq.time,3) == round(1,3));
        
        
        for nchan = 1:6

            
            if nchan < 3
                
                lmf1                                = find(round(freq.freq) == round(11));
                lmf2                                = find(round(freq.freq) == round(15));
                
                pow                                 = freq.powspctrm(nchan,lmf1:lmf2,:);
                pow                                 = squeeze(pow);
                pow                                 = mean(pow,1);
                
                lat                                 = freq.time(find(pow == max(pow)));
                
            else
                
                lmf1                                = find(round(freq.freq) == round(7));
                lmf2                                = find(round(freq.freq) == round(11));
                
                pow                                 = freq.powspctrm(nchan,lmf1:lmf2,:);
                pow                                 = squeeze(pow);
                pow                                 = mean(pow,1);
                
                lat                                 = freq.time(find(pow == min(pow)));
                
            end
            
            list_group                      = {'old','young'};
            name_chan                       = freq.label{nchan};
            
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.2f\n',list_group{ngroup},suj,'CnD',name_chan(1:3),[name_chan(end) 'Hemi'],lat);
            
        end
    end
end

fclose(fid);