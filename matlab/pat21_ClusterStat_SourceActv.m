clear ; clc ; close all ;

dleiftrip_addpath;

suj_list = [1:4 8:17];

load ../data/yc1/headfield/yc1.VolGrid.1cm.mat

ext_freq = {'9t13Hz'};
cnd_time = {{'m550m200','p400p750'}}; % p400p750 p250p600 p300p650

idx = 1;

clc;

for a = 1:length(suj_list)
    
    ext_cnd  = {'RCnD','LCnD'};
    
    for b = 1:2
        
        suj = ['yc' num2str(suj_list(a))];
        
        for c = 1:3
            
            for d = 1:2
                
                ext_comp = 'lrn';
                
                fname = [suj '.pt' num2str(c) '.' ext_cnd{b} '.all.mtmfft.' ext_freq{idx}  '.' cnd_time{idx}{d} '.' ext_comp '.source.mat'];
                fprintf('\nLoading %50s\n',fname);
                load(['../data/' suj '/source/' fname]);
                source_carr{d} = source ;
                
            end
            
            cfg             = [];
            cfg.parameter   = 'avg.pow';
            cfg.operation   = '((x1-x2)./x2)*100';
            tmp1  = ft_math(cfg,source_carr{2},source_carr{1});
            
            clear source_carr
            
            for d = 1:2
                
                ext_comp = 'lrn';
                
                fname = [suj '.pt' num2str(c) '.NCnD.all.mtmfft.' ext_freq{idx}  '.' cnd_time{idx}{d} '.' ext_comp '.source.mat'];
                fprintf('\nLoading %50s\n',fname);
                load(['../data/' suj '/source/' fname]);
                source_carr{d} = source ;
                
            end
            
            cfg             = [];
            cfg.parameter   = 'avg.pow';
            cfg.operation   = '((x1-x2)./x2)*100';
            tmp2            = ft_math(cfg,source_carr{2},source_carr{1});
            
            clear source_carr
            
            clear source ;
            
            cfg             = [];
            cfg.parameter   = 'avg.pow';
            cfg.operation   = 'subtract';
            source_diff{c}  = ft_math(cfg,tmp1,tmp2);
            
            clear source_carr
            
        end
        
        source_avg{a,b}     = ft_sourcegrandaverage([],source_diff{:});
        source_avg{a,b}.pos = grid.MNI_pos;
        
        clear source_diff
        
    end
    
end

% Run Statistics %

clearvars -except source_avg;clc;

cfg                     =   [];
cfg.inputcoord          =   'mni';
cfg.dim                 =   source_avg{1,1}.dim;
cfg.method              =   'montecarlo';
cfg.statistic           =   'depsamplesT';
cfg.parameter           =   'pow';
cfg.correctm            =   'cluster';
cfg.clusteralpha        =   0.05;             % First Threshold
cfg.clusterstatistic    =   'maxsum';
cfg.numrandomization    =   1000;
cfg.alpha               =   0.05;
cfg.tail                =   0;
cfg.clustertail         =   0;
cfg.design(1,:)         =   [1:14 1:14];
cfg.design(2,:)         =   [ones(1,14) ones(1,14)*2];
cfg.uvar                =   1;
cfg.ivar                =   2;

stat = ft_sourcestatistics(cfg,source_avg{:,1},source_avg{:,2}) ;

clearvars -except stat source_avg stat_int

p_val_sort;clc;

stat.mask = stat.prob < p_val(1) + 0.001; %   

mri  = ft_read_mri('../fieldtrip-20151124/template/anatomy/single_subj_T1_1mm.nii');

cfg                 = [];
cfg.parameter       = {'stat','mask'};
cfg.interpmethod    = 'nearest';
stat_int            = ft_sourceinterpolate(cfg, stat , mri);

st_rng  = 70 ;
en_rng = 84 ;

atlas                   = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
stat_int.coordsys       = 'mni';
cfg                     = [];
cfg.method              = 'slice';
cfg.funparameter        = 'stat';
cfg.maskparameter   = 'mask';
% cfg.nslices         = 16;
% cfg.slicerange      = [st_rng en_rng];
cfg.atlas           = atlas ; 
cfg.location = 'min';
ft_sourceplot(cfg,stat_int);

% saveFigure(gcf,['../plots/lr_stat_' ext_freq{idx} '_' cnd_time{idx}{2} '_min_p_' num2str(min_p_val) '.png']);

% for c = 1:2
% 
%     source = ft_sourcegrandaverage([],source_avg{:,c});
% 
%     cfg              = [];
%     cfg.parameter    = 'pow';
%     cfg.interpmethod = 'nearest';
%     source_int  = ft_sourceinterpolate(cfg, source, mri);
% 
%     st_rng  = 70 ;
%     en_rng = 90 ;
% 
%     cfg                 = [];
%     cfg.method          = 'slice';
%     cfg.funparameter    = 'pow';
%     cfg.nslices         = 16;
%     cfg.slicerange      = [st_rng en_rng];
%     cfg.colorlim        = [-20 20];
%     figure
%     ft_sourceplot(cfg,source_int);
% end