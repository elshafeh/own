function posOUT = PrepAtt22_funk_pos_AddFakeDistractors(PosFile_IN)

delay2_min_list     =   [350 50];
rand_delay2         =   295;
delay_tot           =   1000+210;
duree_DIS           =   300;

posOUT = [];

for n=1:length(PosFile_IN)
    
    if floor(PosFile_IN(n,2)/1000)==1 && PosFile_IN(n,3) == 0
        
        code=PosFile_IN(n,2)-1000;  CUE=floor(code/100);  DIS=floor((code-100*CUE)/10); TAR=mod(code,10);
        rej=PosFile_IN(n,3);
        
        if DIS==0
            
            flag=randi(2);
            
            delay2min=delay2_min_list(flag);
            delay2=round(delay2min+rand*rand_delay2);
            delay1=round(delay_tot-duree_DIS-delay2);
            
            fdis_onset    = floor((delay1 * 3/5));
            fdis_onset    = fdis_onset + PosFile_IN(n,1);
            
            ftarget_onset = PosFile_IN(n+1,1) - PosFile_IN(n,1);
            
            fdis_code     = (6000+code)+(flag*10);
            
            posOUT = [posOUT; PosFile_IN(n,:)];
            posOUT = [posOUT; fdis_onset fdis_code rej];
            
        else
            posOUT=[posOUT; PosFile_IN(n,:)];
        end
        
    else
        posOUT=[posOUT; PosFile_IN(n,:)];
    end
    
end