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
    
    sujName                    	= suj_list{nsuj};
    fname                       = [project_dir 'data/' sujName '/tf/' sujName '.cuelock.itc.5binned.withEvoked.withIncorrect.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    list_bin                	= {'bin1' 'bin5'};
    i                           = 0;
    
    for nbin = [1 5]
        
        freq                    = phase_lock{nbin};
        freq                    = rmfield(freq,'rayleigh');
        freq                    = rmfield(freq,'p');
        freq              		= rmfield(freq,'sig');
        freq                    = rmfield(freq,'mask');
        freq                    = rmfield(freq,'mean_rt');
        freq                    = rmfield(freq,'med_rt');
        freq                    = rmfield(freq,'index');
        freq                    = rmfield(freq,'perc_corr');
        
        i                       = i +1;
        alldata{nsuj,i}         = freq; clear freq;
        
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
    cfg.frequency               = [1 7];
    
    list_name{i}                = [[list_bin{ix1}] ' versus ' [list_bin{ix2}]];
    stat{i}                     = ft_freqstatistics(cfg, alldata{:,ix1},alldata{:,ix2});
    [min_p(i), p_val{i}]        = h_pValSort(stat{i});
    
end

%%

nw_stat                         = stat{1};
nw_stat.mask                 	= nw_stat.prob < 0.3;

statplot                        = [];
statplot.powspctrm              = nw_stat.mask .* nw_stat.stat;
statplot.label               	= nw_stat.label;
statplot.dimord               	= nw_stat.dimord;
statplot.time               	= nw_stat.time;
statplot.freq               	= nw_stat.freq;

cfg                             = [];
cfg.layout                      = 'CTF275.lay';
cfg.zlim                        = [-0.3 0.3];
cfg.colormap                    = brewermap(256,'*RdBu');
cfg.marker                      = 'off';
cfg.comment                     = 'no';
cfg.colorbar                    = 'yes';
subplot(2,2,1);
ft_topoplotTFR(cfg,statplot);

list_chan = {'MLC42','MLC53','MLC54','MLC55','MLC62','MLC63','MLO11','MLO12', ... 
    'MLO13','MLO22','MLO23','MLP11','MLP21','MLP22','MLP23','MLP31','MLP32', ... 
    'MLP33','MLP34','MLP41','MLP42','MLP51','MLP52','MLP53','MLP54','MRC17', ...
    'MRC25','MRC32','MRC42','MRC53','MRC54','MRC55','MRC62','MRC63','MRF67',...
    'MRO11','MRO12','MRO13','MRO14','MRO22','MRO23','MRO24','MRP11','MRP12',...
    'MRP21','MRP22','MRP23','MRP31','MRP32','MRP33','MRP34','MRP35','MRP41',...
    'MRP42','MRP43','MRP44','MRP45','MRP51','MRP52','MRP53','MRP54','MRP55','MRP56',...
    'MRT15','MRT16','MRT23','MRT24','MRT25','MRT26','MRT27','MRT35','MRT36','MRT37','MRT46'};

fnd_chan                            = [];

for nchan = 1:length(list_chan)
    fnd_chan                        = [fnd_chan; find(strcmp(nw_stat.label,list_chan{nchan}))];
end

fnd_time                          	= [squeeze(mean(mean(nw_stat.mask(fnd_chan,1:5,:),1),2))]'; 
fnd_time(fnd_time ~= 0)             = 0.1;
fnd_time(fnd_time == 0)             = NaN;

statplot                            = [];
statplot.powspctrm                  = mean(nw_stat.stat(fnd_chan,:,:),1);
statplot.label                      = {'avg'};
statplot.dimord                     = nw_stat.dimord;
statplot.time                       = nw_stat.time;
statplot.freq                       = nw_stat.freq;
statplot.mask                       = logical(mean(nw_stat.mask(fnd_chan,:,:),1));

cfg                                 = [];
cfg.marker                          = 'off';
cfg.comment                         = 'no';
cfg.colormap                        = brewermap(256, '*RdBu');
cfg.colorbar                        = 'no';
cfg.zlim                            = [-3 3];
cfg.maskstyle                       = 'opacity';
cfg.maskparameter                   = 'mask';
cfg.maskalpha                       = 0.7;
subplot(2,2,2);
ft_singleplotTFR(cfg,statplot)
ylim([-0.1 5.5]);
xticks([0 1.5 3 4.5 5.5]);
xticklabels({'1st Cue' '1st Gab' '2nd Cue' '2nd Gab' 'RT'});
ylim([1 7]);
yticks([1 2 3 4 5 6 7]);


for nsuj = 1:size(alldata,1)
    for nbin = 1:size(alldata,2)
        
        fnd_chan                  	= [];
        
        for nchan = 1:length(list_chan)
            fnd_chan              	= [fnd_chan; find(strcmp(alldata{nsuj,nbin}.label,list_chan{nchan}))];
        end
        
        tmp                         = mean(squeeze(mean(alldata{nsuj,nbin}.powspctrm(fnd_chan,1:5,:),1)),1);
        mtrx_data(nsuj,nbin,:)      = tmp; clear tmp;
    end
end

subplot(2,2,3)
hold on;

% Use the standard deviation over trials as error bounds:
for ncon = 1:2
    tmp                                 = squeeze(mtrx_data(:,ncon,:));
    mean_data                           = nanmean(tmp,1);
    bounds                              = nanstd(tmp, [], 1);
    bounds_sem                          = bounds ./ sqrt(size(tmp,1));
    
    %     boundedline(stat.time, mean_data, bounds_sem,['-' cfg_in.color(ncon)],'alpha'); % alpha makes bounds transparent
    if ncon == 1
        boundedline(alldata{1,1}.time, mean_data, bounds_sem,'-b','alpha'); % alpha makes bounds transparent
    else
        boundedline(alldata{1,1}.time, mean_data, bounds_sem,'-r','alpha'); % alpha makes bounds transparent
    end
    clear mean_data bounds_sem bounds
end

xlim([-0.1 5.5]);
xticks([0 1.5 3 4.5 5.5]);
xticklabels({'1st Cue' '1st Gab' '2nd Cue' '2nd Gab' 'RT'});
ylim([0.02 0.1]);
yticks([0.02 0.1]);

plot(nw_stat.time,fnd_time,'LineWidth',6);