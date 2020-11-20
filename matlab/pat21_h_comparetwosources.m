function list = h_comparetwosources(arry,plim)

for n = 1:2
    sig_list{n} = FindSigClusters(arry{n},plim);
end

list.common         = intersect(sig_list{1,1}(:,1),sig_list{:,2}(:,1));
list.unique_first   = {};
list.unique_scnd    = {};

for n = 1:length(sig_list{1})
    
    x = sig_list{1}{n,1};
    y = find(strcmp(sig_list{2}(:,1),x));

    if isempty(y)
        list.unique_first{end+1,1} = x; 
    end
    
end

for n = 1:length(sig_list{2})
    
    x = sig_list{2}{n,1};
    y = find(strcmp(sig_list{1}(:,1),x));

    if isempty(y)
        list.unique_scnd{end+1,1} = x; 
    end
    
end