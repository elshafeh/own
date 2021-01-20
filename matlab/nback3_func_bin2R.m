function nback3_func_bin2R(ext_bin_fname)

alldata                 = [];

for nsuj = [1:33 35:36 38:44 46:51]
    
    fname            	= ['/Volumes/heshamshung/nback/bin/sub' num2str(nsuj) '.' ext_bin_fname '.binsummary.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    bin_summary         = rmfield(bin_summary,'index');
    alldata            	= [alldata bin_summary];
    
end

writetable(struct2table(alldata),['../doc/nback_binning_behavior_' ext_bin_fname '.txt']);