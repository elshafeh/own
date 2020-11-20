function res = h_relchange(data1,data2,param)

% calculates relative change between two data structures;

cfg             = [] ;
cfg.parameter   = param ;
cfg.operation   = '((x1-x2)./x2)';
res             = ft_math(cfg,data1,data2);
