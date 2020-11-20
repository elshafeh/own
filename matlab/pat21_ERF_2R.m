clear ; clc ;

load ../data/yctot/gavg/LRNnDT.pe.mat
load ../data/yctot/gavg/nDT2RChanList.mat

list_latency = [0.05 0.185; 0.185 0.28; 0.28 0.5];

for lat = 1:size(list_chan,1)
    
    lst_comp    = {'N1','P2','P3'};
    fOUT        = ['../txt/pe.LRN.nDT.' lst_comp{lat} '.txt'] ;
    fid         = fopen(fOUT,'W+');
    
    fprintf(fid,'%s\t%s\t%s\t%s\n','SUB','CUE','CHAN','AVG');
    
    for sb = 1:size(allsuj,1)
        
        lst_cnd = {'NCue','LCue','RCue'};
        
        for cnd = 1:size(allsuj,2)
            
            cfg                 = [];
            cfg.baseline        = [-0.2 -0.1];
            allsuj{sb,cnd}      = ft_timelockbaseline(cfg,allsuj{sb,cnd});
            
            for list = 1:4
                
                if ~isempty(list_chan{lat,list})
                    cfg             = [];
                    cfg.latency     = [list_latency(lat,1) list_latency(lat,2)];
                    cfg.avgovertime = 'yes';
                    cfg.avgoverchan = 'yes';
                    cfg.channel     = list_chan{lat,list};
                    data            = ft_selectdata(cfg,allsuj{sb,cnd});
                    x               = strsplit(list_name{lat,list}{:},'.');
                    
                    fprintf(fid,'%s\t%s\t%s\t%.2f\n',['yc' num2str(sb)],lst_cnd{cnd},x{2},squeeze(data.avg));
                    
                end
            end
        end
    end
    
    fclose(fid);   
end