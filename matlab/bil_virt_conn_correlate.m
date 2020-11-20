clear;clc; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

behav_table                     = readtable('../doc/bil.behavioralReport.n34.keep.cor.keep.rt.txt');
load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                          	= suj_list{nsuj};
    list_cond                               = {'pre' 'retro' 'correct'};
    
    for ncond = 1:length(list_cond)
        
        list_connec                         = 'plv'; % coh coh.imag plv ppc amplcorr
        list_band                           = 'beta'; % theta alpha beta gamma
        
        fname                               = ['~/Dropbox/project_me/data/bil/virt/' subjectName '.wallis.' list_connec '.' list_cond{ncond} '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        subjectName                         = suj_list{nsuj};
        dir_data                            = '~/Dropbox/project_me/data/bil/virt/';
        
        list_all                            = {'theta' 'alpha' 'beta' 'gamma'};
        
        f_center                            = find(strcmp(list_band,list_all));
        
        test_done                        	= {};
        chan_label                       	= {};
        data                            	= [];
        i                                   = 0;
        
        for xi =  [1]
            for yi = 1:length(coh.label)
                
                if xi ~= yi
                    
                    str_check_1         	= [num2str(xi) '.' num2str(yi)];
                    str_fnd_1             	= find(strcmp(test_done,str_check_1));
                    
                    str_check_2            	= [num2str(yi) '.' num2str(xi)];
                    str_fnd_2            	= find(strcmp(test_done,str_check_2));
                    
                    
                    if isempty(str_fnd_1) && isempty(str_fnd_2)
                        
                        i                   = i + 1;
                        
                        if isfield(coh,'cohspctrm')
                            tmp          	= squeeze(coh.cohspctrm(xi,yi,f_center,:));
                        elseif isfield(coh,'plvspctrm')
                            tmp          	= squeeze(coh.plvspctrm(xi,yi,f_center,:));
                        elseif isfield(coh,'ppcspctrm')
                            tmp          	= squeeze(coh.ppcspctrm(xi,yi,f_center,:));
                        elseif isfield(coh,'amplcorrspctrm')
                            tmp          	= squeeze(coh.amplcorrspctrm(xi,yi,f_center,:));
                        end
                        
                        data(i,:)           = tmp; clear tmp;
                        test_done           = [test_done; [num2str(xi) '.' num2str(yi)]; [num2str(yi) '.' num2str(xi)]];
                        chan_label          = [chan_label; [coh.label{xi} ' to ' coh.label{yi}]];
                        
                    end
                    
                end
                
            end
        end
        
        keep coh data nsuj suj_list ncond list_* subjectName chan_label alldata behav_table
        
        avg                                 = [];
        avg.avg                             = data; clear data;
        avg.time                            = coh.time;
        avg.label                           = chan_label;
        avg.dimord                          = 'chan_freq_time';
        
        t1                                  = find(round(avg.time,2) == round(-0.4,2));
        t2                                  = find(round(avg.time,2) == round(-0.2,2));
        bsl                                 = mean(avg.avg(:,t1:t2),2);
        
        if ~strcmp(list_connec,'coh.imag')
            avg.avg                     	= (avg.avg - bsl);% ./ bsl;
        end
        
        alldata{nsuj,ncond}                 = avg ; clear freq chan_label;
        
    end
    
    list_cue                = {'pre' 'retro'};
    i                       = 0;
    for ncue = 1:2
        
        find_suj            = behav_table(strcmp(behav_table.suj,subjectName) & strcmp(behav_table.cue_type,list_cue{ncue}),:);
        find_correct        = find_suj(find_suj.corr_rep == 1,:);
        
        i = i + 1;
        allbehav{nsuj,i}   	= median(find_correct.react_time);
        
        i = i + 1;
        allbehav{nsuj,i}   	= height(find_correct) ./ height(find_suj); clear find_*
        
    end
    
    allbehav{nsuj,5}         = mean([allbehav{nsuj,1} allbehav{nsuj,3}]);
    allbehav{nsuj,6}         = mean([allbehav{nsuj,2} allbehav{nsuj,4}]);
    
    
    list_behav              = {'ori rt' 'ori perc' 'freq rt' 'freq perc' 'mean rt' 'mean perc'};
    
end

keep all* list_*

%%

cfg                         = [];
cfg.method                  = 'montecarlo';
cfg.latency                 = [-0.1 5.5];
cfg.statistic               = 'ft_statfun_correlationT';
cfg.clusterstatistics       = 'maxsum';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.alpha                   = 0.025;
cfg.numrandomization        = 1000;
cfg.ivar                    = 1;

i                           = 0;

for ncue = 1:size(alldata,2)
    for nbehav = 1:size(allbehav,2)
        
        nb_suj              = size(alldata,1);
        cfg.type            = 'Spearman';
        cfg.design(1,1:nb_suj)  	= [allbehav{:,nbehav}];
        
        [~,neighbours] 		= h_create_design_neighbours(nb_suj,alldata{1,ncue},'gfp','t');
        cfg.neighbours      = neighbours;
        
        i                   = i + 1;
        
        stat{i}             = ft_timelockstatistics(cfg, alldata{:,ncue});
        [min_p(i),p_val{i}]	= h_pValSort(stat{i});
        
        list_test{i}        = {[list_band ' ' list_connec], [list_cond{ncue} ' with ' list_behav{nbehav}]};
        list_index{i,1}     = ncue;
        list_index{i,2}     = nbehav;
        
        
    end
end

keep all* list_* stat min_p p_val

%%
i                                       = 0;
nrow                                    = 2;
ncol                                    = 2;
plimit                                  = 0.2;

for ntest = 1:length(stat)
    
    statplot                            = stat{ntest};
    statplot.mask                       = statplot.prob < plimit;
    
    for nchan = 1:length(statplot.label)
        
        tmp                             = statplot.mask(nchan,:,:) .* statplot.rho(nchan,:,:);
        iy                              = unique(tmp);iy 	= iy(iy~=0);
        
        tmp                             = statplot.mask(nchan,:,:) .* statplot.prob(nchan,:,:);
        ix                              = unique(tmp); ix 	= ix(ix~=0);
        
        if ~isempty(ix)
            
            i                           = i + 1;
            subplot(nrow,ncol,i)
            
            cfg                         = [];
            cfg.channel                 = statplot.label{nchan};
            cfg.p_threshold             = plimit;
            %                 cfg.z_limit             = [0.49 0.6];
            cfg.time_limit              = statplot.time([1 end]);
            list_color                  = 'k';
            cfg.color                   = list_color(1);
            h_plotSingleERFstat_selectChannel(cfg,statplot,squeeze(alldata(:,list_index{ntest,2})));
            
            ylabel({statplot.label{nchan},['r = ' num2str(round(min(iy),1))]});
            
            title(list_test{ntest});
            set(gca,'FontSize',12,'FontName', 'Calibri');
            vline(0,'-k');
            hline(0.5,'-k');
            
        end
    end
end