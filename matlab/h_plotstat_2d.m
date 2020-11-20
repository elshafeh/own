function h_plotstat_2d(cfg_in,stat,alldata)

% stat: either chan_time or chan_freq
% alldata: array of data used in stat-test
% cfg.plimit = p-val threshold , only clusters with p-values less than
% plimit will be plotted.
% cfg.legend -> for plots
% cfg.layout: e.g. 'CTF275_helmet.mat';
% cfg.colormap : e.g. brewermap(256,'*RdBu');
% cfg.maskstyle: nan or highlight (nan will mask insig time points while
% highlight will display the traditional significant line

% optional 
% cfg.legend
% cfg.xticks
% cfg.xticklabels
% cfg.ylim

[min_pvalue , ~]                            = h_pValSort(stat); % extract p-values for all clusters

if min_pvalue < cfg_in.plimit
    
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
            tmp_labelmat                             = ft_selectdata(cfg,alldata{nsuj,ncond});
            
            if strcmp(stat.dimord,'chan_freq')
                mtrx_data(nsuj,ncond,:,:)   = tmp_labelmat.powspctrm;
            elseif strcmp(stat.dimord,'chan_time')
                mtrx_data(nsuj,ncond,:,:)   = tmp_labelmat.avg;
            end
            
        end
    end
    
    keep mtrx_data stat cfg_in ; clc;
    
    % change the dimord to use less if- loops :)
    if strcmp(stat.dimord,'chan_freq')
        stat.time                           = stat.freq;
        stat                                = rmfield(stat,'freq');
        stat.dimord                         = 'chan_time';
    end
    
    [min_pvalue , list_pvalue]              = h_pValSort(stat); % extract p-values for all clusters
    
    if min_pvalue > cfg_in.plimit
        fprintf('no significant clusters found!\n');
    else
        vct                              	= list_pvalue(1,:);
        fprintf('%2d significant clusters found\n',length(vct(vct<cfg_in.plimit)));
        
        list_signs                          = [-1 1]; % to go through -ve and + clusters
        
        for nsign = [-1 1]
            
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
            
            if length(sig_clusters) > 1
                nrow                     	= length(sig_clusters);
            else
                nrow                        = 2;
            end
            ncol                            = 4;
            i                               = 0;
            figure;
            
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
                stat2plot.dimord            = stat.dimord;
                stat2plot.label             = stat.label;
                stat2plot.avg               = stat.stat .* tmp_labelmat;
                
                cfg                         = [];
                cfg.layout                  = cfg_in.layout;
                cfg.colormap                = cfg_in.colormap;
                cfg.marker                  = 'off';
                cfg.zlim                    = 'maxabs';
                cfg.marker                  = 'off';
                cfg.comment                 = 'no';
                
                i                           = i +1;
                subplot(nrow,ncol,i)
                ft_topoplotER(cfg,stat2plot)
                title({'blue vs red',cfg_in.title,[ext_name ' cluster #' num2str(ncluster) ' topo p=' num2str(round(vct(sig_clusters(ncluster)),3))]});
                
                vct_plot                    = stat2plot.avg;
                vct_plot(vct_plot == 0)     = NaN;
                vct_plot                    = squeeze(nanmean(vct_plot,1));
                vct_plot(isnan(vct_plot))   = 0;
                
                min_val                     = floor(nanmin(vct_plot));
                max_val                     = floor(nanmax(vct_plot));
                
                if nsign == -1
                    ylim_vct                = [min_val 0];
                else
                    ylim_vct                = [0 max_val];
                end
                
                i                           = i +1;
                subplot(nrow,ncol,i)
                plot(stat.time,vct_plot,'-k','LineWidth',2);
                xlim(stat.time([1 end]));
                ylim(ylim_vct);
                yticks(ylim_vct);
                
                vct_plot(vct_plot~=0)       = 1;
                vct_plot                    = stat2plot.time .* vct_plot;
                vct_plot                    = vct_plot(vct_plot ~=0);
                
                time_ext                    = [num2str(round(vct_plot(1),2)) ' - ' num2str(round(vct_plot(end),2)) ' s'];
                
                title([ext_name ' cluster #' num2str(ncluster) ' tval ' time_ext]);
                
                list_color                  = 'br';
                
                i                           = i +1;
                subplot(nrow,ncol,i:i+1)
                hold on;
                i                           = i+1;
                vct_plot                    = [];
                
                for ncond = 1:size(mtrx_data,2)
                    
                    for nsuj = 1:size(mtrx_data,1)
                        if strcmp(cfg_in.maskstyle,'nan')
                            vct_sub             = squeeze(mtrx_data(nsuj,ncond,:,:)) .* tmp_labelmat;
                            vct_sub(vct_sub == 0)	= NaN;
                        elseif strcmp(cfg_in.maskstyle,'highlight')
                            
                            sig_chan            = mean(tmp_labelmat,2);
                            sig_chan            = find(sig_chan ~= 0);
                            vct_sub             = squeeze(mtrx_data(nsuj,ncond,sig_chan,:));
                            
                        end
                        vct_plot(nsuj,:)      	= nanmean(vct_sub,1); clear vct_sub;
                    end
                    
                    mean_data                   = squeeze(nanmean(vct_plot,1));
                    bounds                      = squeeze(nanstd(vct_plot, [], 1));
                    bounds_se                   = squeeze(bounds ./ sqrt(size(vct_plot,1)));
                    
                    mean_data(isnan(mean_data)) = 0;
                    bounds_se(isnan(mean_data)) = 0;
                    boundedline(stat.time, mean_data, bounds_se,['-' list_color(ncond)],'alpha'); % alpha makes bounds transparent
                    
                    clear mean_data bounds* vct_*
                    
                end
                
                if strcmp(cfg_in.maskstyle,'highlight')
                    
                    ax                              = gca;
                    lm                              = ax.YAxis.Limits(end);
                    plot_vct                        = mean(tmp_labelmat,1);
                    plot_vct(plot_vct ~= 0)         = lm;
                    plot_vct(plot_vct == 0)         = NaN;
                    plot(stat.time,plot_vct,'-g','LineWidth',6);
                    
                end
                
                if isfield(cfg_in,'legend')
                    legend({'' cfg_in.legend{1} '' cfg_in.legend{2} ['p < ' num2str(cfg_in.plimit)]});
                end
                
                if isfield(cfg_in,'xticks')
                    xticks(cfg_in.xticks);
                end
                
                if isfield(cfg_in,'xticklabels')
                    xticklabels(cfg_in.xticklabels);
                end
                
                title([ext_name ' cluster #' num2str(ncluster) ' masked data [blue-red]']);
                         
                xlim(stat.time([1 end]));
                
                if isfield(cfg_in,'ylim')
                    ylim(cfg_in.ylim);
                end
                
                if isfield(cfg_in,'vline')
                vline(cfg_in.vline,'--k');
                end
                
                hline(0,'--k');
                
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