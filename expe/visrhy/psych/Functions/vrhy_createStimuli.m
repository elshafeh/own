function vrhy_createStimuli

    global wPtr scr stim Info ctl
    intensity_proportions = [0.35, 0.65, 0.5, 0.75, 0.85]; % 1.0 = both stimuli look the same.
    nrDifficulties = length(intensity_proportions);
    Screen('BlendFunction', wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    targetNames = ['1J'; '4H'; '6E'; '8A'];
    
    % Distractors
    im0 = imread('0.png');
    % Change background to transparent
    transparent = (im0 == 255); % White is considered to be background
    im0(:,:,2) = (~transparent) * 255;
    
    % Targets   
    targetImages = [];
    ambiguous_bars = [];    
    % Get values of ambiguous bar
    max_value = scr.background; % Background, max
    min_value = 0; % Black, min
    middle = (min_value + max_value)/2;
    intensity_values = [intensity_proportions * middle, max_value - flip(intensity_proportions * middle)];

    for idx = 1 : length(targetNames)
        im_temp = imread(strcat(targetNames(idx,:), '.png'));
        
        % Change background into transparent
        transparent = (im_temp == 255); % White is considered to be background
        im_temp(:,:,2) = ~transparent * 255;
        targetImages(idx,:,:,:) = im_temp;
        
        % Get ambiguous bars
        ambiguous_bars(idx,:,:) = uint8((targetImages(idx,:,:,1) == 1));
    end
           
    % Add ambiguity
    lower_targets = [];
    upper_targets = [];
    difficulty = Info.lvl;
    if floor(difficulty) == difficulty % If difficulty level is a simple integer
        intensity_value_high = intensity_values(difficulty); % For A, E, 5, 1
        intensity_value_low = intensity_values(nrDifficulties*2 - difficulty + 1); % For 8, 6, H, J
    else % If difficulty is not a simple integer, take intensity value in between
        value1 = intensity_values(floor(difficulty));
        value2 = intensity_values(ceil(difficulty)); % NOTE: this will fail if difficulty == 5.5, but that won't happen
        intensity_value_high = (value1 + value2)/2;
        
        value1 = intensity_values(floor(nrDifficulties*2 - difficulty + 1));
        value2 = intensity_values(ceil(nrDifficulties*2 - difficulty + 1)); 
        intensity_value_low = (value1 + value2)/2;
       
    end
    demos = zeros(1,4);
    for idx = 1:length(targetNames)
        im_temp = targetImages(idx,:,:,:);
        im_temp = squeeze(im_temp);
        im_temp(im_temp == 1) = 0;
        
        im_temp_low = im_temp;
        im_temp_low(:,:,1) = im_temp(:,:,1) + squeeze(ambiguous_bars(idx,:,:)) * floor(intensity_value_low);
        lower_targets(idx) = Screen('MakeTexture', wPtr, im_temp_low);
        
        im_temp_high = im_temp;
        im_temp_high(:,:,1) = im_temp(:,:,1) + squeeze(ambiguous_bars(idx,:,:)) * floor(intensity_value_high);
        upper_targets(idx) = Screen('MakeTexture', wPtr, im_temp_high);
        
        im_demo = [];
        space = 20; % Space between two targets in demo stimulus
        if ctl.mapping == 1 % letter left
            if ~isempty(strfind(targetNames(idx, :), 'E')) || ~isempty(strfind(targetNames(idx,:), 'A')) % letter is lower target
            	% Lower left
                demo(:,:,1) = [im_temp_low(:,:,1), zeros(size(im_temp, 1), space), im_temp_high(:,:,1)];
                demo(:,:,2) = [im_temp_low(:,:,2), zeros(size(im_temp, 1), space), im_temp_high(:,:,2)];
            else
                % Lower right
                demo(:,:,1) = [im_temp_high(:,:,1), zeros(size(im_temp, 1), space), im_temp_low(:,:,1)];
                demo(:,:,2) = [im_temp_high(:,:,2), zeros(size(im_temp, 1), space), im_temp_low(:,:,2)];
            end
        else
            if ~isempty(strfind(targetNames(idx, :), 'E')) || ~isempty(strfind(targetNames(idx,:), 'A')) % letter is lower target
            	% Lower right
                demo(:,:,1) = [im_temp_high(:,:,1), zeros(size(im_temp, 1), space), im_temp_low(:,:,1)];
                demo(:,:,2) = [im_temp_high(:,:,2), zeros(size(im_temp, 1), space), im_temp_low(:,:,2)];
            else
                % Lower left
                demo(:,:,1) = [im_temp_low(:,:,1), zeros(size(im_temp, 1), space), im_temp_high(:,:,1)];
                demo(:,:,2) = [im_temp_low(:,:,2), zeros(size(im_temp, 1), space), im_temp_high(:,:,2)];
            end
        end 
        demos(idx) = Screen('MakeTexture', wPtr, demo);
    end

    % Save textures    
    stim.textures.zero = Screen('MakeTexture', wPtr, im0);
    stim.textures.one = lower_targets(1);
    stim.textures.four = lower_targets(2);
    stim.textures.six = upper_targets(3);
    stim.textures.eight = upper_targets(4);
    stim.textures.j = upper_targets(1);
    stim.textures.h = upper_targets(2);
    stim.textures.e = lower_targets(3);
    stim.textures.a = lower_targets(4);
    stim.textures.demos = demos;
    
    
