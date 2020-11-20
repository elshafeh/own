function [indx_out] = h_findval(axis_in,val_in,nround)

indx_out = [];

for i = 1:length(val_in)
    indx_out(i)  = find(round(axis_in,nround) == round(val_in(i),nround));
    if isempty(indx_out(i)) || length(indx_out(i))>1
        error('problem finding indices');
    end
end

fprintf('indices correspond to \n');
fprintf('%.2f\n',axis_in(indx_out));
    