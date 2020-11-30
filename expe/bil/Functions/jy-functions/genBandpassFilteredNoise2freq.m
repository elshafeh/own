function output = genBandpassFilteredNoise2freq(cfg)
% Generates bandpass-filtered noisy patches w/ uniform orientation info.
% To run the code, add folder "FFT_tools" to path.
%
% OUTPUT.CFG of the function is just a copy of the cfg used.
% OUTPUT.IMG of the function can be the ifft representation (with contrast
% modulation) of the patch (i.e., when cfg.gauss_mask = 0, default), or the
% ready-to-use version of it (i.e., when cfg.gauss_mask = 1).
%
%
%
% Example parameters:
%
% cfg.sizedeg     = 10; %size in degrees
% cfg.sizepix     = 445; %size in pixels
%
% cfg.freq1_sd    = 0.5; %width of the frequency kernel in cycles/deg
% cfg.freq1_mean  = 2; %mean of the frequency kernel in cycles/deg
%
% cfg.freq2_sd    = 0.5; %width of the frequency kernel in cycles/deg
% cfg.freq2_mean  = 5; %mean of the frequency kernel in cycles/deg
%
% cfg.patchlum    = 0.5; % background luminance of the patch
% cfg.patchcon    = 0.8;  % Michelson contrast = (I_max-I_min)/(I_max + I_min)
%
% cfg.gauss_mask  = 0; %apply gaussian mask (1) or not (0, default)
% cfg.gauss_sd    = 25; %standard deviation of the Gaussian kernel in pixels
%
% JY (25-04-2019)


% examine the input
if ~all(isfield(cfg,{'sizedeg','sizepix','freq1_sd','freq1_mean','freq2_sd','freq2_mean'}))
    error('genBandpassFilteredNoise2freq: incomplete cfg structure!');
end
if ~isfield(cfg,'patchlum')| isempty(cfg.patchlum)
    cfg.patchlum = 0.5;
end
if ~isfield(cfg,'patchcon') | isempty(cfg.patchcon)
    cfg.patchcon = 0.5;
end
if ~isfield(cfg,'gauss_mask') | isempty(cfg.gauss_mask)
    cfg.gauss_mask = 0;
end
if ~isfield(cfg,'gauss_sd') | isempty(cfg.gauss_sd)
    cfg.gauss_sd = cfg.sizepix ./ 8;
end


% get size of the patch
wDeg = cfg.sizedeg; %1;  %size of image (in degrees)
nPix = cfg.sizepix; %200;  %resolution of image (pixels);

% make meshgrids
[x,y] = meshgrid(linspace(-wDeg/2,wDeg/2,nPix+1));
x = x(1:end-1,1:end-1);
y = y(1:end-1,1:end-1);


% control for randomness via a selection loop
meet_standard = 0;

while meet_standard~=1
    
    % generate a noisy patch
    noise = randn(nPix);
    
    % 2D-FFT of the noisy patch
    k = 4; %default by G. Boynton
    F = myfft2(noise,x,y,k);
    
    % define the frequency kernel for frequency 1
    sigma1      = cfg.freq1_sd; 
    centerFreq1 = cfg.freq1_mean; 
    Gaussian1   = exp(-(F.sf-centerFreq1).^2/sigma1^2); %Gaussian kernel
    
    % define the frequency kernel for frequency 2
    sigma2      = cfg.freq2_sd; 
    centerFreq2 = cfg.freq2_mean; 
    Gaussian2   = exp(-(F.sf-centerFreq2).^2/sigma2^2); %Gaussian kernel
    
    % the frequency kernel with 2 freqs of interests
    Gaussian  = Gaussian1 + Gaussian2;
    
    % apply the selection in the Fourier domain
    F.amp = F.amp.*Gaussian; 
    
    % debug:
    %{ 
    figure(222), clf, hold on,
    set(gcf,'position', get(0,'screensize'));
    subplot(2,3,1), hold on,
    title('orientation');
    imagesc(mod(270-F.angle,180)); %match the JY's labeling of orientations
    axis tight; axis square; colormap('gray'); caxis([0, 180]); colorbar;
    
    subplot(2,3,2), hold on,
    title('SF');
    imagesc(F.sf);
    axis tight; axis square; colormap('gray'); colorbar;
    
    subplot(2,3,3), hold on,
    title('Filtered Fourier Spectrum: Amplitude');
    imagesc(F.amp);
    axis tight; axis square; colormap('gray'); colorbar;
    %}
    
    % ifft to get back to the image domain
    im_raw = myifft2(F);
    
    % % % % scale all pixels to [-0.5, 0.5]
    % % % im_raw = ( im_raw - min(im_raw(:)) ) ./ (range(im_raw(:))) - 0.5; 
    
    % normalize pixel intensities to be within [-0.5, 0.5]
    im_raw = im_raw ./ (max( abs([ max(im_raw(:)), min(im_raw(:)) ]) )) * 0.5;
    
    % check if the stimuli meet my standard
    if range(im_raw(:)) > 0.95, meet_standard = 1; break; end
    
end

% when user indicates to apply Gaussian mask
if cfg.gauss_mask == 1
    
    % 2D-Gaussian mask
    sd    = cfg.gauss_sd;
    [x,y] = meshgrid([1:cfg.sizepix]-(cfg.sizepix+1)/2);
    r     = sqrt(x.^2+y.^2); % radius
    m     = normpdf(r,0,sd)./ normpdf(0,0,sd);
    
    % apply Gaussian mask
    im  = im_raw .* m;
    
else
    
    im = im_raw;
    
end

% apply contrast modulation
im = im .* cfg.patchcon;

% normalize the patch so that it's symmetrical around cfg.patchlum
im = im + cfg.patchlum;

% output
output.img = im;
output.cfg = cfg;

end

