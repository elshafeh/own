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
        
        cond_main                           = {''};
        
        for cnd_cue = 1:length(cond_main)
            
            suj                             = suj_list{sb};
            
            list_freq                       = {'.60t100Hz'};
            list_time                       = {'p100p300'};
            
            for ntime = 1:length(list_time)
                for nfreq = 1:length(list_freq)
                    
                    ext_name                = '.dpssFixedCommonDicSourceMinEvoked0.5cm.mat';
                    dir_data                = '../../data/dis_source/';
                    
                    fname                   = [dir_data  suj '.' cond_main{cnd_cue} 'fDIS' list_freq{nfreq} '.' list_time{ntime} ext_name];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    bsl_source              = source; clear source
                    
                    fname                   = [dir_data  suj '.' cond_main{cnd_cue} 'DIS' list_freq{nfreq} '.' list_time{ntime} ext_name];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    act_source              = source; clear source
                    
                    pow                                                         = act_source-bsl_source ;
                    pow(isnan(pow))                                             = 0;
                    
                    load ag2rev_mask.mat;
                    
                    pow                                                         = pow .* corr_mask;
                    pow                                                         = mean(pow(pow ~= 0));
                    
                    i                                                           = i +1;
                    alldata(i,1)                                                = pow;
                    
                    behav_table                                                 = h_behavdis_eval(suj);
                    behav_table                                                 = behav_table(behav_table.CORR==1,:);
                    
                    dis1_mean                                                   = mean(table2array(behav_table(behav_table.DIS ==1,11)));
                    dis1_mdin                                                   = median(table2array(behav_table(behav_table.DIS ==1,11)));

                    dis2_mean                                                   = mean(table2array(behav_table(behav_table.DIS ==2,11)));
                    dis2_mdin                                                   = median(table2array(behav_table(behav_table.DIS ==2,11)));
                    
                    alldata(i,2)                                                = dis2_mean - dis1_mean;
                    alldata(i,3)                                                = dis2_mdin - dis1_mdin;

                    clear act_source bsl_source pow
                    
                end
            end
        end
    end
end

clearvars -except alldata

[rho2,pval2]                                                                      = corr(alldata(:,1),alldata(:,3),'Type','Pearson');
[rho4,pval4]                                                                      = corr(alldata(:,1),alldata(:,3),'Type','Spearman');