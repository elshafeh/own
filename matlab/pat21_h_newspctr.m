function nwspctrm = h_newspctr(freq,twin,tlist,ftap,flist,chn_vctor)

nwspctrm = [];

for chn = 1:length(chn_vctor)
    for t = 1:length(tlist)
        for f = 1:length(flist)
            
            lmt1 = find(round(freq.time,2) == round(tlist(t),2));
            lmt2 = find(round(freq.time,2) == round(tlist(t)+twin,2));
            
            lmf1 = find(round(freq.freq) == round(flist(f)));
            lmf2 = find(round(freq.freq) == round(flist(f)+ftap));
            
            data                = squeeze(mean(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2),3));
            nwspctrm(chn,f,t)   = squeeze(mean(data,2));
            
        end
    end
end