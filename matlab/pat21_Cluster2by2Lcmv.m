clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))];
    lst_time    = {'bsl','N1'};
    lst_cue     = 'VN';
    lst_subCond     = 'nDT';
    
    for ccue = 1:length(lst_cue)
        
        source_carr = [];
        
        for p = 1:3
            
            for ctime = 1:2
                %                 for cdis = 1:2
                fname_in = [suj '.pt' num2str(p) '.' lst_cue(ccue) lst_subCond '.extended.' lst_time{ctime} '.lcmvSource'];
                fprintf('\nLoading %50s',fname_in);
                load(['../data/source/' fname_in '.mat'])
                tmp{ctime} = source ; clear source ;
                %                 tmp{ctime,cdis} = source ; clear source ;
                %                 end
            end
            
            %             pow = tmp{2,1} - tmp{2,2} - tmp{1,1}; % remove fake then bsl
            %             pow = (tmp{2,1} - tmp{2,2}) ./  tmp{2,2}; % rel to fake
            %             pow = (tmp{2,1}-tmp{1,1})./(tmp{1,1}); % rel to own bsl fake
            %             pow = tmp{2,1} ;
            %             pow = tmp{2,1} - tmp{2,2};
            
            %             rldis = (tmp{2,1} - tmp{1,1}) ./  tmp{1,1};
            %             fdis  = (tmp{2,2} - tmp{1,2}) ./  tmp{1,2};
            
            pow   = (tmp{2} - tmp{1}) ./ (tmp{1});
            
            source_carr = [source_carr pow]; clear tmp pow rldis fdis ;
            
        end
        
        load ../data/template/source_struct_template_MNIpos.mat

        source_avg{sb,ccue}.pow     = nanmean(source_carr,2) ; clear source_carr ;
        source_avg{sb,ccue}.pos     = source.pos ;
        source_avg{sb,ccue}.dim     = source.dim ; clear source ;
        
    end
end

clearvars -except source_avg

cfg           = h_prepare_cluster_source(0.001,source_avg{1,1});
stat{1}       = ft_sourcestatistics(cfg, source_avg{:,1},source_avg{:,2});
% stat{2}       = ft_sourcestatistics(cfg, source_avg{:,1},source_avg{:,3});
% stat{3}       = ft_sourcestatistics(cfg, source_avg{:,2},source_avg{:,3});

for cs = 1:length(stat)
    [min_p(cs),p_val{cs}]       = h_pValSort(stat{cs});
    list{cs}                    = FindSigClusters(stat{cs},0.1);
end

for cs = 1:length(stat)
    stat_int                    = h_interpolate(stat{cs});
    stat_int.mask               = stat_int.prob < 0.05;
    stat_int.stat               = stat_int.stat .* stat_int.mask;
    cfg                         = [];
    cfg.method                  = 'slice';
    cfg.funparameter            = 'stat';
    cfg.maskparameter           = 'mask';
    cfg.nslices                 = 16;
    % cfg.slicerange              = [70 84];
    cfg.funcolorlim             = [-5 5];
    ft_sourceplot(cfg,stat_int);clc;
end

% for sb = 1:length(suj_list)
%     
%     suj         = ['yc' num2str(suj_list(sb))];
%     ext_comp    = 'nDT.extended';
%     lst_time    = {'bsl','N1'};
%     lst_cue     = 'VN';
%     
%     for cnd_cue = 1:2
%         
%         source_carr = [];
%         
%         for prt = 1:3
%             
%             for cnd_time = 1:2
%                 fname = dir(['../data/source/' suj '.pt' num2str(prt) '*' lst_cue(cnd_cue) ext_comp '*.' lst_time{cnd_time} '.*']);
%                 fname = fname.name;
%                 fprintf('\nLoading %50s',fname);
%                 load(['../data/source/' fname]);
%                 tmp{cnd_time} = source ; clear source
%             end
%             
%             pow = (tmp{2}-tmp{1}) ./ tmp{1} ; clear tmp ;
%             
%             %             pow = tmp{2}-tmp{1}; clear tmp ;
%             
%             source_carr = [source_carr pow]; clear pow ;
%             
%             clear tmp ;
%             
%         end
%         
%         load ../data/template/source_struct_template_MNIpos.mat
%         
%         source_avg{sb,cnd_cue}.pow            = nanmean(source_carr,2); clear source_carr ;
%         source_avg{sb,cnd_cue}.pos            = source.pos ;
%         source_avg{sb,cnd_cue}.dim            = source.dim ;
%         
%         clear source
%         
%     end
%     
% end
% 
% 


% plot

% for cnd = 1:4
%     gavg{cnd} = ft_sourcegrandaverage([],source_avg{:,cnd});
%     gavg_int{cnd}               = h_interpolate(gavg{cnd});
%     cfg                         = [];
%     cfg.method                  = 'slice';
%     cfg.funparameter            = 'pow';
%     cfg.nslices                 = 16;
%     cfg.slicerange              = [70 84];
%     cfg.funcolorlim             = [-0.2 0.2];
%     ft_sourceplot(cfg,gavg_int{cnd});clc;
% end
%
% cnd_stat = [1 2; 1 3; 2 3; 4 3];
%
% for cs = 1:4
%     cfg=[];
%     cfg.parameter = 'pow';
%     cfg.operation = 'x1-x2';
%     gavg_diff = ft_math(cfg,gavg{cnd_stat(cs,1)},gavg{cnd_stat(cs,2)});
%     gavg_diff_int           = h_interpolate(gavg_diff);
%     cfg                         = [];
%     cfg.method                  = 'slice';
%     cfg.funparameter            = 'pow';
%     cfg.nslices                 = 16;
%     cfg.slicerange              = [70 84];
%     cfg.funcolorlim             = [-0.1 0.1];
%     ft_sourceplot(cfg,gavg_diff_int);clc;
% end