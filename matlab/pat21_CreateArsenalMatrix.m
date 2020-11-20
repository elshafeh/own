clear ; clc ;

occ_ind = [];
roi     = {};
    
cond = {'left','right'};

for c = 1:2
    
    load ../data/yctot/stat/source5mmBaselineStat.mat
    load ../data/template/source_struct_template_MNIpos.mat
    
    clear source_avg min_p p_val;
    
    load ../data/template/template_grid_5mm ;
    
    if strcmp(cond{c},'right')
        [vox_list , vox_indx] = h_findStatMaxVoxel(stat{2,2},0.05,1,cond{c}); clc ;
        maxPos = template_grid.pos(vox_indx,:);
    else
        [vox_list , vox_indx] = h_findStatMaxVoxel(stat{2,2},0.05,6,cond{c}); clc ;
        maxPos = template_grid.pos(vox_indx(6),:);
    end
    
    m1 = maxPos ; m1(1,1) = m1(1,1) + 0.5 ;
    m2 = maxPos ; m2(1,1) = m2(1,1) - 0.5 ;
    
    m3 = maxPos ; m3(1,2) = m3(1,2) + 0.5 ;
    m4 = maxPos ; m4(1,2) = m4(1,2) - 0.5 ;
    
    m5 = m1 ; m5(1,3) = m5(1,3) + 0.5 ;
    m6 = m1 ; m6(1,3) = m6(1,3) - 0.5 ;
    
    m7 = m2 ; m7(1,3) = m7(1,3) + 0.5 ;
    m8 = m2 ; m8(1,3) = m8(1,3) - 0.5 ;
    
    m9  = m3 ; m9(1,3)  = m9(1,3) + 0.5 ;
    m10 = m3 ; m10(1,3) = m10(1,3) - 0.5 ;
    
    m11  = m4 ; m11(1,3)  = m11(1,3) + 0.5 ;
    m12  = m4 ; m12(1,3)  = m12(1,3) - 0.5 ;
    
    m13  = maxPos ; m13(1,3)  = m13(1,3) + 0.5 ;
    m14  = maxPos ; m14(1,3)  = m14(1,3) - 0.5 ;
    
    postot = [maxPos; m1;m2;m3;m4;m5;m6;m7;m8;m9;m10;m11;m12;m13;m14];
    
    clear m*
    
    whereb = [];
    
    bigb = template_grid.pos;
    
    for n = 1:size(postot,1)
        x = postot(n,1) ; y = postot(n,2) ; z = postot(n,3) ;
        whereb = [whereb;find(bigb(:,1) == x & bigb(:,2) == y & bigb(:,3) == z)];
    end
    
    whereb      = sort(whereb);
    
    source.pos = template_grid.pos;
    indx_tot    = h_createIndexfieldtrip(source);
    
    atlas       = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
    
    for n = 1:length(whereb)
        
        ix = find(indx_tot(:,1) == whereb(n));
        
        if ~isempty(ix)
            roi{end+1} = atlas.tissuelabel{indx_tot(ix,2)};
        else
            whereb(n) = 0;
        end
        
    end
    
    whereb = whereb(whereb~=0);
    
    whereb = [whereb, repmat(c,length(whereb),1)];
    
    occ_ind = [occ_ind; whereb];
    
    clearvars -except whereb occ_ind cond c roi;
    
end

clearvars -except occ_ind roi stat;

indx_tot = []; 
indx_tot = [indx_tot ; occ_ind ];

load ../data/yctot/stat/source5mmBaselineStat.mat

for r_list = 79:82
    
    [vox_list,vox_indx] = h_findStatMaxVoxelPerRegion(stat{1,2},0.05,r_list,5);
    
    indx_tot = [indx_tot ; vox_indx repmat(r_list,length(vox_indx),1)];
    
    clear vox_list vox_indx 
    
end

clearvars -except indx_tot

note = 'max in occ right and 6th max in occ left ; 5 max vox in auditory';
save('../data/yctot/index/FantasticFiveArsenalIndex.mat','indx_tot','note');

% indx_tot    = h_createIndexfieldtrip(source);
% indx_tot    = indx_tot(indx_tot(:,2) > 78 & indx_tot(:,2) < 83,:);
% indx_tot    = [indx_tot ; occ_ind];
% 
% note = 'max in occ right and 6th max in occ left ; all heschl and all stg';
% save('../data/yctot/ArsenalIndex.mat','indx_tot','note');