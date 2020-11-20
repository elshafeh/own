clear ; clc;

if isunix
    project_dir                     = '/project/3015079.01/';
    start_dir                       = '/project/';
else
    project_dir                     = 'P:/3015079.01/';
    start_dir                       = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for ns = 1:length(suj_list)
    
    sujName                         = suj_list{ns};
    list_cue                        = {'precuelock' 'retrocuelock'};
    
    for nc = 1:length(list_cue)

        fname                       = [project_dir 'data/' sujName '/tf/' sujName '.'  list_cue{nc} '.itc.5binned.withEvoked.withIncorrect.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        for nb = 1:length(phase_lock)
            
            freq                    = phase_lock{nb};
            freq                    = rmfield(freq,'rayleigh');
            freq                    = rmfield(freq,'p');
            freq              		= rmfield(freq,'sig');
            freq                    = rmfield(freq,'mask');
            freq                    = rmfield(freq,'mean_rt');
            freq                    = rmfield(freq,'med_rt');
            freq                    = rmfield(freq,'index');
            freq                    = rmfield(freq,'perc_corr');
            
            alldata{ns,nc,nb}       = freq; clear freq;
            
        end
    end
end

keep alldata list_*


for nc = 1:length(list_cue)
    
    nsuj                            = size(alldata,1);
    [design,neighbours]             = h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;
    
    cfg                             = [];
    cfg.method                      = 'ft_statistics_montecarlo';
    cfg.statistic                   = 'ft_statfun_depsamplesFmultivariate';
    cfg.correctm                    = 'cluster';
    cfg.clusteralpha                = 0.05;
    cfg.clusterstatistic            = 'maxsum';
    cfg.clusterthreshold            = 'nonparametric_common';
    cfg.tail                        = 1; % For a F-statistic, it only make sense to calculate the right tail
    cfg.clustertail                 = cfg.tail;
    cfg.alpha                       = 0.05;
    cfg.computeprob                 = 'yes';
    cfg.numrandomization            = 1000;
    cfg.neighbours                  = neighbours;
    
    cfg.minnbchan                   = 3; % !!
    cfg.alpha                       = 0.025;
    
    cfg.numrandomization            = 1000;
    cfg.design                      = design;
    
    nbsuj                           = size(alldata,1);
    
    design                          = zeros(2,5*nbsuj);
    design(1,1:nbsuj)               = 1;
    design(1,nbsuj+1:2*nbsuj)       = 2;
    design(1,nbsuj*2+1:3*nbsuj)     = 3;
    design(1,nbsuj*3+1:4*nbsuj)     = 4;
    design(1,nbsuj*4+1:5*nbsuj)     = 5;
    design(2,:)                     = repmat(1:nbsuj,1,5);
    
    cfg.design                      = design;
    cfg.ivar                        = 1; % condition
    cfg.uvar                        = 2; % subject number
    
    cfg.latency                     = [-0.1 6];
    cfg.frequency                   = [1 6];
    
    stat{nc}                        = ft_freqstatistics(cfg, alldata{:,nc,1},alldata{:,nc,2},alldata{:,nc,3},alldata{:,nc,4},alldata{:,nc,5});
    stat{nc}                        = rmfield(stat{nc},'cfg');
    
end

% load ../data/stat/bil.itc.bin.anova.withcues.mat

keep alldata stat list_*

%%

figure;
nrow                                = 3;
ncol                                = 5;
i                                   = 0;

list_topo                           = {'*Reds','*Purples'};
list_color                          = {'-b' '-m'}; 

for nc = 1:length(stat)
    
        stoplot                  	= [];
        stoplot.freq             	= stat{nc}.freq;
        stoplot.time             	= stat{nc}.time;
        stoplot.label             	= stat{nc}.label;
        stoplot.dimord            	= 'chan_freq_time';
        stoplot.powspctrm        	= squeeze(stat{nc}.stat .* stat{nc}.mask);clc;
        
        if length(unique(stoplot.powspctrm)) > 1
            
            i                    	= i + 1;
            subplot(nrow,ncol,i)
            
            cfg                  	= [];
            cfg.layout            	= 'CTF275_helmet.mat'; 
            cfg.marker            	= 'off';
            cfg.comment           	= 'no';
            cfg.colorbar           	= 'no';
            
            if i == 1
                cfg.colormap      	= brewermap(256, '*Reds');
            else
                cfg.colormap    	= brewermap(256, '*Purples');
            end
            
            cfg.zlim              	= 'zeromax';
            ft_topoplotTFR(cfg,stoplot);
            title(list_cue{nc});
            
            
            i = i +1;
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,stoplot);title('');
            vline([0 1.5 3 4.5]);
            
            i = i +1;
            subplot(nrow,ncol,i)
            vct = nanmean(nanmean(stoplot.powspctrm,3));
            plot(stoplot.freq,vct,list_color{nc},'LineWidth',2);
            xlim(stat{nc}.freq([1 end]));
            
            i = i +1;
            subplot(nrow,ncol,i)
            vct = squeeze(nanmean(nanmean(stoplot.powspctrm,1),2));
            plot(stoplot.time,vct,list_color{nc},'LineWidth',2);
            xlim(stat{nc}.time([1 end]));
            
            i = i +1;
            subplot(nrow,ncol,i)
            
            data_plot            	= [];
            
            for nsuj = 1:size(alldata,1)
                for nbin = 1:size(alldata,3)
                    
                    cfg           	= [];
                    cfg.channel  	= stat{nc}.label;
                    cfg.latency   	= stat{nc}.time([1 end]);
                    cfg.frequency  	= stat{nc}.freq([1 end]);
                    tmp           	= ft_selectdata(cfg,alldata{nsuj,nc,nbin});clc;
                    
                    tmp           	= tmp.powspctrm .* squeeze(stat{nc}.mask);
                    tmp(tmp == 0)  	= NaN;
                    tmp            	= nanmean(nanmean(nanmean(tmp)));
                    
                    data_plot(nsuj,nbin,:)  = tmp; clear tmp;
                    
                end
            end
            
            mean_data           	= nanmean(data_plot,1);
            bounds               	= nanstd(data_plot, [], 1);
            bounds_sem            	= bounds ./ sqrt(size(data_plot,1));
            
            errorbar(mean_data,bounds_sem,[list_color{nc} 's']);
            
            xlim([0 6]);
            %         ylim([0 0.1]);
            xticks([1 2 3 4 5]);
            xticklabels({'Fastest','','Median','','Slowest'});
            
            [h2,p2]               	= ttest(data_plot(:,1),data_plot(:,2));
            [h3,p3]              	= ttest(data_plot(:,1),data_plot(:,3));
            [h4,p4]              	= ttest(data_plot(:,1),data_plot(:,4));
            [h5,p5]               	= ttest(data_plot(:,1),data_plot(:,5));
            
            [h6,p6]                	= ttest(data_plot(:,2),data_plot(:,3));
            [h7,p7]               	= ttest(data_plot(:,2),data_plot(:,4));
            [h8,p8]               	= ttest(data_plot(:,2),data_plot(:,5));
            
            [h9,p9]               	= ttest(data_plot(:,3),data_plot(:,4));
            [h10,p10]           	= ttest(data_plot(:,3),data_plot(:,5));
            
            [h11,p11]             	= ttest(data_plot(:,4),data_plot(:,5));
            
            list_group           	= {[1 2],[1 3],[1 4],[1 5],[2 3],[2 4],[2 5],[3 4],[3 5],[4 5]};
            list_p               	= [p2 p3 p4 p5 p6 p7 p8 p9 p10 p11];
            
            %         sigstar(list_group,list_p)
            
        end
end