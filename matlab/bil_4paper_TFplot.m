clear ; clc;

if isunix
    start_dir                   = '/project/';
else
    start_dir                   = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

list_chan                       = [];

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    
    list_cond{1}                = {'pre','correct','*'};
    list_cond{2}                = {'retro','correct','*'};
    
    for ncond = 1:length(list_cond)
        
        fprintf('\n');
        
        ext_name                = ['I:/bil/tf/' subjectName '.cuelock.mtmconvolPOW.m1p7s.20msStep.1t100Hz.1HzStep.AvgTrials.'];
        
        ext_cue                 = list_cond{ncond}{1};
        ext_cor                 = list_cond{ncond}{2};
        ext_rea                 = list_cond{ncond}{3};
        
        flist                   = dir([ext_name '*.' ext_cue '.' ext_cor '.' ext_rea '.mat']);
        
        for nfile = 1:length(flist)
            fname               = [flist(nfile).folder filesep flist(nfile).name];
            fprintf('loading %s\n',fname);
            load(fname);
            tmp{nfile}          = freq_comb; clear freq_comb;
        end
        
        freq                    = ft_freqgrandaverage([],tmp{:}); clear tmp;
        
        % baseline correct
        cfg                     = [];
        cfg.baseline            = [-0.4 -0.2];
        cfg.baselinetype      	= 'relchange';
        freq_bsl                = ft_freqbaseline(cfg,freq);
        alldata{nsuj,ncond,1}  	= freq_bsl; 
        alldata{nsuj,ncond,2}  	= freq; clear freq freq_bsl
        
    end
    
    
    if isunix
        subject_folder          = ['/project/3015079.01/data/' subjectName];
    else
        subject_folder          = ['P:/3015079.01/data/' subjectName];
    end
    
    fname                       = [subject_folder '/erf/' subjectName '.gratinglock.demean.erfComb.max20chan.p0p200ms.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    list_chan                   = [list_chan;max_chan];
    
end

keep alldata list_chan;clc;

%%

list_chan               = unique(list_chan);

freq_pre              	= ft_freqgrandaverage([],alldata{:,1,2});
freq_retro           	= ft_freqgrandaverage([],alldata{:,2,2});

freq_plot               = freq_pre;
freq_plot.powspctrm     = (freq_pre.powspctrm - freq_retro.powspctrm) ./ freq_retro.powspctrm;

cfg                     = [];
cfg.colormap            = brewermap(256, 'PRGn');
cfg.channel             = list_chan;
cfg.colorbar        	= 'yes';
cfg.zlim                = [-0.2 0.2];
subplot(2,2,1);
ft_singleplotTFR(cfg,freq_plot);
title('');
xticks([0 1.5 3 4.5 5.5]);
yticks([5 10 15 20 25 30 35 40 50]);
xlim([-0.1 5.5]);
ylim([3 40]);

% for ncond = 1:2
%
%     cfg                     = [];
%     cfg.colormap            = brewermap(256, '*RdBu');
%     cfg.channel             = list_chan;
%     % cfg.parameter           = 'stat';
%     % cfg.maskparameter       = 'mask';
%     % cfg.maskstyle           = 'outline';
%     %     cfg.zlim                = [-1 1];
%     cfg.colorbar        	='no';
%     subplot(2,2,ncond);
%     ft_singleplotTFR(cfg,ft_freqgrandaverage([],alldata{:,ncond}));
%     title('');
%
%     xticks([0 1.5 3 4.5 5.5]);
%
%     %     yticks(vct_plt);
%     %     xticklabels({'1st G' '0.1' '0.2' '0.3' '0.4' '0.5' '2nd Cue' '2nd G'});
%     %     yticklabels({'1st G' '0.1' '0.2' '0.3' '0.4' '0.5' '2nd Cue' '2nd G'});
%
% end