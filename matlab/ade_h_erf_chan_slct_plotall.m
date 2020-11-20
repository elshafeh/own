%% Plots ERF over each hemisphere - based on max chans (grandavg ; topoplots ; single plots)

clear; close all;

list_modality                           = {'aud','vis'};
list_hemi                               = {'Lhemi','Rhemi'};

for nm = 1:2
    
    list_file                           = dir(['../data/*/erf/*_localizer_timelock_planar_comb_*' list_modality{nm} '.mat']);
    
    for ns = 1:length(list_file)
        
        fname               = [list_file(ns).folder '/' list_file(ns).name];
        fprintf('Loading %s \n',fname);
        load(fname);
        
        for nh = 1:2
            
            fname_hemi                  = [fname(1:end-4) '_' list_hemi{nh} '_maxchan.mat'];
            fprintf('Loading %s \n',fname_hemi);
            load(fname_hemi);
            
            cfg                         = [];
            cfg.channel                 = max_chan;
            cfg.avgoverchan             = 'yes';
            data_sub{nm}{ns,nh}         = ft_selectdata(cfg,localizer_timelock_planar_comb);
            
            data_sub{nm}{ns,nh}.label  = {'chanavg'};
            
        end
        
        fprintf('\n');
        
    end
end

clearvars -except data_sub list_modality list_hemi;

ix                                      = 0;

for nm = 1:2
    for nh = 1:2
        
        ix                              = ix+1;
        subplot(2,2,ix)
        hold on
        
        for ns = 1:size(data_sub{nm},1)
            dataplot                    = data_sub{nm}{ns,nh};
            plot(dataplot.time,dataplot.avg,'color',[0.8 0.8 0.8],'LineWidth',0.5)
        end
        
        dataplot                        = ft_timelockgrandaverage([],data_sub{nm}{:,nh});
        plot(dataplot.time,dataplot.avg,'black','LineWidth',3)
        ylim([0 4.5e-13])
        xlim([-0.2 1]);
        
        vline(0.1,'--r');
        vline(0.2,'--r');
        
        title(upper([list_modality{nm} ' ' list_hemi{nh}]))
        
    end
end

%% Additya

mod                                                = input('Enter modality {aud/vis}: ');

if strcmp(mod{:},'aud')
    sj_list                                        = input('Enter subject list for AUDITORY - {sub00x...}: ');
else if strcmp(mod{:},'vis')
        sj_list                                    = input('Enter subject list for VISUAL - {sub00x...}: ');
    end
end

list_hemi                                          = {'Lhemi','Rhemi'};
nses                                               = 1 ;

% aud subs  = {'sub004','sub006','sub007','sub008','sub009','sub010','sub012','sub013','sub015','sub016','sub018','sub019'};
% vis subs  = {'sub004','sub005','sub006','sub007','sub008','sub010','sub012','sub013','sub015','sub017','sub018'};

%% Grand average
for ns = 1:length(sj_list)
    
    dir_data                                       = ['../data/' sj_list{ns} '/erf/'];
    fname                                          = [dir_data sj_list{ns} '_localizer_timelock_planar_comb_' mod{nses} '.mat'];
    
    fprintf('Loading %s \n',fname);
    load(fname);
    
    for nh = 1:2
        
        fname_hemi                  = [dir_data sj_list{ns} '_localizer_timelock_planar_comb_' mod{nses} '_' list_hemi{nh} '_maxchan.mat'];
        fprintf('Loading %s \n',fname_hemi);
        load(fname_hemi);
        
        cfg                         = [];
        cfg.channel                 = max_chan;
        cfg.avgoverchan             = 'yes';
        data_sub{ns,nh}             = ft_selectdata(cfg,localizer_timelock_planar_comb);
        
        data_sub{ns,nh}.label       = {'chanavg'};
        
    end
    
    fprintf('\n');
    
end
clearvars -except data_sub list_modality list_hemi;

