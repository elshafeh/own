function reg_list = FindSigClustersWithIndex(stat,p_threshold,ix_index,ix_list)

stat.mask               = stat.prob < p_threshold;
source                  = [];
source.pos              = stat.pos ;
source.dim              = stat.dim ;
source.pow              = stat.stat .* stat.mask;

reg_list                = ix_list;

duplicate_voxls_check   = [];

for ni = 1:length(ix_list)
    
    reg_list{ni,2} = 0 ;
    reg_list{ni,3} = [];
    reg_list{ni,4} = [];
    
    flg = ix_index(ix_index(:,2)==ni,1);
    
    if ~isempty(flg)
        
        for nx = 1:length(flg)
            
            if source.pow(flg(nx)) ~= 0 && isempty(duplicate_voxls_check(duplicate_voxls_check==flg(nx)))
                
                reg_list{ni,2}          = reg_list{ni,2} + 1;
                reg_list{ni,3}          = [reg_list{ni,3};flg(nx) source.pow(flg(nx))];
                
                duplicate_voxls_check   = [duplicate_voxls_check;flg(nx)];
                
            end
            
        end
        
        reg_list{ni,4} = reg_list{ni,3};
        
        if size(reg_list{ni,3}) > 1
            reg_list{ni,4} = sortrows(reg_list{ni,4},2);
        end
        
    end
end