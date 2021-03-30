clear ; close all; clc; global ft_default
ft_default.spmversion = 'spm12';

suj_list                                                = [1:33 35:36 38:44 46:51];
bad_suj                                                 = [];

for nsuj = 1:length(suj_list)
    
    subjectname                                         = ['sub' num2str(suj_list(nsuj))];
    
    list_band                                           = {'slow' 'alpha' 'beta'};
    list_bin                                            = {'b1' 'b3'};
    
    for nband = 1:length(list_band)
        
        icount                                          = 0;
        
        for nback = [1 2]
            for nbin = [1 2]
                
                ext_file                                = [num2str(nback) 'back.*'];
                
                flist                                   = dir(['~/Dropbox/project_me/data/nback/erf/' subjectname ...
                    '.' ext_file '.' list_band{nband} '.' list_bin{nbin} '.erfComb.mat']);
                
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
                    
                    icount                              = icount+1;
                    alldata{nsuj,nband,icount}          = avg_temp;
                    
                    clear avg_temp ; clc;
                else
                    bad_suj                             = [bad_suj; nsuj];
                end
                
            end
        end
    end
end
%%

keep alldata list_* bad_suj

bad_suj                                 = unique(bad_suj);
alldata(bad_suj,:,:)                    = [];

nbsuj                                   = size(alldata,1);
[design,neighbours]                     = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

for nband = 1:size(alldata,2)
    
    cfg                                 = [];
    cfg.latency                         = [-0.01 0.5];
    cfg.minnbchan                       = 3;
    cfg.method                          = 'ft_statistics_montecarlo';
    cfg.statistic                       = 'ft_statfun_depsamplesFmultivariate';
    cfg.correctm                        = 'cluster';
    cfg.clusteralpha                    = 0.05;
    cfg.clusterstatistic                = 'maxsum'; %'maxsum', 'maxsize', 'wcm'
    cfg.clusterthreshold                = 'nonparametric_common';
    cfg.tail                            = 1; % For a F-statistic, it only make sense to calculate the right tail
    cfg.clustertail                     = cfg.tail;
    cfg.alpha                           = 0.05;
    cfg.computeprob                     = 'yes';
    cfg.numrandomization                = 1000;
    cfg.neighbours                      = neighbours;
    
    design                              = zeros(2,4*nbsuj);
    design(1,1:nbsuj)                   = 1;
    design(1,nbsuj+1:2*nbsuj)           = 2;
    design(1,nbsuj*2+1:3*nbsuj)         = 3;
    design(1,nbsuj*3+1:4*nbsuj)         = 4;
    design(2,:)                         = repmat(1:nbsuj,1,4);
    cfg.design                          = design;
    cfg.ivar                            = 1; % condition
    cfg.uvar                            = 2; % subject number
    
    stat{nband}                         = ft_timelockstatistics(cfg,alldata{:,nband,1},alldata{:,nband,2},alldata{:,nband,3},alldata{:,nband,4});
    tmp                                 = stat{nband}.prob .* stat{nband}.mask; tmp(tmp == 0) = NaN;
    min_p(nband)                        = nanmin(nanmin(tmp)); clear tmp;
    
end

disp('done testing');
keep alldata list_* stat min_p p_val

%%

close all;

plimit                                  = 0.1;


for nband = 1:length(stat)
    if min_p(nband) < plimit
        
        figure;
        
        cfg                             = [];
        cfg.nrow                        = 3;
        cfg.ncol                     	= 3;
        cfg.start                       = 0;
        cfg.list_cond                   = {'1b-low' '1b-high' '2b-low' '2b-high'};
        func_plotstatanova(cfg,squeeze(alldata(:,nband,:)),stat{nband})
        title(list_band{nband});
        
        
    end
end

%%

nrow                                    = 3;
ncol                                    = 2;
i                                       = 0;

for nband = 1:length(stat)
    if min_p(nband) < plimit
        
        figure;
        
        nw_data                         = squeeze(alldata(:,nband,:));
        nw_stat                         = stat{nband};
        
        statplot                        = [];
        statplot.avg                 	= nw_stat.mask .* nw_stat.stat;
        statplot.label               	= nw_stat.label;
        statplot.dimord              	= nw_stat.dimord;
        statplot.time                 	= nw_stat.time;
        
        cfg                             = [];
        cfg.layout                      = 'neuromag306cmb.lay';
        cfg.zlim                        = [-2 2];
        %         cfg.xlim                        = [0.1 0.15];
        cfg.colormap                    = brewermap(256,'*RdBu');
        cfg.marker                      = 'off';
        cfg.comment                     = 'no';
        cfg.colorbar                    = 'no';
        
        i = i + 1;
        subplot(nrow,ncol,i)
        ft_topoplotER(cfg,statplot);
        title({[list_band{nband}],['p = ' num2str(round(min_p(nband),3))]});
        
        set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');
        
        list_chan                       = {'MEG0732+0733', 'MEG0742+0743', 'MEG1832+1833', ...
            'MEG2012+2013', 'MEG2022+2023', 'MEG2242+2243'};
        
        cfg                             = [];
        cfg.channel                     = list_chan;
        cfg.time_limit              	= nw_stat.time([1 end]);
        cfg.color                       = [253,187,132;227,74,51;158,188,218;136,86,167];
        cfg.color                       = cfg.color ./ 256;
        
        cfg.z_limit                     = [-0.5e-12 5.5e-12];
        cfg.linewidth                   = 10;
        i = i + 1;
        subplot(nrow,ncol,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
        legend({'1b-low' '' '1b-high' '' '2b-low' '' '2b-high'});
        
        xlim(statplot.time([1 end]));
        hline(0,'-k');
        vline(0,'-k');
        xticks([0 0.1 0.2 0.3 0.4 0.5]);
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
    end
end