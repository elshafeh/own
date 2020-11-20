clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all ;

fOUT = '../documents/4R/prep21_saccade_count.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\n','SUB','CUE','PERC_SAC');

suj_list = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'}; %

for sb = 1:length(suj_list)
    
    suj                                     = suj_list{sb};
    fname_in                                = ['../data/paper_data/' suj '.CnD.eog.mat'];
    
    fprintf('Loading %s\n',fname_in);
    load(fname_in);
    
    cfg                                     = [];
    cfg.toilim                              = [-0.6 1.5];
    data_elan                               = ft_redefinetrial(cfg,data_elan);
    
    Fs                                      = 600;
    tblock                                  = round(data_elan.time{1}(1)) * Fs;
    tblock                                  = repmat(tblock,length(data_elan.trial),1);
    trl                                     = [data_elan.sampleinfo tblock data_elan.trialinfo];
    
    load(['../data/paper_data/' suj '.CnD.eog.reject.mat']);
    
    trl(:,5)                                 = 0;
    
    for nsac = 1:size(artifact_EOG,1)
        trl(trl(:,1) == artifact_EOG(nsac,1) & trl(:,2) == artifact_EOG(nsac,2),5) = 1;
    end
    
    if length(trl(trl(:,5)==1,1)) ~= size(artifact_EOG,1)
        error('wrong number of saccades!');
    end
    
    list_ix_cue                             = {0,1,2};
    list_ix_tar                             = {1:4,1:4,1:4};
    list_ix_dis                             = {0,0,0};
    list_ix_name                            = {'NCue','LCue','RCue'};
    
    for ncue = 1:length(list_ix_cue)
        
        ix_trials                           = h_chooseTrial(data_elan,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
        ix_count                            = trl(ix_trials,5);
        
        ix_bad                              = length(find(ix_count==1));
        ix_per                              = (ix_bad/length(ix_count))*100;
        
        fprintf(fid,'%s\t%s\t%.2f\n',suj,list_ix_name{ncue},ix_per);
        
    end
end

fclose(fid);