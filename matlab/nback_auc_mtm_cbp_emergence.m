clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

% load suj_list_peak.mat
% 
% for n_suj = 1:length(suj_list)
%     
%     if n_suj == 1
%         fname                               = ['../../data/source/virtual/0.5cm/sub' num2str(suj_list(n_suj)) '.session1.brain0.5.broadband.dwn80.virt.mat'];
%         fprintf('loading %s\n',fname);
%         load(fname);
%         list_chan                           = data.label;
%     end
%     
%     list_condition                          = {'0v1B','0v2B','1v2B'};
%     list_freq                               = 5:30;
%     
%     pow                                     = [];
%     
%     for n_con = 1:length(list_condition)
%         
%         for n_freq = 1:length(list_freq)
%             
%             fname                           = ['../../data/decode/auc_freq_break/sub' num2str(suj_list(n_suj)) '.' list_condition{n_con} '.broadband.bslcorr.' num2str(list_freq(n_freq)) 'Hz.auc.bychan.mat'];
%             fprintf('loading %s\n',fname);
%             load(fname);
%             
%             pow(:,n_freq,:)                 = scores; clear scores;
%             
%         end
%         
%         freq                                = [];
%         freq.time                           = -1.5:0.05:6;
%         
%         freq.label                          = list_chan;
%         
%         freq.freq                           = list_freq;
%         freq.powspctrm                      = pow;
%         freq.dimord                         = 'chan_freq_time';
%         
%         %         list_unique                         = h_grouplabel(freq,'yes');
%         %         freq                                = h_transform_freq(freq,list_unique(:,2),list_unique(:,1));
%         
%         alldata{n_suj,n_con}                = freq; clear freq;
%         
%     end
%     
%     alldata{n_suj,4}                        = alldata{n_suj,1};
%     alldata{n_suj,4}.powspctrm(:)           = 0.5;
%     
% end
% 
% keep alldata list_*;
% 
% cfg                                         = [];
% cfg.statistic                               = 'ft_statfun_depsamplesT';
% cfg.method                                  = 'montecarlo';
% cfg.correctm                                = 'cluster';
% cfg.clusteralpha                            = 0.05;
% 
% cfg.latency                                 = [-0.1 6];
% 
% cfg.clusterstatistic                        = 'maxsum';
% cfg.minnbchan                               = 0;
% cfg.tail                                    = 0;
% cfg.clustertail                             = 0;
% cfg.alpha                                   = 0.025;
% cfg.numrandomization                        = 1000;
% cfg.uvar                                    = 1;
% cfg.ivar                                    = 2;
% 
% nbsuj                                       = size(alldata,1);
% [design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
% 
% cfg.design                                  = design;
% cfg.neighbours                              = neighbours;
% 
% for n_con = 1:3
%     stat{n_con}                             = ft_freqstatistics(cfg, alldata{:,n_con}, alldata{:,4});
% end

load('/project/3015039.05/temp/nback/data/stat/mtm_decode_stat_with_all_chan.mat');

for ns = 1:length(stat)
    [min_p(ns),p_val{ns}]                       = h_pValSort(stat{ns});
    
    stat{ns}                                    = rmfield(stat{ns},'negdistribution');
    stat{ns}                                    = rmfield(stat{ns},'posdistribution');
end


for ns = 1:length(stat)
    
    figure;
    i                                           = 0;
    plimit                                      = 0.05;
    stat{ns}.mask                               = stat{ns}.prob < plimit;
    
    for nc = 1:length(stat{ns}.label)
        
        tmp                                     = stat{ns}.mask(nc,:,:) .* stat{ns}.prob(nc,:,:);
        ix                                      = unique(tmp);
        ix                                      = ix(ix~=0);
        
        if ~isempty(ix)
            
            i                                   = i + 1;
            
            cfg                                 = [];
            cfg.colormap                        = brewermap(256, '*RdBu');
            cfg.channel                         = nc;
            cfg.parameter                       = 'prob';
            cfg.maskparameter                   = 'mask';
            cfg.maskstyle                       = 'outline';
            cfg.zlim                            = [min(min_p) plimit];
            
            nme                                 = strsplit(stat{ns}.label{nc},',');
            nme                                 = nme{2};
            
            %             nme                                 = strsplit(nme,' ');
            %             nme                                 = [nme{2:end-1}];
            
            if ns == 1
                nrow                            = 1;
                ncol                            = 1;
            elseif ns == 3
                nrow                            = 2;
                ncol                            = 2;
            else
                nrow                            = 6;
                ncol                            = 4;
            end
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,stat{ns});
            title([nme ' ' list_condition{ns}]);
            
            
        end
    end
    
    fprintf('%2d\n',i);
    
