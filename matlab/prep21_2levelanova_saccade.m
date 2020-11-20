clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all ;

suj_list        = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'}; %

saccade_matrix  = [0 3 3 0 1 0;
    8 5 6 5 10 4;
    0 1 2 0 1 0
    13 4 16 5 5 5
    0 0 0 0 0 1
    2 2 4 4 9 2
    8 3 4 2 10 0
    6 3 6 7 9 6
    2 0 3 1 3 3
    0 1 0 1 0 2
    7 7 10 3 7 6
    1 1 0 1 2 1
    2 2 4 2 2 1
    4 1 3 0 2 2];

fOUT = '../documents/4R/prep21_saccade_count2level.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\n','SUB','CUE','DIRECTION','PERC_SAC');

for sb = 1:length(suj_list)
    
    suj                                         = suj_list{sb};
    
    fname_in                                    = ['../data/paper_data/' suj '.CnD.eog.mat'];
    
    fprintf('Loading %s\n',fname_in);
    load(fname_in);
    
    list_direction                              = {'right_to_left','left_to_right'};
    list_cues                                   = {'LCue','NCue','RCue'};
    
    cfg                                         = [];
    cfg.toilim                                  = [-0.6 1.5];
    data_elan                                   = ft_redefinetrial(cfg,data_elan);
    
    Fs                                          = 600;
    tblock                                      = round(data_elan.time{1}(1)) * Fs;
    tblock                                      = repmat(tblock,length(data_elan.trial),1);
    trl                                         = [data_elan.sampleinfo tblock data_elan.trialinfo];
    
    load(['../data/paper_data/' suj '.CnD.eog.reject.mat']);
    
    trl(:,5)                                    = 0;
    
    for nsac = 1:size(artifact_EOG,1)
        trl(trl(:,1) == artifact_EOG(nsac,1) & trl(:,2) == artifact_EOG(nsac,2),5) = 1;
    end
    
    list_ix_cue                             = {1,0,2};
    list_ix_tar                             = {1:4,1:4,1:4};
    list_ix_dis                             = {0,0,0};
    
    i_count                                  = 0;
    
    for ncue = 1:3
        
        ix_trials                           = h_chooseTrial(data_elan,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
        ix_count                            = trl(ix_trials,5);
        
        for ndir = 1:2
            
            i_count                         = i_count + 1;
            
            ix_bad                          = saccade_matrix(sb,i_count);
            ix_per                          = (ix_bad/length(ix_count))*100;
            
            fprintf(fid,'%s\t%s\t%s\t%.2f\n',suj,list_cues{ncue},list_direction{ndir},ix_per);
            
        end
    end
end

fclose(fid);