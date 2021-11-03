clear;clc;

suj_list                    	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    dir_data                  	= '~/Dropbox/project_me/data/nback/tf/behav2tf/';
    ext_fft                 	= 'allstim.correct.pre.fft.mat';
    
    ext_bsl                     = 'freq'; % freq zero none
    ext_freq                    = [5 35];
    
    
    fname_in                 	= [dir_data 'sub' num2str(suj_list(nsuj)) '.0back.allstim.correct.pre.fft.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    f1                          = nearest(freq_comb.freq,ext_freq(1));
    f2                          = nearest(freq_comb.freq,ext_freq(2));
    freq_comb.powspctrm         = freq_comb.powspctrm(:,f1:f2);
    freq_comb.freq              = freq_comb.freq(f1:f2);
      
    bsl                       	= freq_comb.powspctrm; clear freq_comb;
    
    for nback = 1:2
        
        fname_in              	= [dir_data 'sub' num2str(suj_list(nsuj)) '.' num2str(nback) 'back.allstim.correct.pre.fft.mat'];
        fprintf('loading %s\n',fname_in);
        load(fname_in);
        
        f1                     	= nearest(freq_comb.freq,ext_freq(1));
        f2                     	= nearest(freq_comb.freq,ext_freq(2));
        freq_comb.powspctrm   	= freq_comb.powspctrm(:,f1:f2);
        freq_comb.freq        	= freq_comb.freq(f1:f2);
        
        avg                    	= [];
        avg.time              	= freq_comb.freq;
        avg.label            	= freq_comb.label;
        avg.dimord            	= 'chan_time';
        
        if strcmp(ext_bsl,'freq')
            bsl                 = nanmean(freq_comb.powspctrm,2);
            avg.avg          	= (freq_comb.powspctrm - bsl)./ bsl;
        elseif strcmp(ext_bsl,'zero')
            avg.avg           	= (freq_comb.powspctrm - bsl)./ bsl;
        elseif strcmp(ext_bsl,'none')
            avg.avg           	= freq_comb.powspctrm;
        end
        
        alldata{nsuj,nback}    	= avg; clear avg
        
    end
end

keep alldata list_band ext_*

%%

nbsuj                        	= size(alldata,1);
[design,neighbours]           	= h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                             = [];
cfg.statistic               	= 'ft_statfun_depsamplesT';
cfg.method                   	= 'montecarlo';
cfg.correctm                 	= 'cluster';
cfg.clusteralpha             	= 0.05;
cfg.clusterstatistic         	= 'maxsum';
cfg.minnbchan                	= 3; % important %
cfg.tail                     	= 0;
cfg.clustertail              	= 0;
cfg.alpha                   	= 0.025;
cfg.numrandomization         	= 1000;
cfg.uvar                      	= 1;
cfg.ivar                      	= 2;
cfg.neighbours                	= neighbours;
cfg.design                   	= design;
stat                          	= ft_timelockstatistics(cfg,alldata{:,1},alldata{:,2});
[min_p,p_val]                   = h_pValSort(stat);clc;


%%

close all;

plimit                      	= 0.05;
font_size                   	= 16;
nrow                          	= 2;
ncol                         	= 2;
i                           	= 0;

if min_p < plimit
    
    
    nw_data                 	= alldata;
    nw_stat                   	= stat;
    nw_stat.mask            	= nw_stat.prob < plimit;
    
    statplot                 	= [];
    statplot.avg                = nw_stat.mask .* nw_stat.stat;
    statplot.label           	= nw_stat.label;
    statplot.dimord          	= nw_stat.dimord;
    statplot.time             	= nw_stat.time;
    
    find_sig_time            	= mean(statplot.avg,1);
    find_sig_time            	= find(find_sig_time ~= 0);
    list_time                 	= [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
    
    cfg                     	= [];
    cfg.layout              	= 'neuromag306cmb_helmet.mat'; %'neuromag306cmb.lay'; %
    cfg.xlim                 	= list_time;
    cfg.zlim                  	= [-2 2];
    cfg.colormap               	= brewermap(256,'*RdBu');
    cfg.marker                	= 'off';
    cfg.comment              	= 'no';
    cfg.colorbar              	= 'yes';
    cfg.colorbartext         	= 't-values';
    i = i + 1;
    cfg.figure               	= subplot(nrow,ncol,i);
    
    ft_topoplotER(cfg,statplot);
    title({['1-Back vs 2-Back'],['p = ' num2str(round(min_p,3))]});
    
    set(gca,'FontSize',font_size,'FontName', 'Calibri','FontWeight','normal');
    
    find_sig_chan               = mean(statplot.avg(:,find_sig_time),2);
    find_sig_chan               = find(find_sig_chan ~= 0);
    list_chan               	= nw_stat.label(find_sig_chan);
    
    cfg                      	= [];
    cfg.channel             	= list_chan;
    cfg.time_limit            	= nw_stat.time([1 end]);
    cfg.color                 	= [58 161 122; 47 123 182];
    cfg.color                   = cfg.color ./ 256;
    
    if strcmp(ext_bsl,'freq')
        cfg.z_limit           	= [0 4];
    elseif strcmp(ext_bsl,'zero')
        cfg.z_limit           	= [-0.1 0.1];
    end
        
    cfg.linewidth             	= 5;
    cfg.lineshape             	= '-r';
    
    i = i + 1;
    subplot(nrow,ncol,i)
    h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
    legend({'1-Back' '' '2-Back' ''});
    hline(0,'-k');
    vline(0,'-k');
    set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
    
    cfg.time_limit           	= [5 15];
    cfg.z_limit                 = [1 3];
    i = i + 1;
    subplot(nrow,ncol,i)
    h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
    legend({'1-Back' '' '2-Back' ''});
    hline(0,'-k');
    vline(0,'-k');
    set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
    
end