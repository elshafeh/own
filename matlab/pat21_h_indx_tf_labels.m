function x = h_indx_tf_labels(y)

% go back and forth from channel labels to their index and vice versa

cfg         = [];cfg.method  = 'template';
cfg.layout  = 'CTF275.lay';neighbours  = ft_prepare_neighbours(cfg);

if isnumeric(y)
   x = {neighbours(y).label};
else
    for n = 1:length(y)
        x(n) = find(strcmp({neighbours.label},y{n}));
    end
end