clear ; clc ;

% patient_list;
% suj_group{1}                = fp_list_all;
% suj_group{2}                = cn_list_all;
% suj_group{1}                = {'oc1','oc2','oc3','oc4','oc5','oc6','oc7','oc8','oc9','oc10','oc11','oc12','oc13','oc14'};
% suj_group{2}                = {'yc1','yc10','yc11','yc4','yc18','yc21','yc7','yc19','yc15','yc14','yc5','yc13','yc16','yc12'};

[~,suj_list,~]              = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
[~,allsuj,~]                = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}                = suj_list(2:22);
% suj_group{1}                = [suj_group{1};allsuj(2:end,1); allsuj(2:end,2)];

fOUT                        = '../documents/4R/behav_allparticipants.txt';
fid                         = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','SUB','GROUP','CUE_CAT','DIS','TAR_SIDE','MedianRT','PerCorrect','PerFA','PerMiss','CUE_ORIGINAL','CUE_GROUPED','PerIncorrect');

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        fprintf('Handling %s\n',suj);
        
        %         list_cue            = {'uninformative','uninformative','informative','informative'};
        list_cue            = {'neutral','neutral','valid','valid'};
        list_cue_cat        = {'left_target','right_target','left_target','right_target'};
        
        list_cue_orig       = {'NCue','NCue','LCue','RCue'};
        list_cue_grop       = {'NL','NR','L','R'};
        
        list_group          = {'prep22'};
        
        list_ix_cue         = {0,0,1,2};
        list_ix_target      = {[1 3],[2 4],[1 3],[2 4]};
        
        for ncue = 1:length(list_ix_cue)
            for ndis = 1:3
                
                [med_rt,~,perc_corr,~,~,perc_miss,perc_fa,per_incorr] =  h_behav_eval(suj,list_ix_cue{ncue},ndis-1,list_ix_target{ncue});
                
                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.2f\t%.2f\t%.2f\t%.2f\t%s\t%s\t%.2f\n',suj,list_group{ngroup},list_cue{ncue},['D' num2str(ndis-1)], ... 
                    list_cue_cat{ncue},med_rt,perc_corr,perc_fa,perc_miss,list_cue_orig{ncue},list_cue_grop{ncue},per_incorr);
                
            end
        end
    end
end

fclose(fid);
clearvars -except allsuj_data allsuj_behav lst_* ; clc ;