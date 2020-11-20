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
    
    for ncond = 1:length(list_cond)
        
        fname                   = '/Volumes/heshamshung/FieldtrippingData15Feb2019/dis_rep4rev/';
        fname                   = [fname suj '.' list_cond{ncond} '.60t100Hz.p100p300.dpssFixedCommonDicSourceMinEvoked0.5cm.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        act                     = source; clear source;
        
        fname = '/Volumes/heshamshung/FieldtrippingData15Feb2019/dis_rep4rev/';
        fname = [fname suj '.f' list_cond{ncond} '.60t100Hz.p100p300.dpssFixedCommonDicSourceMinEvoked0.5cm.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        bsl                     = source; clear source;
        pow{ncond}              = act-bsl;
        
    end
    
    pow{4}          = pow{3} - pow{2};

    dis1pow         = pow{2};
    dis2pow         = pow{3};
    
    alldispow       = pow{1};
    dis2mdis1       = pow{4}; clear pow;
    
    load ../../data/index/AudTPFCAveraged.mat
    
    for nroi = 1:length(list_H)
        
        ibig                            = ibig + 1;
        
        inx                             = index_H(index_H(:,2) == nroi,1);
        
        info_table(ibig).sub            = suj;
        info_table(ibig).roi            = list_H{nroi};
        
        info_table(ibig).cuebenefit     = sbcuebenef;
        info_table(ibig).arousal        = sbarousal;
        info_table(ibig).capture        = sbcapture;
        info_table(ibig).disRT          = alldis;
        
        info_table(ibig).disPOW         = nanmean(alldispow(inx,1));
        info_table(ibig).dis2m1         = nanmean(dis2mdis1(inx,1));
        
        info_table(ibig).dis1POW        = nanmean(dis1pow(inx,1));
        info_table(ibig).dis2POW        = nanmean(dis2pow(inx,1));

        
        clear inx;
        
    end
    
    clear sbcuebenef sbarousal sbcapture alldis alldispow dis2mdis1
    
end

info_table           = struct2table(info_table);
fname_out            = '../../data/r_data/Scndround_pat22DIS_4correlation_flinecorrected.txt';
writetable(info_table,fname_out);