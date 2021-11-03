clear;clc;

if isunix
    project_dir                                	= '/project/3015079.01/';
    start_dir                                 	= '/project/';
else
    project_dir                               	= 'P:/3015079.01/';
    start_dir                                	= 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

list_win                                        = {'1stgab' 'orientation'; '2ndgab' 'orientation'; '1stgab' 'frequency'; '2ndgab' 'frequency'};

for nsuj = 1:length(suj_list)
    for nw 	= 1:size(list_win,1)
        
        ix_win                                	= nw;
        
        subjectName                         	= suj_list{nsuj};
        subject_folder                        	= [project_dir 'data/' subjectName '/decode/'];
        
        fname                                	= [subject_folder subjectName '.' list_win{ix_win,1}   ...
            '.lock.broadband.centered.decoding.'  list_win{ix_win,2} '.leaveone.mat'];
        fprintf('loading %s\n',fname);
        
        if exist(fname)
            fprintf('loading %s\n',fname);
            load(fname,'y_array','yproba_array','time_axis','e_array');
        else
            
            conc_y_array                        = [];
            conc_yproba_array                   = [];
            conc_e_array                    	= [];
            
            load([subject_folder subjectName '.' list_win{ix_win,1}   ...
                '.lock.broadband.centered.decoding.'  list_win{ix_win,2} '.t0.leaveone.mat'],'time_axis');
            
            for nt = 1:length(time_axis)
                fname                           = [subject_folder subjectName '.' list_win{ix_win,1}   ...
                    '.lock.broadband.centered.decoding.'  list_win{ix_win,2} '.t' num2str(nt-1) '.leaveone.mat'];
                fprintf('loading %s\n',fname);
                load(fname,'y_array','yproba_array','time_axis','e_array');
                conc_y_array(nt,:)              = y_array(nt,:);
                conc_yproba_array(nt,:)       	= yproba_array(nt,:);
                conc_e_array(nt,:)           	= e_array(nt,:); clear y_proba yproba_array e_array; clc;
                
            end
            
            y_array                             = conc_y_array;
            yproba_array                    	= conc_yproba_array;
            e_array                             = conc_e_array; clear conc_*
            
        end
        
        y_array                              	= y_array';
        yproba_array                            = yproba_array';
        e_array                              	= e_array';
        
        list_band                           	= {'theta' 'alpha' 'beta'};
        measure                              	= 'y proba'; %'auc'; %
        
        idx_trials                              = 1:size(yproba_array,1);
        
        for ntime = 1:size(y_array,2)
            
            if strcmp(measure,'y proba')
                
                yproba_array_test     	= yproba_array(idx_trials,ntime);
                
                if min(unique(y_array(:,ntime))) == 1
                    yarray_test        	= y_array(idx_trials,ntime) - 1;
                else
                    yarray_test       	= y_array(idx_trials,ntime);
                end
                
                [~,~,~,AUC_bin_test(ntime)]	= perfcurve(yarray_test,yproba_array_test,1);
            else
                AUC_bin_test(ntime)     = mean(e_array(idx_trials,ntime));
            end
        end
        
        avg                          	= [];
        avg.avg                      	= AUC_bin_test;
        avg.time                      	= time_axis;
        avg.label                      	= {[list_win{nw,1} ' ' list_win{nw,2}(1:3)]};
        avg.dimord                     	= 'chan_time';
        
        alldata{nsuj,nw}             	= avg; clear avg;
        
    end
    
    tmp{1}                              = alldata{nsuj,1};  tmp{1}.label = {'for avg'};
    tmp{2}                              = alldata{nsuj,2};  tmp{2}.label = {'for avg'};
    alldata{nsuj,5}                     = ft_timelockgrandaverage([],tmp{:}); clear tmp;
    alldata{nsuj,5}.label               = {'allgab ori'};
    
    tmp{1}                              = alldata{nsuj,3};  tmp{1}.label = {'for avg'};
    tmp{2}                              = alldata{nsuj,4};  tmp{2}.label = {'for avg'};
    alldata{nsuj,6}                     = ft_timelockgrandaverage([],tmp{:}); clear tmp;
    alldata{nsuj,6}.label               = {'allgab fre'};
    
    tmp{1}                              = alldata{nsuj,5};  tmp{1}.label = {'for avg'};
    tmp{2}                              = alldata{nsuj,6};  tmp{2}.label = {'for avg'};
    alldata{nsuj,7}                     = ft_timelockgrandaverage([],tmp{:}); clear tmp;
    alldata{nsuj,7}.label               = {'allgab mean'};
    
    behav_table                         = readtable('../doc/bil.behavioralReport.n34.keep.cor.keep.rt.txt');
    list_task                           = {'Orientation' 'Frequency'};
    i                                   = 0;
    
    for ntask = 1:2
        
        find_suj                        = behav_table(strcmp(behav_table.suj,subjectName) & strcmp(behav_table.feat_attend,list_task{ntask}),:);
        find_correct                    = find_suj(find_suj.corr_rep == 1,:);
        
        i = i + 1;
        allbehav{nsuj,i}                = median(find_correct.react_time);
        i = i + 1;
        allbehav{nsuj,i}                = height(find_correct) ./ height(find_suj); clear find_*
        
    end
    
    allbehav{nsuj,5}                    = mean([allbehav{nsuj,1} allbehav{nsuj,3}]);
    allbehav{nsuj,6}                    = mean([allbehav{nsuj,2} allbehav{nsuj,4}]);
    
    list_behav                          = {'ori rt' 'ori perc' 'fre rt' 'fre perc' 'mean rt' 'mean perc'};
    
    keep alldata allbehav list_* nsuj suj_list nwin project_dir;
    
