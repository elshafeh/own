function h_plotstat_3d(cfg_in,stat)

% stat: either chan_time or chan_freq
% alldata: array of data used in stat-test
% cfg.plimit = p-val threshold , only clusters with p-values less than
% plimit will be plotted.
% cfg.legend -> for plots
% cfg.layout: e.g. 'CTF275_helmet.mat';
% cfg.colormap : e.g. brewermap(256,'*RdBu');
% cfg.test_name
% cfg.fontsize

% for nsuj = 1:size(alldata,1)
%     for ncond = 1:size(alldata,2)
%
%         % sub select labels and time/frequency points to avoid later
%         % confusion
%
%         fprintf('selecting data for sub %2d cond %2d\n',nsuj,ncond);
%
%         cfg                             = [];
%         cfg.channel                     = stat.label;
%         cfg.frequency                   = stat.freq([1 end]);
%         cfg.latency                     = stat.time([1 end]);
%         tmp                             = ft_selectdata(cfg,alldata{nsuj,ncond});
%
%         mtrx_data(nsuj,ncond,:,:,:)   	= tmp.powspctrm; clear tmp;
%
%
%     end
% end
%
% keep mtrx_data stat cfg_in ;

[min_pvalue , list_pvalue]              = h_pValSort(stat); % extract p-values for all clusters

if min_pvalue > cfg_in.plimit
    fprintf('no significant clusters found!\n');
else
    vct                              	= list_pvalue(1,:);
    nb_all_sig_clusters                 = length(vct(vct<cfg_in.plimit));
    fprintf('%2d significant clusters found\n',nb_all_sig_clusters);
    
    for nsign = cfg_in.sign   % to go through -ve and + clusters
        
        if nsign == -1
            if isempty(stat.negclusters)
                sig_clusters         	= [];
            else
                vct                  	= [stat.negclusters.prob];
                sig_clusters         	= find(vct < cfg_in.plimit);
            end
        else
            if isempty(stat.posclusters)
                sig_clusters         	= [];
            else
                vct                  	= [stat.posclusters.prob];
                sig_clusters         	= find(vct < cfg_in.plimit);
            end
        end
        
        for ncluster = 1:length(sig_clusters)
            
            figure;
            nrow                        = 2;
            ncol                       	= 2;
            i                         	= 0;
            
            if nsign == -1
                tmp_labelmat        	= stat.negclusterslabelmat;
                ext_name                = 'neg';
            else
                tmp_labelmat        	= stat.posclusterslabelmat;
                ext_name                = 'pos';
            end
            
            tmp_labelmat(tmp_labelmat~=sig_clusters(ncluster))         = 0;
            
            stat2topo                   = [];
            stat2topo.time              = stat.time;
            stat2topo.freq              = stat.freq;
            stat2topo.dimord            = stat.dimord;
            stat2topo.label             = stat.label;
            stat2topo.powspctrm       	= stat.stat .* tmp_labelmat;
            
            find_sig_chan             	= mean(mean(stat2topo.powspctrm,2),3);
            find_sig_chan            	= find(find_sig_chan ~= 0);
            
            find_sig_time               = squeeze(mean(mean(stat2topo.powspctrm(find_sig_chan,:,:),1),2));
            find_sig_time               = find(find_sig_time ~= 0);
            
            find_sig_freq               = squeeze(mean(mean(stat2topo.powspctrm(find_sig_chan,:,find_sig_time),1),3));
            find_sig_freq               = find(find_sig_freq ~= 0);
            
            cfg                         = [];
            
            cfg.xlim                    = [min(stat.time(find_sig_time)) max(stat.time(find_sig_time))];
            cfg.ylim                    = [min(stat.freq(find_sig_freq)) max(stat.freq(find_sig_freq))];

            cfg.layout                  = cfg_in.layout;
            cfg.colormap                = cfg_in.colormap;
            cfg.zlim                    = cfg_in.zlim;
            cfg.marker                  = 'off';
            %             cfg.zlim                    = 'maxabs';
            cfg.marker                  = 'off';
            cfg.comment                 = 'no';
            cfg.colorbar                = 'yes';
            cfg.figure                  = 0;
            i                           = i +1;
<<<<<<< HEAD
            cfg.figure                  = subplot(nrow,ncol,i);
            ft_topoplotTFR(cfg,stat2plot)
            title([ext_name ' cluster #' num2str(ncluster) ' topo p=' num2str(vct(sig_clusters(ncluster)))]);
            
            i                           = i +1;
            cfg.figure                  = subplot(nrow,ncol,i);
            ft_singleplotTFR(cfg,stat2plot);
            if ncluster == 1
                title(cfg_in.test_name);
            else
                title('');
            end
            
            if isfield(cfg_in,'vline')
            vline(cfg_in.vline,'--k');
            end
=======
            subplot(nrow,ncol,i)
            ft_topoplotTFR(cfg,stat2topo)
            title({[cfg_in.test_name],[ext_name ' cluster #' num2str(ncluster)],[' p = ' num2str(vct(sig_clusters(ncluster)))]});
            
            set(gca,'FontSize',cfg_in.fontsize,'FontName', 'Calibri','FontWeight','normal');
