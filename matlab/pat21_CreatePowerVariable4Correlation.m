clear ; clc ; dleiftrip_addpath ;

suj_list = [1:4 8:17];

ext_freq    = {'7t11Hz','11t15Hz'};
ext_time    = {'p600p1000'};
ext_bsl     = 'm600m200';

[cnd_freq,cnd_time] = prepare_cnd_freq_time(ext_freq,ext_time);

load ../data/template/source_struct_template_MNIpos.mat; template_source = source ; clear source ;

new_source = [];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    %
    %     for conditions = 1:2
    %         source_avg{sb,conditions}.pow    = zeros(length(template_source.pos),length(cnd_freq),length(cnd_time));
    %     end
    %
    for nfreq = 1:length(ext_freq)
        for ntime = 1:length(ext_time)
            
            src_carr{1} =[]; src_carr{2} =[];
            
            for npart = 1:3
                
                ext_lock    = 'CnD';
                ext_source  = '.NewSource.mat';
                fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_bsl '.' ext_freq{nfreq} ext_source]);
                fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                
                src_carr{1} = [src_carr{1} source]; clear source ;
                
                fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_time{ntime} '.' ext_freq{nfreq} ext_source]);
                fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                
                src_carr{2} = [src_carr{2} source]; clear source ;
                
            end
            
            for conditions = 1:2
                s_pow{conditions} = nanmean(src_carr{conditions},2);
            end
            
            ppower           = (s_pow{2} - s_pow{1}) ./ s_pow{1};
            
            load ../data/yctot/index/NewSourceAudVisMotor.mat
            
            ix{1}                       = indx_arsenal(indx_arsenal(:,2) == 3 | indx_arsenal(:,2) == 5,1);
            ix{2}                       = indx_arsenal(indx_arsenal(:,2) == 4 | indx_arsenal(:,2) == 6,1);
            ix{3}                       = indx_arsenal(indx_arsenal(:,2) == 1,1);
            ix{4}                       = indx_arsenal(indx_arsenal(:,2) == 2,1);
            
            for chn = 1:length(ix)
                new_source(sb,chn,nfreq,ntime)  = squeeze(nanmean(ppower(ix{chn}),1));
            end
            
            clear s_pow ppower;
            
        end
    end
    
end

clearvars -except new_source; clc ;

aud = squeeze(new_source(:,1:2,1));
occ = squeeze(new_source(:,3:4,2));

new_source = [aud occ];

clearvars -except new_source; clc ;

save('../data/yctot/index/ForCorrelation.bslcorrected.p600p100.7t11Hz.1AudL.2AudR.3OccL.4OccR.mat');