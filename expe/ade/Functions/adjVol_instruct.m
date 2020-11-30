function bpress = adjVol_instruct(P,Instruction_probe)

Screen(P.window,'TextSize',P.TextSize);


list_instruction            = {{'\nYES\n\n','','','\nNO\n\n'},{'\nUP\n\n','','','\nDOWN\n\n'}};
trial_instruction           = list_instruction{Instruction_probe};

P.CenterX                   = P.CenterX - P.shiftX; % shift the center to the left and then use that as a reference point to draw all rectangles
P.CenterY                   = P.CenterY - P.shiftY; % shift the center to the left and then use that as a reference point to draw all rectangles

r1                          = [0 0 P.rectangle_width P.rectangle_width]; % [left, top, right, bottom]

rectangle_color     = P.Grey;
text_color          = P.Black;

for nrect = 1:4
    
    multip_factor           = nrect -1 ;
    shifted_x               = P.CenterX+(P.rectangle_width*multip_factor)+(20*multip_factor);
    shifted_y               = P.CenterY+120;
        
    rectangle_centered      = CenterRectOnPoint(r1, shifted_x, shifted_y);
    Screen('FrameRect',P.window, [0, 0, 0], rectangle_centered, 1);
    Screen('FillRect', P.window,rectangle_color, rectangle_centered)

    shifted_x               = shifted_x - 30;
    shifted_y               = shifted_y - 20;
    
    DrawFormattedText(P.window, trial_instruction{nrect}, shifted_x, shifted_y, text_color); % Display task instructions
    
end

Screen('Flip', P.window);

flag    = 0;

while flag == 0
    
    if IsLinux
        [~,bpress]     = get_bitsi_response(P);
    else
        [~,bpress]     = get_adj_response(P);
    end
    
    if ~isempty(bpress)
        if bpress == 1 || bpress == 4
            flag = 1;
        end
    end
    
end

my_fixationpoint(P,P.Black);
Screen('Flip', P.window);