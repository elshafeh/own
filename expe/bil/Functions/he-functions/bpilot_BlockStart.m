function bpilot_BlockStart(bloc_number)

global wPtr scr stim Info

bpilot_darkenBackground;
DrawFormattedText(wPtr, scr.Pausetext{Info.MappingList(bloc_number)}, 'center', 'center', scr.black);
Screen('Flip', wPtr);

if strcmp(Info.MotorResponse,'yes')
    if IsLinux
        bpilot_response_wait;
    else
        KbWait(-1);
    end
end

if IsLinux
    scr.b.sendTrigger(250); % start trigger
end

bpilot_drawFixation;
Screen('Flip', wPtr);