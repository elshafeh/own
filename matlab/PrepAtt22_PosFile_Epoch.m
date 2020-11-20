function [TposOUT,trial] = PrepAtt22_PosFile_Epoch(suj,TposIN)

duree_trial     =   5301;
duree_prestim   =   2400;
debut_trial     =   255;

TposOUT         = [];

trial=0;

for n=1:length(TposIN)
    
    if (floor(TposIN(n,2)/1000)==1 && TposIN(n,3)==0 )
        
        trial = trial+1;
        TposOUT = [TposOUT;  ((trial-1)*duree_trial)+1  debut_trial  TposIN(n,3)];
        TposOUT = [TposOUT;  (trial-1)*duree_trial+duree_prestim+1   TposIN(n,2)  TposIN(n,3)];
        
        i=1;
        while ( n+i<=length(TposIN) && floor(TposIN(n+i,2)/1000)~=1 )
            TposOUT = [TposOUT;  ((trial-1)*duree_trial+duree_prestim+1)+(TposIN(n+i,1)-TposIN(n,1))   TposIN(n+i,2)  TposIN(n+i,3)];
            i=i+1;
        end
        
    end
end
fprintf('nb total de trials non rejetés: %d  pour sujet %s\n', trial, suj);