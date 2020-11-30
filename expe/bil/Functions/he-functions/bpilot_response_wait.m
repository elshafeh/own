function bpilot_response_wait

global scr

if IsLinux
    scr.b.getResponse(120*120,1); % wait for an hour :)
    scr.b.clearResponses;
else
    KbWait(-1);
end