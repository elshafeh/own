clear;clc;

suj_list                        = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    dir_data_in              	= '~/Dropbox/project_me/data/nback/behav_h/';
    fname                     	= [dir_data_in 'sub' num2str(suj_list(nsuj)) '.behav.mat'];
    fprintf('loading %s\n',fname)
    load(fname);
    
    data_behav                  = data_behav(data_behav(:,5) == 0 & data_behav(:,1) ~= 4,[1 6 7]);
    sub_rt                      = [];
    
    for nback = [5 6]
        
        data_sub              	= data_behav(data_behav(:,1) == nback,:);
        sub_rt(nback-4)         = median(data_sub(data_sub(:,3) > 0 & rem(data_sub(:,2),2) ~= 0,3)) / 1000;
        clear data_sub
        
    end
    
    allbehav(nsuj,1)            = sub_rt(2) - sub_rt(1);
    
end

keep suj_list all*

for nsuj = 1:length(suj_list)
    
    for nback = 1:2
        
        ext_stim                = 'target';
        difference_type         = 'difference' ; % difference relative
        
        dir_data             	= '~/Dropbox/project_me/data/nback/tf/behav2tf/';
        file_list            	= dir([dir_data 'sub' num2str(suj_list(nsuj)) '.' num2str(nback) 'back.' ext_stim '.correct.pre.fft.mat']);
        pow                 	= [];
        
        for nfile = 1:length(file_list)
            
            fname_in        	= [file_list(nfile).folder filesep file_list(nfile).name];
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            pow(nfile,:,:,:) 	= freq_comb.powspctrm;
            
        end
        
        avg                   	= [];
        avg.time                = freq_comb.freq;
        avg.label               = freq_comb.label;
        avg.dimord          	= 'chan_time';
        avg.avg               	= squeeze(mean(pow,1)); clear pow;
        
        tmp{nback}              = avg; clear avg pow f1 f2 f_*;
        
    end
    
    alldata{nsuj,1}             = tmp{1};
    
    switch difference_type
        case 'difference'
            alldata{nsuj,1}.avg	= tmp{1}.avg - tmp{2}.avg;
        case 'relative'
            alldata{nsuj,1}.avg	= (tmp{1}.avg - tmp{2}.avg) ./ (tmp{1}.avg + tmp{2}.avg);
        otherwise
            error('pick a difference technique');
    end
    
    clear tmp
    
end

keep suj_list all* list*

%%

nbsuj                     	= size(alldata,1);
[~,neighbours]            	= h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                       	= [];
cfg.method              	= 'montecarlo';
cfg.statistic              	= 'ft_statfun_correlationT';
cfg.type                   	= 'Spearman';
cfg.clusterstatistics     	= 'maxsum';
cfg.correctm            	= 'cluster';
cfg.clusteralpha         	= 0.05;
cfg.tail                 	= 0;
cfg.clustertail           	= 0;
cfg.alpha                 	= 0.025;
cfg.numrandomization     	= 1000;
cfg.minnbchan             	= 2;
cfg.neighbours            	= neighbours;
cfg.ivar                  	= 1;

cfg.design(1,1:nbsuj)     	= [allbehav];
stat                      	= ft_timelockstatistics(cfg, alldata{:});
[min_p,p_val]              	= h_pValSort(stat);

%%

plimit                     	= 0.5;
nrow                     	= 3;
ncol                     	= 2;
i                        	= 0;

if min_p < plimit
    
    nw_data                 = alldata;
    nw_stat                 = stat;
    nw_stat.mask            = nw_stat.prob < plimit;
    
    statplot                = [];
    statplot.avg            = nw_stat.mask .* nw_stat.rho;
    statplot.label          = nw_stat.label;
    statplot.dimord         = nw_stat.dimord;
    statplot.time           = nw_stat.time;
    
    find_sig_time           = mean(statplot.avg,1);
    find_sig_time           = find(find_sig_time ~= 0);
    list_time               = [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
    
    cfg                     = [];
    cfg.layout              = 'neuromag306cmb.lay';
    cfg.xlim                = list_time;
    cfg.zlim                = [-0.1 0.1];
    cfg.colormap            = brewermap(256,'*RdBu');
    cfg.marker              = 'off';
    cfg.comment             = 'no';
    cfg.colorbar            = 'no';
    
    i = i + 1;
    cfg.figure              = subplot(nrow,ncol,i);
    
    ft_topoplotER(cfg,statplot);
    title({'rt with fft', ...
        ['p = ' num2str(round(min_p,3))]});
    
    set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
    
    find_sig_chan           = mean(statplot.avg,2);
    find_sig_chan           = find(find_sig_chan ~= 0);
    list_chan               = nw_stat.label(find_sig_chan);
    
    cfg                     = [];
    cfg.channel             = list_chan;
    cfg.time_limit          = nw_stat.time([1 end]);
    cfg.color               = [0 0 0];
    cfg.lineshape           = '-k';
    cfg.linewidth           = 10;
    %                 cfg.z_limit      	= [0.2e-24 0.9e-24];
    
    i = i + 1;
    subplot(nrow,ncol,i)
    h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
    
    hline(0,'-k');
    vline(0,'-k');
    set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
    
end