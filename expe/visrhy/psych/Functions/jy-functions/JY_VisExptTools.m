function output = JY_VisExptTools(fun_name, cfg)
% To make programming a visual psychophysics experiment easier.
% Joey 

switch fun_name
    
    case 'deg2Pixel' %transforms the specified dva into pixels
        
        % cfg.rect    : rect of the monitor, output of "OpenScreen".
        % cfg.size    : size of the monitor in cm (these values can either be along a single dimension or for both the width and height)
        % cfg.viewDist: viewing distance in cm.
        % cfg.degrees : number of degrees to be transformed
        
        screenRes = cfg.rect(3:4);
        pixInCm   = cfg.size ./ screenRes; %calculates the size of a pixel in cm
        degPerPix = ( 2*atan(pixInCm./(2* cfg.viewDist)) ).*(180/pi);
        pixPerDeg = 1 ./degPerPix;
        
        pixels = pixPerDeg.* cfg.degrees;
        output = pixels; return;
        
        
    case 'ComputeGammaTable'
        
        % cfg.calib_file
        
        load(cfg.calib_file,'gamInverse','dacsize');
        
        
        mean_lum = 0.5;
        contrast = 1; % Max contrast, creates the colour lookup table; this is not the value used in the actual exp
        amp      = mean_lum*contrast;
        
        num_colors = 255;	% number of gray levels to use in mpcmaplist, should be uneven
        mpc_map_list = zeros(256,3);	% color look-up table of 256 RGB values, RANGE 0-1
        
        % make grayscale gradient
        temp_trial = linspace(mean_lum-amp,mean_lum+amp,num_colors)';
        
        % Get background, black and white index
        bgd_color_idx = find(temp_trial==.5) -1;	% idx of background colour in mpcmaplist, subtract 1 for range 0-255
        black_idx = find(temp_trial==0) -1;
        white_idx = find(temp_trial==1) -1;
        
        mpc_map_list(1:num_colors,:) = repmat(temp_trial, [1 3]);
        mpc_map_list(256,1:3) = 1;
        
        
        % % mpc_map_list = round(map2map(mpc_map_list,gamInverse));
        % % output = mpc_map_list;
        
        gPrecision = size(gamInverse, 1);
        tmp = round( (gPrecision-1)*mpc_map_list + 1 );
        r = tmp(:,1);
        g = tmp(:,2);
        b = tmp(:,3);
        out_map(:,1) = gamInverse(r,1);
        out_map(:,2) = gamInverse(g,2);
        out_map(:,3) = gamInverse(b,3);
        output = out_map;
        
        
    case 'draw_fixation' %draws a fixation that can be easily flipped onto screen
        
        % cfg.size : size in pix
        % cfg.type : can be "cross", "dot" or "bulleye"
        % cfg.color: indicated with RGB values 
        
        global wPtr scr
        
        if ~all(isfield(cfg, {'size', 'type'}))
            error('draw_fixation: incomplete cfg structure!');
        end
        if ~isfield(cfg, 'color')
            cfg.color = [0 0 0];
        end
        
        switch cfg.type
            case 'cross'
                
                fixCrossDimPix = cfg.size ./ 2; %length of each arm
                lineWidthPix   = 2; %the line width for our fixation cross
                xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
                yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
                
                Screen('DrawLines', wPtr, [xCoords; yCoords], ...
                    lineWidthPix, cfg.color, [scr.xCtr, scr.yCtr], 2);
                
            case 'dot'
                rect = CenterRectOnPoint([0 0 cfg.size cfg.size], scr.xCtr, scr.yCtr);
                Screen('FrameOval', wPtr, cfg.color, rect, cfg.size, 2);
                
            case 'bulleye'
                
                Screen('DrawDots', wPtr, [scr.xCtr,scr.yCtr], cfg.size, scr.black, [],[]);
                Screen('DrawDots', wPtr, [scr.xCtr,scr.yCtr], cfg.size*0.65, scr.white, [],[]);
                Screen('DrawDots', wPtr, [scr.xCtr,scr.yCtr], cfg.size*0.5, cfg.color, [],[]);
                
            case 'hesham_eye'
                
                Screen('DrawDots', wPtr, [scr.xCtr,scr.yCtr], cfg.size, scr.gray, [],[]); % outer
                Screen('DrawDots', wPtr, [scr.xCtr,scr.yCtr], cfg.size*0.95, cfg.color, [],[]); % fill/middle
                Screen('DrawDots', wPtr, [scr.xCtr,scr.yCtr], cfg.size*0.3, scr.gray, [],[]); % inner
                
                %                 Screen('DrawDots', wPtr, [scr.xCtr,scr.yCtr], cfg.size, scr.gray, [],[]);
                %                 Screen('DrawDots', wPtr, [scr.xCtr,scr.yCtr], cfg.size*0.95, cfg.color, [],[]);
                
        end
        
        output = NaN; return;
        
    case 'make_smooth_donut_mask'
        
        % cfg.innerR: inner radius (in degrees) of the mask;
        % cfg.outerR: outer radius (in degrees) of the mask;
        % cfg.maskSiz: size of the mask in pixels;
        % cfg.degSmoo: size of the edge (in degrees) to smooth
        
        global scr
        
        patchsiz = cfg.maskSiz;
        skirt    = cfg.degSmoo;
        innerR   = cfg.innerR;
        outerR   = cfg.outerR;
        ppd      = scr.ppdX;
        
        [X,Y] = meshgrid([-patchsiz/2:patchsiz/2]);
        r = sqrt(X.^2 + Y.^2);
        
        Y1 = scr.white - (scr.white./ (skirt*ppd)) .* (r-innerR*ppd);
        Y1((r<=innerR*ppd)|(r>=(innerR+skirt)*ppd)) = 0;
        
        Y2 = scr.black + (scr.white./(skirt*ppd)) .* (r-(outerR-skirt)*ppd);
        Y2((r<=(outerR-skirt)*ppd)|(r>=outerR*ppd)) = 0;
        
        Y3 = repmat( scr.white, size(r));
        Y3((r>innerR*ppd) & (r<outerR*ppd)) = 0;
        
        output = Y1+Y2+Y3;
        
        % imshow(output,[]);
        
        
        
    case 'make_gabor' %generates a matrix of a Gabor image
        
        % cfg.patchsiz: patch size (pix)
        % cfg.patchenv: patch spatial envelope (s.d. of the Gaussian kernal in pix)
        % cfg.patchlum: patch background luminance
        % cfg.gaborper: Gabor period (pix/cycle)
        % cfg.gaborang: Gabor angle (degree)
        % cfg.gaborphi: Gabor unit phase
        % cfg.gaborcon: Gabor Michelson contrast
        % REF: Valentin Wyart
        
        if ~all(isfield(cfg,{'patchsiz','patchenv','gaborper','gaborang','gaborcon'}))
            error('make_gabor: incomplete cfg structure!');
        end
        if ~isfield(cfg,'patchlum')| isempty(cfg.gaborlum) 
            % set medium gray as background luminance
            cfg.patchlum = 0.5;
        end
        if ~isfield(cfg,'gaborphi') | isempty(cfg.gaborphi)
            % set random phase to Gabor pattern
            cfg.gaborphi = rand;
        end
        
        % define image coordinates
        [x,y] = meshgrid([1:cfg.patchsiz]-(cfg.patchsiz+1)/2);
        r = sqrt(x.^2+y.^2); % radius
        t = -atan2(y,x); % angle
        
        % make Gabor patch
        a = cfg.gaborang./180*pi;
        u = sin(a)*x + cos(a)*y;
        gaborimg = 0.5*cos(2*pi*(u/cfg.gaborper + cfg.gaborphi));
        gaborimg = gaborimg * cfg.gaborcon;
        patchimg = gaborimg.* normpdf(r,0,cfg.patchenv)/normpdf(0,0,cfg.patchenv);
        patchimg = patchimg + cfg.patchlum;
        
        output.img = patchimg; 
        output.cfg = cfg;
        return;
        
    case 'make_grating' %generate a matrix of grating (gabor without gaussian kernel)
        
        if ~all(isfield(cfg,{'patchsiz','gaborper','gaborang','gaborcon'}))
            error('make_gabor: incomplete cfg structure!');
        end
        if ~isfield(cfg,'patchlum')| isempty(cfg.gaborlum)
            % set medium gray as background luminance
            cfg.patchlum = 0.5;
        end
        if ~isfield(cfg,'gaborphi') | isempty(cfg.gaborphi)
            % set random phase to Gabor pattern
            cfg.gaborphi = rand;
        end
        
        % define image coordinates
        [x,y] = meshgrid([1:cfg.patchsiz]-(cfg.patchsiz+1)/2);
        % r = sqrt(x.^2+y.^2); % radius
        t = -atan2(y,x); % angle
        
        % make grating patch with smooth edge
        a = cfg.gaborang./180*pi;
        u = sin(a)*x + cos(a)*y;
        gaborimg = 0.5*cos(2*pi*(u/cfg.gaborper + cfg.gaborphi));
        gaborimg = gaborimg * cfg.gaborcon;
        patchimg = gaborimg.* 1; %normpdf(r,0,cfg.patchenv)/normpdf(0,0,cfg.patchenv);
        patchimg = patchimg + cfg.patchlum;
        
        output.img = patchimg;
        output.cfg = cfg;
        return;
    
    case 'get_keyboard_response'
        
        % cfg.timestop: time to stop checking keyboard presses
        % cfg.answer  : key of the correct response
        
        global ctl
        
        output.respCheck = 0;
        output.respKey   = nan;
        output.respTime  = nan;
        if ~isfield(cfg,'answer')| isempty(cfg.answer)
            output.answer = cfg.answer;
        end
        while (GetSecs < cfg.timestop)
            [KeyIsDown, tKeyPress, KeyCode] = KbCheck(ctl.DeviceNum);
            
            % check what's being pressed
            if KeyIsDown
                key = find(KeyCode);
                key = key(1);
                
                % check if it is one of the valid keys
                if ismember(key, ctl.keyValid)
                    output.respKey   = key;
                    output.respTime  = tKeyPress;
                    output.respCheck = 1;
                    
                    % check if the experimenter pressed to abort experiment
                    if key == ctl.keyQuit, sca; warning('Expt aborted by user!'); end
                    
                end
            end
        end
        
        if numel(output.respKey) == 1
            output.correct = find(output.respKey == cfg.answer);
        else
            output.correct = find(output.respKey(1) == cfg.answer);
        end
        
        if isempty(output.correct), output.correct = 0; end
        
        
        return;
        
    case 'compute_ori_diff' %compute the difference between 2 orientations
        
        % cfg.compOri: comparison orientation (in degrees)
        % cfg.refOri : reference orientaton (in degrees)
        % NOTE: horizontal = 0; vertical = 90, 1 o'clock = 60 (in degrees).
        % NOTE: if ccw rotate horizontal grating, it goes from 0 to 360. 
        % REF: "circ_dist" function from CircStat2012a toolbox
        
        s = cfg.refOri ./ 180 * pi;
        c = cfg.compOri ./180 * pi;
        output = angle(exp(1i* s * 2)./exp(1i* c * 2))./2;
        output = output ./ pi * 180;
        
        % if output < 0, then the compOri is CCW relative to the stdOri.
        % if output > 0, then the compOri is CW relative to the stdOri.
        
        
    case 'auditory_feedback' %play auditory feedback
        
        % cfg.correct: 1 (correct) or 0 (incorrect)
        % cfg.posFreq: sound frequency for positive feedback (default=800)
        % cfg.negFreq: sound frequency for positive feedback (default=200)
        % cfg.timedur: sound duration (default=80ms)
        
        if ~isfield(cfg,'correct')
            error('auditory_feedback: incomplete cfg structrue!');
        else
            if all(~isfield(cfg,{'posFreq','negFreq','timedur'}))
                cfg.posFreq = 800;
                cfg.negFreq = 300;
                cfg.timedur = 0.1;
            end
        end
        
        fs = 8192; %sample freq (= 2^13) in Hz
        t  = 0:1/fs:cfg.timedur;
        if cfg.correct
            w = cfg.posFreq; 
        else
            w = cfg.negFreq; 
        end
        wave = sin(2*pi*w*t);
        
        %play sound
        sound(wave, fs); return;
        
    otherwise
        
        warning('Please check the fun_name given to JY_VisExptTools!');
        
        output = NaN;
            
end

end