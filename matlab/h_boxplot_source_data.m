function data = h_boxplot_source_data(source,index_H,list_H)

data    = zeros(1,length(list_H));

for nroi = 1:length(list_H)
    
    tmp             = source.pow(index_H(index_H(:,2) == nroi,1),1);
    tmp             = nanmean(tmp);
    data(1,nroi)    = tmp;
    
end
