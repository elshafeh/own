function ade_DarkBackground(P)

bgmask                  = Screen('MakeTexture', P.window, ones(P.rect(4), P.rect(3)).* (P.backgroundColor));
Screen('DrawTextures', P.window,bgmask); 