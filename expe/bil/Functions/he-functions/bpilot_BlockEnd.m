function bpilot_BlockEnd(ix)

global wPtr scr stim Info

i1                                          = ix(1);
i2                                          = ix(end);
bloc_perf                                   = cell2mat(Info.TrialInfo.repCorrect(i1:i2));
bloc_perf                                   = sum(bloc_perf)/length(bloc_perf);

endtext1                                    = [num2str(bloc_perf) '\n\n! GREAT JOB !'];

% if bloc_perf <= 0.5
%     endtext1 = 'GREAT JOB !';
% elseif bloc_perf > 0.5 && bloc_perf <= 0.65
%     endtext1 = 'GREAT JOB !!';
% elseif bloc_perf > 0.65 && bloc_perf <= 0.8
%     endtext1 = 'GREAT JOB !!!';
% elseif bloc_perf > 0.8
%     endtext1 = 'GREAT JOB !!!!';
% end

if IsLinux
    scr.b.sendTrigger(251); % end trigger
end

endtext2                                    = '\n\n\nPlease Take Some Rest :) \n\n\n ';

bpilot_darkenBackground;
DrawFormattedText(wPtr, [endtext1 endtext2], 'center', 'center', scr.black);
Screen('Flip', wPtr);

if strcmp(Info.MotorResponse,'yes')
    KbWait(-1);
end

bpilot_darkenBackground;
bpilot_drawFixation;
Screen('Flip', wPtr);
WaitSecs(stim.dur.InstructionPause);