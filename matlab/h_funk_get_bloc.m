function bloc_lim   = h_funk_get_bloc(behav_table)

bloc_lim            = [];

for nb = 1:10
    
    ix              = [behav_table.nbloc]; 
    bloc_lim        = [bloc_lim;length(ix(ix==nb))];
    
end