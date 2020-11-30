% Ask about sleepiness 
global Info scr wPtr

vrhy_darkenBackground;
text = 'Please rate your sleepiness';
DrawFormattedText(wPtr, text);

trial_instruction           = {'Very\n\nAlert','Quite\n\nAlert','Quite\n\nSleepy','Very\n\nSleepy'};

scr.xCtr                    = scr.xCtr - scr.xShift; % shift the center to the left and then use that as a reference point to draw all rectangles
scr.yCtr                    = scr.yCtr - scr.yShift; % shift the center to the left and then use that as a reference point to draw all rectangles

r1                          = [0 0 scr.rect_width scr.rect_width ]; % [left, top, right, bottom]

rectangle_color             = scr.gray;
text_color                  = scr.black;
oldTextSize=Screen('TextSize', wPtr, 24);
for nrect = 1:4
    
    multip_factor           = nrect -1 ;
    shifted_x               = scr.xCtr+(scr.rect_width *multip_factor)+(20*multip_factor);
    shifted_y               = scr.yCtr;
        
    rectangle_centered      = CenterRectOnPoint(r1, shifted_x, shifted_y);
    Screen('FrameRect',wPtr, [0, 0, 0], rectangle_centered, 1);
    Screen('FillRect', wPtr,rectangle_color, rectangle_centered)

    shifted_x               = shifted_x - 30;
    shifted_y               = shifted_y - 20;
    
    DrawFormattedText(wPtr, trial_instruction{nrect}, shifted_x, shifted_y, text_color); % Display task instructions
    
end

Screen('Flip', wPtr);
if IsLinux
    scr.b.clearResponses;

    [b_button,response_time]            = scr.b.getResponse(120*120,1); % Wait for an hour
    list_bitsi                          = [97 98 99 100 1:96];
    repButton                           = find(list_bitsi == b_button);

    if repButton > 4
        warning('Unexpected button code');
    end
    Info.blocks.sleep = [Info.blocks.sleep, repButton];
    scr.b.clearResponses;
else
    vrhy_response_wait;
end
vrhy_darkenBackground;
Screen('Flip', wPtr);

% Reset values
[scr.xCtr, scr.yCtr]        = RectCenter(scr.rect);
Screen('TextSize', wPtr, oldTextSize);