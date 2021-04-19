clear;clc;

allbehav                                = [];

for nsuj = [1:33 35:36 38:44 46:51]
    
    dir_data                            = '~/Dropbox/project_me/data/nback/trialinfo/';
    fname                               = [dir_data 'sub' num2str(nsuj) '.trialinfo.mat'];
    load(fname);
    
    flg_nback_stim                      = find(trialinfo(:,2) == 2);
    sub_info                            = trialinfo(flg_nback_stim,[4 5 6]);
    
    sub_info_correct                    = sub_info(sub_info(:,1) == 1 | sub_info(:,1) == 3,:); % remove incorrect trials for RT analyses
    sub_info_correct                    = sub_info_correct(sub_info_correct(:,2) ~= 0,:); % remove zeros
    
    %     median_rt                           = median(sub_info_correct(:,2));
    %     allbehav                            = [allbehav;median_rt];
    
    perc_correct                        = length(sub_info_correct) ./ length(sub_info);
    allbehav                            = [allbehav;perc_correct];
    
end

keep allbehav

%%

suj_list  	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname                           	= ['sub' num2str(suj_list(nsuj))];
    
    dir_files                          	= '~/Dropbox/project_me/data/nback/'; %'P:/3035002.01/nback/';
    flist                               = dir([dir_files 'auc/' sujname '.decoding.stim*.nodemean.leaveone.mat']);
    ext_decode                       	= 'stim';
        
    for nstim = 1:length(flist)
        
        % load decoding output
        fname                        	= [flist(nstim).folder filesep flist(nstim).name];
        fprintf('loading %s\n',fname);
        load(fname,'y_array','yproba_array','time_axis','e_array');
        
        % transpose matrices
        y_array                     	= y_array';
        yproba_array                  	= yproba_array';
        e_array                      	= e_array';
        measure                      	= 'yproba'; % auc yproba
        
        idx_trials                      = 1:size(yproba_array,1);
        
        AUC_bin_test                 	= [];
        disp('computing AUC');
        
        for ntime = 1:size(y_array,2)
            
            if strcmp(measure,'yproba')
                
                yproba_array_test     	= yproba_array(idx_trials,ntime);
                
                if min(unique(y_array(:,ntime))) == 1
                    yarray_test        	= y_array(idx_trials,ntime) - 1;
                else
                    yarray_test       	= y_array(idx_trials,ntime);
                end
                
                [~,~,~,AUC_bin_test(ntime)]	= perfcurve(yarray_test,yproba_array_test,1);
                
            elseif strcmp(measure,'auc')
                AUC_bin_test(ntime)     = mean(e_array(idx_trials,ntime));
            end
        end
        
        avg                             = [];
        avg.avg                         = AUC_bin_test;
        avg.time                        = time_axis;
        avg.label                       = {['decoding ' ext_decode]};
        avg.dimord                      = 'chan_time';
        
        tmp{nstim}                      = avg; clear avg;
        
    end
    
    alldata{nsuj,1}                     = ft_timelockgrandaverage([],tmp{:}); clear tmp;
    
end

keep all* ext_decode

%%

cfg                         = [];
cfg.method                  = 'montecarlo';
cfg.latency                 = [0 1];
cfg.statistic               = 'ft_statfun_correlationT';
cfg.clusterstatistics       = 'maxsum';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.alpha                   = 0.025;
cfg.numrandomization        = 1000;
cfg.ivar                    = 1;

list_corr                   = {'Spearman' 'Pearson'};

for n = [1 2]
    
    nb_suj                  = size(alldata,1);
    cfg.type                = list_corr{n};
    cfg.design(1,1:nb_suj) 	= [allbehav];
    
    [~,neighbours]        	= h_create_design_neighbours(nb_suj,alldata{1,1},'gfp','t');
    cfg.neighbours          = neighbours;
    
    stat{n}                 = ft_timelockstatistics(cfg, alldata{:});
    [min_p(n),p_val{n}]   	= h_pValSort(stat{n});
    
end

%%

clc;

i                                	= 0;
nrow                               	= 2;
ncol                               	= 2;
plimit                              = 0.15;

for ncorr = 1:length(stat)
    
    statplot                        = stat{ncorr};
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
        cfg.channel                 = nchan;
        cfg.p_threshold             = plimit;

        cfg.time_limit              = [-0.1 1];
        list_color                  = 'k';
        cfg.color                   = list_color(nchan);
        cfg.lineshape               = '-r';
        cfg.linewidth               = 5;

        if strcmp(ext_decode,'condition')
            cfg.z_limit     	= [0.2 0.6];
        elseif strcmp(ext_decode,'target')
            cfg.z_limit       	= [0.2 1];
        elseif strcmp(ext_decode,'first')
            cfg.z_limit       	= [0.1 0.4];
        elseif strcmp(ext_decode,'stim')
            cfg.z_limit       	= [0.05 0.2];
        end
        
        h_plotSingleERFstat_selectChannel_nobox(cfg,statplot,alldata);
        
        if strcmp(ext_decode,'condition')
            hline(0.35,'--k');
        elseif strcmp(ext_decode,'target')
            hline(0.35,'--k');
        elseif strcmp(ext_decode,'first')
            hline(0.17,'--k');
        elseif strcmp(ext_decode,'stim')
            hline(0.07,'--k');
        end
        
        ylabel(statplot.label{nchan});

        title(['p = ' num2str(round(min(ix),3)) ' r = ' num2str(round(min(iy),1))]);
        set(gca,'FontSize',16,'FontName', 'Calibri');
        vline(0,'--k');

    end
end