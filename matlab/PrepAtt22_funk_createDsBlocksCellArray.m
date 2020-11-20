function blocksArray = PrepAtt22_funk_createDsBlocksCellArray(suj)

if strcmp(suj,'fp1')
    blocksArray = {'02','03','04','05','06','07','08','09','10','11','12'};
    
elseif strcmp(suj,'fp3')
    blocksArray = {'01','02','03','04','05','06','07','09','10','11','12'};
    
elseif strcmp(suj,'fp4')
    blocksArray = {'01','02','03','04','05','06','07','08'};
    
elseif strcmp(suj,'oc8')
    blocksArray = {'01','02','03','05','06','07','08','09','10','11'};
    
elseif strcmp(suj,'oc10')
    blocksArray = {'01','02','03','04','05','07','08','09','10','11','12'};
    
elseif strcmp(suj,'oc13')
    blocksArray = {'01','02','03','04','05','06','07','08','09','10','12'};
    
elseif strcmp(suj,'oc14')
    blocksArray = {'02','03','04','05','06','07','08','09','10','11','12'};
    
elseif strcmp(suj,'yc9')
    blocksArray = {'01','02','05','07','08','09','10','11','12','13','14'};

elseif strcmp(suj,'yc13')
    blocksArray = {'01','02','03','05','06','07','08','09','10','11','12'};
    
elseif strcmp(suj,'yc17')
    blocksArray = {'01','02','03','04','05','06','07','08','09','10',};
    
elseif strcmp(suj,'yc18')
    blocksArray = {'01','02','03','04','05','06','07','08','09','10',};  
    
elseif strcmp(suj,'uc3')
    blocksArray = {'01','02','03','04','05','06','08','09','10','11','12'};
    
elseif strcmp(suj,'uc5')
    blocksArray = {'01','02','03','04','05','07','06','08','09','10'};
    
elseif strcmp(suj,'uc7')
    blocksArray = {'01','02','03','04','05','07','08','09','10','11'};
    
elseif strcmp(suj,'mg1')
    blocksArray = {'01','02','03','04','05', '06','07','08','09','10'};
    
elseif strcmp(suj,'mg2')
    blocksArray = {'03','04','05','06','07','08','09','10','11','12'};
    
elseif strcmp(suj,'mg3')
    blocksArray = {'02','03','04','05','06','07','08','09','10','12'};
    
elseif strcmp(suj,'mg4')
    blocksArray = {'01','02','03','04','05', '06','07','08','09','10'};
    
elseif strcmp(suj,'mg5')
    blocksArray = {'01','02','03','04','05', '06','07','08','09','10'};
    
elseif strcmp(suj,'mg6')
    blocksArray = {'01','02','03','04','05', '06','07','08','09','10'};
    
elseif strcmp(suj,'mg7')
    blocksArray = {'01','02','03','04','05', '06','07','08','09','10'};
    
elseif strcmp(suj,'mg8')
    blocksArray = {'01','02','03','04','05', '06','07','08','09','10'};
   
elseif strcmp(suj,'mg9')
    blocksArray = {'01','02','03','04','05', '06','07','08','09','10'};
    
% ajout des blocs repos � partir du sujet mg10    
elseif strcmp(suj,'mg11')
    blocksArray = {'03','04','05','06','07','08','09','10','11','12','13'};
    
elseif strcmp(suj,'mg13')
    blocksArray = {'02','03','04','05','06','07','08','09','10','11','12'};
    
elseif strcmp(suj,'mg15')
    blocksArray = {'01','02','03','04','05','06','07','09','10','11','13'};
    
else
    blocksArray = {'01','02','03','04','05','06','07','08','09','10','11'};
end