x = indx_tot(indx_tot(:,2)==2,1);

label = {};

for i = 1:length(x)
    
    y = indxH(indxH(:,1)==x(i),2);
    label{end+1} = atlas.tissuelabel{y};
    
end