clear;

global ft_default
ft_default.spmversion = 'spm12';

[~,allsuj,~]                    = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}                    = allsuj(2:15,1);
suj_group{2}                    = allsuj(2:15,2);

load ../../data/template/template_grid_0.5cm.mat

i                               = 0;

for ngroup = 1:length(suj_group)
    
    suj_list                    = suj_group{ngroup};
    list_group                  = {'elderly','young'};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        list_freq               = '.60t100Hz';
        list_time               = 'p100p300';
        
        ext_name                = '.dpssFixedCommonDicSourceMinEvoked0.5cm.mat';
        dir_data                = '../../data/dis_source/';
        
        fname                   = [dir_data  suj '.fDIS' list_freq '.' list_time ext_name];
        fprintf('Loading %50s\n',fname);
        load(fname);
        
        bsl_source              = source; clear source
        
        fname                   = [dir_data  suj '.DIS' list_freq '.' list_time ext_name];
        fprintf('Loading %50s\n',fname);
        load(fname);
        
        act_source              = source; clear source
        
        pow                     = (act_source-bsl_source);%./ bsl_source;
        
        load ag2rev_mask.mat;
        
        %         pow(isnan(pow))         = 0;
        %         pow                     = pow .* corr_mask;
        %         pow                     = mean(pow(pow ~= 0));
        
        pow                     = pow(find(corr_mask==1));
        pow                     = nanmean(pow);
        
        i                       = i +1;
        all_braindata(i,1)      = pow;
        
        load(['../../data/virt_data/' suj '.virt4corr.mat'])
        
        all_braindata(i,2)      = data(1);
        all_braindata(i,3)      = data(2);
        all_braindata(i,4)      = data(3); clear data;
        
        behav_table             = h_behavdis_eval(suj);
        behav_table             = behav_table(behav_table.CORR==1,:);
        
        inf_mdin                = median(table2array(behav_table(behav_table.DIS ==0 & behav_table.CUE >0,11)));
        unf_mdin                = median(table2array(behav_table(behav_table.DIS ==0 & behav_table.CUE ==0,11)));
        
        dis1_mdin               = median(table2array(behav_table(behav_table.DIS ==1,11)));
        dis2_mdin               = median(table2array(behav_table(behav_table.DIS ==2,11)));
        
        all_rtdata(i,1)         = unf_mdin - inf_mdin;
        all_rtdata(i,2)         = dis2_mdin - dis1_mdin;
        
        clear act_source bsl_source pow
        
        tmp_group{i}            = list_group{ngroup};
        
    end
end

clearvars -except all_rtdata all_braindata suj_group tmp_group

DataTable.subject               = [suj_group{1};suj_group{2}];
DataTable.group                 = tmp_group';
DataTable.lpfc_gamma        	= all_braindata(:,1);
DataTable.vis_alpha          	= all_braindata(:,2);
DataTable.aud_alpha          	= all_braindata(:,3);
DataTable.mot_alpha          	= all_braindata(:,4);
DataTable.capture               = all_rtdata(:,2);
DataTable.cue_benefit       	= all_rtdata(:,1);

DataTable                       = struct2table(DataTable);

writetable(DataTable,'../../documents/4JASP/data_multip_regression.txt');
writetable(DataTable,'../../documents/4JASP/data_multip_regression.csv')