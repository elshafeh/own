clear;clc;

if isunix
    project_dir                                     = '/project/3015079.01/';
    start_dir                                       = '/project/';
else
    project_dir                                     = 'P:/3015079.01/';
    start_dir                                       = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

new_suj_list                                        = {};

gab_focus                                           = '1stgab';
feat_focus                                       	= 'orientation';

for nsuj = 1:length(suj_list)
    flist                                       	= dir(['P:\3015079.01\data\' suj_list{nsuj} '\decode\' suj_list{nsuj} ...
        '.' gab_focus '.lock.broadband.centered.decoding.' feat_focus '.leaveone.mat']);
    if ~isempty(flist)
        new_suj_list{end+1} = suj_list{nsuj}; clear flist;
    end
end

%%

suj_list                                            = new_suj_list; clear new_suj_list nsuj;
list_nwin                                           = [1];

for nsuj = 1:length(suj_list)
    for nwin 	= 1:length(list_nwin)
        
        ix_win                                      = list_nwin(nwin);
        
        subjectName                                 = suj_list{nsuj};
        subject_folder                              = [project_dir 'data/' subjectName '/decode/'];
        
        list_win                                    = {gab_focus feat_focus}; % ; 1stgab orientation frequency}; 
        fname                                       = [subject_folder subjectName '.' list_win{ix_win,1}   ...
            '.lock.broadband.centered.decoding.'  list_win{ix_win,2} '.leaveone.mat'];
        fprintf('loading %s\n',fname);
        load(fname,'y_array','yproba_array','time_axis','e_array');
        
        y_array                                     = y_array';
        yproba_array                                = yproba_array';
        e_array                                     = e_array';
        
        list_band                                   = {'theta' 'alpha' 'beta'};
        measure                                     = 'y proba'; %'auc'; %
        
        for nband = 1:length(list_band)
            
            subject_folder                          = [project_dir 'data/' subjectName '/tf/'];
            fname                                   = [subject_folder subjectName '.' list_win{ix_win,1} ...
                '.lock.allbandbinning.' ...
                list_band{nband} '.band.prestim.window.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            list_bin                                = [1 5];
            
            for nbin = 1:length(list_bin)
                
                idx_trials                          = bin_summary.bins(:,list_bin(nbin));
                
                AUC_bin_test                        = [];
                
                for ntime = 1:size(y_array,2)
                    
                    if strcmp(measure,'y proba')
                        
                        yproba_array_test           = yproba_array(idx_trials,ntime);
                        
                        if min(unique(y_array(:,ntime))) == 1
                            yarray_test         	= y_array(idx_trials,ntime) - 1;
                        else
                            yarray_test           	= y_array(idx_trials,ntime);
                        end
                        
                        [~,~,~,AUC_bin_test(ntime)]	= perfcurve(yarray_test,yproba_array_test,1);
                    else
                        AUC_bin_test(ntime)         = mean(e_array(idx_trials,ntime));
                    end
                end
                
                avg                                 = [];
                avg.avg                             = AUC_bin_test;
                avg.time                            = time_axis;
                avg.label                           = {measure};
                avg.dimord                          = 'chan_time';
                
                tmp{nwin,nband,nbin}                = avg; clear avg;
                
            end
        end
    end
    
    keep alldata list_* nsuj suj_list nwin tmp project_dir *_focus
    
    avg_across_features                             = 'no';
    
    for nband = 1:size(tmp,2)
        for nbin = 1:size(tmp,3)
            
            if size(tmp,1) > 1
                if strcmp(avg_across_features,'yes')
                    data_1                       	= tmp{1,nband,nbin}.avg;
                    data_2                        	= tmp{2,nband,nbin}.avg;
                    alldata{nsuj,nband,nbin}      	= tmp{1};
                    alldata{nsuj,nband,nbin}.avg   	= mean([data_1;data_2],1); clear data_1 data_2
                else
                    alldata{nsuj,nband,nbin}     	= tmp{1,nband,nbin};
                end
            else
                alldata{nsuj,nband,nbin}            = tmp{1,nband,nbin};
            end
            
        end
    end
    
    keep alldata list_* nsuj suj_list nwin project_dir *_focus; clc;
    
end

keep alldata list_*

%%

nsuj                            = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nsuj,alldata{1},'gfp','t'); clc;

for nband = 1:size(alldata,2)
    
    cfg                         = [];
    cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                    = 1;cfg.ivar = 2;
    cfg.tail                    = 0;cfg.clustertail  = 0;
    
    cfg.latency                 = [-0.01 1];
    cfg.clusteralpha            = 0.05; % !!
    cfg.alpha                   = 0.025;
    
    cfg.numrandomization        = 1000;
    cfg.design                  = design;
    
    allstat{nband}              = ft_timelockstatistics(cfg, alldata{:,nband,1}, alldata{:,nband,2});
    
end

keep alldata list_* allstat

figure;
nrow                            = 2;
ncol                            = 3;
i                               = 0;
zlimit                          = [0.4 1];
plimit                          = 0.3;

for nband = 1:length(allstat)
    
    stat                        = allstat{nband};
    stat.mask                   = stat.prob < plimit;
    
    for nchan = 1:length(stat.label)
        
        vct                     = stat.prob(nchan,:);
        min_p                   = min(vct);
        
        cfg                     = [];
        cfg.channel             = nchan;
        cfg.time_limit          = stat.time([1 end]);
        cfg.color               = {'-b' '-r'};
        cfg.z_limit             = zlimit(nchan,:);
        cfg.linewidth           = 10;
        
        i = i+1;
        subplot(nrow,ncol,i);
        h_plotSingleERFstat_selectChannel_nobox(cfg,stat,squeeze(alldata(:,nband,:)));
        
        ylabel({stat.label{nchan}, ['p= ' num2str(round(min_p,3))]})
        
        vline([0],'--k');
        
        xticklabels({'Gabor Onset' '0.5' '1' '1.5'});
        xticks([0 0.5 1 1.5]);
        
        hline(0.5,'--k');
        
        title(list_band{nband});
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
        
    end
end