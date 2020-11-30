function [tcue1,tcue2,tcue3] = bpilot_drawcue(CueInfo)

global scr stim wPtr

bpilot_darkenBackground;

fixCrossDimPix  = 40;
xCoords         = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords         = [0 0 0 0];
allCoords       = [xCoords; yCoords];

lineWidthPix    = 7;
DashWidthPix    = 7;

% list_cue        = {'pre','retro'};
% list_task       = {'ori','freq'};

cy1             = scr.yCtr-10;
cy2             = scr.yCtr+10;

if isfield(CueInfo,'tfin')
    tcue1       = CueInfo.tfin;
else
    bpilot_drawFixation;
    tcue1       = Screen('Flip', wPtr);
    bpilot_darkenBackground;
end

switch CueInfo.CueOrder
    case 1
        switch CueInfo.CueType
            case 1
                % pre cue
                switch CueInfo.TaskType
                    case 1
                        % attend orientation
                        Screen('DrawLines', wPtr, allCoords,DashWidthPix, scr.black, [scr.xCtr cy1], 2);
                        Screen('DrawLines', wPtr, allCoords,lineWidthPix, scr.black, [scr.xCtr cy2], 2);
                    case 2
                        % attend frequency
                        Screen('LineStipple', wPtr, 1, 1, [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1]);
                        Screen('DrawLines', wPtr, allCoords,DashWidthPix, scr.black, [scr.xCtr cy1], 2);
                        Screen('LineStipple', wPtr, 1, 1, [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1]);
                        Screen('DrawLines', wPtr, allCoords,lineWidthPix, scr.black, [scr.xCtr cy2], 2);
                end
                
                cueCode         = CueInfo.CueOrder*10 + CueInfo.TaskType;
                
            case 2
                
                Screen('LineStipple', wPtr, 1, 1, [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1]);
                Screen('DrawLines', wPtr, allCoords,DashWidthPix, scr.black, [scr.xCtr cy1], 2);
                Screen('LineStipple', wPtr, 0);
                Screen('DrawLines', wPtr, allCoords,lineWidthPix, scr.black, [scr.xCtr cy2], 2);
                
                cueCode         = CueInfo.CueOrder*10 + 3;
                
        end
        
    case 2
        
        switch CueInfo.CueType
            case 2
                % retro cue
                switch CueInfo.TaskType
                    case 1
                        % attend orientation
                        Screen('DrawLines', wPtr, allCoords,DashWidthPix, scr.black, [scr.xCtr cy1], 2);
                        Screen('DrawLines', wPtr, allCoords,lineWidthPix, scr.black, [scr.xCtr cy2], 2);
                    case 2
                        % attend frequency
                        Screen('LineStipple', wPtr, 1, 1, [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1]);
                        Screen('DrawLines', wPtr, allCoords,DashWidthPix, scr.black, [scr.xCtr cy1], 2);
                        Screen('LineStipple', wPtr, 1, 1, [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1]);
                        Screen('DrawLines', wPtr, allCoords,lineWidthPix, scr.black, [scr.xCtr cy2], 2);
                end
                
                cueCode         = CueInfo.CueOrder*10 + CueInfo.TaskType;
                
            case 1
                
                Screen('LineStipple', wPtr, 1, 1, [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1]);
                Screen('DrawLines', wPtr, allCoords,DashWidthPix, scr.black, [scr.xCtr cy1], 2);
                Screen('LineStipple', wPtr, 0);
                Screen('DrawLines', wPtr, allCoords,lineWidthPix, scr.black, [scr.xCtr cy2], 2);
                
                cueCode         = CueInfo.CueOrder*10 + 3;
                
        end
end

tcue2           = Screen('Flip', wPtr,tcue1+CueInfo.time_before - scr.ifi/2);

if IsLinux
    scr.b.sendTrigger(cueCode); % send trigger
end

bpilot_drawFixation;
tcue3           = Screen('Flip', wPtr,tcue2+CueInfo.CueDur - scr.ifi/2);