function channel_comb = h_connectivitypairs(data)

test_done                               = {};
channel_comb                          	= {};
i                                       = 0;

for xi = 1:length(data.label)
    for yi = 1:length(data.label)
        
        if xi ~= yi
            
            str_check_1               = [num2str(xi) '.' num2str(yi)];
            str_fnd_1                 = find(strcmp(test_done,str_check_1));
            
            str_check_2               = [num2str(yi) '.' num2str(xi)];
            str_fnd_2                 = find(strcmp(test_done,str_check_2));
            
            
            if isempty(str_fnd_1) && isempty(str_fnd_2)
                
                i                   = i + 1;
                test_done           = [test_done; [num2str(xi) '.' num2str(yi)]; [num2str(yi) '.' num2str(xi)]];
                channel_comb{i,1} 	= data.label{xi};
                channel_comb{i,2} 	= data.label{yi};
                
            end
            
        end
        
    end
end