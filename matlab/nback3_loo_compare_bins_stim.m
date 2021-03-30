clear;clc;

suj_list            = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname                                     = ['sub' num2str(suj_list(nsuj))];
    
    dir_files                                   = 'P:/3035002.01/nback/';
    flist                                       = dir([dir_files 'auc/' sujname '.decoding.stim*.nodemean.leaveone.mat']);
    ext_decode                                  = 'stim';
    
    for nstim = 1:length(flist)
        
        % load decoding output
        fname                                   = [flist(nstim).folder filesep flist(nstim).name];
        fprintf('loading %s\n',fname);
        load(fname,'y_array','yproba_array','time_axis','e_array');
        
        % transpose matrices
        y_array                              	= y_array';
        yproba_array                            = yproba_array';
        e_array                              	= e_array';
        
        % load bin information
        ext_bin_name                            = 'exl500concat';
        fname                                   = [dir_files 'bin/' sujname '.' ext_bin_name '.binsummary.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        bin_summary                             = struct2table(bin_summary);
        
        list_band                           	= {'slow'}; % 'alpha' 'beta'};
        measure                              	= 'yproba'; % auc yproba
        
        dir_files                               = 'D:\Dropbox\project_me\data\nback\';
        fname                                   = [dir_files 'trialinfo/' sujname '.trialinfo.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        %         sub_info                                = trialinfo(:,[4 5 6]);
        %         sub_info_correct                        = sub_info(sub_info(:,1) == 1 | sub_info(:,1) == 3,:); % remove incorrect trials for RT analyses
        %         sub_info_correct                        = sub_info_correct(sub_info_correct(:,2) ~= 0,:); % remove zeros
        %         median_rt                               = median(sub_info_correct(:,2));
        %         index_trials{1}                         = sub_info_correct(find(sub_info_correct(:,2) < median_rt),3); % fast
        %         index_trials{2}                         = sub_info_correct(find(sub_info_correct(:,2) > median_rt),3); % slow
        
        for nband = 1:length(list_band)
            for nbin = [1 2]
                
                flg                             = find(strcmp(bin_summary.band,list_band{nband}) & ...
                    strcmp(bin_summary.bin,['b' num2str(nbin)]));
                
                idx_trials                      =  bin_summary(flg,:).index{:}; %index_trials{nbin};%
                
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
                
                alldata{nsuj,nband,nbin,nstim}	= avg; clear avg;
                
            end
        end
    end
    
end

%%

keep alldata list_* ext_decode

for nsuj = 1:size(alldata,1)
    for nband = 1:size(alldata,2)
        for nbin = 1:size(alldata,3)
            
            tmp         = {};
            
            for nstim = 1:size(alldata,4)
                if ~isempty(alldata{nsuj,nband,nbin,nstim})
                    tmp{end+1} = alldata{nsuj,nband,nbin,nstim};
                end
            end
                        
            newdata{nsuj,nband,nbin}    = ft_timelockgrandaverage([],tmp{:});
            clear tmp;
            
        end
    end
end

alldata                         = newdata;

keep alldata list_* ext_decode

%%

nsuj                          	= size(alldata,1);
[design,neighbours]          	= h_create_design_neighbours(nsuj,alldata{1},'gfp','t'); clc;

for nband = 1:size(alldata,2)
    
    cfg                         = [];
    cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                    = 1;cfg.ivar = 2;
    cfg.tail                    = 0;cfg.clustertail  = 0;
    cfg.neighbours              = neighbours;
    cfg.channel                 = 1;
    
    cfg.latency                 = [-0.1 1];
    cfg.clusteralpha            = 0.05; % !!
    cfg.minnbchan               = 0; % !!
    cfg.alpha                   = 0.025;
    
    cfg.numrandomization        = 1000;
    cfg.design                  = design;
    
    allstat{nband,1}          	= ft_timelockstatistics(cfg, alldata{:,nband,1}, alldata{:,nband,2});
    
end

keep alldata list_* allstat ext_decode

%%

clc;

nrow                         	= 2;
ncol                          	= 2;
i                             	= 0;
zlimit                        	= [0.4 1];
plimit                       	= 0.25;

for nband = 1:size(allstat,1)
    
    stat                        = allstat{nband,1};
    stat.mask                   = stat.prob < plimit;
    
    for nchan = 1:length(stat.label)
        
        vct                     = stat.prob(nchan,:);
        min_p                   = min(vct);
        
        cfg                     = [];
        cfg.channel             = nchan;
        cfg.time_limit          = [-0.05 1]; %stat.time([1 end]);
        cfg.color               = {'-b' '-r'};
        
        if strcmp(ext_decode,'condition')
            cfg.z_limit     	= [0.2 0.6];
        elseif strcmp(ext_decode,'target')
            cfg.z_limit       	= [0.2 1];
        elseif strcmp(ext_decode,'first')
            cfg.z_limit       	= [0.1 0.4];
        elseif strcmp(ext_decode,'stim')
            cfg.z_limit       	= [0 0.3];
        end
        
        cfg.linewidth           = 1;
        
        i = i+1;
        subplot(nrow,ncol,i);
        h_plotSingleERFstat_selectChannel_nobox(cfg,stat,squeeze(alldata(:,nband,:)));
        
        ylabel({stat.label{nchan}, ['p= ' num2str(round(min_p,3))]})
        
        vline([0],'--k');
        %         hline(0.5,'--k');
        
        title(list_band{nband});
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
        %         vct         = unique(stat.mask .* stat.time);
        %         disp(vct);
        
    end
end