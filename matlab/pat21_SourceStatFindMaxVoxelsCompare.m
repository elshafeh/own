clear ; clc ; close all ; dleiftrip_addpath;

load ../data/yc1/source/yc1.pt1.CnD.all.mtmfft.11t15Hz.p600p1000.bsl.source.mat
load ../data/yc1/headfield/yc1.VolGrid.1cm.mat

source.pos = grid.MNI_pos ;

source_old = source;
source_new = source ;

for n = 1:length(source_new.avg.pow)
    %     if source.inside(n) ~= 0
    source_new.avg.pow(n) = n;
    %     end
end

atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
mri                 = ft_read_mri('../fieldtrip-20151124/template/anatomy/single_subj_T1_1mm.nii');

cfg                 = [];
cfg.interpmethod    = 'nearest';
cfg.parameter       = 'tissue';
atlasOnmri          = ft_sourceinterpolate(cfg, atlas, mri);
cfg.parameter       = 'pow';
sourceOnmri         = ft_sourceinterpolate(cfg, source_new, mri);

roi = atlas.tissuelabel;

indx_tot                =   [];

for d = 1:length(roi)
    
    ind_atlas               =   find(atlasOnmri.tissue==d);
    ind_source              =   sourceOnmri.pow(ind_atlas);
    ind_source              =   unique(ind_source);
    indx_tot                =   [indx_tot ; ind_source repmat(d,size(ind_source,1),1)];
    
    clear ind_atlas ind_source
    
end

clearvars -except indx_tot source source_old source_new mri

indx_slct = indx_tot(indx_tot(:,2) > 78 & indx_tot(:,2) < 83,:);

chkn = [];

for n = 1:length(source.avg.pow)
    
    if source.inside(n) ~= 0
        
        ix = find(indx_slct(:,1)==n);
        
        if isempty(ix)
            source.avg.pow(n) = 0;
        else
            
            if length(ix) <2
                source.avg.pow(n) = 100 * (mean(indx_slct(ix,2))-78);
            else
                chkn = [chkn;indx_slct(ix,2) repmat(n,length(ix),1)];
                source.avg.pow(n) = 100 * (mean(indx_slct(ix,2))-78);
            end
            
        end
    end
end

old_indx= load('../data/yctot/Roi4FinalVirtual.mat');
old_indx = old_indx.indx_tot;

old_indx = old_indx(old_indx(:,2)>2,:);

for n = 1:length(source_old.avg.pow)
    
    if source_old.inside(n) ~= 0
        
        ix = find(old_indx(:,1)==n);
        
        if isempty(ix)
            source_old.avg.pow(n) = 0;
        else
            
            if length(ix) <2
                source_old.avg.pow(n) = 100 * (mean(old_indx(ix,2))-2);
            else
                chkn = [chkn;old_indx(ix,2) repmat(n,length(ix),1)];
                source_old.avg.pow(n) = 100 * (mean(old_indx(ix,2))-2);
            end
            
        end
    end
end

clearvars -except source mri source_old indx_tot old_indx

cfg                 = [];
cfg.interpmethod    = 'nearest';
cfg.parameter       = 'pow';
indx_verify         = ft_sourceinterpolate(cfg, source, mri);
indx_verify_old         = ft_sourceinterpolate(cfg, source_old, mri);

cfg                         = [];
cfg.method                  = 'slice';
cfg.funparameter            = 'pow';
cfg.nslices                 = 16;
cfg.slicerange              = [70 84];
% cfg.funcolorlim         = [-6 0];
ft_sourceplot(cfg,indx_verify);clc;
ft_sourceplot(cfg,indx_verify_old);clc;

clearvars -except indx_tot old_indx