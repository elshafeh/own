clear;

total_suj               = 36;
total_block             = 12;
nb_repeat               = total_suj/total_block;

BilbolatinSquare        = [];

for nb = 1:nb_repeat
    
    M                   = latsq(12);
    BilbolatinSquare    = [BilbolatinSquare; M];
    
end

clearvars -except 