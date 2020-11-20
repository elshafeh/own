clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list    = [1:4 8:17];

cnd_freq    = {'60t100Hz'}; % {'60t100Hz'};

cnd_time    = {'m600m200','p600p1000'}; %

ext_end     = '.wConcatPCCSource.hanning.0.5cm'; 

for nfreq = 1:length(cnd_freq)
    
    for sb = 1:length(suj_list)
        
        suj = ['yc' num2str(suj_list(sb))];
        
        for ntime = 1:length(cnd_time)
            
            for cp = 1:3
                
                fname = ['../data/prep21_gamma_dics_data/' suj '.pt' num2str(cp) '.CnD.' cnd_freq{nfreq} '.' cnd_time{ntime}     ...
                    ext_end '.mat'];
                
                fprintf('Loading %50s\n',fname);
                
                load(fname);
                
                if isstruct(source);
                    source = source.avg.pow;
                end
                
                if size(source,2) > 1
                    source = mean(source,2);
                end
                
                src_carr{cp} = source ; clear source ;
                
            end
            
            load ../data/template/template_grid_0.5cm.mat
            
            source_avg{sb,ntime,nfreq}.pow        = nanmean([src_carr{1} src_carr{2} src_carr{3}],2); clear src_carr ;
            source_avg{sb,ntime,nfreq}.pos        = template_grid.pos;
            source_avg{sb,ntime,nfreq}.dim        = template_grid.dim;
            
            clear src_carr
            
        end
        
        source_corr{sb,1}                           = source_avg{sb,ntime,nfreq};
        
        %         pow                                         = (source_avg{sb,2,nfreq}.pow - source_avg{sb,1,nfreq}.pow)./ source_avg{sb,1,nfreq}.pow;
        
        pow                                         = (source_avg{sb,2,nfreq}.pow - source_avg{sb,1,nfreq}.pow);
        pow(pow==0)                                 = NaN;
        source_corr{sb,1}.pow                       = pow;
        
        
    end
end

clearvars -except source_corr cnd_freq cnd_time; clc ;

grand_avg_corrct            = ft_sourcegrandaverage([],source_corr{:,1});

% grand_avg_bsl           = ft_sourcegrandaverage([],source_avg{:,1,1});
% grand_avg_act           = ft_sourcegrandaverage([],source_avg{:,2,1});
% grand_avg_corrct.pow    = (grand_avg_act.pow-grand_avg_bsl.pow)./grand_avg_bsl.pow;
% grand_avg_corrct.pos    = grand_avg_bsl.pos;
% grand_avg_corrct.dim    = grand_avg_bsl.dim;

grand_avg_corrct.pow(grand_avg_corrct.pow==0) = NaN;

% cfg = [];
% cfg.method         = 'surface';
% cfg.funparameter   = 'pow';
% cfg.funcolorlim    = [0.0 1.2];
% cfg.funcolormap    = 'jet';
% cfg.opacitylim     = [0.0 1.2]; 
% cfg.opacitymap     = 'rampup';  
% cfg.projmethod     = 'nearest'; 
% cfg.surffile       = 'surface_white_both.mat';
% cfg.surfdownsample = 10; 

% mni_mri                         = ft_read_mri('../fieldtrip-20151124/template/anatomy/single_subj_T1.nii');
%
% cfg                             = [];
% cfg.parameter                   = 'pow';
% sourceDiffInt                   = ft_sourceinterpolate(cfg, grand_avg_corrct , mni_mri);

% cfg                             = [];
% cfg.nonlinear                   = 'no';
% sourceDiffIntNorm               = ft_volumenormalise(cfg, sourceDiffInt);

for iside = [1 2]
    
    lst_side                        = {'left','right','both'};
    
    lst_view                        = [-95 1;95 1;0 50];
    
    cfg                             =   [];
    cfg.method                      =   'surface';
    cfg.funparameter                =   'pow';
    cfg.maskparameter               =   cfg.funparameter;
    cfg.funcolorlim                 =   [0 0.7e+19];
    % cfg.opacitylim                  =   [-0.1 0.1];
    cfg.opacitymap                  =   'rampup';
    cfg.colorbar                    =   'off';
    cfg.camlight                    =   'no';
    cfg.projmethod                  =   'nearest';
    
    cfg.surffile                    =   ['surface_pial_' lst_side{iside} '.mat'];
    cfg.surfinflated                =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
    
    
    ft_sourceplot(cfg, grand_avg_corrct);
    view(lst_view(iside,:))
    
end