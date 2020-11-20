clear;clc;
global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

behav_table                     = readtable('../doc/bil.behavioralReport.n34.keep.cor.keep.rt.txt');

for nsuj = 1:length(suj_list)
    
    subjectName               	= suj_list{nsuj};
    auc_measures             	= [];
    
    dir_data                 	= 'D:/Dropbox/project_me/data/bil/decode/';
    list_decoding             	= {'frequency' 'orientation'};
    list_gab                    = {'2ndgab'}; % '1stgab' 
    
    avg                         = [];
    avg.avg                     = [];
    avg.label                   = {};
    
    for ngab = 1:length(list_gab)
        for ndeco = 1:length(list_decoding)
            % load files for both gabors
            flist                 	= dir([dir_data subjectName '.' list_gab{ngab}  '.lock' ...
                '.broadband.centered.decodinggabor.' list_decoding{ndeco} '.all.bsl.auc.mat']);
            
            for nf = 1:length(flist)
                fname             	= [flist(nf).folder filesep flist(nf).name];
                fprintf('loading %s\n',fname);
                load(fname);
                avg.avg             = [avg.avg;scores]; clear scores;
                avg.label           = [avg.label ; [list_gab{ngab} ' ' list_decoding{ndeco}]];
                
            end
        end
    end
    
    avg.dimord        	= 'chan_time';
    avg.time           	= time_axis;
    
    alldata{nsuj,1}   	= avg; keep alldata nsuj suj_list behav_table subjectName
    
    list_task       	= {'Orientation' 'Frequency'};
    i                   = 1;
    for ntask = 1:2
        
        find_suj     	= behav_table(strcmp(behav_table.suj,subjectName) & strcmp(behav_table.feat_attend,list_task{ntask}),:);
        find_correct  	= find_suj(find_suj.corr_rep == 1,:);
        
        i = i + 1;
        alldata{nsuj,i}   	= median(find_correct.react_time);
        
        i = i + 1;
        alldata{nsuj,i}   	= height(find_correct) ./ height(find_suj); clear find_*
        
    end
    
    alldata{nsuj,6}         = mean([alldata{nsuj,2} alldata{nsuj,4}]);
    alldata{nsuj,7}         = mean([alldata{nsuj,3} alldata{nsuj,5}]);
    
    
    list_behav              = {'ori rt' 'ori perc' 'freq rt' 'freq perc' 'mean rt' 'mean perc'};
    
end

%%

keep alldata list_behav

cfg                     = [];
cfg.method              = 'montecarlo';
cfg.latency             = [-0.1 1];
cfg.statistic           = 'ft_statfun_correlationT';
cfg.clusterstatistics   = 'maxsum';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;
cfg.ivar                = 1;

i                       = 0;

for nbehav = 2:size(alldata,2)
    
    nb_suj              = size(alldata,1);
    cfg.type            = 'Pearson';
    cfg.design(1,1:nb_suj)  	= [alldata{:,nbehav}];
    
    [~,neighbours] 		= h_create_design_neighbours(nb_suj,alldata{1,1},'gfp','t');
    cfg.neighbours      = neighbours;
    
    i                   = i + 1;
    
    if i < 3
        cfg.channel     = 2;
    elseif i == 3 || i == 4
        cfg.channel     = 1;
    else
        cfg.channel     = 'all';
    end
    
    stat{i}             = ft_timelockstatistics(cfg, alldata{:,1});
    [min_p(i),p_val{i}]	= h_pValSort(stat{i});
    
end

keep alldata allbehav list* stat min_p p_val

%%

i                                       = 0;
nrow                                    = 2;
ncol                                    = 2;
z_limit                                 = [0.9 0.9 0.9 0.9];
plimit                                  = 0.2;

for nbehav = 1:length(stat)
    
    statplot                            = stat{nbehav};
    statplot.mask                       = statplot.prob < plimit;
    
    for nchan = 1:length(statplot.label)
        
        tmp                             = statplot.mask(nchan,:,:) .* statplot.rho(nchan,:,:);
        iy                              = unique(tmp);
        iy                              = iy(iy~=0);
        
        tmp                             = statplot.mask(nchan,:,:) .* statplot.prob(nchan,:,:);
        ix                              = unique(tmp);
        ix                              = ix(ix~=0);
        
        if ~isempty(ix)
            
            i                           = i + 1;
            subplot(nrow,ncol,i)
            
            cfg                         = [];
            cfg.channel                 = statplot.label{nchan};
            cfg.p_threshold             = plimit;
            
            if isempty(strfind(statplot.label{nchan},'fre'))
                cfg.z_limit             = [0.49 0.6];
            else
                cfg.z_limit             = [0.47 0.9];
            end
            
            cfg.time_limit              = statplot.time([1 end]);
            list_color                  = 'rbkb';
            cfg.color                   = list_color(nchan);
            h_plotSingleERFstat_selectChannel(cfg,statplot,squeeze(alldata(:,1)));
            
            ylabel(statplot.label{nchan});
            
            title({['correlation with ' list_behav{nbehav}],[' p = ' num2str(round(min(ix),3))], [' r = ' num2str(round(min(iy),1))]});
            set(gca,'FontSize',14,'FontName', 'Calibri');
            vline(0,'-k');
            hline(0.5,'-k');
            
        end
    end
end