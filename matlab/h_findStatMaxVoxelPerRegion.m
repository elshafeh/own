function [vox_list,vox_indx] = h_findStatMaxVoxelPerRegion(stat,threshold,reg,list_size)

atlas               = ft_read_atlas('../../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
roi                 = atlas.tissuelabel;


indx_tot            = h_createIndexfieldtrip(stat.pos,'../../fieldtrip-20151124/');

indx_tot            = indx_tot(indx_tot(:,2) == reg,:);

stat.mask           = stat.prob < threshold ;

nw_stat             = stat ;

r_hem               = find(stat.pos(:,1) > 0 );
l_hem               = find(stat.pos(:,1) < 0 );

tval                = abs(stat.mask .* stat.stat);
tval                = tval(indx_tot(:,1));

vox_list = {};
vox_indx = [];

for ntimes = 1:list_size
    
    if max(tval) ~= 0
        
        t_indx = find(tval==max(tval));
        
        if ~isempty(t_indx)
            
            v_indx = indx_tot(t_indx,1);
            
            vox_list{end+1,1}   = roi{indx_tot(t_indx,2)};
            vox_indx            = [ vox_indx ; v_indx  max(tval) reg];
            
            tval(t_indx) = NaN;
            
            clear t_indx v_indx
            
        end
        
    else
        break;
    end
    
end