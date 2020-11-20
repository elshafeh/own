clear ; clc ; dleiftrip_addpath ; close all ;

% for sb = 1:14
%
%     j                               = 3;
%     suj_list                        = [1:4 8:17];
%     suj                             = ['yc' num2str(suj_list(sb))];
%
%     cue_list                        = {'N','L','R',''};
%
%     for cnd = 1:length(cue_list)
%
%         load(['../data/all_data/' suj '.' cue_list{cnd} 'CnD.Rama3Cov.AllPlusAll.OnlyPLV.mat'])
%
%         allsuj_GA{sb,cnd}.powspctrm       = [];
%         allsuj_GA{sb,cnd}.time            = suj_coh{j}.time;
%         allsuj_GA{sb,cnd}.freq            = suj_coh{j}.freq;
%         allsuj_GA{sb,cnd}.dimord          = 'chan_freq_time';
%         allsuj_GA{sb,cnd}.label           = {};
%
%         aud_list    = [1 2 7];
%         chan_list   = [1 2 7];
%
%         lst_done    = {};
%         i           = 0;
%
%         for x = 1:length(aud_list)
%             for y = 1:length(chan_list)
%                 if aud_list(x) ~= chan_list(y)
%
%                     flg = [num2str(aud_list(x)) '.' num2str(chan_list(y))];
%
%                     if isempty(find(strcmp(lst_done,flg)))
%
%                         lst_done{end+1}                                 = [num2str(aud_list(x)) '.' num2str(chan_list(y))];
%                         lst_done{end+1}                                 = [num2str(chan_list(y)) '.' num2str(aud_list(x))];
%
%                         i                                               = i +1;
%
%                         allsuj_GA{sb,cnd}.powspctrm(i,:,:)              = squeeze(suj_coh{j}.powspctrm(aud_list(x),chan_list(y),:,:));
%
%                         allsuj_GA{sb,cnd}.label{end+1}                  = [suj_coh{j}.label{aud_list(x)} ' ' num2str(aud_list(x)) ' ' suj_coh{j}.label{chan_list(y)} ' ' num2str(chan_list(y))];
%
%                     end
%                 end
%             end
%         end
%
%         twin                                    = 0.1;
%         tlist                                   = -3:twin:3;
%         pow                                     = [];
%
%         if twin ~=0
%             for t = 1:length(tlist)
%                 x1  = find(round(allsuj_GA{sb,cnd}.time,3) == round(tlist(t),3)); x2 = find(round(allsuj_GA{sb,cnd}.time,3) == round(tlist(t)+twin,3));
%                 tmp = squeeze(mean(allsuj_GA{sb,cnd}.powspctrm(:,:,x1:x2),3));
%                 pow = cat(3,pow,tmp);
%                 clear tmp ;
%             end
%
%             allsuj_GA{sb,cnd}.time        =  tlist;
%             allsuj_GA{sb,cnd}.powspctrm   =  pow; clear pow;
%         end
%
%         [allsuj_activation{sb,cnd},allsuj_baselineRep{sb,cnd}]      = h_prepareBaseline(allsuj_GA{sb,cnd},[-0.6 -0.2],[7 15],[0.4 1.6],'no');
%
%         clear coh_suj
%
%     end
% end
%
% clearvars -except allsuj_* ; clc ;
%
% [design,neighbours]     = h_create_design_neighbours(length(allsuj_activation),allsuj_activation{1,3},'virt','t');
%
% cfg                     = [];
% cfg.clusterstatistic    = 'maxsum';
% cfg.method              = 'montecarlo';
% cfg.statistic           = 'depsamplesT';
% cfg.correctm            = 'cluster';
% % cfg.avgoverfreq         = 'yes';
% cfg.clusteralpha        = 0.05;
% cfg.alpha               = 0.025;
% cfg.minnbchan           = 0;
% cfg.tail                = 0;
% cfg.clustertail         = 0;
% cfg.numrandomization    = 1000;
% cfg.design              = design;
% cfg.neighbours          = neighbours;
% cfg.uvar                = 1;
% cfg.ivar                = 2;
%
% for cnd = 1:size(allsuj_activation,2)
%     stat{cnd}           = ft_freqstatistics(cfg, allsuj_activation{:,cnd}, allsuj_baselineRep{:,cnd});
%     stat{cnd}           = rmfield(stat{cnd},'cfg');
% end

load ../data/yctot/4aurelie_conn.mat

all_pval=[];

for cnd = 1:size(stat,2)
    [min_p(cnd),p_val{cnd}]   = h_pValSort(stat{cnd});
    all_pval = [all_pval p_val{cnd}(1,:)];  
end

all_pval = sort(all_pval);

plim = 0.05;

for cnd = 1:size(stat,2)
    stat2plot{cnd}            = h_plotStat(stat{cnd},0.000000000000000000000000001,plim);
end

i = 0 ; close all ;

for chn = 1:length(stat{1}.label)
    
    figure;
    cue_list                        = {'NCnD','LCnD','RCnD','CnD'};
    %     hold on;
    
    for cnd = 1:size(stat,2)
        
        subplot(2,2,cnd)
        %         if max(max(abs(stat2plot{cnd}.powspctrm(chn,:,:)))) ~=0
        
        [x,y,z] = size(stat2plot{cnd}.powspctrm);
        
        if y == 1
            plot(stat2plot{cnd}.time,squeeze(stat2plot{cnd}.powspctrm(chn,:,:)),'LineWidth',2);
            ylim([-5 5]);
            xlim([stat2plot{cnd}.time(1) stat2plot{cnd}.time(end)])
        else
            cfg             =[];
            cfg.channel     = chn;
            cfg.zlim        = [-5 5];
            ft_singleplotTFR(cfg,stat2plot{cnd});clc;
            
        end
        title([stat2plot{cnd}.label{chn} ' ' cue_list{cnd}]);
        
    end
    
    
    %     legend(cue_list);

end