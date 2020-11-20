clear;clc;
global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

behav_table                     = readtable('../doc/bil.behavioralReport.n34.keep.cor.keep.rt.txt');

for nsuj = 1:length(suj_list)
    
    subjectName               	= suj_list{nsuj};
    auc_measures             	= [];
    
    dir_data                 	= 'D:/Dropbox/project_me/data/bil/decode/';
    
    frequency_list           	= {'broadband'};
    decoding_list            	= {'pre.ori.vs.spa' 'retro.ori.vs.spa'};
    
    % load in cue data
    
    tmp                         = [];
    
    for ndeco = 1:length(decoding_list)
        fname                  	= [dir_data subjectName '.1stcue.lock' ...
            '.broadband.centered.decodingcue.' decoding_list{ndeco}  '.correct.auc.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        tmp                     = [tmp;scores]; clear scores;
    end
    
    avg.time                	= time_axis;
    
    t1                          = find(round(time_axis,2) == round(-0.1,2));
    t2                          = find(round(time_axis,2) == round(0.9,2));
    t3                          = find(round(time_axis,2) == round(2.9,2));
    t4                          = find(round(time_axis,2) == round(3.9,2));
    
    nw(1,:)                     = tmp(1,t1:t2);
    nw(2,:)                     = tmp(1,t3:t4); clear tmp t1 t2 t3 t4
    
    decoding_list             	= {'frequency' 'orientation'};
    list_ext                    = {'1stgab' '2ndgab'};
    
    for ngab = 1:2
        
        % load files for both gabors
        tmp1                 	= dir([dir_data subjectName '.' list_ext{ngab}  '.lock' ...
            '.broadband.centered.decodinggabor.frequency.correct.bsl.auc.mat']);
        
        tmp2                 	= dir([dir_data subjectName '.' list_ext{ngab}  '.lock' ...
            '.broadband.centered.decodinggabor.orientation.correct.bsl.auc.mat']);
        
        flist                   = [tmp1;tmp2];
        tmp                     = [];
        
        for nf = 1:length(flist)
            fname             	= [flist(nf).folder filesep flist(nf).name];
            fprintf('loading %s\n',fname);
            load(fname);
            t1                 	= find(round(time_axis,2) == round(-0.1,2));
            t2               	= find(round(time_axis,2) == round(0.9,2));
            tmp                 = [tmp;scores(:,t1:t2)]; clear scores fname
        end
        
        nw                      = [nw;mean(tmp,1)]; clear tmp;
        
    end
    
    avg                         = [];
    avg.avg                     = nw; clear new;
    avg.label                   = {'cue1 decoding' 'cue2 decoding' 'gab1 decoding' 'gab2 decoding'};
    avg.dimord                  = 'chan_time';
    avg.time                    = time_axis(t1:t2);
    
    alldata{nsuj,1}             = avg; keep alldata nsuj suj_list behav_table subjectName
    
    find_suj                	= behav_table(find(strcmp(behav_table.suj,subjectName)),:);
    find_correct                = find_suj(find_suj.corr_rep == 1,:);
    
    alldata{nsuj,2}             = median(find_correct.react_time);
    alldata{nsuj,3}             = height(find_correct) ./ height(find_suj); clear find_*
    
end

keep alldata

cfg                     = [];
cfg.method              = 'montecarlo';
cfg.latency             = [0 1];
cfg.statistic           = 'ft_statfun_correlationT';
cfg.clusterstatistics   = 'maxsum';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;
cfg.ivar                = 1;

list_corr               = {'Spearman'};

for nbehav = [1 2]
    
    nb_suj       	= size(alldata,1);
    cfg.type      	= 'Spearman';
    cfg.design(1,1:nb_suj)  	= [alldata{:,nbehav+1}];
    
    [~,neighbours] 	= h_create_design_neighbours(nb_suj,alldata{1,1},'gfp','t');
    cfg.neighbours 	= neighbours;
    
    stat{nbehav}   	= ft_timelockstatistics(cfg, alldata{:,1});
    [min_p(nbehav),p_val{nbehav}]                	= h_pValSort(stat{nbehav});
    
end

keep alldata allbehav list* stat min_p p_val

%%

i                                	= 0;
nrow                               	= 3;
ncol                               	= 3;
z_limit                           	= [0.6 0.6 0.8 0.8];
plimit                              = 0.3;

for nbehav = 1:length(stat)
    
    statplot                        = stat{nbehav};
    statplot.mask               	= statplot.prob < plimit;
    
    for nchan = 1:length(statplot.label)
        
        tmp                     	= statplot.mask(nchan,:,:) .* statplot.rho(nchan,:,:);
        iy                        	= unique(tmp);
        iy                       	= iy(iy~=0);
        
        tmp                         = statplot.mask(nchan,:,:) .* statplot.prob(nchan,:,:);
        ix                          = unique(tmp);
        ix                          = ix(ix~=0);
        
        i                           = i + 1;
        subplot(nrow,ncol,i)
        
        cfg                         = [];
        cfg.channel                 = statplot.label{nchan};
        cfg.p_threshold             = plimit;
        cfg.z_limit                 = [0.47 z_limit(nchan)];
        cfg.time_limit              = statplot.time([1 end]);
        list_color                  = 'rgbk';
        cfg.color                   = list_color(nchan);
        h_plotSingleERFstat_selectChannel(cfg,statplot,squeeze(alldata(:,1)));
        
        ylabel(statplot.label{nchan});
        
        list_behav                  = {'rt' 'perc corr'};
        
        title([list_behav{nbehav} ' p = ' num2str(round(min(ix),3)) ' r = ' num2str(round(min(iy),1))]);
        set(gca,'FontSize',10,'FontName', 'Calibri');
        vline(0,'--k');
        hline(0.5,'--k');
        xticks([0:0.1:1]);
        
    end
end
