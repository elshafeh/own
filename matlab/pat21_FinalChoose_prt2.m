clear ; clc ; dleiftrip_addpath ;

arsenal_list = {};

load ../data/yctot/index/CnD.Lit4Gamma.mat ;

i = 0 ;

for  n = 1:length(big_where)   
    if n == 1
        i = i +1;
        arsenal_list{n,1}   = big_list{n};
        arsenal_list{n,2}   = big_where(n);
        
    else
        if isempty(find([arsenal_list{:,2}] == big_where(n)))
            i = i + 1;
            arsenal_list{i,1}  = big_list{n};
            arsenal_list{i,2}  = big_where(n);
        end
    end
    
    x                   = arsenal_list{i,1};
    
    if iscell(x)
        x                   = x{:};
        arsenal_list{i,1}     = x;
    end
    
    x                       = strsplit(x,'_');
    arsenal_list{i,3}       = x{1};
    
    clear x
    
end

clearvars -except arsenal_list i;

atlas           = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
reg_indx        = [1:20 23:26 31:36 43:54 57:70 79:90];
reg_list        = atlas.tissuelabel(reg_indx);
indxH           = h_createIndexfieldtrip;

for n = 1:length(reg_indx)
    
    prt = indxH(indxH(:,2) == reg_indx(n),1);
    
    for w = 1:length(prt)
        
        if isempty(find([arsenal_list{:,2}] == prt(w)))
            
            i = i + 1;
            
            arsenal_list{i,1} = [reg_list{n} num2str(w)];
            arsenal_list{i,2} = prt(w);
            arsenal_list{i,3} = reg_list{n};

        end
    end
    
end

clearvars -except arsenal_list;

save ../data/yctot/index/CnD.LitplusAtlas4Gamma.mat ;