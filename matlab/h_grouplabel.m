function list_unique = h_grouplabel(data,hemi_divide)

list_chan                           = data.label;

for nchan = 1:length(list_chan)
    
    pt1                             = strsplit(list_chan{nchan},',');
    pt2                             = strsplit(pt1{2},' ');
    
    if strcmp(hemi_divide,'yes')
        list_new{nchan,1}        	= [pt2{2} ' ' pt1{1}];
    else
        list_new{nchan,1}       	= [pt1{1}];
    end
    
end

list_unique                     	= unique(list_new); clear tmp xi nchan;

for nchan = 1:length(list_unique)
    tmp                             = find(strcmp(list_unique{nchan},list_new));
    list_unique{nchan,2}         	= tmp; clear tmp;
end