if strcmp(suj,'yc1') || strcmp(suj,'yc4')
    nbloc = 14;
else
    nbloc=15;
end

if strcmp(suj,'yc11')
    
    blc_grp{1} = 1:5;
    blc_grp{2} = [6 7 8 14 15];
    blc_grp{3} = [9 10 11 12 13];
    
elseif strcmp(suj,'yc13')
    
    blc_grp{1} = [2 3 4 5 6];
    blc_grp{2} = [7 8 9 13 1];
    blc_grp{3} = [10 11 12 14 15];
    
elseif strcmp(suj,'yc15')
    
    blc_grp{1} = [1 2 3 14 15];
    blc_grp{2} = [4 5 6 7 8];
    blc_grp{3} = [9 10 11 12 13];
    
elseif strcmp(suj,'yc16')
    
    blc_grp{1} = [1 5 6 7 8];
    blc_grp{2} = [2 3 4 9 10];
    blc_grp{3} = [11 12 13 14 15];
    
elseif strcmp(suj,'yc17')
    
    blc_grp{1} = 1:5;
    blc_grp{2} = [14 10 15 11 8];
    blc_grp{3} = [6 7 9 12 13];
    
    
else
    
    blc_grp{1} = 1:5;
    blc_grp{2} = 6:10;
    blc_grp{3} = 11:nbloc;
    
end