end

%%

keep alldata allbehav list_*

cfg                                     = [];
cfg.method                              = 'montecarlo';
cfg.latency                             = [0.2 0.5];
cfg.statistic                           = 'ft_statfun_correlationT';
cfg.clusterstatistics                   = 'maxsum';
cfg.correctm                            = 'cluster';
cfg.clusteralpha                        = 0.05;
cfg.tail                                = 0;
cfg.clustertail                         = 0;
cfg.alpha                               = 0.025;
cfg.numrandomization                    = 1000;
cfg.ivar                                = 1;
nb_suj                                  = size(allbehav,1);

[~,neighbours]                          = h_create_design_neighbours(nb_suj,alldata{1,1},'gfp','t');
cfg.neighbours                          = neighbours;
cfg.type                                = 'Spearman'; %'Pearson';%


for nw = 1:size(alldata,2)
    for nb = 1:size(allbehav,2)
        
        what_win                        = strsplit(alldata{1,nw}.label{:},' ');
        
        if strcmp(what_win{1},'allgab')
            
            what_win                	= what_win{2};
            
            what_beh                  	= strsplit(list_behav{nb},' ');
            what_beh                  	= what_beh{1};
            
            if strcmp(what_win,what_beh)
                
                cfg.design            	= [];
                cfg.design(1,1:nb_suj) 	= [allbehav{:,nb}];
                
                stat{nw,nb}            	= ft_timelockstatistics(cfg, alldata{:,nw});
                [min_p(nw,nb),p_val{nw,nb}]	= h_pValSort(stat{nw,nb});
                
            end
            
        end
    end
end

keep alldata allbehav list_* stat min_p

close all;

i                                           = 0;
nrow                                        = 2;
ncol                                        = 2;
z_limit                                     = [0.9 0.9 0.9 0.9];
plimit                                      = 0.2;

for nwin = 1:size(stat,1)
    for nbehav = 1:size(stat,2)
        
        if min_p(nwin,nbehav) < plimit && min_p(nwin,nbehav) > 0
            
            statplot                      	= stat{nwin,nbehav};
            statplot.mask                 	= statplot.prob < plimit;
            nchan                       	= 1;
            
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
                
                if strfind(statplot.label{nchan},'fre')
                    cfg.z_limit             = [0.45 0.9];
                else
                    cfg.z_limit             = [0.45 0.7];
                end
                
                cfg.time_limit              = statplot.time([1 end]);
                list_color                  = 'rbkb';
                cfg.color                   = list_color(nchan);
                
                h_plotSingleERFstat_selectChannel(cfg,statplot,squeeze(alldata(:,nwin)));
                
                ylabel(statplot.label{nchan});
                
                title({['correlation with ' list_behav{nbehav}],[' p = ' num2str(round(min(ix),3))], [' r = ' num2str(round(min(iy),1))]});
                set(gca,'FontSize',14,'FontName', 'Calibri');
                vline(0,'-k');
                hline(0.5,'-k');
                
            end
        end
    end
end