%glide detection threshold

clear all
close all

step = 0.1;

% values needed to make wav files
srate=44100;
wdms = 10;
pitches = 500 * 2^(1/28);

% glide parameters
glide = 150;
durA = 100;
freqE = 3;
glide = glide/1000;
durA = durA/1000;

t= [1/srate:1/srate:durA];
tgap=[1/srate:1/srate:glide];
gap = zeros(1,length(tgap));

x1 = pitches;  

for freqE = 0:0.1:18
siguE = [];
sigdE = [];

%pitch change up 
f1 = x1;
s1 = sin(2*pi*f1*t);
s1 = s1 * 0.2/std(s1);
s1=wind(srate,10,s1);

f2 = x1 * 2^(freqE/12);
s2 = sin(2*pi*f2*t);
s2 = s2 * 0.2/std(s2);
s2=wind(srate,10,s2);
	
siguE = [siguE s1 gap s2];	

%pitch change down 	
sigdE = [sigdE s2 gap s1];

%wavwrite
tip = freqE*10;
siguE = [siguE', siguE'];
wavwrite(siguE, srate, ['A_' num2str(tip) '_up']);
sigdE = [sigdE', sigdE'];
wavwrite(sigdE, srate, ['A_' num2str(tip) '_dn']);

end