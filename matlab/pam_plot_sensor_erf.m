clear;

for nsuj = 2:21
    
    
    sujname           	= ['yc' num2str(nsuj)];
    list_ext         	= {'CnD' 'nDT' 'nBP'};
    
    for next = [1 2 3]
        
        dir_in         	= '~/Dropbox/project_me/data/pam/erf/';
        fname_in      	= [dir_in sujname '.' list_ext{next} '.erf.mat'];
        fprintf('loading %s\n',fname_in);
        load(fname_in);
        
        t1            	= nearest(avg_comb.time,-0.1);
        t2           	= nearest(avg_comb.time,0);
        
        bsl           	= mean(avg_comb.avg(:,t1:t2),2);
        avg_comb.avg  	= avg_comb.avg - bsl ; clear bsl t1 t2;
        
        alldata{nsuj-1,next}    = avg_comb;
        
    end
    
end

keep alldata;

%%

for next = [1 2 3]
    
    gavg             	= ft_timelockgrandaverage([],alldata{:,next});
    
    cfg               	= [];
    cfg.layout        	= 'CTF275_helmet.mat';
    cfg.marker         	= 'off';
    cfg.colormap       	= brewermap(256,'*RdBu');
    cfg.colorbar       	= 'no';
    cfg.xlim          	= [0 0.2];
    cfg.figure         	= subplot(2,2,next);
    ft_topoplotER(cfg,gavg);
    
end
