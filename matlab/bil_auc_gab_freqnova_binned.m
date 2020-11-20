clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    dir_data                            = 'D:/Dropbox/project_me/data/bil/decode/';
    
    frequency_list                      = {'theta' 'alpha' 'beta' 'gamma'};
    decoding_list                       = {'frequency' 'orientation'};
    
    list_bin                            = [1 2 3 4 5];
    name_bin                            = {'Bin1' 'Bin2' 'Bin3' 'Bin4' 'Bin5'};
    
    for nfreq = 1:length(frequency_list)
        for nbin = 1:length(list_bin)
            
            avg                         = [];
            avg.avg                     = [];
            
            for ndeco = 1:length(decoding_list)
                
                
                flist_1               	= dir([dir_data subjectName '.1stgab.decodinggabor.' frequency_list{nfreq} ...
                    '.band.preGab1.window.bin' num2str(list_bin(nbin)) '.' decoding_list{ndeco}  '.all.bsl.auc.mat']);
                
                flist_2               	= dir([dir_data subjectName '.2ndgab.decodinggabor.' frequency_list{nfreq} ...
                    '.band.preGab2.window.bin' num2str(list_bin(nbin)) '.' decoding_list{ndeco}  '.all.bsl.auc.mat']);
                
                flist                   = [flist_1;flist_2]; clear flist_*
                
                tmp                     = [];
                
                for nf = 1:length(flist)
                    fname               = [flist(nf).folder filesep flist(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    tmp                 = [tmp;scores];clear scores;
                end
                
                avg.avg                 = [avg.avg;mean(tmp,1)]; clear tmp;
            end
            
            avg.label               	= decoding_list;
            avg.dimord                  = 'chan_time';
            avg.time                	= time_axis;
            
            alldata{nsuj,nfreq,nbin}  	= avg; clear avg;
            
        end
        
        %         tmp                             = alldata{nsuj,nfreq,nbin};
        %         rnd_vct                         = 0.495:0.0001:0.505;
        %         for nc = 1:size(tmp.avg,1)
        %             for nt = 1:size(tmp.avg,2)
        %                 tmp.avg(nc,nt)          = rnd_vct(randi(length(rnd_vct)));
        %             end
        %         end
        %         alldata{nsuj,nfreq,nbin+1}      = tmp; clear tmp;
        %         name_bin                        = [name_bin 'chance'];
        
    end
end

keep alldata *_list name_bin

% compute anova
nbsuj                       = size(alldata,1);
[~,neighbours]              = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

for nfreq = 1:size(alldata,2)
    
    
    cfg                         = [];
    cfg.method                  = 'ft_statistics_montecarlo';
    cfg.statistic               = 'ft_statfun_depsamplesFmultivariate';
    cfg.correctm                = 'cluster';
    cfg.clusteralpha            = 0.05;
    cfg.clusterstatistic        = 'maxsum';
    cfg.clusterthreshold        = 'nonparametric_common';
    cfg.tail                 	= 1; % For a F-statistic, it only make sense to calculate the right tail
    cfg.clustertail             = cfg.tail;
    cfg.alpha                   = 0.05;
    cfg.computeprob             = 'yes';
    cfg.numrandomization        = 1000;
    cfg.neighbours              = neighbours;
    cfg.minnbchan               = 0;
    cfg.latency                 = [-0.1 1];
    
    design(1,1:nbsuj)           = 1;
    design(1,nbsuj+1:2*nbsuj)   = 2;
    design(1,nbsuj*2+1:3*nbsuj) = 3;
    design(1,nbsuj*3+1:4*nbsuj) = 4;
    design(1,nbsuj*4+1:5*nbsuj) = 5;
    design(2,:)                 = repmat(1:nbsuj,1,5);
    
    cfg.design                  = design;
    cfg.ivar                    = 1; % condition
    cfg.uvar                    = 2; % subject number
    
    allstat{nfreq}              = ft_timelockstatistics(cfg, alldata{:,nfreq,1}, alldata{:,nfreq,2}, alldata{:,nfreq,3}, alldata{:,nfreq,4}, alldata{:,nfreq,5});
end

keep alldata *_list allstat name_bin

figure;
nrow                            = 3;
ncol                            = 3;
i                               = 0;
zlimit                          = [0.4 0.8];

for nfreq = 1:length(allstat)
    
    stat                    = allstat{nfreq};
    
    for nchan = 1:length(stat.label)
        
        cfg               	= [];
        cfg.channel      	= nchan;
        cfg.time_limit     	= stat.time([1 end]);
        cfg.color          	= 'bckmr';
        cfg.z_limit        	= zlimit;
        cfg.linewidth      	= 10;
        
        i = i+1;
        subplot(nrow,ncol,i);
        h_plotSingleERFstat_selectChannel_nobox(cfg,stat,squeeze(alldata(:,nfreq,:)));
        
        ylabel(stat.label{nchan});
        
        vline([0 1.5 3 4.5 5.5],'--k');
        xticklabels({'1st Cue' '1st Gab' '2nd Cue' '2nd Gab' 'Mean RT'});
        xticks([0 1.5 3 4.5 5.5]);
        hline(0.5,'--k');
        
        title(frequency_list{nfreq});
        
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
    end
end

i = i+1;
subplot(nrow,ncol,i);
hold on
for nb = 1:5
    plot(1,1,['-' cfg.color(nb)],'LineWidth',4);
end
legend(name_bin)
set(gca,'FontSize',20,'FontName', 'Calibri','FontWeight','normal');


% figure;
% zlimit                          = [0.45 0.6];
% nrow                            = 3;
% ncol                            = 3;
% i                               = 0;
%
% for nchan = 1:length(stat.label)
%
%     chk_sig                     = stat.mask .* stat.stat;
%     chk_sig                     = chk_sig(nchan,:);
%
%     if length(unique(chk_sig)) > 1
%
%         chk_clust_mat           = stat.mask .* stat.posclusterslabelmat;
%         chk_clust_mat           = chk_clust_mat(nchan,:);
%
%         clust_nmbr              = unique(chk_clust_mat(chk_clust_mat>0));
%
%         for ncluster = 1:length(clust_nmbr)
%
%             tmp_mat             = chk_clust_mat;
%
%             tmp_mat(tmp_mat ~= clust_nmbr(ncluster)) = 0;
%             tmp_mat(tmp_mat == clust_nmbr(ncluster)) = 1;
%
%             for nsub = 1:size(alldata,1)
%                 for ncond = 1:size(alldata,2)
%                     t1              = find(round(alldata{nsub,ncond}.time,2) == round(stat.time(1),2));
%                     t2              = find(round(alldata{nsub,ncond}.time,2) == round(stat.time(end),2));
%                     tmp_data        = alldata{nsub,ncond}.avg(nchan,[t1(1):t2(end)]);
%                     tmp_data        = tmp_data .* tmp_mat;
%                     tmp_data(tmp_data == 0) = NaN;
%                     data_plot(nsub,ncond)       = nanmean(tmp_data);
%                 end
%             end
%
%             if size(alldata,2) < 5
%
%                 [h1,p1]                   	= ttest(data_plot(:,1),data_plot(:,2));
%                 [h2,p2]                    	= ttest(data_plot(:,1),data_plot(:,3));
%                 [h3,p3]                   	= ttest(data_plot(:,1),data_plot(:,4));
%                 [h4,p4]                   	= ttest(data_plot(:,2),data_plot(:,3));
%                 [h5,p5]                   	= ttest(data_plot(:,2),data_plot(:,4));
%                 [h6,p6]                   	= ttest(data_plot(:,3),data_plot(:,4));
%
%             else
%
%                 [h1,p1]                   	= ttest(data_plot(:,1),data_plot(:,2));
%                 [h2,p2]                    	= ttest(data_plot(:,1),data_plot(:,3));
%                 [h3,p3]                   	= ttest(data_plot(:,1),data_plot(:,4));
%                 [h4,p4]                   	= ttest(data_plot(:,1),data_plot(:,5));
%                 [h5,p5]                   	= ttest(data_plot(:,2),data_plot(:,3));
%                 [h6,p6]                   	= ttest(data_plot(:,2),data_plot(:,4));
%                 [h7,p7]                   	= ttest(data_plot(:,2),data_plot(:,5));
%                 [h8,p8]                   	= ttest(data_plot(:,3),data_plot(:,4));
%                 [h9,p9]                   	= ttest(data_plot(:,3),data_plot(:,5));
%                 [h10,p10]               	= ttest(data_plot(:,4),data_plot(:,5));
%
%             end
%
%
%             mean_data                       = nanmean(data_plot,1);
%             bounds                          = nanstd(data_plot, [], 1);
%             bounds_sem                      = bounds ./ sqrt(size(data_plot,1));
%
%             i = i + 1;
%             subplot(nrow,ncol,i);
%             errorbar(mean_data,bounds_sem,'-ks');
%
%             xlim([0 size(alldata,2)+1]);
%             xticks([1:size(alldata,2)]);
%
%             if size(alldata,2) < 5
%                 xticklabels({'Theta','Alpha','Beta','Gamma'});
%             else
%                 xticklabels({'Broadband' 'Theta' 'Alpha' 'Beta' 'Gamma'});
%             end
%
%             if size(alldata,2) == 5
%                 list_test                	= {'TvA' 'TvB' 'TvG' 'TvC' 'AvB' 'AvG' 'AvC' 'BvG' 'BvC' 'GvC'};
%                 p_val                    	= [p1 p2 p3 p4 p5 p6 p7 p8 p9 p10];
%                 h_val                    	= [h1 h2 h3 h4 h5 h6 h7 h8 h9 h10];
%             else
%                 list_test                 	= {'TvA' 'TvB' 'TvG' 'AvB' 'AvG' 'BvG'};
%                 p_val                    	= [p1 p2 p3 p4 p5 p6];
%                 h_val                    	= [h1 h2 h3 h4 h5 h6];
%             end
%
%             p_val                           = p_val .* h_val;
%             p_val(p_val == 0)               = NaN;
%
%             plimit                          = 0.05;
%             tit_fig                         = [];
%
%             for np = 1:length(p_val)
%                 if p_val(np) < plimit
%                     if p_val(np) == 0
%                         tit_fig                 =[tit_fig list_test{np} ' < 0.0001 '];
%                     else
%                         if np < length(p_val)
%                             tit_fig         	=[tit_fig list_test{np} ' '];
%                         else
%                             tit_fig             =[tit_fig list_test{np}];    % ' = ' num2str(round(p_val(np),3))
%                         end
%                     end
%                 end
%             end
%
%             tmp_time        = tmp_mat .* stat.time;
%             t_find        	= find(tmp_time ~= 0);
%
%             title(tit_fig);
%             hline(0.5,'--k');
%             ylim(zlimit);
%             yticks(zlimit);
%             ylabel({[stat.label{nchan} ' #' num2str(ncluster)] [' ' num2str(round(tmp_time(t_find(1)),2)) ' - ' num2str(round(tmp_time(t_find(end)),2))]})
%
%             set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
%
%             %             list_group                          = {[1 2],[1 3],[1 4],[2 3],[2 4],[3 4]};
%             %             sigstar(list_group,p_val)
%
%         end
%     end
% end
%
% keep alldata *_list allstat