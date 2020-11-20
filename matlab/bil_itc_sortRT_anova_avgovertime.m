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
    list_cue                        = {'cuelock' 'precuelock' 'retrocuelock'};
    
    for nc = 1:length(list_cue)
        
        if nc == 1
            fname                	= [project_dir 'data/' sujName '/tf/' sujName '.' list_cue{nc} '.itc.comb.5binned.allchan.mat'];
            
        else
            fname                   = [project_dir 'data/' sujName '/tf/' sujName '.' list_cue{nc} '.itc.comb.5binned.allchan.withevoked.mat'];
        end
        
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
            
            alldata{ns,nc,nb}       = freq; clear freq;
            
        end
    end
end

keep alldata list_*

list_time                           = [3 3.5; 3.5 4.5; 4.5 5; 5 6];%

for nc = 1:length(list_cue)
    for ntime = 1:size(list_time,1)
        
        nsuj                    	= size(alldata,1);
        [design,neighbours]      	= h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;
        
        cfg                     	= [];
        cfg.method              	= 'ft_statistics_montecarlo';
        cfg.statistic            	= 'ft_statfun_depsamplesFmultivariate';
        cfg.correctm              	= 'cluster';
        cfg.clusteralpha           	= 0.05;
        cfg.clusterstatistic      	= 'maxsum';
        cfg.clusterthreshold      	= 'nonparametric_common';
        cfg.tail                 	= 1; % For a F-statistic, it only make sense to calculate the right tail
        cfg.clustertail         	= cfg.tail;
        cfg.alpha               	= 0.05;
        cfg.computeprob           	= 'yes';
        cfg.numrandomization      	= 1000;
        cfg.neighbours             	= neighbours;
        
        cfg.frequency               = [1 8];
        cfg.minnbchan               = 3; % !!
        cfg.alpha                   = 0.025;
        
        cfg.numrandomization        = 1000;
        cfg.design                  = design;
        
        nbsuj                       = size(alldata,1);
        
        design                      = zeros(2,5*nbsuj);
        design(1,1:nbsuj)           = 1;
        design(1,nbsuj+1:2*nbsuj)   = 2;
        design(1,nbsuj*2+1:3*nbsuj) = 3;
        design(1,nbsuj*3+1:4*nbsuj) = 4;
        design(1,nbsuj*4+1:5*nbsuj) = 5;
        design(2,:)                 = repmat(1:nbsuj,1,5);
        
        cfg.design                  = design;
        cfg.ivar                    = 1; % condition
        cfg.uvar                    = 2; % subject number
        
        t1                        	= list_time(ntime,1);
        t2                        	= list_time(ntime,2);
        list_stat{ntime,nc}        	= [list_cue{nc} ' p' num2str(abs(t1*1000)) 'p' num2str(abs((t2)*1000))];
        
        cfg.latency              	= [t1 t2];
        cfg.avgovertime          	= 'yes';
        stat{ntime,nc}             	= ft_freqstatistics(cfg, alldata{:,nc,1},alldata{:,nc,2},alldata{:,nc,3},alldata{:,nc,4},alldata{:,nc,5});
        stat{ntime,nc}             	= rmfield(stat{ntime,nc},'cfg');
        
    end
end

keep alldata stat list_*

for nc = 1:size(stat,2)
    
    figure;
    nrow                                = 4;
    ncol                                = 3;
    i                                   = 0;
    
    for ntime = 1:size(stat,1)
        
        stoplot                  	= [];
        stoplot.time             	= stat{ntime,nc}.freq;
        stoplot.label             	= stat{ntime,nc}.label;
        stoplot.dimord            	= 'chan_time';
        stoplot.avg                	= squeeze(stat{ntime,nc}.stat .* stat{ntime,nc}.mask);
        
        if length(unique(stoplot.avg)) > 1
            
            i                    	= i + 1;
            subplot(nrow,ncol,i)
            
            cfg                  	= [];
            cfg.layout            	= 'CTF275_helmet.mat'; %'CTF275.lay';
            cfg.marker            	= 'off';
            cfg.comment           	= 'no';
            cfg.colorbar           	= 'no';
            cfg.colormap          	= brewermap(256, '*Reds');
            cfg.ylim              	= 'zeromax';
            ft_topoplotER(cfg,stoplot);
            title(list_stat{ntime,nc});
            
            i = i +1;
            subplot(nrow,ncol,i)
            plot(stoplot.time,nanmean(stoplot.avg,1),'-k','LineWidth',2);
            title(list_stat{ntime,nc});
            
            i = i +1;
            subplot(nrow,ncol,i)
            
            data_plot            	= [];
            
            for nsuj = 1:size(alldata,1)
                for nbin = 1:size(alldata,3)
                    
                    cfg           	= [];
                    cfg.channel  	= stat{ntime,nc}.label;
                    cfg.latency   	= list_time(ntime,:);
                    cfg.frequency  	= stat{ntime,nc}.freq([1 end]);
                    cfg.avgovertime	= 'yes';
                    tmp           	= ft_selectdata(cfg,alldata{nsuj,nc,nbin});
                    
                    tmp           	= tmp.powspctrm .* squeeze(stat{ntime,nc}.mask);
                    tmp(tmp == 0)  	= NaN;
                    tmp            	= nanmean(nanmean(tmp));
                    
                    data_plot(nsuj,nbin,:)  = tmp; clear tmp;
                    
                end
            end
            
            mean_data           	= nanmean(data_plot,1);
            bounds               	= nanstd(data_plot, [], 1);
            bounds_sem            	= bounds ./ sqrt(size(data_plot,1));
            
            errorbar(mean_data,bounds_sem,'-ks');
            
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
end