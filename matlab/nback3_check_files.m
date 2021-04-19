clear;clc;

suj_list                                = [1:33 35:36 38:44 46:51];
bad_sub                                 = {};

for nsuj = 1:length(suj_list)
    
    sujname                             = ['sub' num2str(suj_list(nsuj))];
    
    dir_files                           = 'P:\3035002.01\nback\timegen\';
    list_band                           = {'alpha' 'beta'};
    list_window                         = {'pre' 'post'};
    list_bin                            = {'b1' 'b2'};
    list_decode                         = {'first' 'target' 'stim*'};
    
    for nband = 1:length(list_band)
        for nwin = 1:length(list_window)
            for nbin = 1:length(list_bin)
                for ndeco = 1:length(list_decode)
                    
                    name_parts          = [dir_files sujname '.' list_band{nband} '.' list_window{nwin} '.' list_bin{nbin}];
                    name_parts          = [name_parts '.decoding.' list_decode{ndeco} '.nodemean.auc.timegen.mat'];
                    
                    flist               = dir(name_parts);
                    
                    if length(flist) < 1
                        bad_sub{end+1}  = sujname;
                    end
                    
                end
            end
        end
    end
end

keep bad_sub

bad_sub                                 = unique(bad_sub);