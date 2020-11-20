function [trl_tot,behav_summary,posOUT,all_evnts]  = PrepAtt22_funk_pos_summary(behav_in_recoded)

all_evnts       = {};
posOUT          = [];
behav_summary   = [];
ntrl_blc        = 0;

cnsnt  = 5/3;
ncue    = 0 ;

% format in : 1)sub 2)bloc 3)event 4)sample 5) group index
% fprintf('Analysing performances ...\n');

for n = 1:length(behav_in_recoded)
    
    %     waitbar(n/length(behav_in_recoded))
    
    if  floor(behav_in_recoded(n,3)/1000)==1
        
        ncue = ncue + 1;
        
        if ncue >1
            sub_evnts = PrepAtt22_funk_check_cueBaseline(behav_in_recoded,behav_in_recoded(n,4));
            if isempty(sub_evnts)
                sub_evnts = 0 ;
            end            
        else
            sub_evnts = 0 ;
        end
        
        
        [sub_idx,nbloc,code,CUE,DIS,TAR,XP,REP,CORR,RT,ERROR,cue_idx,CT,DT,cueON,disON,tarON,CLASS,idx_suj,CD] = deal(0);
        
        ntrl_blc = ntrl_blc + 1;
        idx_suj  =  behav_in_recoded(n,5);
        sub_idx  =  behav_in_recoded(n,1);
        nbloc    =  behav_in_recoded(n,2);
        
        code     =behav_in_recoded(n,3)-1000;  CUE=floor(code/100);  DIS=floor((code-100*CUE)/10); TAR=mod(code,10); if TAR>2;XP=2;else XP=1;end;
        
        if CUE == 0
            cue_idx = 2;
        else
            cue_idx = 1;
        end
        
        fcue=1; p=1;
        
        while fcue==1 && n+p <=length(behav_in_recoded)
            
            acc_width = behav_in_recoded(n+p,4) - behav_in_recoded(n,4);
            acc_width = acc_width * cnsnt;
            
            if floor(behav_in_recoded(n+p,3)/1000)~=1 && (behav_in_recoded(n+p,4) > behav_in_recoded(n+p-1,4)) && acc_width <= 5000
                p=p+1;
            else
                fcue=2;
            end
            
            
        end
        
        p               = p-1;
        trl             = behav_in_recoded(n:n+p,:);
        
        if size(trl,1) > 1
            
            trl_tot{ntrl_blc}   = trl;
            
            cuetmp  = find(floor(trl(:,3)/1000)==1);
            tartmp  = find(floor(trl(:,3)/1000)==3);
            distmp  = find(floor(trl(:,3)/1000)==2);
            reptmp  = find(floor(trl(:,3)/1000)==9);
            
            cueON   = trl(cuetmp(1),4);
            
            if isempty(tartmp)
                tarON = 0;
            else
                tarON = trl(tartmp(1),4);
            end
            
            CT = (tarON-cueON);
            
            if DIS ~= 0
                if ~isempty(distmp)
                    disON = trl(distmp(1),4);
                    DT = (tarON-disON); % * 5/3;
                    CD = (disON-cueON);
                end
            else
                DT = 0;
            end
            
            ERROR=0 ; CORR = 0; REP = 0;
            
            if size(reptmp,1) == 0  % ----- MISS ---- %
                ERROR = 1;
            else
                
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
                    REP   = trl(reptmp(1),3)-9000;
                    if REP==XP; CORR=1; else CORR=-1;end
                    
                end
                
                RT = trl(reptmp(1),4)-tarON;
                
            end
            
            if CORR ==1
                
                trl(:,5)=0;
                
            elseif CORR == 0
                
                if ERROR == 1
                    trl(:,5)=5;
                elseif ERROR == 3;
                    trl(:,5)=6;
                end
                
            elseif CORR==-1
                
                trl(:,5) = 7;
                
            end
            
            trl(:,3)        = floor(trl(:,3)/1000)*1000 + code;
            RT              = RT    * cnsnt;
            CT              = CT    * cnsnt;
            DT              = DT    * cnsnt;
            
            behav_summary   = [behav_summary ; sub_idx nbloc ntrl_blc code CUE DIS TAR XP REP CORR RT ERROR cue_idx CT DT cueON disON tarON CLASS idx_suj CD];
            
            
            all_evnts{end+1} = sub_evnts(1,:);
            
        else
            
            trl(:,5)=1;
            
        end
        
        xi = trl(trl(:,5)~=0,5);
        xi = unique(xi);
        
        if ~isempty(xi)
            if length(xi)==1
                trl(:,5)=xi;
            else
                error(sprintf('CAREFUL !! trial is fucked up'))
            end
        end
        
        posOUT = [posOUT;trl(:,4) trl(:,3) trl(:,5)];
        
        clear code CUE DIS TAR XP CORR ERROR cuetmp distmp tartmp reptmp
        
    end
    
end

% close(h);
% if size(reptmp,1)>1
%     ERROR = 2; % multiple response
%     REP1=trl(reptmp(1),3)-9000;
%     if REP1==XP; CORR1=1; else CORR1=-1;end
%     REP2=trl(reptmp(2),3)-9000;
%     if REP2==XP; CORR2=1; else CORR2=-1;end
%     if CORR1 ==1 && CORR2 ==1
%         CLASS=1; % double correct
%     elseif CORR1 ==-1 && CORR2 ==-1
%         CLASS=2; % double incorrect
%     elseif CORR1 == 1 && CORR2 ==-1
%         CLASS=3; % decorrective
%     elseif CORR1 == -1 && CORR2 ==1
%         CLASS=4; % corrective
%     end
%
%     clear REP1 REP2 CORR1 CORR2
% end