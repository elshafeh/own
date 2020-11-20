clear; clc;

big_indx = [];

load ../data/yctot/index/NewSourceIndex.mat ;

big_indx = [big_indx ; indx_arsenal];
big_list = list_arsenal ;

clear *arsenal*

load ../data/yctot/index/NewSourceMotorIndex.mat ;

indx_arsenal(:,2) = indx_arsenal(:,2) + 6 ;

big_list = [big_list list_arsenal];
big_indx = [big_indx ; indx_arsenal];

clear *arsenal*

list_arsenal = big_list ; indx_arsenal = big_indx ; clear *big*

save ../data/yctot/index/NewSourceAudVisMotor.mat;


