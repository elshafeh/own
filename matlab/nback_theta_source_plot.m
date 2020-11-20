clear ; global ft_default
ft_default.spmversion   = 'spm12';

suj_list                                                            = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                                                     = ['sub' num2str(suj_list(nsuj))];
    
    list_time{1}                                                	= {'p0p1000'};
    list_time{2}                                                	= {'p0p1000','p2000p3000'};
    list_time{3}                                                	= {'p0p1000','p2000p3000','p4000p5000'};
    
    
    load('../data/stock/template_grid_0.5cm.mat');
    
    for nback = [1 2 3]
        for ntime = 1:length(list_time{nback})
            
            fname                                                   = ['I:/nback/source/' subjectname '.' num2str(nback-1) 'back.rearranged.nonfill.2t6Hz.m1200m200.dics.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            bsl                                                     = source.pow; clear source;
            
            fname                                                   = ['I:/nback/source/' subjectname '.' num2str(nback-1) 'back.rearranged.nonfill.2t6Hz.' list_time{nback}{ntime} '.dics.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            act                                                     = source.pow; clear source;
            
            source                                                  = [];
            source.pos                                              = template_grid.pos;
            source.dim                                              = template_grid.dim;
            source.pow                                              = (act - bsl) ./ bsl; clear act bsl;
            alldata{nback}{nsuj,ntime}                              = source ; clear source;
            
        end
    end
end

keep alldata list_time

close all;

for nback = [1 2 3]
    for ntime = 1:length(list_time{nback})
        
        list_proj                               = [0.5 0.5 0.4];
        
        cfg                                     = [];
        cfg.method                              = 'surface';
        cfg.funparameter                        = 'pow';
        cfg.maskparameter                       = cfg.funparameter;
        cfg.funcolorlim                         = [0 1];
        cfg.funcolormap                         = brewermap(256,'Reds');
        cfg.projmethod                          = 'nearest';
        cfg.camlight                            = 'no';
        cfg.surfinflated                        = 'surface_inflated_both_caret.mat';
        cfg.projthresh                          = list_proj(nback);
        
        ft_sourceplot(cfg, ft_sourcegrandaverage([],alldata{nback}{:,ntime}));
        view ([0 0 90]);
        %         light ('Position',[0 0 90]);
        material dull
        
        title([num2str(nback-1) 'Back ' list_time{nback}{ntime}]);
        
    end
end