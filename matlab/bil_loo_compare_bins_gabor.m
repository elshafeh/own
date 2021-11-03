clear;clc;

if isunix
    project_dir                                	= '/project/3015079.01/';
    start_dir                                 	= '/project/';
else
    project_dir                               	= 'P:/3015079.01/';
    start_dir                                	= 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

list_win                                        = {'1stgab' 'orientation'; '2ndgab' 'orientation'};
% list_win                                        = {'1stgab' 'frequency'; '2ndgab' 'frequency'};

for nsuj = 1:length(suj_list)
    for nwin 	= 1:size(list_win,1)
        
        ix_win                                	= nwin;
        
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
        
        for nband = 1:length(list_band)
            
            subject_folder                     	= [project_dir 'data/' subjectName '/tf/'];
            fname                           	= [subject_folder subjectName '.' list_win{ix_win,1} ...
                '.lock.allbandbinning.newpeaks.' ...
                list_band{nband} '.band.prestim.window.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);
            
            list_bin                         	= [1 5];
            
            for nbin = 1:length(list_bin)
                
                idx_trials                    	= bin_summary.bins(:,list_bin(nbin));
                
                AUC_bin_test                 	= [];
                
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
                
                avg                             = [];
                avg.avg                         = AUC_bin_test;
                avg.time                        = time_axis;
                avg.label                       = {[list_win{nwin,1} ' ' list_win{nwin,2}(1:3)]};
                avg.dimord                      = 'chan_time';
                
                alldata{nsuj,nband,nwin,nbin}  	= avg; clear avg;
                
            end
        end
    end
    
    for nband = 1:size(alldata,2)
        for nbin = 1:size(alldata,4)
            
            data_1                              = alldata{nsuj,nband,1,nbin}.avg;
            data_2                              = alldata{nsuj,nband,2,nbin}.avg;
            
            data_avg                            = [];
            data_avg.avg                      	= mean([data_1;data_2],1);
            data_avg.time                      	= alldata{nsuj,nband,1,nbin}.time;
            data_avg.label                     	= {'gab avg'};
            data_avg.dimord                   	= 'chan_time';
            
            alldata{nsuj,nband,3,nbin}          = data_avg; clear data_1 data_2 data_avg;
            
        end
    end
    
    keep alldata list_* nsuj suj_list nwin project_dir;
    
end


%%

keep alldata list_*

nsuj                                = size(alldata,1);
[design,neighbours]                 = h_create_design_neighbours(nsuj,alldata{1},'gfp','t'); clc;

for nband = 1:size(alldata,2)
    for nwin = 1:size(alldata,3)
        
        cfg                         = [];
        cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
        cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
        cfg.uvar                    = 1;cfg.ivar = 2;
        cfg.tail                    = 0;cfg.clustertail  = 0;
        cfg.neighbours              = neighbours;
        cfg.channel                 = 1;
        
        cfg.latency                 = [0 0.5];
        cfg.clusteralpha            = 0.05; % !!
        cfg.minnbchan               = 0; % !!
        cfg.alpha                   = 0.025;
        
        cfg.numrandomization        = 1000;
        cfg.design                  = design;
        
        allstat{nband,nwin}      	= ft_timelockstatistics(cfg, alldata{:,nband,nwin,1}, alldata{:,nband,nwin,2});
        
    end
end

keep alldata list_* allstat

%%

clc;

figure;

nrow                                = size(allstat,2);
ncol                                = size(allstat,1);
i                                   = 0;

lo                                  = 0.7;
lf                                  = 1;

zlimit                              = [lo lo lo ;lf lf lf ;lo lo lo; lf lf lf];
plimit                              = 0.15;

for nwin = 1:size(allstat,2)
    for nband = 1:size(allstat,1)
        
        stat                        = allstat{nband,nwin};
        stat.mask                   = stat.prob < plimit;
        
        ix                          = unique(stat.mask .* stat.time);
        ix                          = [];%ix(ix~=0);
        
        for nchan = 1:length(stat.label)
            
            vct                     = stat.prob(nchan,:);
            min_p                   = min(vct);
            
            cfg                     = [];
            cfg.channel             = nchan;
            cfg.time_limit          = [-0.05 1]; %stat.time([1 end]);
            cfg.color               = {'-b' '-r'};
            cfg.z_limit             = [0.45 1]; %zlimit(nwin,nband)];
            cfg.linewidth           = 2;
            cfg.lineshape           = '-x';
            i = i+1;
            subplot(nrow,ncol,i);
            h_plotSingleERFstat_selectChannel_nobox(cfg,stat,squeeze(alldata(:,nband,nwin,:)));
            
            %             plot(stat.time,stat.mask);
            
            ylabel({stat.label{nchan}, ['p= ' num2str(round(min_p,3))]})
            
            vline([0],'--k');
            
            xticklabels({'Gabor Onset' '0.5' '1' 'Gabor Onset'});
            xticks([0 0.5 1 1.5]);
            
            hline(0.5,'--k');
            
            title([list_band{nband} ' ' num2str(ix)]);
            set(gca,'FontSize',12,'FontName', 'Calibri','FontWeight','normal');
            
            vct         = unique(stat.mask .* stat.time);
            disp(vct);

            
        end
    end
end