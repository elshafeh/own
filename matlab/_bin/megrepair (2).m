function data = megrepair(data)
% repair missing chans based on interp of neighbours
% this is needed so that grandavg has some channels remaining..
%
% copyright (c) sashae 2016

% data needs to be double for interp function to work
for i=1:length(data.trial)
  data.trial{i} = double(data.trial{i});
end

% list missing chans
chanmiss = setdiff(data.grad.label,data.label); % note: this also includes the magnetometers (these end in 1; planar are 2+3)
rm=[];
for i=1:length(chanmiss)
  if ~ismember(str2num(chanmiss{i}(end)),[2 3])
    rm = [rm i];
  end
end
chanmiss(rm)=[];

% get neighbours based on template layout
cfg=[];
cfg.method = 'template';
cfg.layout = 'neuromag306planar.lay'; % loads the correct template automatically :)
nb = ft_prepare_neighbours(cfg);

% now repair using all those ingredients
cfg=[];
cfg.neighbours     = nb;
cfg.layout         = 'neuromag306planar.lay';
cfg.missingchannel = chanmiss;
data = ft_channelrepair(cfg, data);

% sometimes all neighbours are missing, loop again to now fix these based on
% fixed neighbours.. probs not ideal but well..
if length(data.label)<204
  data = megrepair(data);
end

% fix grad
data.grad.chanori = nan(length(data.grad.label),3); % just need this field to exist for combineplanar to work later on..

% back to single
for i=1:length(data.trial)
  data.trial{i} = single(data.trial{i});
end
