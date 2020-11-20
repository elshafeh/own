function h_plotanova(cfg_in,stat,alldata,fig_title)

if length(unique(stat.mask)) > 1
    
    for nsuj = 1:size(alldata,1)
        for ncond = 1:size(alldata,2)
            
            % sub select labels and time/frequency points to avoid later
            % confusion
            cfg                             = [];
            cfg.channel                     = stat.label;
            if strcmp(stat.dimord,'chan_freq')
                cfg.frequency               = stat.freq([1 end]);
            elseif strcmp(stat.dimord,'chan_time')
                cfg.latency                 = stat.time([1 end]);
            end
            tmp_labelmat                    = ft_selectdata(cfg,alldata{nsuj,ncond});
            
            if strcmp(stat.dimord,'chan_freq')
                mtrx_data(nsuj,ncond,:,:)   = tmp_labelmat.powspctrm;
            elseif strcmp(stat.dimord,'chan_time')
                mtrx_data(nsuj,ncond,:,:)   = tmp_labelmat.avg;
            end
            
            newalldata{nsuj,ncond}          = tmp_labelmat;
            
        end
    end
    
    clc;
    
    figure;
    nrow                                    = cfg_in.nrow;
    ncol                                    = cfg_in.ncol;
    i                                       = 0;
    
    if isfield(stat,'posclusters')
        for ncluster = 1:length(stat.posclusters)
            
            tmp_mat                         = stat.posclusterslabelmat;
            tmp_mat(tmp_mat ~= ncluster)    = 0;
            tmp_mask                        = tmp_mat .* stat.mask; %.* stat.stat;
            
            new_stat                        = stat;
            new_stat.mask                   = tmp_mask;
            
            vct                            	= mean(double(new_stat.mask),2);
            sig_chan                        = find(vct ~=0);
            
            vct                            	= mean(double(new_stat.mask),1);
            sig_time                        = find(vct ~=0);
            
            if length(unique(tmp_mask)) > 1
                
                statplot                    = [];
                statplot.time               = new_stat.time;
                statplot.label              = new_stat.label;
                statplot.dimord             = new_stat.dimord;
                statplot.avg                = tmp_mask .* new_stat.stat;
                
                % plot results
                
                cfg                         = [];
                cfg.layout                  = cfg_in.topo.layout;
                cfg.colormap                = cfg_in.topo.colormap;
                cfg.marker                  = 'off';
                cfg.comment                 = 'no';
                cfg.colorbar                = 'yes';
                i =i +1;
                subplot(nrow,ncol,i);
                ft_topoplotER(cfg,statplot);
                title([fig_title ' p = ' num2str(stat.posclusters(ncluster).prob,3)]);
                
                cfg                         = [];
                cfg.channel                 = new_stat.label(sig_chan);
                i =i +1;
                subplot(nrow,ncol,i);
                ft_singleplotER(cfg,statplot);
                xlim(statplot.time([1 end]));
                ax	= gca;
                lm  = ax.YAxis.Limits([1 end]);
                ylim(round(lm));
                yticks(round(lm));
                vline(0,'-k');title('');
                
                cfg                         = [];
                cfg.channel                 = new_stat.label(sig_chan);
                cfg.time_limit              = new_stat.time([1 end]);
                cfg.color                   = 'rgb';
                %             cfg.z_limit                 = [-0.2 0.2];
                cfg.linewidth               = 10;
                i =i +1;
                subplot(nrow,ncol,i);
                h_plotSingleERFstat_selectChannel_nobox(cfg,new_stat,newalldata);
                xlim(statplot.time([1 end]));
                vline(0,'--k');
                hline(0,'--k');
                title([num2str(round(stat.time(sig_time(1)),2)) ' s - ' num2str(round(stat.time(sig_time(end)),2)) ' s']);
                
                for nsuj = 1:size(mtrx_data,1)
                    for ncond = 1:size(mtrx_data,2)
                        tmp                 = squeeze(mtrx_data(nsuj,ncond,:,:)) .* tmp_mask;
                        tmp(tmp ==0)        = NaN;
                        tmp                 = nanmean(nanmean(tmp));
                        d_plot(nsuj,ncond)  = tmp; clear tmp;
                    end
                end
                
                [h1,p1]                     = ttest(d_plot(:,1),d_plot(:,2));
                [h2,p2]                  	= ttest(d_plot(:,1),d_plot(:,3));
                [h3,p3]                   	= ttest(d_plot(:,2),d_plot(:,3));
                
                mean_data                   = nanmean(d_plot,1);
                bounds                      = nanstd(d_plot, [], 1);
                bounds_sem                  = bounds ./ sqrt(size(d_plot,1));
                
                i =i +1;
                subplot(nrow,ncol,i);
                errorbar(mean_data,bounds_sem,'-ks');
                
                xlim([0 size(d_plot,2)+1]);
                xticks([1:size(d_plot,2)]);
                xticklabels(cfg_in.posthoc.xticklabels);
                
                title_prt1                  = [cfg_in.posthoc.xticklabels{1} 'v' cfg_in.posthoc.xticklabels{2} ' = ' num2str(round(p1,3))];
                title_prt2                  = [cfg_in.posthoc.xticklabels{1} 'v' cfg_in.posthoc.xticklabels{3} ' = ' num2str(round(p2,3))];
                title_prt3                  = [cfg_in.posthoc.xticklabels{2} 'v' cfg_in.posthoc.xticklabels{3} ' = ' num2str(round(p3,3))];
                
                title([title_prt1 ' ' title_prt2 ' ' title_prt3]);
                
                clear h1 h2 h3 p1 p2 p3 mean_data bounds* d_plot
                
            end
        end
    end
    
end