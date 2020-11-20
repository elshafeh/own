clear; clc; close all;

% plot([1 2 3 4],[5 6 7 8])
% ylim([1 1000]);
% axis tight manual
% ax = gca;
% ax.NextPlot = 'replaceChildren';
% 
% loops = 1000;
% F(loops) = struct('cdata',[],'colormap',[]);
% 
% for j = 1:loops
% 
%     plot([1 2 3 4],[5+j 6+j 7+j 8+j]);ylim([1 1000]);
%     drawnow
%     F(j) = getframe(gcf);
%     
% end
% 
% movie2avi(F,'myavifile.avi','Compression','Cinepak')

% Prepare the new file.
vidObj = VideoWriter('peaks.avi');
open(vidObj);

% Create an animation.
plot([1 2 3 4],[5 6 7 8])
ylim([1 500]);axis tight
set(gca,'nextplot','replacechildren');

for j = 1:500
    plot([1 2 3 4],[5+j 6+j 7+j 8+j]);ylim([1 500]);
    
    % Write each frame to the file.
    currFrame = getframe;
    writeVideo(vidObj,currFrame);
end

close(vidObj);