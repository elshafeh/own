clear;clc;
addpath('../toolbox/sigstar-master/');

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    
    dir_data                        = '~/Dropbox/project_me/data/bil/decode/';
    frequency_list                  = {'broadband' };
    
    decoding_list                   = {'correct' 'match'};
    
    for nfreq = 1:length(frequency_list)
        
        avg                         = [];
        avg.avg                     = [];
        
        lock_focus                  = '1stcue'; % 'response';
        
        for ndeco = 1:length(decoding_list)
            
            % load files for both gabors
            flist                   = dir([dir_data subjectName '.' lock_focus '.lock.' frequency_list{nfreq} ...
                '.centered.decodingresp.' decoding_list{ndeco}  '.auc.mat']);
            
            if length(flist )== 1
                score_concat     	= [];
                
                for nf = 1:length(flist)
                    fname         	= [flist(nf).folder filesep flist(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    score_concat   	= [score_concat;scores]; clear scores;
                end
            else
                error('files missing');
            end
            
            avg.avg                 = [avg.avg;nanmean(score_concat,1)];clear score_concat;
        end
        
        avg.label               	= decoding_list;
        avg.dimord                  = 'chan_time';
        avg.time                	= time_axis;
        
        alldata{nsuj,nfreq}         = avg; clear avg;
        
    end
    
    flg                             = nfreq+1;
    alldata{nsuj,flg}               = alldata{nsuj,1};
    rnd_vct                         = 0.495:0.0001:0.505;
    for nc = 1:size(alldata{nsuj,flg}.avg,1)
        for nt = 1:size(alldata{nsuj,flg}.avg,2)
            alldata{nsuj,flg}.avg(nc,nt)    	= rnd_vct(randi(length(rnd_vct)));
        end
    end
    
    frequency_list            	= [frequency_list 'chance'];
    
end

keep alldata *_list lock_focus

%%

nsuj                            = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;

for nfreq = 1
    
    cfg                         = [];
    cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                    = 1;cfg.ivar = 2;
    cfg.tail                    = 0;cfg.clustertail  = 0;
    cfg.neighbours              = neighbours;
    
    cfg.latency                 = [3 7];
    cfg.clusteralpha            = 0.05; % !!
    cfg.minnbchan               = 0; % !!
    cfg.alpha                   = 0.025;
    
    cfg.numrandomization        = 1000;
    cfg.design                  = design;
    
    allstat{nfreq}              = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});
    
end

%%

figure;
nrow                            = 2;
ncol                            = 2;
i                               = 0;
zlimit                          = [0.47 0.6];

for nfreq = 1:length(allstat)
    
    stat                        = allstat{nfreq};
    stat.mask                   = stat.prob < 0.05;
    
    for nchan = 1:length(stat.label)
        
        vct                     = stat.prob(nchan,:);
        min_p                   = min(vct);
        
        cfg                     = [];
        cfg.channel             = nchan;
        cfg.time_limit          = stat.time([1 end]);
        cfg.color               = {'-k' '-y'};
        cfg.z_limit             = zlimit;
        cfg.linewidth           = 10;
        
        i = i+1;
        subplot(nrow,ncol,i);
        h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata)
        
        ylabel({stat.label{nchan}, ['p= ' num2str(round(min_p,3))]})
        vline([0 1.5 3 4.5 5.5],'--k');
            
        xticklabels({'1st Cue' '1st Gab' '2nd Cue' '2nd Gab' 'Mean RT'});
        
        xticks([0 1.5 3 4.5 5.5]);
        hline(0.5,'--k');
        
        legend({'broad' '' 'chance' ''});
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
        
    end
end