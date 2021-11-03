clear;clc;

allbehav                   	= [];

for nsuj = [1:33 35:36 38:44 46:51]
    
    dir_data                = '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in             	= [ dir_data 'sub' num2str(nsuj) '.singletrial.trialinfo.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    correct_trials          = find(rem(trialinfo(:,4),2) ~= 0);
    perc_correct            = length(correct_trials) ./ length(trialinfo);
    
    correct_trials_with_rt	= find(rem(trialinfo(:,4),2) ~= 0 & trialinfo(:,5) ~= 0);
    rt_vector               = trialinfo(correct_trials_with_rt,5) ./ 1000;
    rt_vector               = rt_vector/mean(rt_vector);
    mean_rt                 = mean(rt_vector);
    
    allbehav                = [allbehav;perc_correct mean_rt];
    
end

keep allbehav

%%

suj_list                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname               	= ['sub' num2str(suj_list(nsuj))];
    
    dir_data                = '~/Dropbox/project_me/data/nback/behav_timegen/';
    
    list_stim               = [1 2 3 4 5 7 8 9];
    pow                     = [];

    for nstim = 1:length(list_stim)
        
        fname_in          	= [dir_data sujname '.all.decoding.stim' num2str(list_stim(nstim)) '.nodemean.auc.timegen.mat'];
        fprintf('loading %s\n',fname_in);
        load(fname_in);
        
        pow(nstim,:,:)      = scores; clear scores;
        
    end
    
    pow                     = mean(pow,1);
    
    time_window             = [0.1 0.3];
    
    t1                   	= nearest(time_axis,time_window(1));
    t2                   	= nearest(time_axis,time_window(2));
    
    avg                   	= [];
    
    avg.avg                	= squeeze(mean(pow(:,t1:t2,:),2));
    if size(avg.avg,2) < size(avg.avg,1)
        avg.avg           	= avg.avg';
    end
    avg.label             	= {'decoding stim'};
    avg.dimord            	= 'chan_time';
    avg.time            	= time_axis;
    
    
    alldata{nsuj,1}         = avg; clear avg;
    
end

%%

cfg                                 = [];
cfg.method                          = 'montecarlo';
cfg.latency                         = [-0.1 2];
cfg.statistic                       = 'ft_statfun_correlationT';
cfg.clusterstatistics               = 'maxsum';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05;
cfg.tail                            = 0;
cfg.clustertail                     = 0;
cfg.alpha                           = 0.025;
cfg.numrandomization                = 1000;
cfg.ivar                            = 1;

list_corr                           = {'Spearman' 'Pearson'};
list_behav                          = {'accuracy' 'reaction time'};

for nbehav = [1 2]
    for ncorr = [1 2]
        
        nb_suj                      = size(alldata,1);
        cfg.type                    = list_corr{ncorr};
        cfg.design(1,1:nb_suj)      = [allbehav(:,nbehav)];
        
        [~,neighbours]              = h_create_design_neighbours(nb_suj,alldata{1,1},'gfp','t');
        cfg.neighbours              = neighbours;
        
        stat{nbehav,ncorr}          = ft_timelockstatistics(cfg, alldata{:});
        [min_p(nbehav,ncorr),p_val{nbehav,ncorr}]   	= h_pValSort(stat{nbehav,ncorr});
        
    end
end

%%

close all;

clc;

i                                	= 0;
nrow                               	= 2;
ncol                               	= 2;
plimit                              = 0.065;


for nbehav = [1 2]
    for ncorr = [1 2]
        
        statplot                   	= stat{nbehav,ncorr};
        statplot.mask             	= statplot.prob < plimit;
        
        for nchan = 1:length(statplot.label)
            
            tmp                   	= statplot.mask(nchan,:,:) .* statplot.rho(nchan,:,:);
            iy                    	= unique(tmp);
            iy                   	= iy(iy~=0);
            
            tmp                  	= statplot.mask(nchan,:,:) .* statplot.prob(nchan,:,:);
            ix                  	= unique(tmp);
            ix                  	= ix(ix~=0);
            
            i                      	= i + 1;
            subplot(nrow,ncol,i)
            
            cfg                  	= [];
            cfg.channel           	= nchan;
            cfg.p_threshold       	= plimit;
            
            cfg.time_limit        	= [-0.1 2];
            list_color            	= 'k';
            cfg.color             	= list_color(nchan);
            cfg.lineshape         	= '-b';
            cfg.linewidth         	= 5;
            
            cfg.z_limit             = [0.3 1];
            
            h_plotSingleERFstat_selectChannel_nobox(cfg,statplot,alldata);
            
            hline(0.07,'--k');
            
            title(list_behav{nbehav});
            ylabel(statplot.label{nchan});
            
            title(['p = ' num2str(round(min(ix),3)) ' ' list_corr{ncorr} ' r = ' num2str(round(min(iy),1))]);
            set(gca,'FontSize',16,'FontName', 'Calibri');
            vline(0,'--k');
            
            
            mask_mean                   = mean(statplot.mask,1);
            mask_mean(mask_mean ~= 0)   = 1;
            sig_time                    = mask_mean .* statplot.time;
            sig_time(sig_time == 0)     = [];
        end
    end
end
