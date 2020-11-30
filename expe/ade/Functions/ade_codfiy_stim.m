function P = ade_codfiy_stim(P,Info)

for nblock = 1:size(P.PresentationSide,1)
    for nt = 1:size(P.PresentationSide,2)
        
        if strcmp(Info.modality,'vis')
            dig1    = 100;
        else
            dig1    = 200;
        end
        
        dig2        = P.PresentationNois(nt) * 10;
        
        if P.PresentationSide(nt) == 1
            dig3    = P.PresentationSide(nt)-1 + P.PresentationType(nt);
        else
            dig3    = P.PresentationSide(nt) + P.PresentationType(nt);
        end
        
        P.TargCode(nblock,nt)      = dig1+dig2+dig3;
        P.ProbeCode(nblock,nt)     = 20+P.PresentationInst(nt);
        
    end
end