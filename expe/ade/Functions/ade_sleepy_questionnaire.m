function [sleep_measure] = ade_sleepy_questionnaire(P,Info)

ade_present_text(P,'End of Block\n\nGood Job!\n\n Please rate your sleepiness :)')
WaitSecs(P.pausewait);

ade_DarkBackground(P);

trial_instruction           = {'Very\n\nAlert','Quite\n\nAlert','Quite\n\nSleepy','Very\n\nSleepy'};

P.CenterX                   = P.CenterX - P.shiftX; % shift the center to the left and then use that as a reference point to draw all rectangles
P.CenterY                   = P.CenterY - P.shiftY; % shift the center to the left and then use that as a reference point to draw all rectangles

r1                          = [0 0 P.rectangle_width P.rectangle_width]; % [left, top, right, bottom]

rectangle_color             = P.Grey;
text_color                  = P.Black;

for nrect = 1:4
    
    multip_factor           = nrect -1 ;
    shifted_x               = P.CenterX+(P.rectangle_width*multip_factor)+(20*multip_factor);
    shifted_y               = P.CenterY;
        
    rectangle_centered      = CenterRectOnPoint(r1, shifted_x, shifted_y);
    Screen('FrameRect',P.window, [0, 0, 0], rectangle_centered, 1);
    Screen('FillRect', P.window,rectangle_color, rectangle_centered)

    shifted_x               = shifted_x - 30;
    shifted_y               = shifted_y - 20;
    
    DrawFormattedText(P.window, trial_instruction{nrect}, shifted_x, shifted_y, text_color); % Display task instructions
    
end

Screen('Flip', P.window);

if strcmp(Info.motor_in,'yes')
    
    if IsLinux
        [RT,sleep_measure]     = get_bitsi_response(P);
    else
        [RT,sleep_measure]     = get_kb_response(P);
    end
    
else
    
   sleep_measure                = 1;
    
end

my_fixationpoint(P,P.Black);
Screen('Flip', P.window);