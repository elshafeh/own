function new_data = PrepAtt22_calc_tukey(data)

% excluded values are marked with 2 while non-excluded values are markes
% with 1

data(:,2)   = 1;

res         = quantile(data(:,1),3) ;
q1          = res(1);
q3          = res(3);

clear res ;

iqr         = q3-q1;
iqr_mult    = iqr * 1.5 ;

up_lim      = iqr_mult + q3;
lw_lim      = q1 - iqr_mult;

new_data = data ;
new_data(new_data(:,1) > up_lim,2) = 2;
new_data(new_data(:,1) < lw_lim,2) = 2;

