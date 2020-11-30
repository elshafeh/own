function toquit = vrhy_BlockEnd(ix)

global wPtr scr stim Info ctl

if IsLinux
    scr.b.sendTrigger(20); % send end of block trigger
    WaitSecs(1.0);
end

i1                                          = ix(1);
i2                                          = ix(end);
bloc_nr                                     = i2/Info.bloc_length;

if strcmp(Info.runtype, 'block')
    if bloc_nr == 1 % If this was the end of the first block
        msg = 'End of block\n\nYou will be asked about rhythmicity';
        vrhy_showWarning(msg);
    end
    vrhy_askRhythmicity;
    WaitSecs(1.0);
    vrhy_askSleep;
    WaitSecs(0.2);
end
  
% Compute and show performance

nonCatchTrials                              = find(Info.trialinfo(:,3) ~= 0);
nonCatchTrials_thisBlock                    = intersect(nonCatchTrials, i1:i2);

bloc_perf                                   = Info.correct(nonCatchTrials_thisBlock);
bloc_perf                                   = sum(bloc_perf)/length(bloc_perf);
Info.blocks.acc                             = [Info.blocks.acc, bloc_perf];


if strcmp(Info.runtype, 'block')
    endtext0                                = [num2str(bloc_nr), ' out of ', num2str(Info.nr_blocs), ' blocks done\n\n']; 
else
    endtext0                                = 'End of training block\n\n';
end
endtext1                                    = strcat('Your performance in this block was:\n\n', num2str(bloc_perf * 100), '%');
endtext2                                    = '\n\n\nPlease take some rest \n\n';

vrhy_darkenBackground;
DrawFormattedText(wPtr, [endtext0, endtext1, endtext2], 'center', 'center', scr.black);
Screen('Flip', wPtr);

WaitSecs(0.2);
[~, keyCode, ~] = KbWait(-1);
button = find(keyCode(ctl.keyValid) == 1);
toquit = button == 2;

WaitSecs(stim.dur.pause);
