clear ; close all;

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    dir_data                            = [project_dir 'data/' subjectName '/decode/'];
    
    list_cond                           = {'cue.pre.freq','cue.retro.ori','cue.retro.freq'};
    list_feature                        = {'gab.ori','gab.freq'};
    
    for n_con = 1:length(list_cond)
        
        tmp                           	= [];
        
        for nfeat = 1:length(list_feature)
            
            ext_gab                     = {'second'};
            ext_feature               	= list_feature{nfeat};
            fname                    	= [dir_data subjectName '.' ext_gab{:} 'gab.lock.' list_cond{n_con} '.' ...
                ext_feature '.correct.bsl.auc.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            tmp(nfeat,:)                = scores; clear scores;
            
        end
        
        avg                             = [];
        avg.label                       = list_feature;
        avg.dimord                      = 'chan_time';
        avg.time                        = time_axis;
        avg.avg                         = tmp; clear tmp;
        alldata{nsuj,n_con}         	= avg; clear avg;
        
    end
    
end

list_color              	= 'rgbk';

keep alldata list_cond ext_gab list_color

nbsuj                       = size(alldata,1);
[~,neighbours]              = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                         = [];
cfg.method                  = 'ft_statistics_montecarlo';
cfg.statistic               = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsum'; %'maxsum', 'maxsize', 'wcm'
cfg.clusterthreshold        = 'nonparametric_common';
cfg.tail                     = 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail             = cfg.tail;
cfg.alpha                   = 0.05;
cfg.computeprob             = 'yes';
cfg.numrandomization        = 1000;
cfg.neighbours              = neighbours;
cfg.latency                 = [-0.1 1];
cfg.ivar                    = 1; % condition
cfg.uvar                    = 2; % subject number


design                      = zeros(2,3*nbsuj);
design(1,1:nbsuj)           = 1;
design(1,nbsuj+1:2*nbsuj)   = 2;
design(1,nbsuj*2+1:3*nbsuj) = 3;
design(2,:) = repmat(1:nbsuj,1,3);
% design(1,nbsuj*3+1:4*nbsuj) = 4;
% design(2,:) = repmat(1:nbsuj,1,4);

cfg.design                  = design;
stat                        = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3});

[min_p,p_val]               = h_pValSort(stat);

for nchan = 1:2
    
    subplot(2,1,nchan)
    
    cfg                         = [];
    cfg.channel                 = stat.label{nchan};
    cfg.p_threshold             = 0.05;
    
    if nchan ==1
        cfg.z_limit          	= [0.48 0.6];
    else
        cfg.z_limit          	= [0.48 0.8];
    end
    
    cfg.time_limit              = stat.time([1 end]);
    cfg.color                   = 'rgbk';
    cfg.linewidth               = 10;
    h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
    
    
    vline(0,'--k');
    hline(0.5,'--k');
    title([ext_gab{:} ' ' cfg.channel]);
    
end