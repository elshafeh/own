clear ; clc ; dleiftrip_addpath ; close all ;

load ../data/template/source_struct_template_MNIpos.mat;

template_source = source ; clear source ;
suj_list        = [1:4 8:17];
lst_cnd         = 'RLN';
cnd_time        = {'nDT.comp1','nDT.comp5'};

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for cnd = 1:length(lst_cnd)
        for ix = 1:2
            for cp = 1:3
                
                fname = dir(['../data/source/' suj '.pt' num2str(cp) '.' lst_cnd(cnd) cnd_time{ix} '.lcmvSource.mat']);
                
                if size(fname,1)==1
                    fname = fname.name;
                end
                
                fprintf('Loading %50s\n',fname);
                load(['../data/source/' fname]);
                
                if isstruct(source);
                    source = source.avg.pow;
                end
                
                src_carr{cp} = source ; clear source ;
                
            end
            
            tmp{ix} = mean([src_carr{1} src_carr{2} src_carr{3}],2); clear src_carr
            
        end
        
        source_avg{sb,cnd}.pow = (tmp{2} - tmp{1}) ./ tmp{1};
        source_avg{sb,cnd}.pos = template_source.pos ;
        source_avg{sb,cnd}.dim = template_source.dim ;
        clear tmp
    end
end

clearvars -except source_avg ;

% for sb = 1:14
%     new_source_avg{sb,1} = ft_sourcegrandaverage([],source_avg{sb,1},source_avg{sb,2});
%     new_source_avg{sb,2} = source_avg{sb,3};
% end
%
% source_avg = new_source_avg ; clearvars -except source_avg ;clc ;

for ncomp = 1:size(source_avg,2)
    gavg{ncomp} = ft_sourcegrandaverage([],source_avg{:,ncomp});
end

% for ncomp = 1:length(gavg)
%     for iside = 1
%         lst_side = {'left','right','both'}; lst_view = [-95 1;95,11;0 50];
%
%         cfg                     =   [];
%         cfg.method              =   'surface'; cfg.funparameter        =   'pow';
%
%         cfg.funcolorlim         =   [-1 1];
%         cfg.opacitylim          =   [-1 1];
%
%         cfg.opacitymap          =   'rampup';
%         cfg.colorbar            =   'off'; cfg.camlight            =   'no';
%         cfg.projthresh          =   0.2;
%         cfg.projmethod          =   'nearest';
%         cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat']; cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
%
%         ft_sourceplot(cfg, gavg{ncomp}); view(lst_view(iside,1),lst_view(iside,2))
%
%     end
% end

for ncomp = 1:length(gavg)
    source_int              = h_interpolate(gavg{ncomp});
    cfg                     = [];
    cfg.method              = 'slice';
    cfg.funparameter        = 'pow';
    cfg.nslices             = 1;
    cfg.colorbar            = 'yes';
    cfg.slicerange          = [70 84];
    cfg.funcolorlim         = [0 0.1];
    ft_sourceplot(cfg,source_int);clc;
end