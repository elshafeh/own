clear; clc ;

for s = [1:4 8:17]
    
    suj = ['yc' num2str(s)];
    
    pos_orig=load(['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/pos/' suj '.pat2.fin.pos']);
    
    pos_orig = pos_orig(pos_orig(:,3) == 0,:);
    
    pos_orig(:,4) = floor(pos_orig(:,2)/1000);
    
    pos_orig      = pos_orig(pos_orig(:,4) ~= 6,1:4);
    
    pos_orig(:,5) = pos_orig(:,2) - pos_orig(:,4)*1000;
    
    pos_orig(:,6) =   floor(pos_orig(:,5)/100);
    
    pos_orig(:,7) =   floor((pos_orig(:,5)-100*pos_orig(:,6))/10);
    
    tmp = load(['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/res/' suj '.dsheader.log']);
    dur = tmp(1);
    PrepAtt2_gp_build;
    
    for b = 1:15
        
        bloc_dur(b,1) = 600 * dur * (b-1) ;
        bloc_dur(b,2) = 600 * dur * b ;
        
    end
    
    posOUT = [];
    
    for b = 1:3
        
        fprintf('Handling Subject %s Part %d\n',suj,b);
        
        PosFile_IN = [];
        
        for n = 1:length(blc_grp{b})
            
            lim1 = bloc_dur(blc_grp{b}(n),1);
            lim2 = bloc_dur(blc_grp{b}(n),2);
            
            PosFile_IN = [PosFile_IN ; pos_orig(pos_orig(:,1) > lim1 & pos_orig(:,1) < lim2,:)];
            
        end
        
        delay_stock = [];
        
        for n = 1:length(PosFile_IN)
            if PosFile_IN(n,4) == 2 && PosFile_IN(n,7) ~= 0
                delay_stock = [delay_stock;PosFile_IN(n,1)-PosFile_IN(n-1,1) PosFile_IN(n,7) PosFile_IN(n,6) PosFile_IN(n+1,1)-PosFile_IN(n,1) PosFile_IN(n+1,1)-PosFile_IN(n-1,1)];
            end
        end
        
        PosFile_IN(:,8:11) = 0;
        
        idx_ncnd = find(PosFile_IN(:,4) == 1 & PosFile_IN(:,7) == 0);
        
        for n = 1:length(delay_stock)
            
            fprintf('Allocating Dis no %3d out of %3d\n',n,length(delay_stock));
            
            flag    = 0;
            
            while flag == 0
                
                f = randi(length(idx_ncnd));
                
                idx = idx_ncnd(f);
                
                if PosFile_IN(idx,8) == 0 && PosFile_IN(idx,6) == delay_stock(n,3);
                    
                    ct_chk = PosFile_IN(idx+1,1) - PosFile_IN(idx,1); 
                    
                    %                     if ct_chk < delay_stock(n,5)+2 && ct_chk > delay_stock(n,5)-2
                        
                        PosFile_IN(idx,9)     = delay_stock(n,1);
                        PosFile_IN(idx,10)    = delay_stock(n,2);
                        PosFile_IN(idx,8)     = 1;
                        
                        flag = 1;
                        
                        %                     end
                    
                end
                
            end
            
        end
        
        for n = 1:length(PosFile_IN);
            if PosFile_IN(n,4) == 1 && PosFile_IN(n,8) == 1
                posOUT = [posOUT  ; PosFile_IN(n,1:3)];
                posOUT = [posOUT  ; PosFile_IN(n,1)+PosFile_IN(n,9) 6000+PosFile_IN(n,5)+(PosFile_IN(n,10)*10) 0];
            else
                posOUT = [posOUT  ; PosFile_IN(n,1:3)];
            end
        end
        
        
    end
    
    posOUT = sortrows(posOUT,1);
    
    posnameout = ['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/pos/' suj '.pat2.fin.fDisMirror.pos'] ;
    dlmwrite(posnameout,posOUT,'delimiter','\t','precision','%10d');
    
    clearvars -except s
    
end