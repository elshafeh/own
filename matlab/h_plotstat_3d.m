function h_plotstat_3d(cfg_in,stat) 

% stat: either chan_time or chan_freq
% alldata: array of data used in stat-test
% cfg.plimit = p-val threshold , only clusters with p-values less than
% plimit will be plotted.
% cfg.legend -> for plots
% cfg.layout: e.g. 'CTF275_helmet.mat';
% cfg.colormap : e.g. brewermap(256,'*RdBu');


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
        
                
        figure;
        nrow                        	= length(sig_clusters);
        if nrow < 2
            nrow = 2;
        end
        ncol                            = 4;
        i                               = 0;
        
        for ncluster = 1:length(sig_clusters)
            
            if nsign == -1
                tmp_labelmat        	= stat.negclusterslabelmat;
                ext_name                = 'neg';
            else
                tmp_labelmat        	= stat.posclusterslabelmat;
                ext_name                = 'pos';
            end
            
            tmp_labelmat(tmp_labelmat~=sig_clusters(ncluster))         = 0;
            
            stat2plot                   = [];
            stat2plot.time              = stat.time;
            stat2plot.freq              = stat.freq;
            stat2plot.dimord            = stat.dimord;
            stat2plot.label             = stat.label;
            stat2plot.powspctrm       	= stat.stat .* tmp_labelmat;
            
            cfg                         = [];
            cfg.layout                  = cfg_in.layout;
            cfg.colormap                = cfg_in.colormap;
            cfg.zlim                    = cfg_in.zlim;
            cfg.marker                  = 'off';
            cfg.zlim                    = 'maxabs';
            cfg.marker                  = 'off';
            cfg.comment                 = 'no';
            
            i                           = i +1;
            subplot(nrow,ncol,i)
            ft_topoplotTFR(cfg,stat2plot)
            title([ext_name ' cluster #' num2str(ncluster) ' topo p=' num2str(vct(sig_clusters(ncluster)))]);
            
            i                           = i +1;
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,stat2plot);
            title('');
            
            if isfield(cfg_in,'vline')
            vline(cfg_in.vline,'--k');
            end
            
            % - % - avg over time
            vct_plot                    = squeeze(mean(stat2plot.powspctrm,3));
            vct_plot(vct_plot == 0)     = NaN;
            vct_plot                    = squeeze(nanmean(vct_plot,1));
            vct_plot(isnan(vct_plot))   = 0;
            
            min_val                     = floor(min(vct_plot)); % round down
            max_val                     = ceil(max(vct_plot)); % round up
            
            if nsign == -1
                ylim_vct                = [min_val 0];
            else
                ylim_vct                = [0 max_val];
            end
            
            i                           = i +1;
            subplot(nrow,ncol,i)
            plot(stat.freq,vct_plot,'-k','LineWidth',2);
            xlim(stat.freq([1 end]));
            title([ext_name ' cluster #' num2str(ncluster) ' tval']);
            ylim(ylim_vct);
            yticks(ylim_vct);
            
            % - % - avg over freq
            vct_plot                    = squeeze(mean(stat2plot.powspctrm,2));
            vct_plot(vct_plot == 0)     = NaN;
            vct_plot                    = squeeze(nanmean(vct_plot,1));
            vct_plot(isnan(vct_plot))   = 0;
            
            min_val                     = floor(min(vct_plot)); % round down
            max_val                     = ceil(max(vct_plot)); % round up
            
            if nsign == -1
                ylim_vct                = [min_val 0];
            else
                ylim_vct                = [0 max_val];
            end
            
            i                           = i +1;
            subplot(nrow,ncol,i)
            plot(stat.time,vct_plot,'-k','LineWidth',2);
            xlim(stat.time([1 end]));
            title([ext_name ' cluster #' num2str(ncluster) ' tval']);
            if length(unique(ylim_vct)) >1
            ylim(ylim_vct);
            yticks(ylim_vct);
            end
            
            if isfield(cfg_in,'vline')
            vline(cfg_in.vline,'--k');
            end
            
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