function [parcel_pow,parcel_name] = h_source2parcel(source,index_file)

load(index_file);

source              = source .* 1;
parcel_pow          = [];

for nparcel = 1:length(index_name)
    parcel_pow      = [parcel_pow;source(index_vox(index_vox(:,2) == nparcel,1),:)];
end

parcel_name         = index_name;