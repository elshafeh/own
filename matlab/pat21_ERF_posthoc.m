clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/LRNnDT.pe.mat	
load ../data/yctot/gavg/nDT2RChanList.mat

list_latency = [0.05 0.185; 0.185 0.28; 0.28 0.5];

for lat = 1
    for sb = 1:size(allsuj,1)
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
                    
                    data2permute{lat}(sb,cnd,list) = data.avg;
                    
                end
            end
        end
    end  
end

clearvars -except data2permute ;

t = 1;

for chn = 1:4
    p_RL(chn) = permutation_test(squeeze(data2permute{t}(:,[3 2],chn)),10000);
    p_RN(chn) = permutation_test(squeeze(data2permute{t}(:,[3 1],chn)),10000);
    p_LN(chn) = permutation_test(squeeze(data2permute{t}(:,[2 1],chn)),10000);
end

x = [p_RN;p_LN;p_RL];