clear;clc;

for nsuj = [1:33 35:36 38:44 46:51]
    
    fname            	= ['/Volumes/heshamshung/nback/bin/sub' num2str(nsuj) '.excludemotor500pre.binsummary.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    bin_summary         = struct2table(bin_summary);
    
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
        
        list_back       = [5 6];
        list_name     	= {'1back','2back'};
        list_stim      	= {'first' 'target'};
        list_band      	= {'slow' 'alpha' 'beta' 'gamma1' 'gamma2'};
        
        for nback = [1 2]
            for nstim = [1 2]
                
                %-%- crucial
                cfg             	= [];
                cfg.trials        	= find(data.trialinfo(:,1) == list_back(nback) & data.trialinfo(:,3) == nstim);
                data_slct         	= ft_redefinetrial(cfg,data);
                
                for nband = [1 2 3 4 5]
                    for nbin = [1 2]
                        
                        
                        flg             = find(strcmp(bin_summary.cond,list_name{nback}) ...
                            & strcmp(bin_summary.sess,['s' num2str(nsess)]) ...
                            & strcmp(bin_summary.stim,list_stim{nstim}) ...
                            & strcmp(bin_summary.band,list_band{nband}) ...
                            & strcmp(bin_summary.bin,['b' num2str(nbin)]));
                        
                        if ~isempty(flg)
                            
                            cfg         = [];
                            cfg.trials  = bin_summary(flg,:).index{:};
                            avg        	= ft_timelockanalysis(cfg, data_slct);
                            avg_comb   	= ft_combineplanar([],avg);
                            avg_comb   	= rmfield(avg_comb,'cfg'); clc;
                            
                            fname_out  	= ['/Volumes/heshamshung/nback/erf/sub' num2str(nsuj)];
                            fname_out  	= [fname_out '.' list_name{nback} '.' list_stim{nstim}];
                            fname_out  	= [fname_out '.' list_band{nband} '.' ['b' num2str(nbin)]];
                            fname_out  	= [fname_out '.sess' num2str(nsess) '.erfComb.mat'];
                            
                            fprintf('Saving %s\n',fname_out);
                            tic;save(fname_out,'avg_comb','-v7.3');toc
                            
                        end
                        
                    end
                end
            end
        end
    end
end