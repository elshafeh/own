clear;

global ft_default
ft_default.spmversion = 'spm12';

[~,allsuj,~]    = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

load ../../data/template/template_grid_0.5cm.mat

i               = 0;

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
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
        
        pow                     = act_source-bsl_source ;
        pow(isnan(pow))         = 0;
        
        load ag2rev_mask.mat;
        
        pow                     = pow .* corr_mask;
        pow                     = mean(pow(pow ~= 0));
        
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
        
    end
end

clearvars -except all_rtdata all_braindata

DataTable.LPFC                  = all_braindata(:,1);
DataTable.vis                   = all_braindata(:,2);
% DataTable.aud                   = all_braindata(:,3);
% DataTable.mot                   = all_braindata(:,4);
DataTable.capture               = all_rtdata(:,2);
% DataTable.cue                   = all_rtdata(:,1);

DataTable                       = struct2table(DataTable);

[R,PValue]                      = corrplot(DataTable,'type','Spearman');

% for nd = 1:4
%     for nr = 1:2
%
%         [rho(nd,nr),pval(nd,nr)] = corr(all_braindata(:,nd),all_rtdata(:,nr),'Type','Spearman');
%
%         if pval(nd,nr) < 0.05
%             figure;
%
%             DataTable.
%
%             corrplot([all_braindata(:,nd) all_rtdata(:,nr)],'type','Spearman')
%         end
%
%     end
% end