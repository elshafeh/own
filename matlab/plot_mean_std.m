function plot_mean_std(v_mean,v_var,s_color)

% plot_mean_std(v_mean,v_var,s_color)
% v_mean : vector of mean values
% v_var : vector of variance values
% s_color : character string for plot color: 'r', 'b', 'g', 'r', 'c', 'm', 'y', 'k', 'w'  
% if (feature('OpenGLLoadStatus') ==0)
%     opengl software
% end
npts= length(v_mean);
set(gcf,'color','white')
plot(v_mean,s_color,'LineWidth',2);
hold on
X=[1:npts npts:-1:1];
Y =[ v_mean-sqrt(v_var) fliplr(v_mean+sqrt(v_var))];
h = fill(X,Y,s_color);
set(h,'FaceAlpha',0.3,'EdgeColor','w');
% hold off
