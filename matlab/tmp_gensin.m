clear;

figure;
hold on ;

fs              = 512; % Sampling frequency (samples per second)
dt              = 1/fs; % seconds per sample
StopTime        = 0.1; % seconds
t               = (0:dt:StopTime)'; % seconds
F               = 1; % Sine wave frequency (hertz)
data            = sin(2*pi*F*t);
plot(t,data)

nb_cyc          = 7;
%%For one cycle get time period
T = nb_cyc/F ;
% time step for one time period
tt              = 0:dt:T+dt ;
d               = sin(2*pi*F*tt) ;
plot(tt,d,'k','LineWidth',3) ;

for n = 0:7
    plot(n,0,'-s','MarkerSize',100,'MarkerEdgeColor','black','MarkerFaceColor',[0.8 0.8 0.8]);
end

ylim([-3 3]);
xlim([-1 nb_cyc+1]);