clear ; clc ; 

[~,allsuj,~]    = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_list        = [allsuj(2:15,1);allsuj(2:15,2)];


for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb} ;
    
    for cond_main           = {'CnD'}
        
        ext_name            = '.AV.1t20Hz.M.1t40Hz.m800p2000msCov';
        
        fname_in            = ['/Volumes/heshamshung/Fieldtripping6Dec2018/data/ageing_data/' suj '.' cond_main{:} ext_name '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        cond_ix_sub         = {'V'};
        cond_ix_cue         = {[1 2]};
        cond_ix_dis         = {0};
        cond_ix_tar         = {1:4};
        
        for ncue = 1:length(cond_ix_sub)
            
            cfg                             = [];
            cfg.trials                      = h_chooseTrial(virtsens,cond_ix_cue{ncue},cond_ix_dis{ncue},cond_ix_tar{ncue});
            sub_virtsens                    = ft_selectdata(cfg,virtsens);
            
            % ---- !!!!!! ---- %
            % ---- !!!!!! ---- %
            sub_virtsens                    = h_removeEvoked(sub_virtsens);  % !!!
            % ---- !!!!!! ---- %
            % ---- !!!!!! ---- %
            
            fname_out                       = ['../../data/ageing_data/' suj '.' cond_ix_sub{ncue} cond_main{:} ext_name];
            
            freq                            = in_function_computeTFR(sub_virtsens,fname_out,'wavelet','pow','no',7,4,-3:0.05:3,1:20,'yes');

            clear sub_virtsens
            
        end
        
        clear virtsens
        
    end
end