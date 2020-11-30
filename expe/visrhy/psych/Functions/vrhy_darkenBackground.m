function vrhy_darkenBackground

global wPtr scr

bgmask                  = Screen('MakeTexture', wPtr, ones(scr.rect(4), scr.rect(3)).*scr.background);
Screen('DrawTextures', wPtr,bgmask);