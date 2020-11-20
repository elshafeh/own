%% LOADING TFRs and PLOTS

clear;

% adding Fieldtrip path
fieldtrip_path                              = '/project/3015039.04/fieldtrip-20190618';
addpath(fieldtrip_path); ft_defaults ;

sj_list                                     = {'sub004'};
md_list                                     = {'aud','vis'};
list_condition                              = {'allTrials'}; % 'correct','incorrect','conf','nonconf'}; %type1 = leftori./low, type2= rightor./high

%% General TFR name saving guidelines
name_ext_tfr                            = [cfg.method upper(cfg.output)];
name_ext_time                           = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000) 'ms' num2str(abs(toi_step)*1000) 'Step'];
name_ext_freq                           = [num2str(round(cfg.foi(1))) 't' num2str(round(cfg.foi(end))) 'Hz' num2str(round(foi_step)) 'Step'];

dir_data                                = ['../data/' sj_list{nsub} '/tf/'];
fname                                   = [dir_data name_ext_tfr '_' name_ext_time '_' name_ext_freq mod{nses} '.mat'];
%%

for nsuj = 1:length(sj_list)
    for nmod = 1:length(md_list)
        for nlist = 1:length(list_condition)
            
            dir_data                            = ['../data/' sj_list{nsuj} '/tf/'];
            file_ext                            = [sj_list{nsuj} '_mtmconvolPOW_m3000p3000ms50Step_2t40Hz1Step_' list_condition{nlist} '_' md_list{nmod}];
            fname                               = [dir_data file_ext '.mat'];
            
            fprintf('Loading %s\n',fname);
            load(fname);
            
            allFreq{nsuj,nmod,nlist}                  = freq; clear freq;
            
        end
        
    end
end

clearvars -except allFreq *_list ; close all;

%%
figure;
ii                                                  = 0;

for nsuj = 1:length(sj_list)
    
    time_win                                        = 0.2;
    list_time                                       = -0.6:time_win:0.6;
    
    for nmod = 1:length(md_list)
        for ntime = 1:length(list_time)
            
            ii                                      = ii +1;
            nplt_x                                  = 2;
            nplt_y                                  = length(list_time);
            
            subplot(nplt_x,nplt_y,ii)
            
            cfg                                     = [];
            cfg.layout                              = 'CTF275_helmet.mat';
            cfg.ylim                                = [7 14];
            cfg.marker                              = 'off';
            cfg.comment                             = 'no';
            
            cfg.baseline                            = [-1.2 0.8];
            cfg.baselinetype                        = 'relchange';
            cfg.zlim                                = [-0.15 0.15];
            
            cfg.colorbar                            = 'no';
            
            cfg.xlim                                = [list_time(ntime) list_time(ntime)+time_win];
            ft_topoplotTFR(cfg, allFreq{nsuj,nmod,1});
            
            title([sj_list{nsuj} ' ' md_list{nmod} ' ' num2str(list_time(ntime))]);
            
        end
        
    end
end

%%
figure;

for nsuj = 1:length(sj_list)
    
    time_win                                        = 0.6;
    list_time                                       = -0.6;
    
    for nmod = 1:length(md_list)
        for ntime = 1:length(list_time)
            
            list_ix                                 = [1 3];
            
            nplt_x                                  = length(list_time);
            nplt_y                                  = 2;
            
            subplot(2,2,list_ix(nmod))
            
            cfg                                     = [];
            cfg.layout                              = 'CTF275_helmet.mat';
            cfg.ylim                                = [7 14];
            cfg.marker                              = 'off';
            cfg.comment                             = 'no';
            
            cfg.baseline                            = [-1.2 0.8];
            cfg.baselinetype                        = 'relchange';
            cfg.zlim                                = [-0.15 0.15];
            
            cfg.colorbar                            = 'no';
            
            cfg.xlim                                = [list_time(ntime) list_time(ntime)+time_win];
            ft_topoplotTFR(cfg, allFreq{nsuj,nmod,1});
            
            title([sj_list{nsuj} ' ' md_list{nmod} ' ' num2str(list_time(ntime))]);
            
        end
        
    end
end

%%
list_chan{1}    = {'MRT23', 'MRT24', 'MRT33', 'MRT34', 'MRT35', 'MRT42', 'MRT43', 'MRT44', 'MRT53'};
list_chan{2}    = {'MLO11', 'MLO12', 'MLO13', 'MLO21', 'MLO22', 'MLO23', 'MLO24', 'MLO32'};

for nsuj = 1:length(sj_list)
    for nmod = 1:length(md_list)
        
        list_ix                                 = [2 4];
        
        nplt_x                                  = 2;
        nplt_y                                  = 1;
        
        subplot(2,2,list_ix(nmod))
        
        cfg                                     = [];
        cfg.layout                              = 'CTF275_helmet.mat';
        cfg.ylim                                = [5 20];
        cfg.marker                              = 'off';
        cfg.comment                             = 'no';
        
        cfg.channel                             = list_chan{nmod};
        
        cfg.baseline                            = [-1.2 -0.8];
        cfg.baselinetype                        = 'relchange';
        
        cfg.zlim                                = [-0.2 0.2];
        
        cfg.colorbar                            = 'no';
        cfg.xlim                                = [-1 1];
        ft_singleplotTFR(cfg, allFreq{nsuj,nmod,1});
        
        title([sj_list{nsuj} ' ' md_list{nmod}]);
        
    end
end

cfg                                     = [];
cfg.layout                              = 'CTF275_helmet.mat';
cfg.ylim                                = [5 20];
cfg.marker                              = 'off';
cfg.comment                             = 'no';

%         cfg.channel                             = list_chan{nmod};

%         cfg.baseline                            = [-1.2 -0.8];
%         cfg.baselinetype                        = 'relchange';

cfg.zlim                                = [-0.2 0.2];

cfg.colorbar                            = 'no';
cfg.xlim                                = [-1 1];
ft_singleplotTFR(cfg, freq.powspctrm);

figure
plot(freq.powspctrm)
