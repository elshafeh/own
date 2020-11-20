clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

<<<<<<< HEAD
for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    list_cond                           = {'*'}; % 'pre' 'retro' 
    
    for ncond = 1:length(list_cond)
        
        ext_name                        = ['/project/3015079.01/data/' subjectName '/tf/' subjectName '.cuelock.mtmconvolPOW.m1p7s.20msStep.1t100Hz.1HzStep.AvgTrials.'];
=======
load('~/Dropbox/project_me/data/bil/allsuj_alphabetapeak.mat');

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    list_cond                           = {'pre' 'retro' '*'};
    
    for ncond = 1:length(list_cond)
        
        ext_name                        = ['~/Dropbox/project_me/data/bil/tf/' subjectName '.cuelock.mtmconvolPOW.m1p7s.20msStep.1t100Hz.1HzStep.AvgTrials.'];
>>>>>>> 6cb674d58140ad1fcf7b4f3f585eb0969eba7f48
        flist                           = dir([ext_name '*.' list_cond{ncond} '.correct.*.mat']);
        
        for nfile = 1:length(flist)
            fname                       = [flist(nfile).folder filesep flist(nfile).name];
            fprintf('loading %s\n',fname);
            load(fname);
            tmp{nfile}                  = freq_comb; clear freq_comb;
        end
        
        freq                            = ft_freqgrandaverage([],tmp{:}); clear tmp;
        
        % baseline correct
        t1                              = find(round(freq.time,2) == round(-0.4,2));
        t2                              = find(round(freq.time,2) == round(-0.2,2));
        bsl                             = nanmean(freq.powspctrm(:,:,t1:t2),3);
        act                             = freq.powspctrm;
<<<<<<< HEAD
=======
        
>>>>>>> 6cb674d58140ad1fcf7b4f3f585eb0969eba7f48
        freq.powspctrm                  = (act - bsl) ./bsl;
        
        alldata{nsuj,ncond}             = freq; clear freq act bsl xi yi t1 t2;
        
<<<<<<< HEAD
        fname                           = ['/project/3015079.01/data/' subjectName '/behav/' subjectName '.auc2correlate.trio.mat'];
=======
        fname                           = ['~/Dropbox/project_me/data/bil/behav/' subjectName '.auc2correlate.mat'];
>>>>>>> 6cb674d58140ad1fcf7b4f3f585eb0969eba7f48
        load(fname);
        
        list_var                        = {};
        
        for lu = 1:length(auc_measures)
            list_var{lu}                = auc_measures(lu).name;
            allbehav{nsuj,lu}           = auc_measures(lu).value;
        end
        
    end
end

<<<<<<< HEAD

keep alldata list_var allbehav

list_cue                                = {'all'}; % 'pre' 'retro' 
=======
%%

keep alldata list_var allbehav

list_cue                                = {'pre' 'retro' 'all'};

cfg                                     = [];
cfg.method                              = 'montecarlo';
cfg.latency                             = [0 5.5];
cfg.frequency                           = [3 100];
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

for nauc = 1:size(allbehav,2)
    
<<<<<<< HEAD
    cfg                               	= [];
    cfg.method                       	= 'montecarlo';
    cfg.latency                      	= [0 5.5];
    cfg.frequency                   	= [3 100];
    cfg.statistic                     	= 'ft_statfun_correlationT';
    cfg.clusterstatistics             	= 'maxsum';
    cfg.correctm                       	= 'cluster';
    cfg.clusteralpha                 	= 0.05;
    cfg.tail                          	= 0;
    cfg.clustertail                  	= 0;
    cfg.alpha                         	= 0.025;
    cfg.numrandomization              	= 500;
    cfg.ivar                          	= 1;
    cfg.type                        	= 'Spearman';
    cfg.minnbchan                   	= 3; % !!
    
    %     if strcmp(list_var{nauc},'pre task')
    %         list_indx                       = 1;
    %     elseif strcmp(list_var{nauc},'retro task')
    %         list_indx                       = 2;
    %     else
    %         list_indx                       = 3;
    %     end
    
    for ncond = 1
=======
    if strcmp(list_var{nauc},'pre task')
        list_indx                       = 1;
    elseif strcmp(list_var{nauc},'retro task')
        list_indx                       = 2;
    else
        list_indx                       = 3;
    end
    
    for ncond = list_indx
>>>>>>> 6cb674d58140ad1fcf7b4f3f585eb0969eba7f48
        
        nb_suj                          = size(alldata,1);
        cfg.design(1,1:nb_suj)          = [allbehav{:,nauc}];
        
        [~,neighbours]                  = h_create_design_neighbours(nb_suj,alldata{1,1},'meg','t');
        cfg.neighbours                  = neighbours;
        
        i                               = i + 1;
        stat{i}                         = ft_freqstatistics(cfg, alldata{:,ncond});
        
        list_test{i,1}                  = [list_cue{ncond} ' with ' list_var{nauc}];
        [list_test{i,2},pval]           = h_pValSort(stat{i});
        
    end
end

keep alldata allbehav list_* stat

<<<<<<< HEAD
=======
%%

>>>>>>> 6cb674d58140ad1fcf7b4f3f585eb0969eba7f48
i                                       = 0;
ncol                                    = 3;
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
        
        i                               = i + 1;
        subplot(nrow,ncol,i);
        ft_topoplotTFR(cfg, stoplot);
        
        title({list_test{ntest,1},['p=' num2str(list_test{ntest,2})]})
        
    end
end