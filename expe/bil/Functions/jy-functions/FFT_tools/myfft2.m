function Y = myfft2(img,x,y,k)
%Y = myfft2(img,x,y,k)
%
%Returns the fft of y in 'real' values of amplitudes, phases and dc.
%
%Inputs:
%   y        real-valued vector
%   t        time vector of size y (default is 1:length(y));
%
%Outputs:    Structure Y with fields:
%   dc       mean value of y
%   amp      vector of amplitudes (length ceil(length(t)/2))
%   ph       vector of phases (in degrees, cosine phase)
%   nPix       length of t (needed for myifft)
%
%SEE ALSO    myifft2 complex2real2 fft2 ifft2
%


%4/15/09     Written by G.M. Boynton at the University of Washington

if ~exist('k','var')
    k=1;
end
%Deal with defaults
if ~exist('x','var') | ~exist('y','var')
    [x,y] = meshgrid(1:size(img,1));
end
    

F =fft2(img,size(y,1)*k,size(y,2)*k);
Y = complex2real2(F,x,y);
