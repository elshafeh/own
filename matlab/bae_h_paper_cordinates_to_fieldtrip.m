function [mni_pos,mni_list] = h_paper_cordinates_to_fieldtrip(source,csv_list,search_width)

extra_table = readtable(csv_list,'Delimiter',';');

mni_pos       = [];
mni_list      = {};

indx_tot      = h_createIndexfieldtrip(source.pos,'../../fieldtrip-20151124/');

tata          = 0 ;

for nextra = 1:height(extra_table)
    
    vox_x  = str2double(extra_table.X{nextra});
    vox_y  = str2double(extra_table.Y{nextra});
    vox_z  = str2double(extra_table.Z{nextra});
    
    maxPos = round([vox_x vox_y vox_z]/10); clear vox_* ;
    whereb = [];
    
    m1  = maxPos ;
    m1(1,1) = m1(1,1) + search_width;
    m2 = maxPos ;
    m2(1,1) = m2(1,1) - search_width;
    m3  = maxPos ;
    m3(1,2) = m3(1,2) + search_width;
    m4 = maxPos ;
    m4(1,2) = m4(1,2) - search_width;
    m5  = m1 ;
    m5(1,3) = m5(1,3) + search_width;
    m6 = m1 ;
    m6(1,3) = m6(1,3) - search_width;
    m7  = m2 ;
    m7(1,3) = m7(1,3) + search_width;
    m8 = m2 ;
    m8(1,3) = m8(1,3) - search_width;
    m9  = m3 ;
    m9(1,3)  = m9(1,3) + search_width;
    m10 = m3 ;
    m10(1,3) = m10(1,3) - search_width;
    m11 = m4 ;
    m11(1,3)  = m11(1,3) + search_width;
    m12  = m4 ;
    m12(1,3)  = m12(1,3) - search_width;
    m13 = maxPos ;
    m13(1,3)  = m13(1,3) + search_width;
    m14  = maxPos ;
    m14(1,3)  = m14(1,3) - search_width;
    
    postot = [maxPos; m1;m2;m3;m4;m5;m6;m7;m8;m9;m10;m11;m12;m13;m14];
    
    clear maxPos m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12 m13 m14
    
    
    bigb    = source.pos;
    
    for n = 1:size(postot,1)
        x = postot(n,1) ; y = postot(n,2) ; z = postot(n,3) ;
        if isnumeric(x) && isnumeric(y) && isnumeric(z)
            whereb = [whereb;find(bigb(:,1) == x & bigb(:,2) == y & bigb(:,3) == z)];
        end
    end
    
    %     whereb      = sort(whereb);
    
    for n = 1:length(whereb)
        ix = find(indx_tot(:,1) == whereb(n));
        
        if isempty(ix)
            whereb(n) = 0;
        end
    end
    
    whereb = whereb(whereb~=0);
    
    if ~isempty(whereb)
        
        %         tata = 0 ;
        %
        %         for w = 1:length(whereb)
        %             if isempty(find(mni_pos==whereb(w)))
        %
        %                 if length(mni_pos)>1 || isempty(find(mni_pos==whereb(w)))
        %                     mni_pos          = [mni_pos;whereb(w) nextra];
        %
        %                     tata = tata + 1;
        %
        %                 end
        %             end
        %         end
        %
        %         if tata > 0
        
        tata               = tata +1;
        
        mni_list{tata,1}   = [extra_table.Shortcut{nextra}];
        mni_pos            = [mni_pos;whereb repmat(tata,length(whereb),1)];
        
        %         end
        
    end
end

clearvars -except mni_* source csv_list