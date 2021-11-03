clear;clc;

suj_list                        = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname                 	= ['sub' num2str(suj_list(nsuj))];
    
    % load fft
    dir_data                 	= '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in                	= [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.fft.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    % load trialinfo
    dir_data                  	= '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in                	= [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.trialinfo.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    flg_trials                 	= 1:length(trialinfo);
    
    dir_files                  	= '~/Dropbox/project_me/data/nback/';
    flist                      	= dir([dir_files 'auc/' sujname '.decoding.stim*.nodemean.leaveone.mat']);
    
    rho_carrier               	= [];
    
    for nstim = 1:length(flist)
        
        % load decoding output
        fname               	= [flist(nstim).folder filesep flist(nstim).name];
        fprintf('loading %s\n',fname);
        load(fname,'y_array','yproba_array','time_axis','e_array');
        
        % transpose matrices
        y_array               	= y_array';
        yproba_array          	= yproba_array';
        e_array                	= e_array';
        measure               	= 'yproba'; % auc yproba
        
        t1                     	= nearest(time_axis,0.08);
        t2                     	= nearest(time_axis,0.28);
        tmp                  	= yproba_array(flg_trials,t1:t2);
        auc                   	= [];
        
        % find max instead of mean
        for ntrial = 1:size(tmp,1)
            auc                	= [auc;max(tmp(ntrial,:))];
        end
        pow                     = freq_comb.powspctrm(flg_trials,:,:);
        
        for nfreq = 1:size(pow,3)
            
            x               	= auc;
            y                  	= pow(:,:,nfreq);
            
            [rho,p]           	= corr(x,y , 'type', 'Spearman');
            
            rho               	= .5.*log((1+rho)./(1-rho));
            rho_carrier(nstim,:,nfreq) = rho; clear rho x y rho;
            
        end
    end
    
    avg                         = [];
    avg.time                    = freq_comb.freq;
    avg.label                   = freq_comb.label;
    avg.dimord                  = 'chan_time';
    avg.avg                     = squeeze(mean(rho_carrier,1)); clear rho_carrier;
    
    alldata{nsuj,1}             = avg;
    
    avg.avg(:)                  = 0;
    alldata{nsuj,2}             = avg; clear avg rho
    
end

keep alldata ext_*

%%

nbsuj                        	= size(alldata,1);
[design,neighbours]          	= h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                           	= [];
cfg.latency                     = [1 100];
cfg.statistic                  	= 'ft_statfun_depsamplesT';
cfg.method                     	= 'montecarlo';
cfg.correctm                   	= 'cluster';
cfg.clusteralpha              	= 0.05;
cfg.clusterstatistic         	= 'maxsum';
cfg.minnbchan                	= 2; % important %
cfg.tail                     	= 0;
cfg.clustertail              	= 0;
cfg.alpha                    	= 0.025;
cfg.numrandomization          	= 1000;
cfg.uvar                      	= 1;
cfg.ivar                       	= 2;
cfg.neighbours                	= neighbours;
cfg.design                     	= design;
stat                          	= ft_timelockstatistics(cfg,alldata{:,1},alldata{:,2});
[min_p,p_val]               	= h_pValSort(stat);clc;

%%

plimit                          = 0.05;
font_size                     	= 16;
nrow                          	= 2;
ncol                            = 2;
i                               = 0;

if min_p < plimit
    
    nw_data                 	= alldata;
    nw_stat                   	= stat;
    nw_stat.mask              	= nw_stat.prob < plimit;
    
    statplot                 	= [];
    statplot.avg              	= nw_stat.mask .* nw_stat.stat;
    statplot.label            	= nw_stat.label;
    statplot.dimord           	= nw_stat.dimord;
    statplot.time             	= nw_stat.time;
    
    find_sig_time           	= mean(statplot.avg,1);
    find_sig_time              	= find(find_sig_time ~= 0);
    list_time                	= [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
    
    cfg                      	= [];
    cfg.layout              	= 'neuromag306cmb_helmet.mat'; %'neuromag306cmb.lay'; %
    cfg.xlim                 	= list_time;
    cfg.zlim                  	= [-3 3];
    cfg.colormap               	= brewermap(256,'*RdBu');
    cfg.marker               	= 'off';
    cfg.comment              	= 'no';
    cfg.colorbar              	= 'yes';
    cfg.colorbartext         	= 't-values';
    i = i + 1;
    cfg.figure                	= subplot(nrow,ncol,i);
    
    ft_topoplotER(cfg,statplot);
    title({'fft with auc',['p = ' num2str(round(min_p,3))]});
    
    set(gca,'FontSize',font_size,'FontName', 'Calibri','FontWeight','normal');
    
    find_sig_chan             	= mean(statplot.avg(:,find_sig_time),2);
    find_sig_chan           	= find(find_sig_chan ~= 0);
    list_chan                 	= nw_stat.label(find_sig_chan);
    
    cfg                      	= [];
    cfg.channel                 = list_chan;
    cfg.time_limit            	= nw_stat.time([1 end]);
    cfg.color                  	= {'-k' '-k'};
    cfg.z_limit             	= [-0.05 0.05];
    
    cfg.linewidth             	= 5;
    cfg.lineshape            	= '-r';
    
    i = i + 1;
    subplot(nrow,ncol,i)
    h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
    hline(0,'-k');
    set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
    
end