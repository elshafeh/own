function data_out = h_mask(data_in,dtype,val)

data_out = data_in ;

if strcmp(dtype,'pe')
    nw_data             = abs(data_in.avg);
    mask                = nw_data > val;
    data_out.avg  = data_in.avg .* mask;
elseif strcmp(dtype,'tf')
    nw_data             = abs(data_in.powspctrm);
    mask                = nw_data > val;
    data_out.powspctrm  = data_in.powspctrm .* mask;
end