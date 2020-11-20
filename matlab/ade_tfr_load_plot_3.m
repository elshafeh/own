% loads all tfrs and plots them
clear;
sj_list                                         = {'sub004'};
md_list                                         = {'vis'};

list_condition                                  = {'correct','incorrect','conf','nonconf'}; % 

for nsuj = 1:length(sj_list)
    for nmod = 1:length(md_list)
        for nlist = 1:length(list_condition)
            
            dir_data                                    = ['../data/' sj_list{nsuj} '/tf/'];
            file_ext                                    = [sj_list{nsuj} '_mtmconvolPOW_m3000p3000ms50Step_2t40Hz1Step_' list_condition{nlist} '_' md_list{nmod}];
            fname                                       = [dir_data file_ext '.mat'];
            
            fprintf('Loading %s\n',fname);
            load(fname);
            
            cfg                                         = [];
            cfg.baseline                                = [-1.2 -0.8];
            cfg.baselinetype                            = 'relchange';
            freq                                        = ft_freqbaseline(cfg,freq);
            
            cfg                                         = [];
            cfg.channel                                 = {'MLO11', 'MLO12', 'MLO13', 'MLO21', 'MLO22', 'MLO23', 'MLO24', 'MLO32'};
            cfg.frequency                               = [7 14];
            cfg.avgoverchan                             = 'yes';
            cfg.avgoverfreq                             = 'yes';
            
            allFreq{nsuj,nmod,nlist}                    = h_freq2avg(cfg,freq); clear freq;
            allFreq{nsuj,nmod,nlist}.avg                = allFreq{nsuj,nmod,nlist}.avg';
            
        end
    end
end

clearvars -except allFreq;

% Fieldtrip plotting
close all;

cfg                                         = [];
cfg.layout                                  = 'CTF275_helmet.mat';
cfg.marker                                  = 'off';
cfg.comment                                 = 'no';

cfg.xlim                                    = [-2 2];
cfg.ylim                                    = [-0.6 1.2];
cfg.linewidth                               = 2;           

subplot(1,2,1)
ft_singleplotER(cfg,allFreq{:,1,1},allFreq{:,1,2});title('');
legend({'correct','incorrect'});
vline(0,'--k');

subplot(1,2,2)
ft_singleplotER(cfg,allFreq{:,1,3},allFreq{:,1,4});title('');
vline(0,'--k');
legend({'conf','nonconf'});