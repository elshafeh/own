clear; global ft_default
ft_default.spmversion = 'spm12';

for ns = 1:51
    
    subjectname                         = ['sub' num2str(ns)];
    time_list                           = {'m600m100','p0p500'};
    
    fname                               = '../data/template/template_grid_1cm.mat';
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    for nt = 1:2
        fname                           = ['../data/source/vis/' subjectname '.2t6Hz.' time_list{nt} '.dics.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        source                          = rmfield(source,'noise');
        source.pos                      = template_grid.pos;
        source.dim                      = template_grid.dim;
        source.inside                   = template_grid.inside;
        
        carr{nt}                        = source; clear source;
        
    end
    
    alldata{ns,1}                       = carr{1};
    alldata{ns,1}.pow                   = (carr{2}.pow - carr{1}.pow) ./ carr{2}.pow; clear carr;
    
    
end

keep alldata

cfg                     =   [];
cfg.method              =   'surface';
cfg.funparameter        =   'pow';
cfg.funcolorlim         =   [-1 1];
cfg.opacitylim          =   [-1 1];
cfg.opacitymap          =   'rampup';
cfg.colorbar            =   'off';
cfg.camlight            =   'no';
cfg.projmethod          =   'nearest';
cfg.surffile            =   'surface_white_both.mat';
cfg.surfinflated        =   'surface_inflated_both_caret.mat';
cfg.projthresh          = 0.5;
ft_sourceplot(cfg, ft_sourcegrandaverage([],alldata{:}));