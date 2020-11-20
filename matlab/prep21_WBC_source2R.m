
clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); clc ;

load ../data/template/template_grid_0.5cm.mat

suj_list                                = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                                 = ['yc' num2str(suj_list(sb))] ;
    
    list_freq                           = {'7t15Hz'};
    list_time                           = {'.m600m200','.p600p1000'};
    list_roi                            = {'MinEvoked.aud_L','MinEvoked.aud_R'};
    
    list_mesure                         = {'plvConn'};
    
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                
                list_cue    = {'RCnD','LCnD','NCnD'};
                
                for ncue = 1:length(list_cue)
                    
                    for ntime = 1:length(list_time)
                        
                        source_part         = [];
                        
                        for npart = 1:3
                            
                                
                            fname_in = ['../data/paper_data/' suj '.pt' num2str(npart) '.' list_cue{ncue} list_time{ntime} '.' ...
                                list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes} '.paper_data.mat'];
                            
                            
                            fprintf('Loading %s\n',fname_in);
                            load(fname_in)
                            
                            source_ztransform   = .5.*log((1+source)./(1-source)); clear source ;
                            
                            source_part         = [source_part source_ztransform];
                            
                        end
                        
                        tmp{ntime}          = mean(source_part,2);
                        
                    end
                    
                    source_gavg{sb,ncue,nfreq,nroi,nmes}.pow = (tmp{2}-tmp{1})./(tmp{1}); % tmp{2}-tmp{1} ; % 
                    source_gavg{sb,ncue,nfreq,nroi,nmes}.pos = template_grid.pos;
                    source_gavg{sb,ncue,nfreq,nroi,nmes}.dim = template_grid.dim;
                    
                    clear tmp
                    
                end
                
                list_to_subtract                = [1 3; 2 3];
                index_cue                       = 3;
                
                for nadd = 1:length(list_to_subtract)
                    
                    source_gavg{sb,index_cue+nadd,nfreq,nroi,nmes}  = source_gavg{sb,list_to_subtract(nadd,1),nfreq,nroi,nmes} ;
                    
                    pow                                             = source_gavg{sb,list_to_subtract(nadd,1),nfreq,nroi,nmes}.pow - ...
                        source_gavg{sb,list_to_subtract(nadd,2),nfreq,nroi,nmes}.pow ;
                    
                    source_gavg{sb,index_cue+nadd,nfreq,nroi,nmes}.pow = pow; clear pow;
                    
                    list_cue{index_cue+nadd}                        = [list_cue{list_to_subtract(nadd,1)} 'm' list_cue{list_to_subtract(nadd,2)}];
                    
                end
            end
        end
    end
end

clearvars -except source_gavg list_* *_list ;

load ../data/mask/audR.plv.conn.prep21.mask.mat

fOUT = '../documents/4R/prep21_plv2plot.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n','SUB','CUE_COND','FREQ','CHAN','METHOD','POW');

for sb = 1:size(source_gavg,1)
    for ncue = 4:size(source_gavg,2)
        for nfreq = 1:size(source_gavg,3)
            for nroi = 1:size(source_gavg,4)
                for nmes = 1:size(source_gavg,5)
                    
                    x_pow       = source_gavg{sb,ncue,nfreq,nroi,nmes}.pow;
                    x_pow       = x_pow(stat_mask ==1);
                    x_pow       = nanmean(x_pow);
                    
                    x_suj       = ['yc' num2str(sb)];
                    x_cue       = list_cue{ncue};
                    x_freq      = list_freq{nfreq};
                    x_chan      = list_roi{nroi};
                    x_meth      = list_mesure{nmes};
                    
                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.4f\n',x_suj,x_cue,x_freq,x_chan,x_meth,x_pow);
                    
                    clear x_*
                    
                end
            end
        end
    end
end

fclose(fid);