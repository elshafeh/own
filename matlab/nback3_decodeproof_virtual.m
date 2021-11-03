clear; clc;

suj_list                            = [1:33 35:36 38:44 46:51];

load /project/3035002.01/nback/virt/sub1.wallis.roi.mat
chan_list                           = data.label; clear data;

for nsuj = 1:length(suj_list)

    sujname                  	    = ['sub' num2str(suj_list(nsuj))];
    auc_carrier                     = [];

    for nchan = 1:length(chan_list)
        for nstim = [1 2 3 4 5 6 7 8 9]

            dir_data                = '/project/3035002.01/nback/virt_auc/';
            fname_in                = [ dir_data 'sub' num2str(suj_list(nsuj)) '.virt.decoding.stim' num2str(nstim) '.chan' num2str(nchan) '.cv4fold.auc.mat'];
            fprintf('loading %s\n',fname_in);
            load(fname_in);

            auc_carrier(nchan,nstim,:)  = scores; clear scores;

        end

    end



    avg                   	    = [];
    avg.avg               	    = squeeze(mean(auc_carrier,2));
    avg.time              	    = time_axis;
    avg.label             	    = chan_list;
    avg.dimord            	    = 'chan_time';

    alldata{nsuj,1}          	= avg; clear svg;

    alldata{nsuj,2}          	= alldata{nsuj,1};
    chance_level                = 0.5;
    alldata{nsuj,2}.avg(:)      = chance_level;


end

keep alldata chance_level

%%

nbsuj                          	= size(alldata,1);
[design,neighbours]           	= h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                          	= [];
cfg.latency                  	= [-0.1 2];
cfg.statistic                 	= 'ft_statfun_depsamplesT';
cfg.method                    	= 'montecarlo';
cfg.correctm                  	= 'cluster';
cfg.clusteralpha              	= 0.05;
cfg.clusterstatistic         	= 'maxsum';
cfg.minnbchan                	= 0;

cfg.tail                    	= 0;
cfg.clustertail                 = 0;
cfg.alpha                   	= 0.025;
cfg.numrandomization          	= 1000;
cfg.uvar                      	= 1;
cfg.ivar                      	= 2;
cfg.neighbours                	= neighbours;
cfg.design                    	= design;
stat                         	= ft_timelockstatistics(cfg,alldata{:,1},alldata{:,2});
[min_p,p_val]                   = h_pValSort(stat);clc;

clc; close all;

i                               = 0;

for nchan = 1:length(stat.label)

    tmp                         = stat.stat(nchan,:) .* stat.mask(nchan,:);
    tmp                         = length(unique(tmp));

    if tmp > 1

        i                       = i + 1;

        cfg                     = [];
        cfg.channel             = nchan;
        cfg.time_limit          = stat.time([1 end]);
        cfg.color               = [0 0 0; 0.5 0.5 0.5];
        cfg.z_limit             = [0.48 0.57];
        cfg.linewidth           = 1;
        cfg.lineshape           = '-b';

        subplot(4,4,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);

        hline(chance_level,'-k');
        vline(0,'-k');
        set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');

        title(stat.label{nchan})

    end
end