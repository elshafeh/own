function list_unique = h_parcellatelabel(data)

list_chan                           = data.label;
list_parcels                        = {'ccipital','rontal','arietal','central'};
list_sensible                       = {'occipital','frontal','parietal','pre post central'};
list_unique                         = {};


for np = 1:length(list_parcels)   
    list_unique{np,1}               = list_sensible{np};
    list_unique{np,2}               = find(contains(list_chan,list_parcels{np}));
end