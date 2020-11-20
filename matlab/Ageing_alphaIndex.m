clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
suj_group      = suj_group(1:2);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                                 = suj_list{sb};
        
        dir_data                            = '../data/ageing_data/';
        
        fname_in                            = [dir_data suj '.CnD.AV.1t20Hz.M.1t40Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked.mat'];
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        freq                                = h_transform_freq(freq,{[1 2],[3 4]},{'Visual','Auditory'});
        
        vis_pow                             = freq.powspctrm(1,:,:);
        aud_pow                             = freq.powspctrm(2,:,:);
        lIdx                                = (aud_pow-vis_pow) ./ (aud_pow+vis_pow);
        
        new_freq                            = freq;
        new_freq.label                      = {'alpha_index'};
        new_freq.powspctrm                  = lIdx;
        
        list_freq                           = [7 11; 11 15];
        
        for nfreq = 1:2
            
            lmf1                                = find(round(new_freq.freq) == round(list_freq(nfreq,1)));
            lmf2                                = find(round(new_freq.freq) == round(list_freq(nfreq,2)));
            
            lmt1                                = find(round(new_freq.time,3) == round(0.6,3));
            lmt2                                = find(round(new_freq.time,3) == round(1,3));
            
            data                                = nanmean(nanmean(new_freq.powspctrm(1,lmf1:lmf2,lmt1:lmt2)));
            
            allsuj_data(ngroup,nfreq,sb)        = data; clear data ;
            
        end
    end
end

clearvars -except allsuj_data ;

figure;
hold on;

for ngroup = 1:2
    
    data        = squeeze(allsuj_data(ngroup,:,:));
    data_mean   = mean(data,2);
    data_std    = std(data');
    data_sem    = data_std/sqrt(14);
    
    errorbar(data_mean,data_sem);
    
    clear data*
    
end

legend({'Old','young'});
ylim([0 0.6])