function [repRT,repButton,repCorrect] = bpilot_getResponse
% this captures responses from keyboard or
% response device in DCCN behavioral cubicles

global scr ctl

t_report                                = GetSecs;

if IsLinux % when used in cub. or MEG
    
    scr.b.clearResponses;
    
    [b_button,response_time]	= scr.b.getResponse(120*120,1); % wait for an hour :)
    list_bitsi                  = [97 100 98 99 1:96]; % make sure which button gives out what code
    repButton                   = find(list_bitsi == b_button);
    
    if repButton > 2
        repButton         	= -1;
    end
    
    scr.b.clearResponses;
    
else % when used on mac or pc
    
    [response_time, keyCode, ~]         = KbWait(-1);
    repButton             	= find(keyCode(ctl.keyValid) == 1);
    
    if isempty(repButton)
        repButton         	= -1;
    end
    
end

repRT                      	= response_time-t_report;

if repButton < 0
    repCorrect              = 0;
else
    if repButton == ctl.expectedRep
        repCorrect          = 1;
    else
        repCorrect          = 0;
    end
end