clear;clc;

suj_list = [1:4 8:17];

ext_freq = {'60t100Hz'};
ext_time = {'p0p100','p100p200','p200p300','p300p400','p400p500','p500p600','p600p700','p700p799','p800p900','p900p1000','p1000p1100'};

ext_bsl  = 'm200m100';

cnd_freq    = 80;
cnd_time    = 0:0.1:1;

load ../data/template/source_struct_template_MNIpos.mat; template_source = source ; clear source ;

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    lst_cnd2compare = 'RLN';
    
    for ncond = 1:length(lst_cnd2compare)
        
        source_avg{sb,ncond}.pow    = zeros(length(template_source.pos),length(cnd_freq),length(cnd_time));
        source_avg{sb,ncond}.pos    = template_source.pos;
        source_avg{sb,ncond}.dim    = template_source.dim;
        source_avg{sb,ncond}.freq   = cnd_freq;
        source_avg{sb,ncond}.time   = cnd_time;
        
        for nfreq = 1:length(ext_freq)
            for ntime = 1:length(ext_time)
                
                src_carr{1} =[]; src_carr{2} =[];
                
                for npart = 1:3
                    
                    ext_lock    = [lst_cnd2compare(ncond) 'CnD'];
                    ext_source  = '.MinSameEvokedSource.mat';
                    fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_bsl '.' ext_freq{nfreq} ext_source]);
                    fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                    
                    src_carr{1} = [src_carr{1} source]; clear source ;
                    
                    fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_time{ntime} '.' ext_freq{nfreq} ext_source]);
                    fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                    
                    src_carr{2} = [src_carr{2} source]; clear source ;
                    
                end
                
                bsl                                             = nanmean(src_carr{1},2);
                act                                             = nanmean(src_carr{2},2);
                pow                                             = (act-bsl)./bsl; clear bsl act src_carr;
                %                 pow                                             = (act-bsl); clear bsl act src_carr;
                
                source_avg{sb,ncond}.pow(:,nfreq,ntime)    = pow ; clear pow;
                
            end
        end
    end
end

clearvars -except source_avg ;

for ncue = 1:3
    gavg{ncue} = ft_sourcegrandaverage([],source_avg{:,ncue});
end

clearvars -except gavg;

lst_cue = {'R','L','N'};

for ncue = 1:3
    for ntime           = 2
        for nfreq = 1
            
            source                      = [];
            source.pos                  = gavg{ncue}.pos;
            source.dim                  = gavg{ncue}.dim;
            source.pow                  = gavg{ncue}.pow(:,nfreq,ntime);
            source_int                  = h_interpolate(source);
            
            cfg                         = [];
            cfg.method                  = 'slice';
            cfg.funparameter            = 'pow';
            cfg.nslices                 = 16;
            cfg.slicerange              = [70 84];
            cfg.funcolorlim             = [-0.05 0.05];
            ft_sourceplot(cfg,source_int);clc;
            title([lst_cue{ncue} num2str(gavg{ncue}.time(ntime))]);
            clear source source_int;
        end
    end
end