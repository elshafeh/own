%glide detection threshold

clear all
close all

step = 0.1;

% values needed to make wav files
srate=44100;
wdms = 10;
pitches = 500 * 2^(1/28);

% glide parameters
glide = 300;
durA = 100;
durB = 100;
freqE = 3;
glide = glide/1000;
durA = durA/1000;
durB = durB/1000;
t1g= durA;
t2g= glide+durA;
t3g= durA + glide + durB;
tg=[1/srate:1/srate:t3g];
ramp=zeros(size(tg));
ramp(floor(t1g*srate):floor(t2g*srate))= 1;
ramp=cumsum(ramp);   
x1 = pitches;  

for freqE = 0:0.1:18
siguE = [];
sigdE = [];
%glide up 
f1 = x1;
f2 = x1 * 2^(freqE/12);
fc=zeros(size(tg))+f1;
rampu=fc+ramp*(f2-f1)/max(ramp);
ft=cumsum(rampu*1/srate);
yy 	= sin(2*pi*ft);
yy = yy * 0.2/std(yy);
yy=wind(srate,20,yy);	
siguE = [siguE yy];	
%glide down 
f1 = x1 * 2^(freqE/12);
f2 = x1;
fc=zeros(size(tg))+f1;
rampu=fc+ramp*(f2-f1)/max(ramp);
ft=cumsum(rampu*1/srate);
yy 	= sin(2*pi*ft);
yy = yy * 0.2/std(yy);
yy=wind(srate,20,yy);	
sigdE = [sigdE yy];

%wavwrite
tip = freqE*10;
siguE = [siguE', siguE'];
wavwrite(siguE, srate, ['A_' num2str(tip) '_up']);
sigdE = [sigdE', sigdE'];
wavwrite(sigdE, srate, ['A_' num2str(tip) '_dn']);

end