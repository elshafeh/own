clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    dir_data                        = '~/Dropbox/project_me/data/bil/decode/';
    
    frequency_list                  = {'broadband'};
    decoding_list                   = {'pre.ori.vs.spa' 'retro.ori.vs.spa'};
    
    for nfreq = 1:length(frequency_list)
        
        avg                         = [];
        avg.avg                     = [];
        
        for ndeco = 1:length(decoding_list)
            fname                  	= [dir_data subjectName '.1stcue.lock.' frequency_list{nfreq} ...
                '.centered.decodingcue.' decoding_list{ndeco}  '.correct.auc.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            avg.avg                 = [avg.avg;scores]; clear scores;
        end
        
        t1                          = find(round(time_axis,2) == round(-0.1,2));
        t2                          = find(round(time_axis,2) == round(1.5,2));
        t3                          = find(round(time_axis,2) == round(2.9,2));
        t4                          = find(round(time_axis,2) == round(4.5,2));
        
        tmp                         = [avg.avg(1,t1:t2);avg.avg(2,t3:t4)];
        tme                         = time_axis(t1:t2);
        
        %         avg.avg                     = mean(tmp,1);
        %         avg.time                	= tme; clear tme tmp;
        %         avg.label               	= {'cue auc'}; %decoding_list;
        %         avg.dimord                  = 'chan_time';
        
        avg.time                	= time_axis;
        avg.label               	= decoding_list;
        avg.dimord                  = 'chan_time';
        
        
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
    
    cfg.latency                 = [-0.1 5.5];
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
        vline([0],'--k');

        %         xticklabels({'Cue' '0.5' '1' 'Gabor'});
        %         xticks([0 0.5 1 1.5]);
        
        xticklabels({'1st Cue' '1st Gab' '2nd Cue' '2nd Gab' 'Mean RT'});
        xticks([0 1.5 3 4.5 5.5]);
        
        hline(0.5,'--k');
        
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
        
    end
end