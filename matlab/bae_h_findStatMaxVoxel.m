function [vox_list,vox_indx] = h_findStatMaxVoxel(stat,threshold,list_size,hemi)

% input : stat struct , p value , number of maximum ,

atlas               = ft_read_atlas('../../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
roi                 = atlas.tissuelabel;

indx_tot    = h_createIndexfieldtrip(stat.pos,'../../fieldtrip-20151124/');

stat.mask   = stat.prob < threshold ;

nw_stat = stat ;

r_hem = find(stat.pos(:,1) > 0 );
l_hem = find(stat.pos(:,1) < 0 );

if strcmp(hemi,'R')
    stat.stat(l_hem,:) = 0;
elseif  strcmp(hemi,'L')
    stat.stat(r_hem,:) = 0;
end

tval        = abs(stat.mask .* stat.stat);

vox_list = {};
vox_indx = [];

while size(vox_list) < list_size
    
    t_indx = find(tval==max(tval));
    v_indx = find(indx_tot(:,1) == t_indx);
    
    if ~isempty(v_indx) && length(t_indx)<2
        vox_list{end+1,1} = roi{indx_tot(v_indx,2)};
        vox_indx = [ vox_indx ; t_indx max(tval)];
    end
    
    tval(t_indx) = NaN;
    clear t_indx v_indx
    
end

end