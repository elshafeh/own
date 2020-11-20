function [DS,DATA] = ds2mat(ds_directory)
% Convert *.ds CTF file to mat
% [DS,DATA] = ds2mat(ds_directory)
%  ds_directory : *ds file name to convert


  % importe le dataset
   DS=readCTFds(ds_directory);
   DATA=getCTFdata(DS);

