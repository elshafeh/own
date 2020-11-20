clear ; clc ;

[~,allsuj,~]                    = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{2}                    = allsuj(2:15,1);
suj_group{1}                    = allsuj(2:15,2);

lst_group                       = {'Young','Old'};

fOUT                        = '../../documents/4R/ageing_normalizedRT.txt';
fid                         = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','SUB','GROUP','CUE_CAT','DIS','TAR_SIDE','MedianRT','PerCorrect','PerFA','PerMiss','CUE_ORIGINAL','CUE_GROUPED','PerIncorrect');

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        fprintf('Handling %s\n',suj);
        
        [all_rt,~,~,~,~,~,~,~]  =  h_behav_eval(suj,0:2,0:3,1:4);
        
        list_cue                = {'uninformative','informative'};
        list_cue_cat            = {'uninformative','informative'};
        
        list_cue_orig           = {'NCue','VCue'};
        list_cue_grop           = {'N','V'};
        
        list_group              = {'Young','Old'};
        
        list_ix_cue             = {0,[1 2]};
        list_ix_target          = {1:4,1:4};
        
        for ncue = 1:length(list_ix_cue)
            for ndis = 1:3
                
                [med_rt,~,perc_corr,~,~,perc_miss,perc_fa,per_incorr]   = h_behav_eval(suj,list_ix_cue{ncue},ndis-1,list_ix_target{ncue});
                med_rt                                                  = med_rt/all_rt;
                
                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.2f\t%.2f\t%.2f\t%.2f\t%s\t%s\t%.2f\n',suj,list_group{ngroup},list_cue{ncue},['D' num2str(ndis-1)], ... 
                    list_cue_cat{ncue},med_rt,perc_corr,perc_fa,perc_miss,[list_cue_cat{ncue} '_' list_group{ngroup}],list_cue_grop{ncue},per_incorr);
                
            end
        end
        
        clear all_Rt;
        
    end
end

fclose(fid);
clearvars -except allsuj_data allsuj_behav lst_* ; clc ;