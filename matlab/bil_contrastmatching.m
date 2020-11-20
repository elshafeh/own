clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

if isunix
    project_dir                     = '/project/3015079.01/';
    start_dir                       = '/project/';
else
    project_dir                     = 'P:/3015079.01/';
    start_dir                       = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    
    fname                           = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.freqComb.alphaPeak.m1000m0ms.gratinglock.demean.erfComb.max20chan.p0p200ms.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    allpeaks(nsuj,1)                = [apeak];
    
    fname                           = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.1overf.orig.alphabetaPeak.' ...
        'm1000m0ms.mat'];
    load(fname);
    allpeaks(nsuj,2)                = [bpeak_orig];
    
end

allpeaks(isnan(allpeaks(:,2)),2)    = nanmean(allpeaks(:,2));
allpeaks                            = round(allpeaks);

keep suj_list allpeaks ; clc;

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    subject_folder                  = ['P:/3015079.01/data/' subjectName '/'];
    
    list_foi{1}                     = [3 5];
    list_foi{2}                     = [allpeaks(nsuj,1)-1 allpeaks(nsuj,1)+1];
    list_foi{3}                     = [allpeaks(nsuj,2)-2 allpeaks(nsuj,2)+2];
    list_foi{4}                     = [60 100];
    
    list_cond                       = {'match' 'nomatch'};
    list_freq                       = {'theta' 'alpha' 'beta' 'gamma'};
    
    for ncond = 1:length(list_cond)
        
        fname                       = ['I:/bil/tf/' subjectName '.cuelock.correct.mtmconvolPOW.m1p7s.50msStep.1t100Hz.1HzStep.AvgTrials.' list_cond{ncond} '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        for nfreq = 1:length(list_foi)
            
            % choose frequency band
            xi                    	= find(round(freq_comb.freq) == round(list_foi{nfreq}(1)));
            yi                    	= find(round(freq_comb.freq) == round(list_foi{nfreq}(2)));
            
            avg                     = [];
            avg.avg                 = squeeze(nanmean(freq_comb.powspctrm(:,xi:yi,:),2));
            avg.label           	= freq_comb.label;
            avg.dimord             	= 'chan_time';
            avg.time              	= freq_comb.time; clear freq;
            
            % baseline correct
            t1                    	= find(round(avg.time,2) == round(-0.4,2));
            t2                    	= find(round(avg.time,2) == round(-0.2,2));
            bsl                     = nanmean(avg.avg(:,t1:t2),2);
            avg.avg                 = (avg.avg - bsl) ./bsl;
            
            alldata{nsuj,nfreq,ncond}     = avg; clear avg bsl xi yi t1 t2;
            
            
        end
    end
end

keep alldata list_*

i                               = 0;

for nfreq = 1:size(alldata,2)
    
    nsuj                        = size(alldata,1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;
    
    cfg                         = [];
    cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                    = 1;cfg.ivar = 2;
    cfg.tail                    = 0;cfg.clustertail  = 0;
    cfg.neighbours              = neighbours;
    
    cfg.clusteralpha            = 0.05; % !!
    cfg.minnbchan               = 3; % !!
    cfg.alpha                   = 0.025;
    
    cfg.numrandomization        = 1000;
    cfg.design                  = design;
    
    i                           = i +1;
    cfg.latency                 = [-0.2 6];
    
    list_name{i}                = [list_freq{nfreq} ' match v nomatch'];
    stat{i}                     = ft_timelockstatistics(cfg, alldata{:,nfreq,1},alldata{:,nfreq,2});
    [min_p(i), p_val{i}]        = h_pValSort(stat{i});
    
end

close all;

cfg                             = [];
cfg.layout                      = 'CTF275.lay';
cfg.zlim                        = [-3 3];
cfg.colormap                    = brewermap(256,'*RdBu');
cfg.plimit                      = 0.2;
cfg.vline                       = [0 1.5 3 4.5 5.5];
cfg.sign                        = [-1 1];
cfg.maskstyle                   = 'highlight';%'nan';
cfg.xticks                      = cfg.vline;
cfg.xticklabels                 = {'1st Cue' '1st Gab' '2nd Cue' '2nd Gab' 'RT'};

ntest                           = 1;
cfg.title                       = list_name{ntest};
cfg.ylim                        = [-0.3 0.1];
h_plotstat_2d(cfg,stat{ntest},squeeze(alldata(:,ntest,:)));

ntest                           = 4;
cfg.title                       = list_name{ntest};
cfg.ylim                        = [-0.05 0.2];
h_plotstat_2d(cfg,stat{ntest},squeeze(alldata(:,ntest,:)));
    