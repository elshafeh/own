wDeg = 1;  %size of image (in degrees)
nPix = 200;  %resolution of image (pixels);

[x,y] = meshgrid(linspace(-wDeg/2,wDeg/2,nPix+1));
x = x(1:end-1,1:end-1);
y = y(1:end-1,1:end-1);

noise = randn(nPix);

%% Low-Pass filtering
%
% We can low-pass an image by multiplying the amplitudes in the frequency
% domain by a Gaussian centered at zero frequency.  Just like for the fft,
% the output of fft2 has complex numbers that are scaled in a funny way.
% I've provided a function 'myfft2' that returns a structure containing the
% amplitudes and phases for each frequency in the image.  'myifft2' takes
% the inverse fft (using matlab's 'ifft2') to get the filtered image back.

k = 1;
F = myfft2(noise,x,y,k);

% multiply the amplitudes by a Gaussian:
sigma    = 10;  %c/deg
Gaussian = exp(-F.sf.^2/sigma^2);
F.amp    = F.amp.*Gaussian;

lowPassImg = myifft2(F);

plotFFT2(lowPassImg,x,y,k,20);


%% Band-Pass filtering
% Band-Pass filtering is similar, but using a Gaussian 'envelope' that is
% centered at some nonzero spatial frequency:

k=4;  
F = myfft2(noise,x,y,k);
sigma = .5;  %c/deg
centerFreq = 5; %c/deg
Gaussian = exp(-(F.sf-centerFreq).^2/sigma^2);
F.amp = F.amp.*Gaussian;

lowPassImg = myifft2(F);

plotFFT2(lowPassImg,x,y,k,10);


%% Orientation filtering
% Orientation filtering can be done by multiplying the amplitudes by a
% window in the angle dimension.  A good way to do this is with the 'Von
% Mises' function that deals with the circularity of the angle dimension:

k=4;
F = myfft2(noise,x,y,k);
sigmaAng  = 20;  %deg
centerAng = 90; %c/deg

%vonMises function
VonMises = exp(-sigmaAng*cos(pi*(2*(F.angle-centerAng))/180));
F.amp = F.amp.*VonMises;

angleImg = myifft2(F);

plotFFT2(angleImg,x,y,k);


%% Band-Pass + Orientation filtering

k=4;  
F = myfft2(noise,x,y,k);
sigma = 2;  %c/deg
centerFreq = 10; %c/deg
Gaussian = exp(-(F.sf-centerFreq).^2/sigma^2);

sigmaAng  = 50;  %kappa, in deg
centerAng = 0;    %deg
VonMises = exp(-sigmaAng*cos(pi*(2*(F.angle-centerAng))/180));

F.amp = F.amp .* Gaussian .* VonMises;

lowPassAngImg = myifft2(F);

imshow(lowPassAngImg, []);

plotFFT2(lowPassAngImg,x,y,k,10);



