function huba_list = h_compare_stat_to_index(stat,index,index_label,p_threshold)

huba_list = {};

stat.mask    = stat.prob < p_threshold;
source       = stat.stat .* stat.mask;

lilist = index_label ;

for xi = 1:length(index_label)
    
    flag            = source(index(index(:,2)==xi,1));
    flag_2          = find(flag~=0);    
    lilist{xi,2}    = length(flag_2);
    
    if ~isempty(flag_2)
        lilist{xi,3}    = index(index(:,2)==xi,1);
        lilist{xi,3}    = lilist{xi,3}(flag_2);
    end
    
end

i = 0 ;

for xi = 1:length(index_label)
   
    if lilist{xi,2} ~= 0
        i = i + 1;
        huba_list{i,1} = lilist{xi,1};
        huba_list{i,2} = lilist{xi,2};
        huba_list{i,3} = lilist{xi,3};
    end
    
end

