clear ; clc ;

for sb = 1
    
    suj_list    = 1;
    suj         = ['yc' num2str(suj_list(sb))];
    
    load(['../data/' suj '/elan/' suj '.CnD.eeg.mat']);
    
    data_elan = rmfield(data_elan,'grad');
    data_elan = rmfield(data_elan,'hdr');
    
    cfg             = [];
    cfg.toilim      = [-0.7 1.2];
    data4filt       = ft_redefinetrial(cfg, data_elan);
    
    cfg               = [];
    cfg.method        = 'mtmfft';
    cfg.foi           = 11;
    cfg.tapsmofrq     = 1.2;
    cfg.output        = 'powandcsd';
    freq4filt         = ft_freqanalysis(cfg,data4filt);
    
    load(['../data/' suj '/headfield/' suj '.eegVolElecLead.mat']);
    
    cfg                     = [];
    cfg.method              = 'dics';
    cfg.channel             = 1:54;
    cfg.elec                = elec;
    cfg.frequency           = freq4filt.freq;
    cfg.grid                = leadfield;
    cfg.headmodel           = vol;
    cfg.dics.keepfilter     = 'yes';
    cfg.dics.fixedori       = 'yes';
    cfg.dics.projectnoise   = 'yes';
    cfg.dics.lambda         = '5%';
    source                  = ft_sourceanalysis(cfg, freq4filt);
    com_filter              = source.avg.filter ;
    
    clear source *4filt
    
    t_list = [-0.6 0.2 0.6];
    f_list = [9 13];
    
    for t = 1:length(t_list)
        
        for frq = 1:length(f_list)
            
            cfg             = [];
            cfg.toilim      = [t_list(t) t_list(t)+0.4];
            poi             = ft_redefinetrial(cfg, data_elan);
            
            cfg               = [];
            cfg.method        = 'mtmfft';
            cfg.foi           = f_list(frq);
            cfg.tapsmofrq     = 2;
            cfg.output        = 'powandcsd';
            freq              = ft_freqanalysis(cfg,poi);
            
            cfg                     = [];
            cfg.method              = 'dics';
            cfg.channel             = 1:54;
            cfg.elec                = elec;
            cfg.frequency           = freq.freq;
            cfg.grid                = leadfield;
            cfg.grid.filter         = com_filter ;
            cfg.headmodel           = vol;
            cfg.dics.keepfilter     = 'yes';
            cfg.dics.fixedori       = 'yes';
            cfg.dics.projectnoise   = 'yes';
            cfg.dics.lambda         = '5%';
            tmp                     = ft_sourceanalysis(cfg, freq);
            
            source{t,frq}.pow = tmp.avg.pow ;
            source{t,frq}.dim = tmp.dim ;
            source{t,frq}.pos = vol.MNI_pos;
            
            clear freq poi tmp
            
        end
        
    end
    
    save(['../data/' suj '/source/' suj '.eeg.testpack.mat'],'source','-v7.3')
    
end


% for t = 2:size(source,1)
%     for f = 1:size(source,2)
%
%         x = source{t,f}.avg.pow;
%         y = source{1,f}.avg.pow;
%
%         nw_src{t-1,f}.pow = (x-y) ./ y ;
%         nw_src{t-1,f}.pos = vol.MNI_pos;
%         nw_src{t-1,f}.dim = source{t,f}.dim;
%
%     end
% end
%
% for t = 1:size(nw_src,1)
%     for f = 1:size(nw_src,2)
%
%         src_int{t,f} = h_interpolate(nw_src{t,f});
%
%         cfg                     = [];
%         cfg.method              = 'slice';
%         cfg.funparameter        = 'pow';
%         cfg.nslices             = 16;
%         cfg.slicerange          = [70 84];
%         cfg.funcolorlim         = [-0.2 0.2];
%         ft_sourceplot(cfg,src_int{t,f});
%
%     end
% end