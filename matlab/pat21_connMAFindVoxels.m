% Right FEF:  31, 1, 58
% Left  FEF:  ?31 ?3 57
% Left IPS :  ?31, ?63, 42
% Right IPS:  30, ?65, 39

clear ; clc ;

vox2find = [31  1  58; -31 -3 57; -31 -63 42;30 -65 39];
vox2find = floor(vox2find/10);

postot = [] ; 

for i = 1:size(vox2find,1)
    
    maxPos = vox2find(i,:) ;
    
    m1 = maxPos ; m1(1,1) = m1(1,1) + 0.5 ;
    m2 = maxPos ; m2(1,1) = m2(1,1) - 0.5 ;
    
    m3 = maxPos ; m3(1,2) = m3(1,2) + 0.5 ;
    m4 = maxPos ; m4(1,2) = m4(1,2) - 0.5 ;
    
    m5 = m1 ; m5(1,3) = m5(1,3) + 0.5 ;
    m6 = m1 ; m6(1,3) = m6(1,3) - 0.5 ;
    
    m7 = m2 ; m7(1,3) = m7(1,3) + 0.5 ;
    m8 = m2 ; m8(1,3) = m8(1,3) - 0.5 ;
    
    m9  = m3 ; m9(1,3)  = m9(1,3) + 0.5 ;
    m10 = m3 ; m10(1,3) = m10(1,3) - 0.5 ;
    
    m11  = m4 ; m11(1,3)  = m11(1,3) + 0.5 ;
    m12  = m4 ; m12(1,3)  = m12(1,3) - 0.5 ;
    
    m13  = maxPos ; m13(1,3)  = m13(1,3) + 0.5 ;
    m14  = maxPos ; m14(1,3)  = m14(1,3) - 0.5 ;
    
    postot = [postot ; maxPos;m1;m2;m3;m4;m5;m6;m7;m8;m9;m10;m11;m12;m13;m14];
    
    clear maxPos m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12 m13 m14
    
end

clearvars -except postot 

load ../data/template/source_struct_template_MNIpos.mat

indx = [];

for i = 1:size(postot,1)
    
    x = postot(i,1) ; y = postot(i,2) ; z = postot(i,3) ;
    
    indx = [indx ; find(source.pos(:,1) == x & source.pos(:,2) == y & source.pos(:,3) == z)];
    
end

tmp = [];

for i = 3:6
    
    tmp = [tmp ; repmat(i,15,1)];
    
end

indx = [indx tmp] ; clear tmp ; 

clearvars -except indx

load ../data/yctot/index/FantasticFiveArsenalIndex.mat

indx_tot = [indx_tot;indx] ; clear indx note;

save('../data/yctot/index/conMaIndx.mat');