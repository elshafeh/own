function [RT,Report] = get_kb_response(P)
% Wait for a button press and store result if the response was one of the
% pre-defined buttons
% the way this is coded now will only take in the response buttons we put
% in!

flag  = 0;

while flag == 0
    
    t_report                            = GetSecs;
    [response_time, keyCode, ~]         = KbWait(-1);
    
    if strcmp(P.experiment,'stair')
        
        if keyCode(P.keyL)
            Report = 1;
        elseif keyCode(P.keyR)
            Report = 2;
        else
            Report = -1;
        end
        
    else
        
        if keyCode(P.key1)
            Report = 1;
        elseif keyCode(P.key2)
            Report = 2;
        elseif keyCode(P.key3)
            Report = 3;
        elseif keyCode(P.key4)
            Report = 4;
        else
            Report = -1;
        end
            
    end
    
    if Report > 0
        flag = 1;
    end
    
end

RT                                  = response_time-t_report; % record reaction time 'if ever it's useful :)';