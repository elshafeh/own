function [index_good,index_bad] = calc_tukey(data)

% input: vector containing reaction times
% output: index of trials of "good" trials

res                             = quantile(data,3) ;
q1                              = res(1);
q3                              = res(3);

clear res ;

iqr                             = q3-q1;
iqr_mult                        = iqr * 1.5 ;

up_lim                          = iqr_mult + q3;
lw_lim                          = q1 - iqr_mult;

index_good                     	= find(data < up_lim & data > lw_lim);
index_bad                    	= find(data > up_lim | data < lw_lim);

perc_left                       = round(length(index_good)./length(data),2) * 100;

fprintf('\n%.2f perc of trials kept\n',perc_left)