clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all ;

suj_list = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'}; %

for sb = 1 %:length(suj_list)
    
    suj                                     = suj_list{sb};
    fname_in                                = ['../data/paper_data/' suj '.CnD.eog.mat'];
    
    fprintf('Loading %s\n',fname_in);
    load(fname_in);
    
    list_ix_cue                             = {0:2};
    list_ix_tar                             = {1:4};
    list_ix_dis                             = {0};
    list_ix_name                            = {''};
    
    %     cfg                                     = [];
    %     cfg.demean                              = 'yes';
    %     cfg.detrend                             = 'yes';
    %     data_elan                               = ft_preprocessing(cfg,data_elan);
    
    cfg                                     = [];
    cfg.toilim                              = [-0.6 1.5];
    data_elan                               = ft_redefinetrial(cfg,data_elan);
    
    for ncue = 1:length(list_ix_cue)
        
        ix_trials                           = h_chooseTrial(data_elan,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
        
        cfg                                 = [];
        cfg.trials                          = ix_trials;
        data_select                         = ft_selectdata(cfg,data_elan);
        
        Fs                                  = 600;
        
        %         data_select.sampleinfo              = data_elan.sampleinfo(ix_trials,:);
        %         data_select.sampleinfo(:,1)         = data_select.sampleinfo(:,1) + ((3-0.2)*600);
        %         data_select.sampleinfo(:,2)         = data_select.sampleinfo(:,2) - ((3-2)*600);
        
        tblock                              = round(data_select.time{1}(1)) * Fs;
        tblock                              = repmat(tblock,length(data_select.trial),1);
        
        trl                                 = [data_select.sampleinfo tblock data_select.trialinfo];
        
        cfg                                 = [];
        cfg.trl                             = trl;
        cfg.continuous                      = 'yes';
        cfg.artfctdef.zvalue.channel        = [1 2];
        cfg.artfctdef.zvalue.cutoff         = 5;
        cfg.artfctdef.zvalue.trlpadding     = 0;
        cfg.artfctdef.zvalue.artpadding     = 0.1;
        cfg.artfctdef.zvalue.fltpadding     = 0;
        
        % algorithmic parameters
        cfg.artfctdef.zvalue.bpfilter       = 'yes';
        cfg.artfctdef.zvalue.bpfilttype     = 'but';
        cfg.artfctdef.zvalue.bpfreq         = [0.5 40];
        cfg.artfctdef.zvalue.bpfiltord      = 4;
        cfg.artfctdef.zvalue.hilbert        = 'yes';
        
        % feedback
        cfg.artfctdef.zvalue.interactive    = 'yes';
        
        [cfg, artifact_EOG]                 = ft_artifact_zvalue(cfg,data_select);
        
        %         save(['../data/paper_data/' suj '.' list_ix_name{ncue} 'CnD.eog.reject.mat'],'artifact_EOG') ; clear artifact_EOG ;
        
    end
end

%     save('data.mat','data');
%
%     cfg             = [];
%     cfg.method      = 'velocity2D';
%     cfg.channel     = 'all';
%     cfg.trials      = 'all';
%     cfg.velocity2D  = [];
%     movement        = ft_detect_movement(cfg, data_elan);
%
%
%
% data            = [];
%
% for ntrial = 1:length(data_elan.trial)
%     data            = [data data_elan.trial{ntrial}];
% end
%
%     data                = data';
%
%     samplingrate        = 600; %sampling rate in Hertz
%     mspersample         = 1000/samplingrate; %milliseconds per sample
%     mytime              = [1:1:size(data,1)]'; %create column vector of length same as your data mytime=mytime*mspersample; %adjust time vector to sample rate
%     data                = [mytime data]; %attach the time column to your x and y data already stored in 'data'
%
% data_elan                       = rmfield(data_elan,'trialinfo');
% data_elan                       = rmfield(data_elan,'sampleinfo');
% data_elan                       = rmfield(data_elan,'trial');
% data_elan                       = rmfield(data_elan,'time');
%
% data(isnan(data))               = 0;
%
% data_elan.trial{1}              = data ;
% data_elan.time{1}               = 1:1:size(data,2);
% data_elan.fsample               = 600;
%
% cfg                             = [];
% cfg.trl                         = 1:length(data_elan.trial);
% cfg.continuous                  = 'yes';
% cfg.artfctdef.eog.interactive   = 'yes';
%
% channel selection, cutoff and padding
% cfg.artfctdef.eog.channel       = 'hEOG.-1';
% cfg.artfctdef.eog.cutoff        = 2.5; % z-value at which to threshold (default = 4)
% cfg.artfctdef.eog.trlpadding    = 0;
% cfg.artfctdef.eog.boxcar        = 10;
%
% conservative rejection intervals around EOG events
% cfg.artfctdef.eog.pretim        = 10; % pre-artifact rejection-interval in seconds
% cfg.artfctdef.eog.psttim        = 0; % post-artifact rejection-interval in seconds
%
% cfg                             = ft_artifact_eog(cfg, data_elan);
%
% make a copy of the samples where the EOG artifacts start and end, this is needed further down
% EOG_detected                    = cfg.artfctdef.eog.artifact;