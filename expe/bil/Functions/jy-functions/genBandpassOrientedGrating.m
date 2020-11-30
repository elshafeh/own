function output = genBandpassOrientedGrating(cfg)
% This function generates orientated grating with bandpass-filtered noise. 
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
% cfg.sizedeg = 1; %size in degrees
% cfg.sizepix = 200; %size in pixels
% 
% cfg.freq_sd   = 2; %width of the frequency kernel in cycles/deg
% cfg.freq_mean = 10; %mean of the frequency kernel in cycles/deg
% 
% cfg.ori_kappa = 50; %kappa of the Von Mises orientation kernel -->
% introduce orientation bandwitdh noise ; make it smaller to blur it out a
% bit

% cfg.ori_mean  = 0;  %mean of the Von Mises orientation kernel
% 
% cfg.patchlum = 0.5; %background luminance of the patch
% cfg.patchcon = 0.5;  %Michelson contrast = (I_max-I_min)/(I_max + I_min)
%
% cfg.gauss_mask= 0; %apply gaussian mask (1) or not (0, default)
% cfg.gauss_sd  = 25; %standard deviation of the Gaussian kernel in pixels
% 
% JY (Feb, 2019)


% examine the input
if ~all(isfield(cfg,{'sizedeg','sizepix','freq_sd','freq_mean','ori_kappa','ori_mean'}))
    error('make_gabor: incomplete cfg structure!');
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

% generate a noisy patch
noise = randn(nPix);
% noise = rand(nPix); %noise = randn(nPix);

% 2D-FFT of the noisy patch
k = 4; %default by G. Boynton 
F = myfft2(noise,x,y,k);

% define the frequency kernel
sigma      = cfg.freq_sd; %2;  %c/deg
centerFreq = cfg.freq_mean; %10; %c/deg
Gaussian   = exp(-(F.sf-centerFreq).^2/sigma^2); %Gaussian kernel

% define the orientation kernel
sigmaAng  = cfg.ori_kappa;  %concentration parameter
centerAng = mod(270-cfg.ori_mean, 180);   %match the JY's labeling of orientations
VonMises  = exp( sigmaAng*cos(2 * (F.angle-centerAng)*pi/180) );

% apply the selection in the Fourier domain
F.amp = F.amp.*Gaussian.*VonMises; %for orientation debug: F.amp = F.amp .* VonMises;

% ifft to get back to the image domain
im_raw = myifft2(F);

% scale all pixels to [-0.5, 0.5]
im_raw = ( im_raw - min(im_raw(:)) ) ./ (range(im_raw(:))) - 0.5;

% apply contrast modulation 
im = im_raw .* cfg.patchcon;

% when user indicates to apply Gaussian mask
if cfg.gauss_mask
    
    % 2D-Gaussian mask
    sd    = cfg.gauss_sd;
    [x,y] = meshgrid([1:cfg.sizepix]-(cfg.sizepix+1)/2);
    r     = sqrt(x.^2+y.^2); % radius
    m     = normpdf(r,0,sd)./ normpdf(0,0,sd);
    
    % apply Gaussian mask
    im  = im .* m + cfg.patchlum;
    
else
    
    im = im + cfg.patchlum;
    
    
end


% output
output.img = im;
output.cfg = cfg;


% % ========= OLD =============
% % normalize the image to be in [0,1]
% im = im_raw - min(im_raw(:));
% im = im ./ max(im(:));
% 
% % apply Michelson contrast modulation to the image
% michelson_contrast  = cfg.patchcon;
% mean_grey_value     = cfg.patchlum;
% im = im .* michelson_contrast + mean_grey_value;
% % =============================

% surf(im);

end