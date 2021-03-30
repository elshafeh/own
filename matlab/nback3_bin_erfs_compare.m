clear ; close all; clc; global ft_default
ft_default.spmversion = 'spm12';

suj_list                                            = [1:33 35:36 38:44 46:51];
bad_suj                                             = [];

for nsuj = 1:length(suj_list)
     
    subjectname                                     = ['sub' num2str(suj_list(nsuj))];
    
    list_band                                       = {'slow.post' 'alpha.post' 'beta.post'};
    list_bin                                        = {'2binsb1' '2binsb2'};
    
    for nband = 1:length(list_band)
        for nbin = [1 2]
                        
            flist                                   = dir(['~/Dropbox/project_me/data/nback/erf/' subjectname ...
                '.' list_band{nband} '.' list_bin{nbin} '.erfComb.mat']);
            
            if ~isempty(flist)
                
                for nf = 1:length(flist)
                    
                    fname                           = [flist(nf).folder filesep flist(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    
                    if nf == 1
                        avg_temp                    = avg_comb;
                        avg_temp.avg                = [];
                    end
                    
                    t1                              = nearest(avg_comb.time,-0.1);
                    t2                              = nearest(avg_comb.time,0);
                    bsl                             = mean(avg_comb.avg(:,t1:t2),2);
                    avg_comb.avg                    = avg_comb.avg - bsl ; clear bsl t1 t2;
                    
                    avg_temp.avg(nf,:,:)         	= avg_comb.avg;
                    
                end
                
                avg_temp.avg                        = squeeze(mean(avg_temp.avg,1));
                alldata{nsuj,nband,nbin}            = avg_temp;
                
                clear avg_temp ; clc;
            else
                bad_suj                             = [bad_suj; nsuj];
            end
            
        end
    end
end

%%

keep alldata list_* bad_suj

bad_suj                                         = unique(bad_suj);
alldata(bad_suj,:,:)                            = [];

nbsuj                                       	= size(alldata,1);
[design,neighbours]                             = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

for nband = 1:size(alldata,2)
    
    cfg                                         = [];
    cfg.latency                                 = [-0.01 0.5];
    cfg.statistic                               = 'ft_statfun_depsamplesT';
    cfg.method                                  = 'montecarlo';
    cfg.correctm                                = 'cluster';
    cfg.clusteralpha                            = 0.05;
    cfg.clusterstatistic                        = 'maxsum';
    cfg.minnbchan                               = 3;
    
    cfg.tail                                    = 0;
    cfg.clustertail                             = 0;
    cfg.alpha                                   = 0.025;
    cfg.numrandomization                        = 1000;
    cfg.uvar                                    = 1;
    cfg.ivar                                    = 2;
    cfg.neighbours                              = neighbours;
    cfg.design                                  = design;
    stat{nband}                               	= ft_timelockstatistics(cfg,alldata{:,nband,1},alldata{:,nband,2});
    [min_p(nband),p_val{nband}]               	= h_pValSort(stat{nband});clc;
    
end

disp('done testing');
keep alldata list_* stat min_p p_val

%%

close all;

plimit          = 0.15;
font_size       = 20;
nrow            = 2;
ncol            = 2;
i               = 0;

for nband = 1:length(stat)
    if min_p(nband) < plimit
        
        nw_data                         = squeeze(alldata(:,nband,:));
        nw_stat                         = stat{nband};
        nw_stat.mask                 	= nw_stat.prob < plimit;
        
        statplot                        = [];
        statplot.avg                 	= nw_stat.mask .* nw_stat.stat;
        statplot.label               	= nw_stat.label;
        statplot.dimord              	= nw_stat.dimord;
        statplot.time                 	= nw_stat.time;
        
        find_sig_time                	= mean(statplot.avg,1);
        find_sig_time                  	= find(find_sig_time ~= 0);
        list_time                     	= [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
        
        
        cfg                             = [];
        cfg.layout                      = 'neuromag306cmb.lay';
        cfg.zlim                        = [-2 2];
        cfg.xlim                        = list_time;
        cfg.colormap                    = brewermap(256,'*RdBu');
        cfg.marker                      = 'off';
        cfg.comment                     = 'no';
        cfg.colorbar                    = 'no';
        
        i = i + 1;
        subplot(nrow,ncol,i)
        ft_topoplotER(cfg,statplot);
        title({[list_band{nband} ' low - high'],'',['p = ' num2str(round(min_p(nband),3))]});
        
        set(gca,'FontSize',font_size,'FontName', 'Calibri','FontWeight','normal');
        
        find_sig_chan                	= mean(statplot.avg,2);
        find_sig_chan                 	= find(find_sig_chan ~= 0);
        list_chan                       = nw_stat.label(find_sig_chan);
        
        cfg                             = [];
        cfg.channel                     = list_chan;
        cfg.time_limit              	= nw_stat.time([1 end]);
        cfg.color                       = [109 179 177; 111 71 142];
        cfg.color                       = cfg.color ./ 256;
        cfg.z_limit                     = [-0.5e-12 5.5e-12];
        cfg.linewidth                   = 10;
        i = i + 1;
        subplot(nrow,ncol,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
        legend({'low' '' 'high' ''});
        
        xlim(statplot.time([1 end]));
        hline(0,'-k');
        vline(0,'-k');
        xticks([0 0.1 0.2 0.3 0.4 0.5]);
        set(gca,'FontSize',font_size,'FontName', 'Calibri','FontWeight','normal');
        
    end
end