clear ; clc ;
addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;

global ft_default
ft_default.spmversion = 'spm12';

[~,suj_list,~]              = xlsread('../../documents/PrepAtt22_PreProcessingIndex.xlsx','A:B');
suj_list                    = suj_list(2:22,2);

ibig                        = 0;

for sb = 1:21
    
    suj                             = suj_list{sb};
    fprintf('calculating behav for %s\n',suj);
    
    list_ix_cue                     = 0:2;
    list_ix_tar                     = 1:4;
    list_ix_dis                     = 1;
    [dis1_median,~,~,~]             = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
    
    list_ix_dis                     = 2;
    [dis2_median,~,~,~]             = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
    
    list_ix_dis                     = 0;
    [dis0_median,~,~,~]             = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
    
    ibig                            = ibig + 1;
    
    if sb < 10
        suj                         = ['s0' num2str(sb)];
    else
        suj                         = ['s' num2str(sb)];
    end
    
    info_table(ibig).sub            = suj;
    
    info_table(ibig).arousal        = dis1_median-dis0_median;
    info_table(ibig).capture        = dis2_median-dis1_median;
    
end

clearvars -except info_table;

info_table           = struct2table(info_table);
fname_out            = '../../data/r_data/Scndround_BehavEffectVar.txt';
writetable(info_table,fname_out);