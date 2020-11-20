clear ; clc;

if isunix
    start_dir                   = '/project/';
else
    start_dir                   = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    
    list_cond{1}                = {'pre','correct','*'};
    list_cond{2}                = {'retro','correct','*'};
    
    %     list_cond{3}                = {'*','correct','*'};
    %     list_cond{4}                = {'*','incorrect','*'};
    %
    %     list_cond{5}                = {'*','correct','fast'};
    %     list_cond{6}                = {'*','correct','slow'};
    %
    %     list_cond{7}                = {'pre','correct','*'};
    %     list_cond{8}                = {'pre','incorrect','*'};
    %
    %     list_cond{9}                = {'retro','correct','*'};
    %     list_cond{10}           	= {'retro','incorrect','*'};
    
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
        
        fname                   = [start_dir '3015079.01/data/' subjectName '/tf/' subjectName '.firstcuelock.freqComb.alphaPeak.m1000m0ms.gratinglock.demean.erfComb.max20chan.p0p200ms.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        % choose frequency band
        xi                    	= find(round(freq.freq) == round(apeak-1));
        yi                    	= find(round(freq.freq) == round(apeak+1));
        
        avg                     = [];
        avg.avg                 = squeeze(nanmean(freq.powspctrm(:,xi:yi,:),2));
        avg.label           	= freq.label;
        avg.dimord             	= 'chan_time';
        avg.time              	= freq.time; clear freq;
        
        % baseline correct
        t1                    	= find(round(avg.time,2) == round(-0.4,2));
        t2                    	= find(round(avg.time,2) == round(-0.2,2));
        bsl                     = nanmean(avg.avg(:,t1:t2),2);
        avg.avg                 = (avg.avg - bsl) ./bsl;
        
        alldata{nsuj,ncond}     = avg; clear avg freq bsl xi yi t1 t2;
        
    end
end

%%

list_test                       = [1 2];
list_name                       = {};
i                               = 0;

for ntest = 1:size(list_test,1)
    
    nsuj                        = size(alldata,1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;
    
    cfg                         = [];
    cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                    = 1;cfg.ivar = 2;
    cfg.tail                    = 0;cfg.clustertail  = 0;
    cfg.neighbours              = neighbours;
    
    cfg.clusteralpha            = 0.05; % !!
    cfg.minnbchan               = 4; % !!
    cfg.alpha                   = 0.025;
    
    cfg.numrandomization        = 1000;
    cfg.design                  = design;
    
    i                           = i +1;
    ix1                         = list_test(ntest,1);
    ix2                         = list_test(ntest,2);
    
    cfg.latency                 = [-0.2 5.5];
    
    list_name{i}                = [[list_cond{ix1}{:}] ' versus ' [list_cond{ix2}{:}]];
    stat{i}                     = ft_timelockstatistics(cfg, alldata{:,ix1},alldata{:,ix2});
    [min_p(i), p_val{i}]        = h_pValSort(stat{i});
    
end

close all;

%%
nw_stat                         = stat{1};
nw_stat.mask                 	= nw_stat.prob < 0.05;

statplot                        = [];
statplot.avg                  	= nw_stat.mask .* nw_stat.stat;
statplot.label               	= nw_stat.label;
statplot.dimord               	= nw_stat.dimord;
statplot.time               	= nw_stat.time;

cfg                             = [];
cfg.layout                      = 'CTF275.lay';
cfg.zlim                        = [-3 3];
cfg.colormap                    = brewermap(256,'PRGn');
cfg.marker                      = 'off';
cfg.comment                     = 'no';
cfg.colorbar                    = 'yes';
subplot(2,2,1);
cfg.xlim                        = [0.35 0.98];
ft_topoplotER(cfg,statplot);
cfg.xlim                        = [3 4];
subplot(2,2,2);
ft_topoplotER(cfg,statplot);


list_chan                       = {'MLO12','MLO13','MLO14','MLP33','MLP34','MLP42','MLP43','MLP44','MLP53','MLP54','MLP55','MLP56', ...
    'MLT15','MLT16','MLT26','MLT27','MLT37'};

cfg                             = [];
cfg.channel                     = list_chan;
cfg.time_limit              	= nw_stat.time([1 end]);
cfg.color                       = {'-b' '-r'};
cfg.z_limit                     = [-0.65 0.1];
cfg.linewidth                   = 10;
subplot(2,2,3:4);
h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,alldata);
xlim(statplot.time([1 end]));
hline(0,'--k');
vline(0,'--k');
xticks([0 1.5 3 4.5 5.5]);
xticklabels({'1st Cue' '1st Gab' '2nd Cue' '2nd Gab' 'RT'});
yticks([-0.65 0 0.1]);