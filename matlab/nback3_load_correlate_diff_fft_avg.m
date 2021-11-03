clear;clc;

suj_list                 	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    fname_in             	= ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1)	= apeak;
    allbetapeaks(nsuj,1)  	= bpeak;
    
    allchan{nsuj,1}     	= max_chan;
    
end

mean_beta_peak            	= round(nanmedian(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))          	= mean_beta_peak;


for nsuj = 1:length(suj_list)
    
    dir_data_in          	= '~/Dropbox/project_me/data/nback/behav_h/';
    fname                	= [dir_data_in 'sub' num2str(suj_list(nsuj)) '.behav.mat'];
    fprintf('loading %s\n',fname)
    load(fname);
    
    data_behav            	= data_behav(data_behav(:,5) == 0 & data_behav(:,1) ~= 4,[1 6 7]);
    sub_rt               	= [];
    
    for nback = [5 6]
        
        data_sub          	= data_behav(data_behav(:,1) == nback,:);
        sub_rt(nback-4)  	= median(data_sub(data_sub(:,3) > 0 & rem(data_sub(:,2),2) ~= 0,3)) / 1000;
        clear data_sub
        
    end
    
    allbehav(nsuj,1)     	= sub_rt(2) - sub_rt(1);
    
end

keep suj_list all*

for nsuj = 1:length(suj_list)
    
    for nback = 1:2
        
        ext_stim          	= 'target';
        difference_type  	= 'difference' ; % difference relative
        
        dir_data          	= '~/Dropbox/project_me/data/nback/tf/behav2tf/';
        file_list         	= dir([dir_data 'sub' num2str(suj_list(nsuj)) '.' num2str(nback) 'back.' ext_stim '.correct.pre.fft.mat']);
        pow              	= [];
        
        for nfile = 1:length(file_list)
            
            fname_in       	= [file_list(nfile).folder filesep file_list(nfile).name];
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            pow(nfile,:,:,:) 	= freq_comb.powspctrm;
            
        end
        
        avg              	= [];
        avg.time         	= freq_comb.freq;
        avg.label       	= freq_comb.label;
        avg.dimord      	= 'chan_time';
        avg.avg           	= squeeze(mean(pow,1)); clear pow;
        
        tmp{nback}        	= avg; clear avg pow f1 f2 f_*;
        
    end
    
    diff                  	= tmp{1};
    
    switch difference_type
        case 'difference'
            diff.avg      	= tmp{1}.avg - tmp{2}.avg;
        case 'relative'
            diff.avg        = (tmp{1}.avg - tmp{2}.avg) ./ (tmp{1}.avg + tmp{2}.avg);
        otherwise
            error('pick a difference technique');
    end
    
    clear tmp
    
    find_chan            	= [];
    for nchan = 1:length(allchan{nsuj})
        find_chan           = [find_chan; find(strcmp(diff.label,allchan{nsuj}{nchan}))];
    end
    
    list_band               = {'alpha' 'beta'};
    
    for nband = 1:length(list_band)
        
        test_band       	= list_band{nband};
        
        switch test_band
            case 'alpha'
                f_focus  	= allalphapeaks(nsuj);
                f_width   	= 1;
            case 'beta'
                f_focus   	= allbetapeaks(nsuj);
                f_width    	= 2;
        end
        
        f1              	= nearest(diff.time,f_focus-f_width);
        f2                	= nearest(diff.time,f_focus+f_width);
        
        pow                 = diff.avg(find_chan,f1:f2);
        alldata(nsuj,nband)	= nanmean(nanmean(pow)); clear pow;
        
    end
    
end

%%

keep suj_list all* ; clc; 

for nband = [1 2]
    
    x                       = alldata(:,nband);
    y                       = allbehav;
    
    [rho_s(nband),p_s(nband)]          	= corr(x,y , 'type', 'Spearman');
    [rho_p(nband),p_p(nband)]          	= corr(x,y , 'type', 'Pearson');
    
end