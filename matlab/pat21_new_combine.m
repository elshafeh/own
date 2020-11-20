clear ; clc ; dleiftrip_addpath ;

arsenal_list = {};

load ../data/yctot/index/CnD.ExtraRois.4Gamma.mat ; % 232

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

load ../data/yctot/index/CnD.AtlasRois.4Gamma.mat % 294

for  n = 1:length(roi_vox)
    
    if isempty(find([arsenal_list{:,2}] == roi_vox(n)))
        
        i = i + 1;
        arsenal_list{i,1}  = roi_list{n};
        arsenal_list{i,2}  = roi_vox(n);
        
    end
    
    x                   = arsenal_list{i,1};
    
    if iscell(x)
        x                   = x{:};
        arsenal_list{i,1}   = x;
    end
    
    x                       = strsplit(x,'_');
    arsenal_list{i,3}       = x{1};
    
    clear x
end

clearvars -except arsenal_*

unique_list = unique(arsenal_list(:,3));

for n = 1:length(arsenal_list)
    
    ix = find(strcmp(arsenal_list{n,3},unique_list));
    arsenal_list{n,4} = ix;
    
end

clearvars -except arsenal_* unique_list ;

save ../data/yctot/index/CnD.CombinedRois.4Gamma.mat ;