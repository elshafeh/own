clear ; clc ; dleiftrip_addpath ;

extra_table = readtable('../xls/FrontalCoordinates.csv','Delimiter',';');
indx_tot    = h_createIndexfieldtrip;

load ../data/template/source_struct_template_MNIpos.mat

rama_list           = [extra_table.Shortcut];
% rama_where          = [];

for nextra = 1:height(extra_table)
    
    vox_x  = extra_table.X(nextra);
    vox_y  = extra_table.Y(nextra);
    vox_z  = extra_table.Z(nextra);
    
    maxPos = round([str2num(vox_x{:}) str2num(vox_x{:}) str2num(vox_x{:})]/10);
    clear vox_* ;
    whereb = [];
    
    m1  = maxPos ; m1(1,1) = m1(1,1) + 0.5 ;    m2 = maxPos ; m2(1,1) = m2(1,1) - 0.5 ;
    m3  = maxPos ; m3(1,2) = m3(1,2) + 0.5 ;m4 = maxPos ; m4(1,2) = m4(1,2) - 0.5 ;
    m5  = m1 ; m5(1,3) = m5(1,3) + 0.5 ;m6 = m1 ; m6(1,3) = m6(1,3) - 0.5 ;
    m7  = m2 ; m7(1,3) = m7(1,3) + 0.5 ;m8 = m2 ; m8(1,3) = m8(1,3) - 0.5 ;
    m9  = m3 ; m9(1,3)  = m9(1,3) + 0.5 ;m10 = m3 ; m10(1,3) = m10(1,3) - 0.5 ;
    m11 = m4 ; m11(1,3)  = m11(1,3) + 0.5 ;m12  = m4 ; m12(1,3)  = m12(1,3) - 0.5 ;
    m13 = maxPos ; m13(1,3)  = m13(1,3) + 0.5 ;m14  = maxPos ; m14(1,3)  = m14(1,3) - 0.5 ;
    
    postot = [maxPos; m1;m2;m3;m4;m5;m6;m7;m8;m9;m10;m11;m12;m13;m14];
    
    clear maxPos m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12 m13 m14
    
    bigb    = source.pos;
    
    for n = 1:size(postot,1)
        x = postot(n,1) ; y = postot(n,2) ; z = postot(n,3) ;
        if isnumeric(x) && isnumeric(y) && isnumeric(z)
            whereb = [whereb;find(bigb(:,1) == x & bigb(:,2) == y & bigb(:,3) == z)];
        end
    end
    
    whereb      = sort(whereb);
    
    for n = 1:length(whereb)
        ix = find(indx_tot(:,1) == whereb(n));
        
        if isempty(ix)
            whereb(n) = 0;
        end
    end
    
    whereb = whereb(whereb~=0);
    
    rama_list{nextra,2} = whereb ; clear whereb;
    
    %     if ~isempty(whereb)
    %         for w = 1:length(whereb)
    %             if isempty(find(rama_where==whereb(w)))
    %
    %                 if length(rama_where)>1 || isempty(find(rama_where==whereb(w)))
    %
    %
    %
    %                     rama_where              = [rama_where;whereb(w) nextra];
    %                     big_list{end+1}         = [extra_table.Shortcut{nextra}];
    %
    %
    %                 end
    %             end
    %         end
    %     end
end

clearvars -except rama_where rama_list big_list;

% atlas_label     = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
% atlas_tot       = h_createIndexfieldtrip;
% atlas_tot(:,2)  = atlas_tot(:,2)+length(rama_list);
%
% rama_list       = [rama_list;[atlas_label.tissuelabel]'];
%
% for n = 1:size(atlas_tot,1)
%
%     if isempty(find(rama_where(:,1)==atlas_tot(n,1)))
%         rama_where = [rama_where; atlas_tot(n,1) atlas_tot(n,2)];
%     end
% end
% clearvars -except rama_where rama_list;
% save('../data/yctot/index/rama_index.mat');