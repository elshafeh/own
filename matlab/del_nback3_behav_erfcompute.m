clear;clc;

for nsuj = [1:33 35:36 38:44 46:51]
    

    for nsess = 1:2
        
        fname        	= ['/Volumes/heshamshung/nback/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        %-%-% low pass filtering
        cfg            	= [];
        cfg.demean    	= 'yes';
        cfg.baselinewindow    	= [-0.1 0];
        cfg.lpfilter  	= 'yes';
        cfg.lpfreq   	= 20;
        data           	= ft_preprocessing(cfg,data);
        
        %-%-% exclude trials with a previous response
        cfg             = [];
        cfg.trials     	= find(data.trialinfo(:,5) == 0);
        data          	= ft_selectdata(cfg,data);
        data          	= megrepair(data);
        
    end
    
end