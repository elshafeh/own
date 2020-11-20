function source = h_pccSeparate(suj,data_in,tpoint,twin,tpad,f_focus,freq_tap,com_filter,pkg,ext_source_2,concat,taper_type)

if strcmp(concat,'no')
    cfg                 = [];
    cfg.toilim          = [tpoint-tpad tpoint+tpad+twin];
    data                = ft_redefinetrial(cfg, data_in);
else
    data                = data_in;
end

cfg                     = [];
cfg.taper               = taper_type;
cfg.method              = 'mtmfft';
cfg.output              = 'fourier';
cfg.keeptrials          = 'yes';
cfg.foi                 = f_focus;
cfg.tapsmofrq           = freq_tap;
freq                    = ft_freqanalysis(cfg,data);

ext_freq                = [num2str(f_focus-freq_tap) 't' num2str(f_focus+freq_tap) 'Hz'];

cfg                     = [];
cfg.method              = 'pcc';
cfg.frequency           = freq.freq;
cfg.grid                = pkg.leadfield;
cfg.grid.filter         = com_filter ;
cfg.headmodel           = pkg.vol;
cfg.pcc.fixedori        = 'yes';
cfg.pcc.projectnoise    = 'yes';
cfg.pcc.keepmom         = 'yes';
cfg.pcc.lambda          = '5%';
cfg.keeptrials          = 'yes';

source                  = ft_sourceanalysis(cfg, freq);

mom                     = source.avg.mom ;

mom                     = cellfun(@(x) abs(x).^2, mom, 'UniformOutput',false);
iy                      = size(source.avg.mom{find(source.inside,1,'first')},2);
iz                      = length(freq.trialinfo);

mom(cellfun(@isempty, mom)) = {nan(1,iy)};

source = cell2mat(mom);

if iy ~= iz
    
    fct = iy/iz ;
    
    for ii = 1:fct
        
        lmSrc1 = ((ii-1) * iz) + 1;
        lmSrc2 = lmSrc1 + iz - 1;
        
        src{ii}   = source(:,lmSrc1:lmSrc2);
        
    end
    
    source = cat(3,src{:});
    source = mean(source,3);
    
    clear src lmSrc1 lmSrc2 fct
    
end

if tpoint < 0
    ext_ext= 'm';
else
    ext_ext='p';
end

ext_time_source         = [ext_ext num2str(abs(tpoint*1000)) ext_ext num2str(abs((tpoint+twin)*1000))];
f_name_source           = [suj '.' ext_freq '.' ext_time_source '.' ext_source_2 '.mat'];
fprintf('\n\nSaving %50s \n\n',f_name_source);

save(f_name_source,'source','-v7.3');