while ~responded
    
    if IsLinux
        [KeyDown,~]             = params.b.getResponse(0.00001,0); % keyDown                 = BitsiGet(0);
        [~, ~, keyCode]         = KbCheck;
    else
        [keyDown, ~, keyCode]   = KbCheck;
    end
    
    currentTime=GetSecs-startTime;
    
    if keyDown
        if keyCode(params.Screen.escapeKey)
            ShowCursor;
            sca;
            return
        else
            RT          =currentTime;
            responded   =1;
            resp        =1;
        end
    end
    
    if currentTime >= waitForResp %max response window
        RT              =params.Time.respWindow;
        resp            =0;
        responded       =1;
    end
    
end