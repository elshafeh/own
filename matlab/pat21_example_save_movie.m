% Plot on surface ( if you want you can set the colorlimt to be the same
% in each frames so you will be able to see changes in the "amplitude" as
% well)

for tt = 1:length(sourceInt{tt})

    cfg                     = [];
    cfg.method              = 'surface';
    cfg.funparameter        = 'momint';
    cfg.funcolormap         = 'hot';
    ft_sourceplot(cfg, sourceInt{tt})
    drawnow
    Frames(tt) = getframe; % get the current frame and store it
end

% Show movie
figure
movie(Frames,1)


% Save movie (frames) in AVI format

writerObj = VideoWriter('Movie.avi'); % Name it.
writerObj.FrameRate = 60; % How many frames per second.
open(writerObj);

for tt=1:size(Frames,2)
    writeVideo(writerObj, Frames(tt));
end

hold off
close(writerObj); % Saves the movie.