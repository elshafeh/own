clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

if isunix
    project_dir              	= '/project/3015079.01/';
    start_dir                	= '/project/';
else
    project_dir              	= 'P:/3015079.01/';
    start_dir               	= 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName               	= suj_list{nsuj};    
    list_bin                	= {'bin1' 'bin5'};
    
    for nbin = 1:length(list_bin)
        
        fname               	= [project_dir 'data/' subjectName '/erf/' subjectName '.cuelock.itc.withcorrect.' list_bin{nbin} '.erf.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        t1                    	= find(round(avg_comb.time,2) == round(-0.11,2));
        t2                  	= find(round(avg_comb.time,2) == round(0.01,2));
        
        bsl                  	= mean(avg_comb.avg(:,t1:t2),2);
        avg_comb.avg         	= avg_comb.avg - bsl ; clear bsl t1 t2;
        alldata{nsuj,nbin}      = avg_comb; clear avg_comb;
        
        
    end
    
    fprintf('\n');
    
end

keep alldata list_*; clc ;

%%

list_test                       = [2 1];
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
    
    cfg.latency                 = [-0.1 5.5];
    
    list_name{i}                = [[list_bin{ix1}] ' versus ' [list_bin{ix2}]];
    stat{i}                     = ft_timelockstatistics(cfg, alldata{:,ix1},alldata{:,ix2});
    [min_p(i), p_val{i}]        = h_pValSort(stat{i});
    
end


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
cfg.zlim                        = [-0.5 0.5];
cfg.colormap                    = brewermap(256,'*RdBu');
cfg.marker                      = 'off';
cfg.comment                     = 'no';
cfg.colorbar                    = 'yes';
subplot(2,2,1);
ft_topoplotER(cfg,statplot);

list_chan                       = {'MLO11','MLO12','MLO13','MLO14','MLO21', ... 
    'MLO22','MLO23','MLP11','MLP21','MLP22','MLP31', ... 
    'MLP32','MLP33','MLP34','MLP41','MLP42','MLP43','MLP44', ... 
    'MLP51','MLP52','MLP53','MLP54','MLP55','MRO21','MRP11','MRP21','MRP31','MRP51'};


cfg                             = [];
cfg.channel                     = list_chan;
cfg.time_limit              	= nw_stat.time([1 end]);
cfg.color                       = {'-b' '-r'};
cfg.z_limit                     = [-1e-14 1.5e-13];
cfg.linewidth                   = 10;
subplot(2,2,2);
h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,alldata);
xlim(statplot.time([1 end]));
hline(0,'-k');
vline(0,'-k');
xticks([0 1.5 3 4.5 5.5]);
xticklabels({'1st Cue' '1st Gab' '2nd Cue' '2nd Gab' 'RT'});

%%

sig_time = unique(stat{1}.time .* stat{1}.mask);
sig_time = sig_time(sig_time ~=0);
sig_time = [min(sig_time) max(sig_time)];
