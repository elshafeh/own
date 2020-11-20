clear ; clc ; dleiftrip_addpath ; close all ;

load('../data/yctot/stat/sourceBasline_gavg.mat','stat')

for ifreq = 1:2
    for itime = 1:3
        [min_p(ifreq,itime),p_val{ifreq,itime}]     =   h_pValSort(stat{ifreq,itime});
    end
end

cnd_time = {'early','late','post'};
cnd_freq = {'low','high'};

for itime = 1:3
    for ifreq = 2
        
        clear source
        
        source.pos                  = stat{ifreq,itime}.pos ;
        source.dim                  = stat{ifreq,itime}.dim ;
        source.pow                  = stat{ifreq,itime}.stat .* stat{ifreq,itime}.mask;
        
        source_int                  = h_interpolate(source);
        source_int.coordsys         = 'mni';
        
        cfg                         =   [];
        cfg.method                  =   'slice';
        cfg.funparameter            =   'pow';
        cfg.atlas                   =   '../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii';
        cfg.nslices                 =   1 ;
        cfg.slicerange              =   [70 70];       % [83 84];% [70 70] %[70 84];
        cfg.funcolorlim             =   [-3.5 3.5];
        cfg.colorbar                = 'no';
        ft_sourceplot(cfg,source_int);clc;
        saveFigure(gcf,['/Users/heshamelshafei/Google Drive/MyDrive/PhD/Publications/Papers/alpha2017/Figures/source.' cnd_time{itime} '.' cnd_freq{ifreq} '.png']);close all;
        
    end
end