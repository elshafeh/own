function [trial_instruction,list_stimulus,list_condfidence] = ade_draw_instruction(P,Info,Instruction_probe)

% I came up with this to automatically draw four rectangles with
% pre-define width and ~ 1cm apart then to automatically draw text in the four instruction
% boxes

Screen(P.window,'TextSize',P.TextSize);

if strcmp(Info.experiment,'expe')
    
    if strcmp(Info.modality,'vis')
        list_instruction        = {'LEFT\n\nSURE','LEFT\n\nUNSURE','RIGHT\n\nUNSURE','RIGHT\n\nSURE'};
    elseif strcmp(Info.modality,'aud')
        list_instruction        = {'LOW\n\nSURE','LOW\n\nUNSURE','HIGH\n\nUNSURE','HIGH\n\nSURE'};
    end
    
    list_stimulus               = [1 1 2 2; 2 2 1 1];
    list_condfidence            = [1 -1 -1 1; -1 1 1 -1];
    
elseif strcmp(Info.experiment,'stair')
    
    if strcmp(Info.modality,'vis')
        list_instruction        = {'LEFT\n\n','','','RIGHT\n\n'};
    elseif strcmp(Info.modality,'aud')
        list_instruction        = {'LOW\n\n','','','HIGH\n\n'};
    end
    
    list_stimulus               = [1 0 0 2; 0 2 1 0];
    list_condfidence            = [1 0 0 1; 0 1 1 0];
    
end

random_vect                 = [1 2 3 4; 3 4 1 2]; % for the configurations that we've chosen (A sure A unsure B unsure B sure) & (B unsure B sure A sure B unsure)
trial_instruction           = list_instruction(random_vect(Instruction_probe,:));

list_stimulus               = list_stimulus(Instruction_probe,:);
list_condfidence            = list_condfidence(Instruction_probe,:);

P.CenterX                   = P.CenterX - P.shiftX; % shift the center to the left and then use that as a reference point to draw all rectangles
P.CenterY                   = P.CenterY - P.shiftY; % shift the center to the left and then use that as a reference point to draw all rectangles

r1                          = [0 0 P.rectangle_width P.rectangle_width]; % [left, top, right, bottom]

if Instruction_probe == 1
    rectangle_color     = P.Black;
    text_color          = P.White;
else
    rectangle_color     = P.Grey;
    text_color          = P.Black;
end

ade_DarkBackground(P);

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

WaitSecs(P.ProbeWait);

trigCode        = round(20+Instruction_probe);

P.bitsi.sendTrigger(trigCode);
Screen('Flip', P.window);