clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

lst_group       = {'Old','Young'};

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    lst_freq    = {'7t11Hz'};
    lst_time    = {'m600m200','p600p1000'};
    ext_comp    = 'dpssFixedCommonDicSource.mat';
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = {'LCnD','NLCnD','LmNLCnD'};
        
        for cnd_freq = 1:length(lst_freq)
            for cnd_time = 1:length(lst_time)
                
                
                fname = ['../data/' suj '/field/' suj '.' cond_main{1} '.' lst_freq{cnd_freq} '.' lst_time{cnd_time}   '.' ext_comp];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                bsl_source                                            = source; clear source
                
                fname = ['../data/' suj '/field/' suj '.' cond_main{2} '.' lst_freq{cnd_freq} '.' lst_time{cnd_time}   '.' ext_comp];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                act_source                                            = source; clear source
                
                source                                                = bsl_source - act_source;
                
                fname = ['../data/' suj '/field/' suj '.' cond_main{3} '.' lst_freq{cnd_freq} '.' lst_time{cnd_time}   '.' ext_comp];
                fprintf('saving %50s\n',fname);
                save(fname,'source');
                
                clear source ;
                
            end
        end
    end
end