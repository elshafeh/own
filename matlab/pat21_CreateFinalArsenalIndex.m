% clear ; clc ;

indx_arsenal = [];

load ../data/yctot/stat/dis_4index_sourcestat.mat

llist = 79:82;

for r_list = 1:length(llist)
    
    [~,vox_indx] = h_findStatMaxVoxelPerRegion(stat{llist},0.05,llist(r_list),10);
    indx_arsenal        = [indx_arsenal ; vox_indx repmat(r_list,length(vox_indx),1)];
    
    clear vox_list vox_indx
    
end

clearvars -except indx_arsenal ;

save ../data/yctot/index/dis.lcmv.index.mat ;

% clearvars -except indx_arsenal
% 
% % R precentral/inferior frontal gyrus (BA 44/6):
% % 52 19 33
% % R precentralgyrus/inf front oper/triang
% % 54 18 26
% % R anterior insuls, inferior frontal gyrus orb part
% % 48 26 -6
% 
% vox2find = [52 19 33
%     54 18 26
%     48 26 -6
%     ];
% 
vox2find = floor(vox2find/10);

postot = [] ;

for i = 1:size(vox2find,1)
    
    maxPos = vox2find(i,:) ;
    
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
    
    postot = [postot ; maxPos;m1;m2;m3;m4;m5;m6;m7;m8;m9;m10;m11;m12;m13;m14];
    
    clear maxPos m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12 m13 m14
    
end

clearvars -except postot indx_arsenal
% 
% load ../data/template/source_struct_template_MNIpos.mat
% 
% indx = [];
% 
% for i = 1:size(postot,1)
%     x = postot(i,1) ; y = postot(i,2) ; z = postot(i,3) ;
%     indx = [indx ; find(source.pos(:,1) == x & source.pos(:,2) == y & source.pos(:,3) == z)];
% end
% 
% tmp = [] ;
% 
% for i = 11:13
%     
%     tmp = [tmp ; repmat(i,15,1)];
%     
% end
% 
% indx = [indx tmp] ; clear tmp ;
% 
% indx_arsenal = [indx_arsenal ; indx ] ;
% 
% indx_tot = indx_arsenal ;
% 
% clearvars -except indx_tot
% 
% % R precentral/inferior frontal gyrus (BA 44/6):
% % R precentralgyrus/inf front oper/triang
% % R anterior insuls, inferior frontal gyrus orb part
% 
% arsenal_list = {'maxLO','maxRO', ...
%     'maxHL','maxHR','maxSTL','maxSTR', ...
%     'maxPreL','maxPreR','maxSupL','maxSupR', ...
%     'rpiF','rpifO','raifG'};
% 
% save('../data/yctot/index/PaperIndex.mat');
% 
% clear source_avg min_p p_val;
% 
% load ../data/template/template_grid_5mm ;
% 
% if strcmp(cond{c},'right')
%     [vox_list , vox_indx] = h_findStatMaxVoxel(stat{2,2},0.05,6,cond{c}); clc ;
%     vox_indx = vox_indx([1:2 4:6]);
%     maxPos = template_grid.pos(vox_indx(:,:));
% else
%     [vox_list , vox_indx] = h_findStatMaxVoxel(stat{2,2},0.05,5,cond{c}); clc ;
%     maxPos = template_grid.pos(vox_indx(:,:));
% end
% 
% indx_arsenal = [indx_arsenal ; vox_indx repmat(c,length(vox_indx),1)];