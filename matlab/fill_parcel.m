function new_index = fill_parcel(indxH,source)

find_pos                = source.pos(indxH,:);
min_x                   = min(find_pos(:,1));
max_x                   = max(find_pos(:,1));

min_y                   = min(find_pos(:,2));
max_y                   = max(find_pos(:,2));

min_z                   = min(find_pos(:,3));
max_z                   = max(find_pos(:,3));

all_pos                 = [source.pos source.inside];

find_pos                = find(all_pos(:,1) >= min_x & all_pos(:,1) <= max_x & ...
    all_pos(:,2) >= min_y & all_pos(:,2) <= max_y & ...
    all_pos(:,3) >= min_z & all_pos(:,3) <= max_z & ...
    all_pos(:,4) == 1);


new_index            	= [indxH;find_pos];
new_index               = unique(new_index);