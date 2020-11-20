function list_iaf   = ageingrev_infunc_iaf(freq)

flist                   = [7 15];
twin                    = 0.4;
tlist                   = 0.6;

for nchan = 1:length(freq.label)
    
    name_chan           = freq.label{nchan};
    list_iaf{nchan,1}   = name_chan;
    
    lmt1                = find(round(freq.time,3) == round(tlist,3));
    lmt2                = find(round(freq.time,3) == round(tlist+twin,3));
    
    lmf1                = find(round(freq.freq) == round(flist(1)));
    lmf2                = find(round(freq.freq) == round(flist(end)));
    
    data                = squeeze(freq.powspctrm(nchan,lmf1:lmf2,lmt1:lmt2));
    data                = squeeze(mean(data,2))';
    
    f_axes              = round(freq.freq(lmf1:lmf2));
    
    chn_prts            = strsplit(name_chan,'_');
    
    if length(chn_prts) > 1
        chan_mod        = chn_prts{1};
    else
        chan_mod        = name_chan(1:3);
    end
    
    if strcmp(chan_mod,'aud') || strcmp(chan_mod,'mot')
        iaf             = f_axes(find(data==min(data)));
    else
        iaf             = f_axes(find(data==max(data)));
    end
    
    list_iaf{nchan,2}   = iaf;
    
end