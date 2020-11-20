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
            '.broadband.centered.decodingcue.' decoding_list{ndeco}  '.all.auc.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        tmp                     = [tmp;scores]; clear scores;
    end
    
    avg                	= [];
    avg.avg            	= tmp; clear new;
    avg.label          	= {'cue1 decoding' 'cue2 decoding'};
    avg.dimord      	= 'chan_time';
    avg.time         	= time_axis;
    
    alldata{nsuj,1}   	= avg; keep alldata nsuj suj_list behav_table subjectName
    
    list_cue            = {'pre' 'retro'};
    i                   = 1;
    for ncue = 1:2
        
        find_suj     	= behav_table(strcmp(behav_table.suj,subjectName) & strcmp(behav_table.cue_type,list_cue{ncue}),:);
        find_correct  	= find_suj(find_suj.corr_rep == 1,:);
        
        i = i + 1;
        alldata{nsuj,i}   	= median(find_correct.react_time);
        
        i = i + 1;
        alldata{nsuj,i}   	= height(find_correct) ./ height(find_suj); clear find_*
        
    end
    
    list_behav          = {'pre rt' 'pre perc' 'retro rt' 'retro perc'};
    
end

keep alldata list_behav

cfg                     = [];
cfg.method              = 'montecarlo';
cfg.latency             = [-0.1 5.5];
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
i                       = 0;

for nbehav = 2:size(alldata,2)
    
    nb_suj       	= size(alldata,1);
    cfg.type      	= 'Spearman';
    cfg.design(1,1:nb_suj)  	= [alldata{:,nbehav}];
    
    [~,neighbours] 	= h_create_design_neighbours(nb_suj,alldata{1,1},'gfp','t');
    cfg.neighbours 	= neighbours;
    
    i               = i + 1;
    stat{i}   	= ft_timelockstatistics(cfg, alldata{:,1});
    [min_p(i),p_val{i}]                	= h_pValSort(stat{i});
    
end

keep alldata allbehav list* stat min_p p_val

%%

i                                	= 0;
nrow                               	= 3;
ncol                               	= 2;
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
        
        if ~isempty(ix)
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
            
            title([list_behav{nbehav} ' p = ' num2str(round(min(ix),3)) ' r = ' num2str(round(min(iy),1))]);
            set(gca,'FontSize',10,'FontName', 'Calibri');
            vline(0,'--k');
            hline(0.5,'--k');
            
        end
    end
end
