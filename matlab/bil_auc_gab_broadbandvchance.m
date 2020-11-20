clear;clc;
addpath('../toolbox/sigstar-master/');

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    
    dir_data                            = '~/Dropbox/project_me/data/bil/decode/';
    frequency_list                      = {'broadband'};
    
    decoding_list                       = {'frequency' 'orientation'};
    
    for nfreq = 1:length(frequency_list)
        
        avg                             = [];
        avg.avg                         = [];
        
        for ndeco = 1:length(decoding_list)
            
            % load files for both gabors
            tmp1                 	= dir([dir_data subjectName '.1stgab.lock.' frequency_list{nfreq} ...
                '.centered.decodinggabor.' decoding_list{ndeco}  '.correct.bsl.auc.mat']);
            
            tmp2                 	= dir([dir_data subjectName '.2ndgab.lock.' frequency_list{nfreq} ...
                '.centered.decodinggabor.' decoding_list{ndeco}  '.correct.bsl.auc.mat']);
            
            flist                   = [tmp1;tmp2];
            
            
            for nf = 1:length(flist)
                fname             	= [flist(nf).folder filesep flist(nf).name];
                fprintf('loading %s\n',fname);
                load(fname);
                
                avg.avg         	= [avg.avg;scores]; clear scores
            end
            
            
        end
        
        %         tmp                         = [mean(avg.avg([1 3],:),1);mean(avg.avg([2 4],:),1)];
        %         avg.avg                     = tmp;
        %         avg.label               	= {'gab1 properties' 'gab2 propoerties'};
        
        tmp                         = [mean(avg.avg([1 2],:),1);mean(avg.avg([3 4],:),1)];
        avg.avg                     = tmp;
        avg.label               	= {'freq' 'ori'}; 
        
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
    
end

keep alldata *_list

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
    
    cfg.latency                 = [-0.05 1.5];
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
zlimit                          = [1 1];

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
        cfg.z_limit             = [0.48 zlimit(nchan)];
        cfg.linewidth           = 10;
        
        i = i+1;
        subplot(nrow,ncol,i);
        h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata)
        
        ylabel({stat.label{nchan}, ['p= ' num2str(round(min_p,3))]})
        vline([0],'--k');
            
        xticklabels({'Gab' '0.5' '1'});
        xticks([0 0.5 1]);
        
        hline(0.5,'--k');
        
        legend({'broad' '' 'chance' ''});
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
        
    end
end