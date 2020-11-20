clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
% suj_list      = [suj_group{1};suj_group{2}];

suj_list = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb} ;
    
    for cond_main           = {'CnD'}
        
        ext_name            = '.prep21.AV.1t20Hz.m800p2000msCov';
        
        fname_in            = ['../data/paper_data/' suj '.' cond_main{:} ext_name '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        cond_ix_sub         = {'NL','NR'};
        cond_ix_cue         = {0,0};
        cond_ix_dis         = {0,0};
        cond_ix_tar         = {[1 3],[2 4]};
        
        %         load(['../data/res/' suj '.CnD.AgeContrastEquiSlct.mat']); % cfg  = []; % cfg.trials  = [trial_array{:}]; % virtsens  = ft_selectdata(cfg,virtsens);
        
        for ncue = 1:length(cond_ix_sub)
            
            cfg                             = [];
            cfg.trials                      = h_chooseTrial(virtsens,cond_ix_cue{ncue},cond_ix_dis{ncue},cond_ix_tar{ncue});
            sub_virtsens                    = ft_selectdata(cfg,virtsens);
            
            % ---- !!!!!! ---- %
            sub_virtsens                    = h_removeEvoked(sub_virtsens);  % !!!
            % ---- !!!!!! ---- %
            
            fname_out                       = ['../data/ageing_data/' suj '.' cond_ix_sub{ncue} cond_main{:} ext_name];
            
            %             freq                            = in_function_computeTFR(sub_virtsens,fname_out,'wavelet','pow','no',7,4,-3:0.05:3,1:20,'MinEvoked');
            freq                            = in_function_computeTFR(sub_virtsens,fname_out,'wavelet','pow','no',7,4,-3:0.01:3,50:120,'MinEvoked');

            clear sub_virtsens
            
        end
        
        clear virtsens
        
    end
end