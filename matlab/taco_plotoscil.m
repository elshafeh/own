clear; close all;


N   = 4000;
phi = pi/4;
A   = 1;
B   = 1;
t0  = -2;
tf  = 6;
t   =  t0:(tf-t0)/(N-1):tf;
w   = pi;
x   = A*cos(w*t+phi);
y   = B*cos(2*w*t-phi);
subplot(4,2,1:2)
plot(t,x,'linewidth',4,'color','b')
xticks([]);
yticks([]);