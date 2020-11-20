clear;

% this creates matrix to be used for decoding later 
% to avoid redundant testing

test_done                               = [];
i                                       = 0;

for a = 1:10
    for b = 1:10
        
        if a ~= b
            
            if i == 0
                
                i                       = i + 1;
                
                test_done(i,1)          = a;
                test_done(i,2)          = b;
                
            else
                
                chk                     = length(find(test_done(:,1) == a)) + length(find(test_done(:,2) == b));
                
                if length(chk) < 2
                    chk                 = length(find(test_done(:,1) == b)) + length(find(test_done(:,2) == a));
                    
                    if length(chk) < 2
                        i                   = i + 1;
                        
                        test_done(i,1)      = a;
                        test_done(i,2)      = b;
                    end
                    
                end
                
            end
            
        end
        
    end
end

clearvars -except test_done

save decode_stim_mtrx.mat