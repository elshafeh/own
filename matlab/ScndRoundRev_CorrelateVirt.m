clear ; clc ;
addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;

global ft_default
ft_default.spmversion = 'spm12';

[~,suj_list,~]              = xlsread('../../documents/PrepAtt22_PreProcessingIndex.xlsx','A:B');
suj_list                    = suj_list(2:22,2);
ibig                        = 0;

for sb = 1:21
    
    suj                     = suj_list{sb};
    list_cond               = {'DIS','DIS1','DIS2'};
    
    fprintf('calculating behav for %s\n',suj);
    
    load(['../../data/scnd_round/' suj '.behav.mat']);
    
    sbcuebenef                  = unf_median-inf_median;
    sbarousal                   = dis0_median-dis1_median;
    sbcapture                   = dis2_median-dis1_median;
    alldis                      = alldis_median;
    
    clear *_median
    
    list_categ                  = {'broadband','narrowband'};
    list_name{1}                = 'AudTPFC.1t120Hz.m200p800msCov.waveletPOW.40t120Hz.m1000p1000.10Mstep.AvgTrials.MinEvoked';
    list_name{2}                = 'AudTPFCAveraged.40t120Hz.m200p800msCov.waveletPOW.40t120Hz.m1000p1000.10Mstep.AvgTrials.MinEvoked';
    
    for nbroad  = 1:2
        
        for ncond = 1:length(list_cond)
            
            fname                   = '../../data/scnd_round/';
            fname                   = [fname suj '.' list_cond{ncond} '.' list_name{nbroad} '.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            act                     = freq.powspctrm;
            
            fname                   = '../../data/scnd_round/';
            fname                   = [fname suj '.f' list_cond{ncond} '.' list_name{nbroad} '.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            bsl                     = freq.powspctrm;
            pow{ncond}              = act-bsl;
            
        end
        
        pow{4}              = pow{3} - pow{2};
        
        dis1pow             = pow{2};
        dis2pow             = pow{3};
        
        alldispow           = pow{1};
        dis2mdis1           = pow{4}; clear pow;
        
        fwin                = 40;
        fstart              = 60;
        fend                = 90;
        
        for nfreq = fstart:fwin:fend
            for nroi = 1:length(freq.label)
                
                ibig                            = ibig + 1;
                
                info_table(ibig).sub            = suj;
                info_table(ibig).roi            = freq.label{nroi};
                info_table(ibig).filter         = list_categ{nbroad};
                
                if1                             = find(round(freq.freq) == nfreq);
                if2                             = find(round(freq.freq) == nfreq+fwin);
                
                it1                             = find(round(freq.time,2) == round(0.1,2));
                it2                             = find(round(freq.time,2) == round(0.3,2));

                info_table(ibig).cuebenefit     = sbcuebenef;
                info_table(ibig).arousal        = sbarousal;
                info_table(ibig).capture        = sbcapture;
                info_table(ibig).disRT          = alldis;
                
                info_table(ibig).disPOW         = mean(mean(alldispow(nroi,if1:if2,it1:it2)));
                info_table(ibig).dis2m1         = mean(mean(dis2mdis1(nroi,if1:if2,it1:it2)));
                
                info_table(ibig).dis1POW        = mean(mean(dis1pow(nroi,if1:if2,it1:it2)));
                info_table(ibig).dis2POW        = mean(mean(dis2pow(nroi,if1:if2,it1:it2)));
                
                
            end
        end
    end
    
    
end

info_table           = struct2table(info_table);
fname_out            = '../../data/r_data/Scndround_pat22DIS_4correlation_VirtualCorrected.txt';
writetable(info_table,fname_out);