function [repRT,repButton,repCorrect] = vrhy_getResponse(expectedRep, freq_inv)
% this captures responses from keyboard or
% response device in DCCN behavioral cubicles

global Info scr ctl stim

% set value for maximum time to wait for response (in seconds)
t2wait                              = stim.dur.resp;

% Set time to wait to three cycles plus a constant
if expectedRep == -1
    a = 0.1;
    b = 0.2;
    r = (b-a).*rand(1) + a;
    jitter = round(r,3); % round to 3 decimal places
    t2wait = freq_inv * 3 + 0.2 + jitter; % wait three cycles + constant + jitter between 100 and 200ms
end
repRT                               = NaN;

% suppress echo to the command line for keypresses
ListenChar(2);
% get the time stamp at the start of waiting for key input

tStart                              = GetSecs;
 
scr.b.clearResponses;

[b_button,response_time]            = scr.b.getResponse(t2wait,1);
list_bitsi                          = [97 98 99 100 1:96];
repButton                           = find(list_bitsi == b_button);

if isempty(repButton)        
    repButton                       = -1;        
end
if repButton > 2 
    scr.b.sendTrigger(250); % Send trigger for invalid button used
    vrhy_showWarning('Invalid button\n\nPlease use the yellow and blue button to give a response');
    repButton                       = -1;
end

scr.b.clearResponses;   

% Wait half a second after button response (or end of response window)
WaitSecs( round(0.5 ./ scr.ifi) * scr.ifi);


if repButton ~= -1 % Only if button press is valid, 
    repRT                                  = response_time-tStart;
end

if repButton == expectedRep
    repCorrect          = 1;
else
    repCorrect          = 0;
end

