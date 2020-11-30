%glide detection threshold

clear all
close all

level = input('enter start level ');
step = 0.1;
score = [];
lng = 30;

% values needed to make wav files
srate=44100;
wdms = 10;
pitches = [];
num = 7;
for jc = 1:num
    add = 500 * 2^(jc/28);
    pitches = [pitches add];
end

X = imread('instr1.jpg','jpg');
scr = get(0,'ScreenSize');
%figure('outerposition',scr, 'toolbar', 'none', 'menubar', 'none', 'WindowButtonDownFcn',@mouseclick);
h=figure('outerposition',scr, 'toolbar', 'none', 'menubar', 'none');
hold on;
axis off;
set(gca,'YDir','reverse')
image(X);

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

ggap = 500/1000;

%LOOP DETAILS

%create random list for order of presenting the standard
cc = 1;
while cc ~= 1.5
    sd = rand(1,lng);
for w = 1:length(sd)
    if sd(w) <=0.5
        sd(w)=1; 
    else sd(w) = 2;
    end
end
cc = sum(sd)/length(sd);
end

level_all = [level];
dir_lg = [];

%start test
for vh = 1:lng
corres = sd(vh);
   
% make wav files
%decide on pitches
if level > 0
    freqE = level;
else freqE = 0;
end
dp = randperm(num);
ff= dp(1);
x1 = pitches(ff);

%decide whether to use up or down
sigdE = [];
if rand > 0.5
%glide up 
f1 = x1;
f2 = x1 * 2^(freqE/12);
fc=zeros(size(tg))+f1;
rampu=fc+ramp*(f2-f1)/max(ramp);
ft=cumsum(rampu*1/srate);
yy 	= sin(2*pi*ft);
yy = yy * 0.2/std(yy);
yy=wind(srate,20,yy);	
sigdE = [sigdE yy];	
else
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
end

%make pure tone sound
sequence = [];
ts = [0:1/srate:t3g];
x2 = x1 * 2^((freqE/2)/12);
sn = sin(2* pi* x2 * ts);
sn = sn * 0.2/std(sn);
sn=wind(srate,20,sn);	
snow = [sequence sn];

tgap = [0:1/srate:ggap];
gap = zeros(1,length(tgap));
    
%Read and play wav files   
if corres ==1
    vector = [sigdE gap snow];
elseif corres ==2
    vector = [snow gap sigdE];
end

vector = [vector', vector'];

pause (0.5)
sound(vector, 44100)
pause(0.5)

%ask for response
[x,y,button] = ginput(1);
if button == 1
    response = 1;
elseif button == 3
    response = 2;
end

%see if response correct or not
if response == 1 & corres == 1
    score = [score 1];
    df = 1;
    dir_lg = [dir_lg 1];
elseif response == 1 & corres ==2
    score = [];
    df = 2;
    dir_lg = [dir_lg -1];
elseif response == 2 & corres ==1
    score = [];
    df = 2;
    dir_lg = [dir_lg -1];
elseif response == 2 & corres ==2
    score = [score 1];
    df = 1;
    dir_lg = [dir_lg 1];
end

% adaptive tracking
f = length(score);
if df == 2 & f < 2
    level = level + step;
elseif df == 1 & f ==2
    level = level - step;
    score = [];
else level = level;
end

if level < 0
    level = 0;
end
    
%make matrix of levels
level_all = [level_all level];
end


%present results
level = level
level_all

close Figure 1

plot(level_all)

save glide_det_r2 level_all
