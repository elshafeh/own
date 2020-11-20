clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);
% suj_list            = [suj_group{1};suj_group{2}]; %;suj_group{3}];
% suj_list            = unique(suj_list);
% suj_list = {'yc3','yc6','yc8','yc9','yc17','yc20','yc21'};
% suj_list   = {'yc21'};

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list       = suj_list(2:22);

for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb};
    
    for cond_main           = {'nDT'}
        
        ext_name            = '.NewAVBroad.50t120Hz.m400p800msCov';
        fname_in            = ['../data/' suj '/field/' suj '.' cond_main{:} ext_name '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        load(['../data/' suj '/field/' suj '.CnD.100Slct.RLNRNL.mat']); 
        %         load(['../data/' suj '/field/' suj '.CnD.AgeContrast80Slct.RLNRNL.mat']);
        
        cfg             = [];
        cfg.trials      = sort([trial_array{:}]);
        virtsens        = ft_selectdata(cfg,virtsens);
        
        virtsens        = h_transform_data(virtsens,{[1 3 5],[2 4 6],[7 9 11],[8 10 12]},{'occ_L','occ_R','aud_L','aud_R'});
        
        cond_ix_sub     = {'NL','NR'};
        
        cond_ix_cue     = {0,0};
        
        cond_ix_dis     = {0,0};
        
        cond_ix_tar     = {[1 3],[2 4]};
        
        for ncue = 1:length(cond_ix_sub)
            
            cfg                             = [];
            
            cfg.trials                      = h_chooseTrial(virtsens,cond_ix_cue{ncue},cond_ix_dis{ncue},cond_ix_tar{ncue});
            
            sub_virtsens                    = ft_selectdata(cfg,virtsens);
            
            sub_virtsens                    = h_removeEvoked(sub_virtsens);
            
            fname_out                       = [suj '.' cond_ix_sub{ncue} cond_main{:} ext_name];
            
            freq                            = in_function_computeTFR(sub_virtsens,suj,fname_out,'wavelet','pow','no',7,4,-2.5:0.01:2.5,50:120,'MinEvoked10MStep100Slct');
            
            clear sub_virtsens
            
        end
        
        clear virtsens
        
    end
end