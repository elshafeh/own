function [x,y,z] = find_in_3d(val,mtrx)

[x,y,z] = ind2sub(size(mtrx),find(mtrx == val));
