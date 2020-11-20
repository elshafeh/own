clear ; clc ; close all ; dleiftrip_addpath;

% suj_list = [1:4 8:17];
% load ../data/template/source_struct_template_MNIpos.mat
% indx = h_createIndexfieldtrip(source);
% 
% for sb = 1:length(suj_list)
%     
%     suj         = ['yc' num2str(suj_list(sb))];
%     ext_comp    = '';
%     lst_time    = {'bsl','N1'};
%     lst_dis     = {'','f'};
%     
%     for cnd = 1:2
%         for cdis = 1:2
%             
%             source_carr = [];
%             
%             for prt = 1:3
%                 fname = dir(['../data/source/' suj '.pt' num2str(prt) '.' lst_dis{cdis} 'DIS.*' lst_time{cnd} '*']);
%                 fname = fname.name;
%                 fprintf('\nLoading %50s',fname);
%                 load(['../data/source/' fname]);
%                 source_carr = [source_carr source] ; clear source
%             end
%             
%             source_avg{sb,cnd,cdis}.pow = nanmean(source_carr,2); clear source_carr;
%             load ../data/template/source_struct_template_MNIpos.mat
%             source_avg{sb,cnd,cdis}.pos            = source.pos ;
%             source_avg{sb,cnd,cdis}.dim            = source.dim ;
%             clear source;
%             source_avg{sb,cnd,cdis}.pow(indx(indx(:,2) > 90,1)) = 0 ;
%         end
%     end
%     
% end
% 
% clearvars -except source_avg ; 
% 
% for sb = 1:14
%     for cnd = 1:2
% 
%         tmp{sb,cnd}     = source_avg{sb,cnd,1} ;
%         tmp{sb,cnd}.pow = source_avg{sb,cnd,1}.pow - source_avg{sb,cnd,2}.pow;
%         
%     end
% end
% 
% source_avg = tmp ; clearvars -except source_avg;
% 
% cfg                 = h_prepare_cluster_source(0.0015,source_avg{1,1});
% stat                = ft_sourcestatistics(cfg, source_avg{:,2},source_avg{:,1});
% stat                = rmfield(stat ,'cfg');

load ../data/yctot/stat/new.dis.lcmv.stat.mat

[min_p,p_val]       = h_pValSort(stat);
list                = FindSigClusters(stat,0.05);

stat_int           = h_interpolate(stat);
stat_int.mask      = stat_int.prob < 0.05;
stat_int.stat      = stat_int.stat .* stat_int.mask;

cfg                         = [];
cfg.method                  = 'slice';
cfg.funparameter            = 'stat';
cfg.maskparameter           = 'mask';
cfg.nslices                 = 16;
cfg.slicerange              = [70 84];
cfg.funcolorlim             = [-5 5];
ft_sourceplot(cfg,stat_int);clc;