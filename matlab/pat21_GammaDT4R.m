clear ; clc ; dleiftrip_addpath ;

for a = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(a))];
    lst         = {'nDT','DT1','DT2','DT3'};
    ext1        = '.all.wav.40t150Hz.m2000p2000.MinusEvoked.mat' ;
    
    for cnd = 1:length(lst)
        
        fname_in                = ['../data/tfr/' suj '.' lst{cnd} ext1];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        cfg                     = [];
        cfg.baseline            = [-1.4 -1.3];
        cfg.baselinetype        = 'relchange';
        freq                    = ft_freqbaseline(cfg,freq);
        
        cfg                     = [];    
        cfg.latency             = [0 0.6];
        cfg.frequency           = [60 90];
        cfg.channel             = {'MLC22', 'MLC31', 'MLC41', 'MLC42', 'MLC51', 'MLC52', 'MLC53', 'MLC54', 'MLC55', ...
            'MLC61', 'MLC62', 'MLC63', 'MLP12', 'MLP23', 'MRC14', 'MRC22', 'MRC23', 'MRC31', 'MRC32', ...
            'MRC41', 'MRC42', 'MRC51', 'MRC52', 'MRC53', 'MRC54', 'MRC55', 'MRC61', 'MRC62', 'MRC63', ...
            'MRP12', 'MRP23'};
        cfg.avgoverfreq         = 'yes';
        cfg.avgoverchan         = 'yes';
        freq                    = ft_selectdata(cfg, freq);
        matrix4R(a,cnd,:)      = freq.powspctrm;
        time4R                  = freq.time;
        
        clear freq ;
        
    end
end

clearvars -except matrix4R time4R

fout = '../txt/GammaDT.latEffect.txt';
fid  = fopen(fout,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\n','SUB','LATENCY','DELAY','POW');

for sb = 1:14
    for cnd = 1:4
        
        twin    = 0.05;
        tlist   = 0:twin:0.55;
        lst_cnd = {'D0','D1','D2','D3'};
        
        for t   = 1:length(tlist)
            
            x1   = find(round(time4R,3) == round(tlist(t),3));
            x2   = find(round(time4R,3) == round(tlist(t)+twin,3));

            data = squeeze(mean(matrix4R(sb,cnd,x1:x2)));
            
            fprintf(fid,'%s\t%s\t%s\t%.3f\n',['yc' num2str(sb)],[num2str(round(tlist(t),2)*1000) 'ms'],lst_cnd{cnd},data);
            
            clear data ;
            
        end
    end
end

fclose(fid);