clear;

alldata                             = [];
i                                   = 0;

for nsuj = [1:33 35:36 38:44 46:51]
    
    ext_bin_fname                   = 'exl500concat';
    fname                           = ['/Volumes/heshamshung/nback/bin/sub' num2str(nsuj) '.' ext_bin_fname '.binsummary.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    list_stim                       = {'first' 'target'};
    
    for ni = 1:length(bin_summary)
        
        for nback = [1 2]
            for nstim = [1 2]
        
                i                   = i +1;
                alldata(i).sub      = bin_summary(ni).sub;
                alldata(i).band     = bin_summary(ni).band;
                alldata(i).bin      = bin_summary(ni).bin;
                alldata(i).cond  	= [num2str(nback) 'back'];
                alldata(i).stim  	= list_stim{nstim};
                alldata(i).count  	= bin_summary(ni).trialcount(nback,nstim);
        
            end
        end
    end
    
end

keep alldata ext_bin_fname

writetable(struct2table(alldata),['../doc/nback_binning_behavior_' ext_bin_fname '_trialcount.txt']);