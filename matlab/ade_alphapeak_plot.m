% Plots alpha peak frequencies for each subjects

%%
clear;

% adding Fieldtrip path
fieldtrip_path                                      = '/project/3015039.04/fieldtrip-20190618';
addpath(fieldtrip_path); ft_defaults ;

%% Subject details
mod                                                 = input('Enter modality {aud/vis}: ');
nm                                                  = 1 ; 
if strcmp(mod{:},'aud')
    sj_list                                         = input('Enter subject list for AUDITORY - {sub00x...}: ');
    
else if strcmp(mod{:},'vis')
        sj_list                                     = input('Enter subject list for VISUAL - {sub00x...}: '); % sj_list={'sub004','sub006','sub007','sub008','sub009','sub010','sub012','sub013'};
    end
end
    
    subplot(1,2,nm)
    hold on
%     
    for ns = 1:length(sj_list)
        
         dir_data                                    = ['../data/' sj_list{ns} '/tf/'];
         fname                                       = [dir_data sj_list{ns} '_prestim_pow_mtmfft_-500ms-0ms_' mod{nm} '.mat'] ;
         fprintf('Loading %s \n',fname);
         load(fname)
        
        cfg                                          = [];
        cfg.avgoverchan                              = 'yes';
        cfg.avgoverrpt                               = 'yes';
        dataplot                                     = ft_selectdata(cfg,freq);
        dataplot.label                               = {'chanavg'};
        
        data_sub{ns}                                 = dataplot; clear dataplot;
        
%         suj                                          = strsplit(list_file(ns).name,'_');
%         suj                                          = suj{1};
       
        dir_data                                    = ['../data/' sj_list{ns} '/tf/'];
        fname_alpha                                 = [dir_data sj_list{ns} '_peakalpha_' mod{nm} '.mat'] ;
        fprintf('Loading peak alpha %s \n',fname_alpha);
        load (fname_alpha);
        
        data_peak{ns}                           = apeak;
      
        fprintf('\n');
        
    end


% clearvars -except data_* list_modality;
close all;

% for nm = 1:length(data_sub)
    
%     subplot(1,2,nm)
    hold on;
    
    for ns = 1:length(data_sub)
        
        dataplot    = data_sub{ns};
        plot(dataplot.freq,dataplot.powspctrm,'color',[0.8 0.8 0.8],'LineWidth',0.5);
        clear dataplot;
        
        x           = data_peak{ns}(1);
        y           = data_peak{ns}(1);
        
        plot(x,y,'-o',...
            'LineWidth',0.5,...
            'MarkerSize',5,...
            'MarkerEdgeColor',[0.7,0.7,0.7],...
            'MarkerFaceColor',[0.7,0.7,0.7])
        
    end
    
    dataplot       = ft_freqgrandaverage([],data_sub{:});
    plot(dataplot.freq,dataplot.powspctrm,'black','LineWidth',3);
    title(upper(mod{nm}));
    
    ylim([0 1e-26]);
    
% end