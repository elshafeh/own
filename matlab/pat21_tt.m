if size(reptmp,1) == 0  % ----- MISS ---- %
    ERROR = 1;
    
elseif size(reptmp,1) == 1
    
    if reptmp(1) < tartmp
        ERROR = 3; % False alarm
        
        if DIS ~=0
            
            if reptmp(1) < distmp
                CLASS = 2;
            else
                CLASS =1;
            end
            
        else
            CLASS =1;
        end
        
    else
        
        %                 if size(reptmp,1)>1
        %                     ERROR = 2; % multiple response
        %
        %                     REP1=trl(reptmp(1),3)-9000;
        %                     if REP1==XP; CORR1=1; else CORR1=-1;end
        %
        %                     REP2=trl(reptmp(2),3)-9000;
        %                     if REP2==XP; CORR2=1; else CORR2=-1;end
        %
        %                     if CORR1 ==1 && CORR2 ==1
        %                         CLASS=1; % double correct
        %                     elseif CORR1 ==-1 && CORR2 ==-1
        %                         CLASS=2; % double incorrect
        %                     elseif CORR1 == 1 && CORR2 ==-1
        %                         CLASS=3; % decorrective
        %                     elseif CORR1 == -1 && CORR2 ==1
        %                         CLASS=4; % corrective
        %                     end
        %
        %                     clear REP1 REP2 CORR1 CORR2
        %
        %                 else
        
        REP   = trl(reptmp(1),3)-9000;
        if REP==XP; CORR=1; else CORR=-1;end
        
        %                 end
    end
    
    RT = trl(reptmp(1),4)-tarON;
    
end