function [x, y, z] = h_voxelcoords(dim, transform)

xgrid     = 1:dim(1);
ygrid     = 1:dim(2);
zgrid     = 1:dim(3);
npix      = prod(dim(1:2));  % number of voxels in a single slice

x = zeros(dim);
y = zeros(dim);
z = zeros(dim);
X = zeros(1,npix);
Y = zeros(1,npix);
Z = zeros(1,npix);
E = ones(1,npix);
% determine the voxel locations per slice
for i=1:dim(3)
    [X(:), Y(:), Z(:)] = ndgrid(xgrid, ygrid, zgrid(i));
    tmp = transform*[X; Y; Z; E];
    x((1:npix)+(i-1)*npix) = tmp(1,:);
    y((1:npix)+(i-1)*npix) = tmp(2,:);
    z((1:npix)+(i-1)*npix) = tmp(3,:);
end