end

figure;
i                                   = 0;
for ns = 1:length(stat)
    
    
    plimit                      	= 0.05;
    stat{ns}.mask                	= stat{ns}.prob < plimit;
    tmp                           	= stat{ns}.mask .* stat{ns}.stat;
    
    list_time                       = [0.5 1; 2.5 3; 4.5 5;5 5.5];%[0 1; 1 2; 2 3; 3 4; 4 5; 5 6];
    
    i = i +1;
    subplot(3,2,i);
    hold on;
    
    for nt = 1:size(list_time,1)
        
        ix1             = find(round(stat{ns}.time,2) == round(list_time(nt,1),2));
        ix2             = find(round(stat{ns}.time,2) == round(list_time(nt,2),2));
        
        avg_over_time   = nanmean(nanmean(tmp(:,:,ix1:ix2),1),3);
        
        plot(stat{ns}.freq,avg_over_time,'LineWidth',2);
        
        mx_find         = stat{ns}.freq(find(avg_over_time == max(avg_over_time)));
        mx_val          = max(avg_over_time);
        
        title([list_condition{ns}]);
        xlim(stat{ns}.freq([1 end]));
        
    end
    
    %     legend({'0-1','1-2','2-3','3-4','4-5','5-6'});
    
    avg_over_freq = nanmean(nanmean(tmp,1),2);
    i = i +1;
    subplot(3,2,i);
    plot(stat{ns}.time,squeeze(avg_over_freq),'-k','LineWidth',2);
    title([list_condition{ns}]);
    xlim(stat{ns}.time([1 end]));
    
    
end

figure;
i                                           = 0;

for ns = 1:length(stat)
    
    plimit                                          = 0.05;
    stat{ns}.mask                                   = stat{ns}.prob < plimit;
    list_unique                                     = h_grouplabel(stat{ns},'no'); % h_parcellatelabel(stat{ns});
    
    tmp                                             = stat{ns}.mask .* stat{ns}.stat;
    
    list_time                                       = [0.5 1;
                                                        1 1.5;
                                                        1.5 2; 
                                                        2 2.5;
                                                        2.5 3;
                                                        3 3.5;
                                                        3.5 4;
                                                        4.5 5;
                                                        5 5.5];
    
    for nt = 1:size(list_time,1)
        
        i = i +1;
        subplot(3,size(list_time,1),i);
        hold on;
        
        list_name                                   = [num2str(round(list_time(nt,1),2)) '-' num2str(round(list_time(nt,2),2)) 's'];
        
        plot_indx                                   = [];
        
        ix1                                         = find(round(stat{ns}.time,2) == round(list_time(nt,1),2));
        ix2                                         = find(round(stat{ns}.time,2) == round(list_time(nt,2),2));
        
        for nc = 1:length(list_unique)
            
            avg_over_time                           = nanmean(nanmean(tmp(list_unique{nc,2},:,ix1:ix2),1),3);
            avg_over_time(isnan(avg_over_time))     = 0;
            
            if length(unique(avg_over_time)) > 1
                plot(stat{ns}.freq,avg_over_time,'LineWidth',2);
                title([list_condition{ns} ' ' list_name]);
                xlim(stat{ns}.freq([1 end]));
                plot_indx                           = [plot_indx;nc];
            end
            
        end
        
        legend(list_unique(plot_indx,1));
        
    end 
end

figure;
i                                           = 0;

for ns = 1:length(stat)
    
    plimit                                      = 0.05;
    stat{ns}.mask                               = stat{ns}.prob < plimit;
    list_unique                                 = h_grouplabel(stat{ns},'no'); % h_parcellatelabel(stat{ns});
    
    tmp                                         = stat{ns}.mask .* stat{ns}.stat;
    
    i = i +1;
    subplot(3,1,i);
    hold on;
    
    plot_indx                                   = [];
    
    for nc = 1:length(list_unique)
        
        avg_over_freq = squeeze(nanmean(nanmean(tmp(list_unique{nc,2},:,:),1),2));
        avg_over_freq(isnan(avg_over_freq))    	= 0;
        
        if length(unique(avg_over_freq)) > 1
            plot(stat{ns}.time,avg_over_freq,'LineWidth',2);
            title([list_condition{ns}]);
            xlim(stat{ns}.time([1 end]));
            plot_indx                           = [plot_indx;nc];
        end
    end
    
    legend(list_unique(plot_indx,1));
    
end