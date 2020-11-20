% Alpha peak calculation ; Binning ; Plotting

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

%% Peak alpha and binning of noisy trials

for ns = 1:length(sj_list)
    
    dir_data                                    = ['../data/' sj_list{ns} '/tf/'];
    fname                                       = [dir_data sj_list{ns} '_prestim_pow_mtmfft_-500ms-0ms_' mod{nm} '.mat'] ;
        
    fprintf('Loading %s \n',fname);
    load(fname);
    
    cfg                                         = [];
    cfg.method                                  = 'maxabs' ;
    cfg.channel                                 = freq.label;
    cfg.foi                                     = [7 15];
    apeak                                       = alpha_peak(cfg,freq);
    apeak                                       = apeak(1);
    
    dir_data                                    = ['../data/' sj_list{ns} '/tf/'];
    fname_alpha                                 = [dir_data sj_list{ns} '_peakalpha_' mod{nm} '.mat'] ;
    fprintf('Saving peak alpha %s \n',fname_alpha);
    save (fname_alpha, 'apeak') ;

    bnwidth                                     = 1;
    
    % binning only noisy trials
    cfg                                         = [];
    cfg.foi                                     = [apeak-bnwidth apeak+bnwidth]; % alpha peak for the subject and modlaity
    cfg.channel                                 = 'all';
    cfg.bin                                     = 10;
    cfg.trials                                  = find(freq.trialinfo(:,3) == 1); % noisy trials from trial info
    bins                                        = prepare_bin(cfg,freq);
    
    list_name                                   = {};
    
        for nb = 1:size(bins,2)
    
        flg                             = freq.trialinfo(bins(:,nb),[6 7 8]);
        flg                             = flg(~isnan(flg(:,1)) & ~isnan(flg(:,2)) & ~isnan(flg(:,3)),:);
        
        lngth                           = size(flg,1);
        
        perc_corr                       = sum(flg(:,1))/lngth; % corr
        perc_conf                       = sum(flg(:,2))/lngth; % conf
        med_rt                          = median(flg(:,3)); % rt
        
        data_sub{nm}(ns,nb,1)           = perc_corr;
        data_sub{nm}(ns,nb,2)           = perc_conf;
        
        list_var                        = {'corr','conf'};
        list_name{end+1}                = ['B' num2str(nb)];
    
        clear flg lngth perc_corr perc_conf med_rt ;
        
        end
        
        fprintf('\n');
        clear bins fname freq ;
    
end

%% Bin plots
ix              = 0;

for nv = 1:2
        
        ix              = ix+1;
        subplot(1,2,ix);
        
        vct_to_plot     = squeeze(data_sub{nm}(:,:,nv));
        nb_suj          = size(vct_to_plot,1);
        
        mean_to_plot    = mean(vct_to_plot,1);
        sem_to_plot     = std(vct_to_plot,[],1)/sqrt(nb_suj); % calculate sem
        
        hold on
        
        errorbar(mean_to_plot,sem_to_plot,'-s','MarkerSize',10,'MarkerEdgeColor','red','MarkerFaceColor','red')
        
        xticks(0:length(list_name)+1)
        xticklabels([{''} list_name {''}]);
        xlim([0 length(list_name)+1]);
        
        list_ylim       = [0.6 0.9;0.2 0.7;1 1.6];
        
        ylim(list_ylim(nv,:));
        
        title([mod{nm} ' ' list_var{nv} ' n=' num2str(nb_suj)]);
        
    end
