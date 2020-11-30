function keyTime = vrhy_response_wait

global scr ctl

if IsLinux   
    keyCode = 0;
    while ~ismember(keyCode, ctl.buttonCodesOn) % To prevent letting go of a button is interpreted as a response
        [keyCode, keyTime]   = scr.b.getResponse(120*120,1); % wait for an hour
        disp(keyCode);
        scr.b.clearResponses;
    end
else
    [keyTime, ~, ~] = KbWait(-1);
end