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

keep suj_list allpeaks project_dir
clc;

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    list_cond                       = {'*'};
    
    for ncond = 1:length(list_cond)
        
        fprintf('\n');
        
        ext_name                    = [project_dir 'data/' subjectName '/tf/' subjectName '.cuelock.mtmconvolPOW.m1p7s.20msStep.1t100Hz.1HzStep.AvgTrials.'];
        flist                       = dir([ext_name '*.' list_cond{ncond} '.correct.*.mat']);
        
        for nfile = 1:length(flist)
            fname                   = [flist(nfile).folder filesep flist(nfile).name];
            fprintf('loading %s\n',fname);
            load(fname);
            tmp{nfile}              = freq_comb; clear freq_comb;
        end
        
        freq                        = ft_freqgrandaverage([],tmp{:}); clear tmp;
        
        % baseline correct
        t1                       	= find(round(freq.time,2) == round(-0.4,2));
        t2                        	= find(round(freq.time,2) == round(-0.2,2));
        bsl                        	= nanmean(freq.powspctrm(:,:,t1:t2),3);
        act                        	= freq.powspctrm;
        freq.powspctrm            	= (act - bsl) ./bsl;
        
        list_time                   = [
            0 0.5;
            0.5 1.5;
            1.5 2;
            2 3;
            3 3.5;
            3.5 4.5;
            4.5 5];
        
        for ntime = 1:size(list_time,1)
            
            % choose time window band
            xi                          = find(round(freq.time,2) == round(list_time(ntime,1),2));
            yi                          = find(round(freq.time,2) == round(list_time(ntime,2),2));
            
            avg                         = [];
            avg.avg                     = squeeze(nanmean(freq.powspctrm(:,:,xi:yi),3));
            avg.label                   = freq.label;
            avg.dimord                  = 'chan_time';
            avg.time                    = freq.freq;
            
            alldata{nsuj,ncond,ntime}   = avg; clear avg bsl xi yi t1 t2;

            
        end
    end
    
    fname                               = [project_dir 'data/' subjectName '/behav/' subjectName '.auc2correlate.trio.mat'];
    load(fname);
    
    list_var                            = {};
    
    for lu = 1:length(auc_measures)
        list_var{lu}        = auc_measures(lu).name;
        allbehav{nsuj,lu}   = auc_measures(lu).value;
    end
    
end

keep alldata list_var allbehav

list_time                               = {'cue1 proc' 'cue1 gab1' 'gab1 proc' 'gab1 cue2' 'cue2 proc' 'cue2 gab2' 'gab2 proc'};
list_cue                                = {'all'};

cfg                                     = [];
cfg.method                              = 'montecarlo';
cfg.latency                             = [3 40];
cfg.statistic                           = 'ft_statfun_correlationT';
cfg.clusterstatistics                   = 'maxsum';
cfg.correctm                            = 'cluster';
cfg.clusteralpha                        = 0.05;
cfg.tail                                = 0;
cfg.clustertail                         = 0;
cfg.alpha                               = 0.025;
cfg.numrandomization                    = 500;
cfg.ivar                                = 1;
cfg.type                                = 'Spearman';
cfg.minnbchan                           = 3; % !!

i                                       = 0;

for ntime = 1:size(alldata,3)
    for nauc = 1:size(allbehav,2)
        
        list_indx                       = 1;
        
        for ncond = list_indx
            
            nb_suj                      = size(alldata,1);
            cfg.design(1,1:nb_suj)  	= [allbehav{:,nauc}];
            
            [~,neighbours]              = h_create_design_neighbours(nb_suj,alldata{1,1},'meg','t');
            cfg.neighbours              = neighbours;
            
            i                           = i + 1;
            stat{i}                     = ft_timelockstatistics(cfg, alldata{:,ncond,ntime});
            
            list_test{i,1}          	= [list_cue{ncond} ' ' list_time{ntime} ' ' list_var{nauc}];
            [list_test{i,2},pval]   	= h_pValSort(stat{i});
            
        end
    end
end

keep alldata allbehav list_* stat

%

i                                       = 0;
ncol                                    = 4;
nrow                                    = 3;
plimit                                  = 0.15;

for ntest = 1:length(stat)
    
    if list_test{ntest,2} < plimit
        
        stoplot                         = h_plotStat(stat{ntest},10e-13,plimit,'rho');
        cfg                             = [];
        cfg.layout                      = 'CTF275_helmet.mat';
        cfg.marker                      = 'off';
        cfg.comment                     = 'no';
        cfg.colormap                    = brewermap(256, '*RdBu');
        cfg.zlim                        = 'maxabs';
        
        i                               = i +1;
        subplot(nrow,ncol,i);
        ft_topoplotER(cfg, stoplot);
        
        title({list_test{ntest,1},['p=' num2str(round(list_test{ntest,2},3))]})
        
        i                               = i +1;
        subplot(nrow,ncol,i);
        plot(stoplot.time,mean(stoplot.avg,1),'LineWidth',1);
        xlim(stoplot.time([1 end]));
        
        
    end
end