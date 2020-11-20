clear ; close all;

suj_list 	= [1:33 35:36 38:44 46:51];
ext_fix     = 'target'; % first target

for nsuj = 1:length(suj_list)
    
    suj_name                                            = ['sub' num2str(suj_list(nsuj))];
    list_lock                                           = {['alpha.peak.centered.lockedon.' ext_fix]};
    
    list_cond                                           = {'1back','2back'};
    
    for nback = 1:length(list_cond)
        for nlock = 1:length(list_lock)
            
            ext_lock                                    = list_lock{nlock};
            
            for nstim = 1:10
                flist                                   = dir(['J:/nback/sens_level_auc/timegen/' suj_name '.' list_cond{nback} '.' ext_lock ...
                    '.decoding.stim' num2str(nstim) '.agaisnt.all.bsl.excl.timegen.mat']);
                file_count{nback}(nsuj,nstim)           = length(flist);
            end
            
        end
        
    end
end

keep file_count

for nback = 1:2
    for nstim = 1:10
        count_total(nback,nstim) = sum(file_count{nback}(:,nstim));
    end
end

keep count_total

for nback = 1:2
    count_final(nback) = sum(count_total(nback,:));
end

keep count_total count_final