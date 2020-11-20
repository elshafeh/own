clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}        = allsuj(16:end,1);
suj_group{2}        = allsuj(16:end,2); clear allsuj;

fOUT                = '../documents/4R/patient_behavioral_performance.txt';
fid                 = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','SUB','GROUP','CUE_CAT','DIS','TAR_SIDE','MedianRT', ... 
    'PerCorrect','PerFA','PerMiss','CUE_ORIGINAL','LAT_LESION','PerIncorrect');

[~,pat_info,~]      = xlsread('../documents/patient_info.xlsx','A:H');
pat_info            = pat_info(2:end,[1 8]);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        fprintf('Handling %s\n',suj);
        
        list_ix_cue         = {0,0,1,2};
        
        if length(list_ix_cue)>3
            
            list_ix_target      = {[1 3],[2 4],[1 3],[2 4]};
            
            list_cue            = {'uninformative','uninformative','informative','informative'};
            list_cue_cat        = {'left_target','right_target','left_target','right_target'};
            list_cue_orig       = {'NCue','NCue','LCue','RCue'};
            
        else
            
            list_ix_target      = {1:4,1:4,1:4};
            
            list_cue            = {'uninformative','informative','informative'};
            list_cue_cat        = {'lr_target','left_target','right_target'};
            list_cue_orig       = {'NCue','LCue','RCue'};
            
            
        end
        
        if ngroup == 1
            list_cue_grop       = [pat_info{sb,2} '_lesion'];
        else
            list_cue_grop       = 'nonapp';
        end
        
        list_group          = {'patient','control'};
        
        for ncue = 1:length(list_ix_cue)
            for ndis = 1:3
                
                [med_rt,~,perc_corr,~,~,perc_miss,perc_fa,per_incorr] =  h_behav_eval(suj,list_ix_cue{ncue},ndis-1,list_ix_target{ncue}); clc ;
                
                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.2f\t%.2f\t%.2f\t%.2f\t%s\t%s\t%.2f\n',suj,list_group{ngroup},list_cue{ncue},['D' num2str(ndis-1)], ... 
                    list_cue_cat{ncue},med_rt,perc_corr,perc_fa,perc_miss,list_cue_orig{ncue},list_cue_grop,per_incorr);
                
            end
        end
    end
end

fclose(fid);

clearvars -except allsuj_data allsuj_behav lst_* ; clc ;