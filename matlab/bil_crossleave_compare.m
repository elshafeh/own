clear;clc;

if isunix
    project_dir                                 = '/project/3015079.01/';
    start_dir                                   = '/project/';
else
    project_dir                                 = 'P:/3015079.01/';
    start_dir                                   = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

alldata                                         = [];

for nsuj = 1:length(suj_list)
    
    subjectName                                 = suj_list{nsuj};
    subject_folder                              = [project_dir 'data/' subjectName '/decode/'];
    
    list_band                                   = {'theta' 'alpha' 'beta'};
    list_bin                                    = [1 5];
    
    list_label                                  = {'1stgab' 'orientation' ; '1stgab' 'frequency'};
    
    for ncue = 1:length(list_label)
        for nband = 1:length(list_band)
            for nbin = 1:length(list_bin)
                
                scores_avg                      = [];
                
                for nshuffle = 1:4
                    
                    flist                       = dir([subject_folder subjectName '.' list_label{ncue,1} '.lock.decoding.' list_label{ncue,2} ...
                        '.' list_band{nband} '.bin' num2str(list_bin(nbin)) '.shuffle' num2str(nshuffle) '.crossone.mat']);
                    
                    for nfile = 1:length(flist)
                        fname                   = fullfile(flist(nfile).folder,flist(nfile).name);
                        fprintf('loading %s\n',fname);
                        load(fname);
                        scores_avg              = [scores_avg;scores]; clear scores;
                    end
                    
                end
                
                if isempty(scores_avg)
                    error('');
                end
                
                avg                             = [];
                avg.avg                         = mean(scores_avg,1); clear scores_avg;
                avg.time                        = time_axis;
                avg.label                       = {[list_label{ncue,2} ' AUC']};
                avg.dimord                      = 'chan_time';
                
                alldata{nsuj,ncue,nband,nbin} 	=  avg; clear avg;
                
            end
        end
    end
end

keep alldata list_* time_axis
    
figure;
nrow                                = 3;
ncol                                = 3;
i                                   = 0;
zlimit                              = [0.4 0.8];
plimit                              = 0.1;

for ncue = 1:length(list_label)
    
    nsuj                            = size(alldata,1);
    [design,neighbours]             = h_create_design_neighbours(nsuj,alldata{1},'gfp','t'); clc;
    
    for nband = 1:length(list_band)
        
        cfg                         = [];
        cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
        cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
        cfg.uvar                    = 1;cfg.ivar = 2;
        cfg.tail                    = 0;cfg.clustertail  = 0;
        cfg.neighbours              = neighbours;
        cfg.channel                 = 1;
        
        cfg.latency                 = [-0.01 0.6];
        cfg.clusteralpha            = 0.05; % !!
        cfg.minnbchan               = 0; % !!
        cfg.alpha                   = 0.025;
        
        cfg.numrandomization        = 1000;
        cfg.design                  = design;
        
        allstat{nband}              = ft_timelockstatistics(cfg, alldata{:,ncue,nband,1}, alldata{:,ncue,nband,2});
        
    end
    
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
            h_plotSingleERFstat_selectChannel_nobox(cfg,stat,squeeze(alldata(:,ncue,nband,:)));
            
            ylabel({stat.label{nchan}, ['p= ' num2str(round(min_p,3))]})
            
            vline([0],'--k');
            
            xticklabels({'Cue Onset' '0.5' '1' 'Gabor Onset'});
            xticks([0 0.5 1 1.5]);
            
            hline(0.5,'--k');
            
            title(['prestim ' list_band{nband} ' binning']);
            set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
            
            
        end
    end
end