function bpilot_displayStimFam(target,mask,degIn)

global scr stim wPtr

% prepare the PTB texture for target, probe and mask
tex1                    = Screen('MakeTexture', wPtr, round(target.img*scr.white,1));
tex2                    = Screen('MakeTexture', wPtr, round(mask.img*scr.white,1));

% prepare the PTB texture for the background
bgmask                  = Screen('MakeTexture', wPtr, ones(scr.rect(4), scr.rect(3)).*scr.gray);

% prepare the PTB texture for the aperture mask
masktex                 = Screen('MakeTexture', wPtr, stim.mask); % aperture for stimuli
fix_tex                 = Screen('MakeTexture', wPtr, stim.Fix.mask); % aperture for fixation

tPrefix                 = bpilot_drawFixation;

% ----------- stimulus 1 ---------------
% draw the mask apertures into the background mask
Screen('DrawTextures', bgmask, masktex);
Screen('DrawTextures', wPtr, fix_tex);

% draw the target
Screen('DrawTextures', wPtr, tex1);
% draw the background again
Screen('DrawTexture', wPtr, bgmask);
% draw fixation
stim.Fix.color          = repmat(stim.patch.FixColor, [1,3]);
JY_VisExptTools('draw_fixation', stim.Fix);

% DrawFormattedText(wPtr, num2str(degIn), 'center', scr.yCtr-350, scr.black);
% flip to the screen
Screen('DrawingFinished', wPtr);
tStim1                  = Screen('Flip',wPtr, tPrefix - scr.ifi/2);

% % ----------- stimulus 2 ---------------
% % draw the mask apertures into the background mask
% Screen('DrawTextures', bgmask, masktex);
% Screen('DrawTextures', wPtr, fix_tex);
%
% % draw the gratings
% Screen('DrawTextures', wPtr, tex2);
%
% % draw the background again
% Screen('DrawTexture', wPtr, bgmask);
%
% % draw grey fixation
% stim.Fix.color          = repmat(scr.lightgray, [1,3]);
% JY_VisExptTools('draw_fixation', stim.Fix);
%
% % flip to the screen
% Screen('DrawingFinished', wPtr);
% tStim2                  = Screen('Flip', wPtr, tStim1 + stim.dur.target - scr.ifi/2);
%
% % --------- ISI  ------------
% bpilot_darkenBackground;
% JY_VisExptTools('draw_fixation', stim.Fix); % draw fixation
% tStimOff                = Screen('Flip', wPtr, tStim2+stim.dur.mask - scr.ifi/2); % flip to the screen