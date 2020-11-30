function bpilot_darkenBackground

global wPtr scr

bgmask                  = Screen('MakeTexture', wPtr, ones(scr.rect(4), scr.rect(3)).*scr.gray/2);
Screen('DrawTextures', wPtr,bgmask);%, masktex);