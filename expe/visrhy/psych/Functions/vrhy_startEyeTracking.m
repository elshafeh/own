function vrhy_startEyeTracking( input_args )
    global Info wPtr

    if strcmp(Info.runtype,'block')
        Info.eyefolder          = ['EyeData' filesep  Info.name];
        mkdir(Info.eyefolder);
        
        Info.eyefile            = ['eye' Info.name];
        
        
        % = % Start Eyetracking
        [el,exitFlag]                               = rd_eyeLink('eyestart', wPtr, Info.eyefile);
        useEyetrack                                 = 0;
        if exitFlag, return; end

        % = % Calibrate eye tracker
        [cal,exitFlag]                              = rd_eyeLink('calibrate', wPtr, el);
        if exitFlag, return; end

        % = % Start recording
        rd_eyeLink('startrecording',wPtr, el);
        useEyetrack                                 = 1;
    end
end

