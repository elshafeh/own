function my_fixationpoint(P,fillcolor)

w           = P.window;
rect        = P.rect;
diameter    = P.fixationdiameter;

%% set dimension of circle
d1 = 0.6; % diameter of outer circle (degrees)

if diameter == 5
    d2 = 0.2; % diameter of inner circle (degrees)
else
    d2 = 0.1; % diameter of inner circle (degrees)
end
%% set colors
colorCross  = fillcolor;
colorOval   = fillcolor;
    
%get size of the screen
width = P.sz(1); % horizontal dimension of display (cm)
dist = P.vdist; % viewing distance (cm)

[cx, cy] = RectCenter(rect);
%cx = x;
%cy = y;

ppd = pi * (rect(3)-rect(1)) / atan(width/ dist/2) / 360; % pixel per degree

penWidth = d2 * ppd;
if penWidth >7
    penWidth = 6;
end

ade_DarkBackground(P);

Screen('FillOval', w, colorOval, [cx-d1/2 * ppd, cy-d1/2 * ppd, cx+d1/2 * ppd, cy+d1/2 * ppd], d1 * ppd);
Screen('DrawLine', w, colorCross, cx-d1/2 * ppd, cy, cx+d1/2 * ppd, cy, penWidth);  %Screen('DrawLine', windowPtr [,color], fromH, fromV, toH, toV [,penWidth]);
Screen('DrawLine', w, colorCross, cx, cy-d1/2 * ppd, cx, cy+d1/2 * ppd, penWidth);
Screen('FillOval', w, colorOval, [cx-d2/2 * ppd, cy-d2/2 * ppd, cx+d2/2 * ppd, cy+d2/2 * ppd], d2 * ppd);
