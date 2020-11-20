clear ; clc ;

for sb = 1:14
    
    load ../data/yctot/rt/rt_CnD_adapt.mat
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/tfr/' suj '.CnD.all.wav.5t18Hz.m4p4.mat'];
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg                         = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    data_sub                    = ft_freqbaseline(cfg,freq);
    
    %     data_sub = freq;
    
    flist       = [9 13];
    tim_win     = 0.4;
    tlist       = 0.6;
    ftap        = 2;
    
    for t = 1:length(tlist)
        for f = 1:length(flist)
            
            x1                  = find(round(data_sub.time,2) == round(tlist(t),2)) ;
            x2                  = find(round(data_sub.time,2) == round(tlist(t)+tim_win,2)) ;
            x3                  = find(round(data_sub.freq)   == round(flist(f)-ftap));
            x4                  = find(round(data_sub.freq)   == round(flist(f)+ftap));
            
            tmp                     = nanmean(data_sub.powspctrm(:,x3:x4,x1:x2),3);
            tmp                     = nanmean(tmp,2);
            nwspctr(sb,f,t,:)   = tmp;
        end
    end
    
    rtCorrMat(:,1)  = cellfun(@median,rt_all);
    %     rtCorrMat(:,2)  = cellfun(@mean,rt_all);
    
end

clearvars -except nwspctr rtCorrMat data_sub

i = 0 ;
for rt = 1
    for f = 1:2
        
        [rho,p] = corr(squeeze(nwspctr(:,f,1,:)),rtCorrMat(:,rt), 'type', 'Pearson');
        mask    = p < 0.05;
        
        freq{rt,f}.powspctrm    = rho;%  .* mask ;
        freq{rt,f}.label        = data_sub.label ;
        freq{rt,f}.freq         = 9;
        freq{rt,f}.time         = 0.8 ;
        freq{rt,f}.dimord       = data_sub.dimord ;
        
        i = i + 1;
        
        cfg             = [];
        cfg.layout      = 'CTF275.lay';
        cfg.zlim        = [-1 1];
        cfg.colorbar    = 'yes';
        cfg.comment     = 'no';
        figure;
        ft_topoplotTFR(cfg,freq{rt,f});
        
    end
end

rhoList = {'MRO11', 'MRO12', 'MRO13', 'MRO14', 'MRO22', 'MRO23',...
    'MRO24', 'MRO31', 'MRO32', 'MRO33', 'MRO34', 'MRO42', 'MRO43', ...
    'MRO44', 'MRP31', 'MRP41', 'MRP42', 'MRP52', 'MRP53', 'MRP54',...
    'MRP55', 'MRT16', 'MRT26', 'MRT27', 'MRT37', 'MRT47', 'MRT57'};
