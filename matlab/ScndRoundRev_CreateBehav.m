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
    
    list_ix_cue                 = 0:2;
    list_ix_tar                 = 1:4;
    list_ix_dis                 = 1;
    [dis1_median,Z,~,~]         = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
    
    list_ix_dis                 = 2;
    [dis2_median,~,~,~]         = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
    
    list_ix_dis                 = 1:2;
    [alldis_median,~,~,~]       = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
    
    list_ix_dis                 = 0;
    [dis0_median,~,~,~]         = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
    
    list_ix_cue                 = [1 2];
    list_ix_tar                 = 1:4;
    list_ix_dis                 = 0;
    [inf_median,~,~,~]          = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
    
    list_ix_cue                 = 0;
    [unf_median,~,~,~]          = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
   
    save(['../../data/scnd_round/' suj '.behav.mat'],'dis1_median','dis2_median','alldis_median','dis0_median','inf_median','unf_median')
    
    clear dis1_median dis2_median alldis_median dis0_median inf_median unf_median list_*
    
end