>>>>>>> c4f75347842ec11e353b3cb2cf9bc2a287cf912e
            
            i                           = i +1;
            subplot(nrow,ncol,i);
            
            stat2tfr                    = [];
            stat2tfr.label              = {'avg chan'};
            stat2tfr.freq               = stat.freq;
            stat2tfr.time               = stat.time;
            stat2tfr.dimord           	= stat.dimord;
            stat2tfr.powspctrm          = nanmean(stat.stat(find_sig_chan,:,:),1);
            stat2tfr.mask               = nanmean(tmp_labelmat(find_sig_chan,:,:),1);
            stat2tfr.mask(stat2tfr.mask ~= 0) = 1;
            stat2tfr.mask               = logical(stat2tfr.mask);
            
            cfg                         = rmfield(cfg,'xlim');
            cfg                         = rmfield(cfg,'ylim');
            
            cfg.maskparameter           = 'mask';
            cfg.maskstyle               = 'outline';
            cfg.colorbar                = 'no';
            
            ft_singleplotTFR(cfg,stat2tfr);
            
            title('');
            set(gca,'FontSize',cfg_in.fontsize,'FontName', 'Calibri','FontWeight','normal');
            
            if isfield(cfg_in,'vline')
                vline(cfg_in.vline,'--k');
            end
            
            if isfield(cfg_in,'hline')
                hline(cfg_in.hline,'--k');
            end
            
            stat2tfr.powspctrm          = stat2tfr.powspctrm .* stat2tfr.mask;
            h_addaxesplots(stat2tfr);
            
            %             % - % - avg over time
            %             vct_plot                    = squeeze(mean(stat2topo.powspctrm,3));
            %             vct_plot(vct_plot == 0)     = NaN;
            %             vct_plot                    = squeeze(nanmean(vct_plot,1));
            %             vct_plot(isnan(vct_plot))   = 0;
            %
            %             min_val                     = floor(min(vct_plot)); % round down
            %             max_val                     = ceil(max(vct_plot)); % round up
            %
            %             if nsign == -1
            %                 ylim_vct                = [min_val 0];
            %             else
            %                 ylim_vct                = [0 max_val];
            %             end
            %
            %             i                           = i +1;
            %             subplot(nrow,ncol,i)
            %             plot(stat.freq,vct_plot,'-k','LineWidth',2);
            %             xlim(stat.freq([1 end]));
            %             title([ext_name ' cluster #' num2str(ncluster) ' tval']);
            %             ylim(ylim_vct);
            %             yticks(ylim_vct);
            %
            %             xlabel('Frequency (Hz)');
            %
            %             set(gca,'FontSize',cfg_in.fontsize,'FontName', 'Calibri','FontWeight','normal');
            %
            %             % - % - avg over freq
            %             vct_plot                    = squeeze(mean(stat2topo.powspctrm,2));
            %             vct_plot(vct_plot == 0)     = NaN;
            %             vct_plot                    = squeeze(nanmean(vct_plot,1));
            %             vct_plot(isnan(vct_plot))   = 0;
            %
            %             min_val                     = floor(min(vct_plot)); % round down
            %             max_val                     = ceil(max(vct_plot)); % round up
            %
            %             if nsign == -1
            %                 ylim_vct                = [min_val 0];
            %             else
            %                 ylim_vct                = [0 max_val];
            %             end
            %
            %             i                           = i +1;
            %             subplot(nrow,ncol,i)
            %             plot(stat.time,vct_plot,'-k','LineWidth',2);
            %             xlim(stat.time([1 end]));
            %             title([ext_name ' cluster #' num2str(ncluster) ' tval']);
            %             if length(unique(ylim_vct)) >1
            %             ylim(ylim_vct);
            %             yticks(ylim_vct);
            %             end
            %
            %             if isfield(cfg_in,'vline')
            %             vline(cfg_in.vline,'--k');
            %             end
            %
            %             xlabel('Time (s)');
            %
            %             set(gca,'FontSize',cfg_in.fontsize,'FontName', 'Calibri','FontWeight','normal');
            
        end
    end
    
end
end

function [min_p_val,p_val] = h_pValSort(x)

% input : cluster-based permutation stat structure
% ouput : minimum p-value + vector of the p-values of all the clusters with
% indexed by their sign (+/-)

if isfield(x,'posclusters') && isfield(x,'negclusters')
    
    if isempty(x.posclusters)
        p_val       = [x.negclusters.prob; repmat(-1,1,length([x.negclusters.prob]))];
    elseif isempty(x.negclusters)
        p_val       = [x.posclusters.prob; ones(1,length([x.posclusters.prob]))];
    else
        p_val       = horzcat([x.posclusters.prob ; ones(1,length([x.posclusters.prob]))],[x.negclusters.prob ; repmat(-1,1,length([x.negclusters.prob]))]);
    end
    
    p_val           = sortrows(p_val',1)';
    min_p_val       = min(p_val(1,:));
    
else
    
    p_val           = sortrows(unique(x.prob),1);
    min_p_val       = min(p_val);
    
end
end