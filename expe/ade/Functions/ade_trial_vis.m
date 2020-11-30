function targ = ade_trial_vis(P,targSid_thistrial,targOri_trial,noisecontrast,TargetCode)
% Present gabor patch only without capturing any RESPONSE %

global adeBitsi

targOri_trial   = P.VistargOri(targOri_trial);

x               = meshgrid(-P.VisgratingSizePix:P.VisgratingSizePix, -P.VisgratingSizePix:P.VisgratingSizePix);
grating         = P.Grey + P.Viscontrast*P.inc*cos(P.Visfr*x);

[x,y]           = meshgrid(-P.VisgratingSizePix:P.VisgratingSizePix, -P.VisgratingSizePix:P.VisgratingSizePix); %Create circular aperture for the alpha-channel
circle          = P.White * (x.^2 + y.^2 <= (P.VisgratingSizePix)^2);

grating(:,:,2)  = 0; % Set 2nd channel (the alpha channel) of 'grating' to the aperture defined in 'circle'
grating(1:2*P.VisgratingSizePix+1, 1:2*P.VisgratingSizePix+1, 2)    = circle;

noise           = P.Grey+P.inc*noisecontrast(1)*((rand(size(grating,1),size(grating,2)).*2)-1); %make noise texture for this trial
noise(:,:,2)    = 0; %define arpeture for noise nexture
noise(1:2*P.VisgratingSizePix+1, 1:2*P.VisgratingSizePix+1, 2) = circle;

targ            = mean(cat(4,grating,noise),4); % average noise and signal
targtex         = Screen('MakeTexture', P.window, targ, [], [], [], [], P.glsl); %make grating texture with noise

my_fixationpoint(P,P.Black);
vbl             = Screen('Flip', P.window); % Flip to sync us to the vertical retrace draw trigger to buffer

% P.Eccentricity  = P.Eccentricity100;
gabor_pos(1,:)  = CenterRectOnPoint([P.srcRect], P.CenterX-P.Eccentricity, P.CenterY); %#ok<*AGROW>
gabor_pos(2,:)  = CenterRectOnPoint([P.srcRect], P.CenterX+P.Eccentricity, P.CenterY); %#ok<*AGROW>

%start target presentation

for frame = 1:P.VistargTimeFrames
    
    if frame ==1
        P.bitsi.sendTrigger(TargetCode);
    end
    
    my_fixationpoint(P,P.Black);
    Screen('DrawTexture', P.window, targtex, P.srcRect, gabor_pos(targSid_thistrial,:), targOri_trial); %draw grating texture
    vbl   = Screen('Flip', P.window, vbl + (P.Viswaitframes - 0.5) * P.ifi); % Flip to the screen
    
end

my_fixationpoint(P,P.Black); % this is meant to ensure that fixation point stays there!
Screen('Flip', P.window); % % Flip to the screen % %, vbl + (P.Viswaitframes - 0.5) * ifi);