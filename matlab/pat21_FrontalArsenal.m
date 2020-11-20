clear ; clc ;

list_arsenal={'LdiFPC',...
    'RdlPFC','LdFC','RdFC','LIPS1','LIPS2','LIPS3','RIPS1','RIPS2','RIPS3','rFeF1','rFeF2','rFEF3','rFEF4','lFEF1', ...
 'lFEF2','LIFG1','LIFG2','LIFG3','RIFG1','RIFG2','rTPJ1','rTPJ2','lTPJ','riPl','liPl','bpcc','rosmfg','riplasg'};

 list_pos = 
 [-41 21 38 
 43	21	38
 -41	1	39
 41	1	39
 -31	-63	42
 -24	-60	46
 -29.4	-48.8	44.8
 30	-65	39
 29	-52.8	50
 32	-60	50
 31	-14	65
 31	1	58
 33	36	26
 34.6	-1.9	50.8
 -38	16	42
 -28.7	-6.3	50.8
 -36	16	-4
 -48	14	28
 -51	10.6	30.6
 42	18	-6
 34.1	5.2	44.3
 58	-44	14
 58.5	-60	16.5
 -58	-42	32
 46	-52	58
 -31	-53	39
 -8	-24	50
 22	68	2
 56	-38	46];

list_pos = round(list_pos/10) ;

indx_arsenal = [];

for chan = 1:length(list_arsenal)
    
    whereb  = [];
    
    load ../data/template/source_struct_template_MNIpos.mat
    
    maxPos = list_pos(chan,:);
    
    m1  = maxPos ; m1(1,1) = m1(1,1) + 0.5 ;    m2 = maxPos ; m2(1,1) = m2(1,1) - 0.5 ;
    m3  = maxPos ; m3(1,2) = m3(1,2) + 0.5 ;m4 = maxPos ; m4(1,2) = m4(1,2) - 0.5 ;
    m5  = m1 ; m5(1,3) = m5(1,3) + 0.5 ;m6 = m1 ; m6(1,3) = m6(1,3) - 0.5 ;
    m7  = m2 ; m7(1,3) = m7(1,3) + 0.5 ;m8 = m2 ; m8(1,3) = m8(1,3) - 0.5 ;  
    m9  = m3 ; m9(1,3)  = m9(1,3) + 0.5 ;m10 = m3 ; m10(1,3) = m10(1,3) - 0.5 ;
    m11 = m4 ; m11(1,3)  = m11(1,3) + 0.5 ;m12  = m4 ; m12(1,3)  = m12(1,3) - 0.5 ;
    m13 = maxPos ; m13(1,3)  = m13(1,3) + 0.5 ;m14  = maxPos ; m14(1,3)  = m14(1,3) - 0.5 ;
    
    postot = [maxPos; m1;m2;m3;m4;m5;m6;m7;m8;m9;m10;m11;m12;m13;m14];
    
    clear m*
    
    bigb    = source.pos;
    
    for n = 1:size(postot,1)
        x = postot(n,1) ; y = postot(n,2) ; z = postot(n,3) ;
        whereb = [whereb;find(bigb(:,1) == x & bigb(:,2) == y & bigb(:,3) == z)];
    end
    
    whereb      = sort(whereb);
    indx_tot    = h_createIndexfieldtrip;
    atlas       = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
    
    for n = 1:length(whereb)
        ix = find(indx_tot(:,1) == whereb(n));
        
        if isempty(ix)
            whereb(n) = 0;
        end
        
    end
    
    whereb = whereb(whereb~=0);
    
    whereb = [whereb, repmat(chan,length(whereb),1)];

    indx_arsenal = [indx_arsenal;whereb];
    
    clearvars -except indx_arsenal list_pos chan list_arsenal;
    
end

clear chan list_pos ;

save('../data/yctot/index/Frontal.mat');