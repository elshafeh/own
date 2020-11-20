clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

load ../data_fieldtrip/template/template_grid_0.5cm.mat

summary_array = {};
ix            = 0;

for sb = 1:21
    
    suj = ['yc' num2str(sb)];
    
    cond_main = {''};
    list_time = {'p100p300'};
    list_freq = {'.60t100Hz','1.60t100Hz','2.60t100Hz'};
    
    ext_sorce = '.dpssFixedCommonDicSourceMinEvoked0.5cm.mat';
    
    list_ix_cue                 = 0:2;
    list_ix_tar                 = 1:4;
    list_ix_dis                 = 1;
    [dis1_median,dis1_mean,~,~] = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
    
    list_ix_dis                 = 2;
    [dis2_median,dis2_mean,~,~] = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
    
    list_ix_dis                 = 0;
    [dis0_median,dis0_mean,~,~] = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
    
    list_ix_cue                 = [1 2];
    list_ix_tar                 = 1:4;
    list_ix_dis                 = 0;
    [inf_median,inf_mean,~,~]   = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
    
    list_ix_cue                 = 0;
    [unf_median,unf_mean,~,~]   = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
    
    for cnd_cue = 1:length(cond_main)
        for ntime = 1:length(list_time)
            for nfreq = 1:length(list_freq)
                
                fname = ['../data/' suj '/field/' suj '.' cond_main{cnd_cue} 'fDIS' list_freq{nfreq} '.' list_time{ntime} ext_sorce];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                bsl_source            = source; clear source
                
                fname = ['../data/' suj '/field/' suj '.' cond_main{cnd_cue} 'DIS' list_freq{nfreq} '.' list_time{ntime} ext_sorce];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                act_source                                        = source; clear source
                pow                                               = act_source-bsl_source;
                final_source{cnd_cue,ntime,nfreq}                 = pow ;
                
                clear act_source bsl_source pow
                
            end
        end
    end
    
    list_index = {'TD_BU_index'};
    
    for nindex = 1:length(list_index)
        
        load(['../data_fieldtrip/index/' list_index{nindex} '.mat']);
        
        for nroi = 1:length(list_H)
            
            ix                           = ix+1;
            
            summary_array{ix,1}          = suj;
            summary_array{ix,2}          = list_H{nroi};
            
            summary_array{ix,3}          = dis2_median - dis1_median;
            summary_array{ix,4}          = dis2_mean - dis1_mean;
            
            summary_array{ix,5}          = unf_median - inf_median;
            summary_array{ix,6}          = unf_mean - inf_mean ;
            
            summary_array{ix,7}          = dis0_median - dis1_median;
            summary_array{ix,8}          = dis0_mean - dis1_mean ;
            
            ix_stop                      = 8;
            
            for cnd_cue = 1:length(cond_main)
                for ntime = 1:length(list_time)
                    for nfreq = 1:length(list_freq)
                        
                        ix_stop                     = ix_stop + 1;
                        mini_source                 = nanmean(final_source{cnd_cue,ntime,nfreq}(index_H(index_H(:,2) == nroi,1)));
                        
                        summary_array{ix,ix_stop}   = mini_source;
                        
                    end
                end
            end
            
        end
    end
end

clearvars -except summary_array ;

list_table                  = {'SUB','ROI','medianCapture','meanCapture','medianTD','meanTD','medianArousal','meanArousal','disGamma','dis1Gamma','dis2Gamma'};
summary_table               = array2table(summary_array,'VariableNames',list_table);

writetable(summary_table,'../documents/4R/AllyoungControl_DisCorrelation4R_SchaefOnly.csv','Delimiter',';')