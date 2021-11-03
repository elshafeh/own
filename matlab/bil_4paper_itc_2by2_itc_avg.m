clear ; clc;

if isunix
    project_dir                     = '/project/3015079.01/';
    start_dir                       = '/project/';
else
    project_dir                     = 'P:/3015079.01/';
    start_dir                       = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    sujName                   	= suj_list{nsuj};
    i                         	= 0;
    
    fname                       = [project_dir 'data/' sujName '/tf/' sujName '.cuelock.itc.5binned.withEvoked.withIncorrect.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    list_bin                	= {'bin1w' 'bin5w'};
    
    for nbin = [1 5]
        
        f1                      = nearest(phase_lock{nbin}.freq,2);
        f2                      = nearest(phase_lock{nbin}.freq,6);
        
        avg                     = [];
        avg.time                = phase_lock{nbin}.time;
        avg.label               = phase_lock{nbin}.label;
        avg.dimord              = 'chan_time';
        avg.avg                 = squeeze(mean(phase_lock{nbin}.powspctrm(:,f1:f2,:),2));
        
        i                       = i +1;
        alldata{nsuj,i}         = avg; clear avg;
        
    end
end

keep alldata list_*

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
    
    list_name{i}                = 'Bin1 versus Bin5';
    stat{i}                     = ft_timelockstatistics(cfg, alldata{:,ix1},alldata{:,ix2});
    [min_p(i), p_val{i}]        = h_pValSort(stat{i});
    
end

%%

nw_stat                         = stat{1};

statplot                        = [];
statplot.avg                  	= nw_stat.mask .* nw_stat.stat;
statplot.label               	= nw_stat.label;
statplot.dimord               	= nw_stat.dimord;
statplot.time               	= nw_stat.time;

cfg                             = [];
cfg.layout                      = 'CTF275.lay'; %'CTF275_helmet.mat';
cfg.zlim                        = [-2 2];
cfg.colormap                    = brewermap(256,'*RdBu');
cfg.marker                      = 'off';
cfg.comment                     = 'no';
cfg.colorbar                    = 'yes';
cfg.xlim                        = [4.4 5.5];
cfg.figure                      = subplot(2,2,1);
ft_topoplotER(cfg,statplot);

find_chan                      	= mean(mean(nw_stat.mask,2),3);
find_chan                     	= find(find_chan ~= 0);
list_chan                       = nw_stat.label(find_chan);

cfg                             = [];
cfg.channel                     = list_chan;
cfg.time_limit              	= nw_stat.time([1 end]);
cfg.color                       = {'-b' '-r'};
cfg.z_limit                     = [0.1 0.5]; 
cfg.linewidth                   = 5;
cfg.linehsape                   = '-k';
subplot(2,2,3:4);
h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,alldata);
xlim(statplot.time([1 end]));
hline(0,'-k');
vline(0,'-k');
vline([1.5 3 4.5],'--k');

ylabel('ITC 2 - 6 Hz');

xticks([0 1.5 3 4.5 5.5]);
xticklabels({'1st Cue' 'Sample' '2nd Cue' 'Probe' 'RT'});
legend({'Bin1' '' 'Bin5' ''},'Location','northwest');

set(gca,'FontSize',16);