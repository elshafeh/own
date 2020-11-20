function new_avg = h_transform_avg(avg,chan_index,chan_list)

if isfield(avg,'dof')
    avg                     = rmfield(avg,'dof');
end
if isfield(avg,'var')
    avg                   	= rmfield(avg,'var');
end

pow                         = [];

for nroi = 1:length(chan_list) 
    indx                    = chan_index{nroi};
    pow                     = [pow;mean(avg.avg(indx,:),1)];
end

new_avg                     = avg;
new_avg.avg                 = pow; clear pow;
new_avg.label               = chan_list;