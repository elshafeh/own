function [t1,t2] = vrhy_drawstim(trl_stim,t_in)

global scr stim wPtr

switch trl_stim
    case '0'
        to_draw = stim.textures.zero;
        codeOn = 105;
        codeOff = 106;
    case '1'
        to_draw = stim.textures.one();
        codeOn = 111;
        codeOff = 112;
    case '4'
        to_draw = stim.textures.four();
        codeOn = 113;
        codeOff = 114;
    case '6'
        to_draw = stim.textures.six();
        codeOn = 115;
        codeOff = 116;
    case '8'
        to_draw = stim.textures.eight();
        codeOn = 117;
        codeOff = 118;
    case 'J'
        to_draw = stim.textures.j();
        codeOn = 121;
        codeOff = 122;
    case 'H'
        to_draw = stim.textures.h();
        codeOn = 123;
        codeOff = 124;
    case 'E'
        to_draw = stim.textures.e();
        codeOn = 125;
        codeOff = 126;
    case 'A'
        to_draw = stim.textures.a();
        codeOn = 127;
        codeOff = 128;
    otherwise
        msg = 'Stimulus label not valid.';
        error(msg)
end

bgmask          = Screen('MakeTexture', wPtr, ones(scr.rect(4), scr.rect(3)).*scr.background);
Screen('DrawTextures', wPtr,bgmask);
Screen('DrawTexture', wPtr, to_draw)
Screen('DrawingFinished', wPtr); 
t1              = Screen('Flip',wPtr, t_in - scr.ifi/2);
scr.b.sendTrigger(codeOn); % send stimulus onset trigger
    
bgmask          = Screen('MakeTexture', wPtr, ones(scr.rect(4), scr.rect(3)).*scr.background);
Screen('DrawTextures', wPtr,bgmask); 
Screen('DrawingFinished', wPtr); 
t2              = Screen('Flip',wPtr, t1+stim.dur.stim - scr.ifi/2);
scr.b.sendTrigger(codeOff); % send stimulus offset trigger
                   
