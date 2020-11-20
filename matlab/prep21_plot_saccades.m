clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all ;

suj_list                                        = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'}; %
tot_number                                      = zeros(14,3);


for sb = 1:length(suj_list)
    
    suj                                         = suj_list{sb};
    fname_in                                    = ['../data/paper_data/' suj '.CnD.eog.mat'];
    
    %     mkdir(['/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/images/saccade_count/' suj '/'])
    
    fprintf('Loading %s\n',fname_in);
    load(fname_in);
    
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
    
    nmat                                    = 1:size(trl,1);
    trl                                     = [trl nmat'];
    
    list_ix_cue                             = {0,1,2};
    list_ix_tar                             = {1:4,1:4,1:4};
    list_ix_dis                             = {0,0,0};
    list_ix_name                            = {'NCue','LCue','RCue'};
    
    for ncue = 1:length(list_ix_cue)
        
        %         mkdir(['/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/images/saccade_count/' suj '/' list_ix_name{ncue} '/'])
        
        ix_trials                           = h_chooseTrial(data_elan,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
        
        ix_count                            = trl(ix_trials,:);
        ix_bad                              = ix_count(ix_count(:,5)==1,6);
        
        tot_number(sb,ncue)                 = length(ix_bad);
        
        figure;
        %         hold on;
        
        for nsac = 1:length(ix_bad)
            
            subplot(7,3,nsac)
            data_to_plot                    = data_elan.trial{ix_bad(nsac)}(1,:);
            %             data_to_plot                    = (data_to_plot-mean(data_to_plot))/mean(data_to_plot(1));
            data_to_plot                    = (data_to_plot-data_to_plot(1))/data_to_plot(1);
            
            plot(data_elan.time{1},data_to_plot);
            xlim([data_elan.time{1}(1) data_elan.time{1}(end)]);
            
            %             saveas(gcf,['../images/saccade_count/' suj '/' list_ix_name{ncue} '/sac_no_' num2str(nsac) '.png'])
            %             close all;
            
        end
        
        title([suj ' ' list_ix_name{ncue}]);
        
    end
end

clearvars -except tot_number