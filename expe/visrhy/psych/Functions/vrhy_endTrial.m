function tfin = vrhy_endTrial(repCorrect)

global stim wPtr Info ctl scr

% send end of trial trigger. 202 = correct, 204 = incorrect
if IsLinux 
    if repCorrect
        scr.b.sendTrigger(202); 
    else
        scr.b.sendTrigger(204); 
    end
end

if strcmp(Info.runtype, 'block')
    vrhy_darkenBackground;
else
    if repCorrect == 1
        stim.Fix.color          = scr.green; % repmat(scr.green, [1,3]);
    else
        stim.Fix.color          = scr.red; % repmat(scr.red, [1,3]);
    end
    vrhy_darkenBackground;
    JY_VisExptTools('draw_fixation', stim.Fix);
end
tfin                        = Screen('Flip', wPtr);