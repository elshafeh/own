clear ; clc ;  dleiftrip_addpath ;

fOUT = '../txt/CnD_CorrVirtual4R.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%5s\t%5s\t%5s\t%5s\n','SUB','CHAN','FREQ','CORR');

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/' suj '/tfr/' suj '.CnD.Paper.TimeCourse.KeepTrial.conv.5t18Hz.m4p4.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg                         = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    freq                        = ft_freqbaseline(cfg,freq);
    
    c_list = 1:10;
    f_list = 7:15;
    t_list = 0.9;
    
    for chn = 1:length(c_list)
        
        for t = 1:length(t_list)
            
            for f = 1:length(f_list)
                
                load  ../data/yctot/rt/rt_CnD_adapt.mat
                
                x = find(round(freq.freq) == round(f_list(f)));
                y = find(round(freq.time,2) == round(t_list(t),2));
                z = find(round(freq.time,2) == round(t_list(t)+0.2,2));
                
                ext_freq    = [num2str(f_list(f)) 'Hz'];
                ext_chan    = freq.label{chn};
                
                data        = squeeze(freq.powspctrm(:,chn,x,y:z));
                data        = mean(data,2);
                [rho,p]     = corr(data,rt_all{sb} , 'type', 'Spearman');
                
                rhoF        = .5.*log((1+rho)./(1-rho));
                
                fprintf(fid,'%5s\t%5s\t%5s\t%.4f\n',suj,ext_chan,ext_freq,rhoF);
                
            end
            
        end
    end
    
end

fclose(fid);