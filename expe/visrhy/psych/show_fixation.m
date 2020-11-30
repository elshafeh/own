% Clear old session
sca;
clear;

% Set parameters
global wPtr Info
addpath(genpath('Functions/'));
addpath(genpath('Stimuli/'));
Info.debug = 'no  ';
Info.name = 'XX1'; % To prevent error of missing field
 
% Setup screen
vrhy_setParameters;  
if strcmp(Info.debug,'no')
    HideCursor;
end
Screen('BlendFunction', wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Create 0 stimulus
im0 = imread('0.png');
transparent = (im0 == 255);
im0(:,:,2) = ~transparent * 255 ;
stimulus = Screen('MakeTexture', wPtr, im0);

% Show fixation cross and wait for KB input
vrhy_darkenBackground;
vrhy_drawFixation;
Screen('Flip', wPtr);

% Wait for KB response
WaitSecs(0.2);
KbWait(-1);
Screen('Flip', wPtr);     

% Show a zero to check
vrhy_darkenBackground;
Screen('DrawTexture', wPtr, stimulus);
Screen('DrawingFinished', wPtr); 
Screen('Flip',wPtr);

% Wait for KB response
WaitSecs(0.2);
KbWait(-1);

% End
sca;
ShowCursor;