ix                                                 = 0;
for nh = 1:2
    
    ix                              = ix+1;
    subplot(1,2,ix)
    hold on
    
    for ns = 1:size(data_sub,1)
        dataplot                    = data_sub{ns,nh};
        plot(dataplot.time,dataplot.avg,'color',[0.8 0.8 0.8],'LineWidth',0.5)
    end
    
    dataplot                        = ft_timelockgrandaverage([],data_sub{:,nh});
    plot(dataplot.time,dataplot.avg,'black','LineWidth',3)
    ylim([0 4.5e-13])
    xlim([-0.2 1]);
    
    vline(0.1,'--r');
    vline(0.2,'--r');
    
    title(upper([mod{nses} ' ' list_hemi{nh}]))
    
end

%% Topoplots
i = 0 ;
nses = 1 ;
for nsub = 1:length(sj_list)
    dir_data                                       = ['../data/' sj_list{nsub} '/erf/'];
    fname                                          = [dir_data sj_list{nsub} '_localizer_timelock_planar_comb_' mod{nses} '.mat'];
    
    fprintf('Loading %s \n',fname);
    load(fname);
    
    i                                              = i + 1 ;
    
    for nhemi = 1:2
        
        fname_chans                                = [dir_data sj_list{nsub} '_localizer_timelock_planar_comb_' mod{nses}...
            '_' list_chan(nhemi) 'hemi_maxchan' '.mat'];
        fprintf('Loading %s \n',fname_chans);
        load(fname_chans);
        
        max_chan_comb{nhemi}                       = max_chan ;
        
        clear max_chan ;
        
    end
    all_chans                                      = [max_chan_comb{:}];
    
    cfg                                            = [];
    cfg.layout                                     = 'CTF275_helmet.mat';
    cfg.xlim                                       = time_window;
    cfg.zlim                                       = 'maxabs' ;
    cfg.marker                                     = 'off';
    cfg.comment                                    = 'no';
    cfg.colorbar                                   = 'no';
    cfg.highlight                                  = 'on';
    cfg.highlightchannel                           = all_chans;
    cfg.highlightsize                              = 8;
    
    subplot(2,6,i)
    ft_topoplotER(cfg, localizer_timelock_planar_comb);
    
    title([sj_list{nsub}]);
    clear max_chan localizer_timelock_planar_comb ;
    
end

sgtitle([upper(mod{nses}) '-10 Channel Selection'])

%% Single plots
i    = 0 ;
for nsub = 1:length(sj_list)
    dir_data                                       = ['../data/' sj_list{nsub} '/erf/'];
    fname                                          = [dir_data sj_list{nsub} '_localizer_timelock_planar_comb_' mod{nses} '.mat'];
    
    fprintf('Loading %s \n',fname);
    load(fname);
    
    for nhemi = 1:2
        fname_chans                                = [dir_data sj_list{nsub} '_localizer_timelock_planar_comb_' mod{nses}...
            '_' list_chan(nhemi) 'hemi_maxchan' '.mat'];
        fprintf('Loading %s \n',fname_chans);
        load(fname_chans);
        
        max_chan_comb{nhemi}                       = max_chan ;
        
        clear max_chan ;
        
        cfg                                        = [];
        cfg.layout                                 = 'CTF275_helmet.mat';
        cfg.xlim                                   = [-0.2 1];
        cfg.zlim                                   = 'maxabs' ;
        cfg.marker                                 = 'off';
        cfg.comment                                = 'no';
        cfg.colorbar                               = 'no';
        cfg.highlight                              = 'on';
        cfg.highlightchannel                       = max_chan_comb{nhemi};
        cfg.highlightsize                          = 8;
        i                                          = i + 1 ;
        
        subplot(6,4,i)
        ft_singleplotER(cfg, localizer_timelock_planar_comb);
        
        title([sj_list{nsub} ' ' list_chan(nhemi) ' max chan']);
        sgtitle([mod{nses} ' : Max Channel ERF :- 200ms to 1000ms'])
        
    end
end
