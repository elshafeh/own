clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

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
    fname                           = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.1overf.orig.alphabetaPeak.' ...
        'm1000m0ms.mat'];
    load(fname);
    allpeaks(nsuj,1)                = [apeak_orig];
    allpeaks(nsuj,2)                = [bpeak_orig];
    
end

allpeaks(isnan(allpeaks(:,2)),2) 	= nanmean(allpeaks(:,2));

keep allpeaks suj_list project_dir

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    pow                             = [];
    
    for nbin = 1:5
        
        fname                       = [project_dir 'data/' subjectName '/tf/' subjectName '.itc.withcorrect.bin' num2str(nbin) '.mtm.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        list_band                 	= {'theta' 'alpha' 'beta'};
        
        for nband = 1:length(list_band)
            
            test_band            	= list_band{nband};
            fprintf('looking for %s\n',test_band);
            
            switch test_band
                case 'theta'
                    f_focus        	= 4;
                    f_width       	= 1;
                case 'alpha'
                    f_focus       	= allpeaks(nsuj,1);
                    f_width       	= 1;
                case 'beta'
                    f_focus        	= allpeaks(nsuj,2);
                    f_width        	= 2;
                case 'gamma'
                    f_focus      	= 80;
                    f_width        	= 20;
            end
            
            f1                     	= find(round(freq_comb.freq) == round(f_focus-f_width));
            f2                    	= find(round(freq_comb.freq) == round(f_focus+f_width));
            
            pow(nband,nbin,:,:)    	= squeeze(nanmean(freq_comb.powspctrm(:,f1:f2,:),2));
            
        end
    end
    
    % -- baseline correct
    
    for nband = 1:3
        
        sub_pow                         = squeeze(pow(nband,:,:,:));
        bsl                             = squeeze(mean(sub_pow,1));
        
        for nbin = 1:5
            avg                         = [];
            avg.time                    = freq_comb.time;
            avg.label                   = freq_comb.label;
            avg.dimord                  = 'chan_time';
            avg.avg                     = squeeze(sub_pow(nbin,:,:)) ./ bsl;
            alldata{nsuj,nbin,nband}    = avg; clear avg;
        end
    end
    
    keep alldata allpeaks suj_list nsuj project_dir list_*
    
    fprintf('\n');
    
end

keep alldata list_*;

%%

list_name                           = {};
i                                   = 0;

for nband = 1:size(alldata,3)
    
    nsuj                            = size(alldata,1);
    [design,neighbours]             = h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;
    
    cfg                             = [];
    cfg.clusterstatistic            = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                    = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                        = 1;cfg.ivar = 2;
    cfg.tail                        = 0;cfg.clustertail  = 0;
    cfg.neighbours                  = neighbours;
    
    cfg.clusteralpha                = 0.05; % !!
    cfg.minnbchan                   = 4; % !!
    cfg.alpha                       = 0.025;
    
    cfg.numrandomization            = 1000;
    cfg.design                      = design;
    
    i                               = i +1;
    cfg.latency                     = [-0.1 5.5];
    
    list_name{i}                    = [list_band{nband} ' B5 versus B1'];
    stat{i}                         = ft_timelockstatistics(cfg, alldata{:,5,nband},alldata{:,1,nband});
    [min_p(i), p_val{i}]            = h_pValSort(stat{i});
    
end

keep alldata list_* stat min_p p_val; clc ;

%%

close all;

for nband = 1:length(stat)
    
    figure;
    
    test_band                       = list_band{nband};
    
    nw_stat                         = stat{nband};
    nw_stat.mask                 	= nw_stat.prob < 0.05;
    
    statplot                        = [];
    statplot.avg                  	= nw_stat.mask .* nw_stat.stat;
    statplot.label               	= nw_stat.label;
    statplot.dimord               	= nw_stat.dimord;
    statplot.time               	= nw_stat.time;
    
    cfg                             = [];
    cfg.layout                      = 'CTF275.lay';
    cfg.zlim                        = [-3 3];
    cfg.colormap                    = brewermap(256,'*RdBu');
    cfg.marker                      = 'off';
    cfg.comment                     = 'no';
    cfg.colorbar                    = 'yes';
    subplot(2,2,1);
    
    switch test_band
        case 'theta'
            cfg.xlim                = [2.3 4.1];
        case 'alpha'
            cfg.xlim                = [4.1 5.1];
        case 'beta'
            cfg.xlim                = [4.1 5.1];
    end
    
    ft_topoplotER(cfg,statplot);
    
    switch test_band
        case 'theta'
            list_chan           	= {'MLF22','MLF31','MLF32','MLF41','MLF42','MLF43','MLF51','MLT22','MLT32','MLT42','MZF02'};
        case 'alpha'
            list_chan             	= {'MLC55','MLO11','MLP11','MLP21','MLP31', ... 
                'MLP32','MLP51','MLP52','MRC55','MRO11','MRO12','MRP11','MRP12','MRP21','MRP22','MRP31','MRP32', ... 
                'MRP41','MRP51','MRP52'};
        case 'beta'
            list_chan             	= {'MLP11', 'MLP21', 'MLP22', 'MLP31', 'MLP32', 'MLP33', 'MLP41', 'MLP42', ...
                'MLP51', 'MLP52', 'MLP53', 'MRP11', 'MRP21', 'MRP31', 'MRP51', 'MZP01'};
    end
    
    cfg                             = [];
    cfg.channel                     = list_chan;
    cfg.time_limit              	= nw_stat.time([1 end]);
    cfg.color                       = {'-b' '-r'};
    cfg.z_limit                     = [0.8 1.3];
    cfg.linewidth                   = 10;
    subplot(2,2,3:4);
    h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,squeeze(alldata(:,[1 5],nband)));
    xlim(statplot.time([1 end]));
    hline(1,'-k');
    vline(0,'-k');
    xticks([0 1.5 3 4.5 5.5]);
    xticklabels({'1st Cue' '1st Gab' '2nd Cue' '2nd Gab' 'RT'});
    yticks(sort([cfg.z_limit 1]));
    
    clear list_chan test_band nw_stat statplot
    
end