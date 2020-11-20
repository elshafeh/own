clear ; clc ; dleiftrip_addpath ;

ext_pe = '.CnD' ;

load(['../data/yctot/gavg/LRN' ext_pe '.pe.mat']);

fOUT    = ['../txt/New.NLR' ext_pe '.GFP.200msWindow.txt'];
fid     = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\n','SUB','COND','COMP','GFP');

for sb = 1:14
    for cnd = 1:size(allsuj,2)
        
        cfg                 = [];
        cfg.baseline        = [-0.1 0];
        avg                 = ft_timelockbaseline(cfg,allsuj{sb,cnd});
        
        cfg                 = [];
        cfg.method          = 'amplitude';
        gfp                 = ft_globalmeanfield(cfg, avg); clear avg ;
        
        %         list_latency        = [0.6 1.1];
        %         list_latency        = [0.05 0.18;0.18 0.27;0.28 0.5];
        %         list_latency        = [ 0.06 0.15;0.16 0.36;0.37 0.55];

        tm_window           = 0.2;
        list_latency        = 0.5:tm_window:1;

        for t = 1:size(list_latency,2)
            
            lmt1                = find(round(gfp.time,3) == round(list_latency(t),3));
            lmt2                = find(round(gfp.time,3) == round(list_latency(t)+tm_window,3));
            
            data                = mean(squeeze(gfp.avg(lmt1:lmt2)));
            
            lst_cond = {'NCue','LCue','RCue'};
            
            lst_comp = [num2str((list_latency(t)*1000)) 'ms'];
            
            %             lst_comp = {'CNV'};
            %             lst_comp = {'N1','P2','P3'};
            
            fprintf(fid,'%s\t%s\t%s\t%.2f\n',['yc' num2str(sb)],lst_cond{cnd},lst_comp,data);
            
        end
    end
end

fclose(fid);