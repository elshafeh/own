clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

load('~/Dropbox/project_me/data/bil/allsuj_alphabetapeak.mat');

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
<<<<<<< HEAD
    
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
=======
>>>>>>> 6cb674d58140ad1fcf7b4f3f585eb0969eba7f48
    list_cond                       = {'pre' 'retro' '*'};
    
    for ncond = 1:length(list_cond)
        
<<<<<<< HEAD
        fprintf('\n');
        
        ext_name                    = [project_dir 'data/' subjectName '/tf/' subjectName '.cuelock.mtmconvolPOW.m1p7s.20msStep.1t100Hz.1HzStep.AvgTrials.'];
=======
        ext_name                    = ['~/Dropbox/project_me/data/bil/tf/' subjectName '.cuelock.mtmconvolPOW.m1p7s.20msStep.1t100Hz.1HzStep.AvgTrials.'];
>>>>>>> 6cb674d58140ad1fcf7b4f3f585eb0969eba7f48
        flist                       = dir([ext_name '*.' list_cond{ncond} '.correct.*.mat']);
        
        for nfile = 1:length(flist)
            fname                   = [flist(nfile).folder filesep flist(nfile).name];
            fprintf('loading %s\n',fname);
            load(fname);
            tmp{nfile}              = freq_comb; clear freq_comb;
        end
        
        freq                        = ft_freqgrandaverage([],tmp{:}); clear tmp;
        
        list_foi{1}                 = [3 5];
        list_foi{2}                 = [allpeaks(nsuj,1)-1 allpeaks(nsuj,1)+1];
        list_foi{3}                 = [allpeaks(nsuj,2)-2 allpeaks(nsuj,2)+2];
        list_foi{4}                 = [60 100];
        
        for nfreq = 1:length(list_foi)
            
            % choose frequency band
            xi                    	= find(round(freq.freq) == round(list_foi{nfreq}(1)));
            yi                    	= find(round(freq.freq) == round(list_foi{nfreq}(2)));
            
            avg                     = [];
            avg.avg                 = squeeze(nanmean(freq.powspctrm(:,xi:yi,:),2));
            avg.label           	= freq.label;
            avg.dimord             	= 'chan_time';
            avg.time              	= freq.time;
            
            % baseline correct
            t1                    	= find(round(avg.time,2) == round(-0.4,2));
            t2                    	= find(round(avg.time,2) == round(-0.2,2));
            bsl                     = nanmean(avg.avg(:,t1:t2),2);
            avg.avg                 = (avg.avg - bsl) ./bsl;
            
            alldata{nsuj,ncond,nfreq}     = avg; clear avg bsl xi yi t1 t2;
            
<<<<<<< HEAD
            fname                   = [project_dir 'data/' subjectName '/behav/' subjectName '.auc2correlate.mat'];
=======
            fname                   = ['~/Dropbox/project_me/data/bil/behav/' subjectName '.auc2correlate.mat'];
>>>>>>> 6cb674d58140ad1fcf7b4f3f585eb0969eba7f48
            load(fname);
            
            list_var                = {};
            
            for lu = 1:length(auc_measures)
                list_var{lu}        = auc_measures(lu).name;
                allbehav{nsuj,lu}   = auc_measures(lu).value;
            end
            
        end
    end
end

%%

keep alldata list_var allbehav

<<<<<<< HEAD
list_freq                               = {'theta' 'alpha' 'beta' 'gamma'};
list_cue                                = {'pre' 'retro' 'all'};

=======

list_freq                               = {'theta' 'alpha' 'beta' 'gamma'};
list_cue                                = {'pre' 'retro' 'all'};

cfg                                     = [];
cfg.method                              = 'montecarlo';
cfg.latency                             = [-0.1 5.5];
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

>>>>>>> 6cb674d58140ad1fcf7b4f3f585eb0969eba7f48
i                                       = 0;

for nfreq = 1:size(alldata,3)
    for nauc = 1:size(allbehav,2)
        
<<<<<<< HEAD
        cfg                          	= [];
        cfg.method                  	= 'montecarlo';
        cfg.statistic                	= 'ft_statfun_correlationT';
        cfg.clusterstatistics        	= 'maxsum';
        cfg.correctm                	= 'cluster';
        cfg.clusteralpha            	= 0.05;
        cfg.tail                    	= 0;
        cfg.clustertail               	= 0;
        cfg.alpha                   	= 0.025;
        cfg.numrandomization          	= 500;
        cfg.ivar                    	= 1;
        cfg.type                    	= 'Spearman';
        cfg.minnbchan                	= 3; % !!
        
        if strcmp(list_var{nauc},'pre task')
            list_indx                   = 1;
            cfg.latency                 = [-0.5 1.5];
        elseif strcmp(list_var{nauc},'retro task')
            list_indx                   = 2;
            cfg.latency                 = [2.5 4];
        else
            if strcmp(list_var{nauc},'gab1 prop')
                cfg.latency         	= [-0.1 2];
            elseif strcmp(list_var{nauc},'gab2 prop')
                cfg.latency          	= [3 5];
            else
                cfg.latency             = [3 5.5];
            end
=======
        if strcmp(list_var{nauc},'pre task')
            list_indx                   = 1;
        elseif strcmp(list_var{nauc},'retro task')
            list_indx                   = 2;
        else
>>>>>>> 6cb674d58140ad1fcf7b4f3f585eb0969eba7f48
            list_indx                   = 3;
        end
        
        for ncond = list_indx
            
            nb_suj                      = size(alldata,1);
            cfg.design(1,1:nb_suj)  	= [allbehav{:,nauc}];
            
            [~,neighbours]              = h_create_design_neighbours(nb_suj,alldata{1,1},'meg','t');
            cfg.neighbours              = neighbours;
            
            i                           = i + 1;
            stat{i}                     = ft_timelockstatistics(cfg, alldata{:,ncond,nfreq});
            
            list_test{i,1}          	= [list_cue{ncond} ' ' list_freq{nfreq} ' ' list_var{nauc}];
            [list_test{i,2},pval]   	= h_pValSort(stat{i});
            
        end
    end
end

keep alldata allbehav list_* stat

<<<<<<< HEAD
%

i                                       = 0;
ncol                                    = 4;
=======
%%

i                                       = 0;
ncol                                    = 3;
>>>>>>> 6cb674d58140ad1fcf7b4f3f585eb0969eba7f48
nrow                                    = 3;
plimit                                  = 0.12;

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
        
<<<<<<< HEAD
        i                               = i +1;
        subplot(nrow,ncol,i);
        plot(stoplot.time,mean(stoplot.avg,1),'LineWidth',1);
        xlim(stoplot.time([1 end]));
        
        vline([0 1.5 3 4.5 5.5],'--k');
        xticklabels({'1st Cue' '1st Gab' '2nd Cue' '2nd Gab' 'RT'});
        xticks([0 1.5 3 4.5 5.5]);
        
        title({list_test{ntest,1},['p=' num2str(round(list_test{ntest,2},2))]})
        
    end
end
=======
        title({list_test{ntest,1},['p=' num2str(list_test{ntest,2})]})
        
    end
end

>>>>>>> 6cb674d58140ad1fcf7b4f3f585eb0969eba7f48
