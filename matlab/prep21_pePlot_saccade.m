clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all ;

suj_list                                        = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'}; %

for sb = 1:length(suj_list)
    
    suj                                         = suj_list{sb};
    fname_in                                    = ['../data/paper_data/' suj '.CnD.eog.mat'];
    
    fprintf('Loading %s\n',fname_in);
    load(fname_in);
    
    cfg                                         = [];
    cfg.toilim                                  = [-0.6 1.5];
    data_elan                                   = ft_redefinetrial(cfg,data_elan);
    
    cfg                                         = [];
    cfg.bpfilter                                = 'yes';
    cfg.bpfreq                                  = [0.5 20];
    data_elan                                   = ft_preprocessing(cfg,data_elan);
    
    Fs                                          = 600;
    tblock                                      = round(data_elan.time{1}(1)) * Fs;
    tblock                                      = repmat(tblock,length(data_elan.trial),1);
    trl                                         = [data_elan.sampleinfo tblock data_elan.trialinfo];
    
    load(['../data/paper_data/' suj '.CnD.eog.reject.mat']);
    
    trl(:,5)                                    = 0;
    
    for nsac = 1:size(artifact_EOG,1)
        trl(trl(:,1) == artifact_EOG(nsac,1) & trl(:,2) == artifact_EOG(nsac,2),5) = 1;
    end
    
    nmat                                    = 1:size(trl,1);
    trl                                     = [trl nmat'];
    
    list_ix_cue                             = {0,1,2};
    list_ix_tar                             = {1:4,1:4,1:4};
    list_ix_dis                             = {0,0,0};
    list_ix_name                            = {'NCue','LCue','RCue'};
    
    for ncue = 1:length(list_ix_cue)
        
        ix_trials                           = h_chooseTrial(data_elan,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
        ix_count                            = trl(ix_trials,:);
        ix_bad                              = ix_count(ix_count(:,5)==1,6);
        
        if length(ix_bad) ~= 0
            cfg                                 = [];
            cfg.trials                          = ix_bad;
            allsuj_data{sb,ncue}                = ft_timelockanalysis(cfg,data_elan);
        else
            allsuj_data{sb,ncue}                = allsuj_data{1,1};
            allsuj_data{sb,ncue}.avg(:)         = 0;
        end
        
    end
end

clearvars -except allsuj_data

for ncue = 1:3
    grand_average{ncue} = ft_timelockgrandaverage([],allsuj_data{:,ncue});
end

clearvars -except allsuj_data grand_average

for nchan = 1:2
    
    subplot(1,2,nchan)
    hold on
    
    for ncue = 1:3
        
        plot(grand_average{ncue}.time,grand_average{ncue}.avg(nchan,:));
        
    end
end