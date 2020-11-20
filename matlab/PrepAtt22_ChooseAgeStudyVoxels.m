clear ; clc ; 

load ../data_fieldtrip/stat/oldVsyoun.DicSource.11t15Hz.mat

list_roi = {[49 51 53],[50 52 54],[79 81],[80 82]};

clear vox_list ;

for nroi = 1:length(list_roi)
    
    vox_list{nroi,1} = [];
    vox_list{nroi,2} = {};
    
    for sub_roi = 1:length(list_roi{nroi})
        
        v_limit             = 20;
        
        [tmp_list,tmp_indx] = h_findStatMaxVoxelPerRegion(stat,0.05,list_roi{nroi}(sub_roi),v_limit);
        
        vox_list{nroi,1}    = [vox_list{nroi,1}; tmp_indx repmat(nroi,size(tmp_indx,1),1)];
        vox_list{nroi,2}    = [vox_list{nroi,2}; tmp_list];
        
    end
    
    v_limit                 = 5;
    
    vox_list{nroi,3}        = sortrows(vox_list{nroi,1},-2);
    vox_list{nroi,4}        = vox_list{nroi,3}(1:v_limit,[1 4]);
    
end

clearvars -except stat min_p p_val vox_list; 

index_H = [vox_list{1,4};vox_list{2,4};vox_list{3,4};vox_list{4,4}];

h_seeyourvoxels(index_H(:,1),stat.pos,length(index_H))