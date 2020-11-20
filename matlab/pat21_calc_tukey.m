function new_data = calc_tukey(data)

data = sort(data);

res     = quantile(data,3) ;
q1      = res(1);
q3      = res(3);

clear res ;

iqr         = q3-q1;
iqr_mult    = iqr * 1.5 ;

up_lim = iqr_mult + q3;
lw_lim = q1 - iqr_mult;

new_data = data ;
new_data(new_data > up_lim) = [];
new_data(new_data < lw_lim) = [];

