function vrhy_demonstrateStimuli
    global stim wPtr scr Info ctl
    letterFirst = ctl.mapping == 1;
    
    text = '\n\n\n All possible targets will be demonstrated \n\n Left will always be the ';
    if letterFirst
        text = [text, 'letter\n\n'];
    else
        text = [text, 'number\n\n'];
    end
    text = [text, 'Right will always be the '];
    if letterFirst
        text = [text, 'number\n\n'];
    else
        text = [text, 'letter\n\n'];
    end    
    text = [text, '\n\n\n Press any button to continue to the next stimulus'];
    vrhy_darkenBackground;
    DrawFormattedText(wPtr, text, 'center', 'center', scr.black);
    Screen('Flip', wPtr);

    vrhy_response_wait;
    WaitSecs(0.2);
    for idx = 1:4
        vrhy_darkenBackground; 
        Screen('DrawTexture', wPtr, stim.textures.demos(idx));
        Screen('Flip',wPtr);        
        vrhy_response_wait;
        WaitSecs(stim.dur.pause/4);
    end
    
    