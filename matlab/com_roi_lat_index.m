clear ;

atlas                                       = ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii');

rm '~/Desktop/data/*mat'

for ns =  [1:4 8:17]
    
    list_orig                               = {'CnD.com90roi.meg','CnD.com90roi.eeg'};
    
    for ndata = 1:length(list_orig)
        
        % load data
        fname                               = ['../data/lcmv/yc' num2str(ns) '.' list_orig{ndata} '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        new_data                            = data;
        new_data.label                      = {};
        new_data.trial                      = {};
        
        for ntrial = 1:length(data.trialinfo)
            
            roi_name                        = {};
            i                               = 0 ;
            
            for nchan = 1:2:length(data.label)
                
                i                           = i + 1;
                
                ch1                         = nchan;
                ch2                         = nchan+1;
                
                data1                       = data.trial{ntrial}(ch1,:);
                data2                       = data.trial{ntrial}(ch2,:);
                
                lt_index                    = (data1 - data2) ./ (data1+data2);
                
                tmp                         = atlas.tissuelabel{nchan}(1:end-2);
                roi_name{i}                 = tmp;clear tmp
                
                new_data.trial{ntrial}(i,:) = lt_index; clear lt_index data1 data2 ch1 ch2;
                
            end
            
        end
        
        new_data.label                      = roi_name; clear roi_name i nchan ntrial;
        data                                = new_data; clear new_data;
        
        % load data
        fname                               = ['~/Desktop/data/yc' num2str(ns) '.' list_orig{ndata} '.latindex.mat'];
        fprintf('saving %s\n',fname);
        save(fname,'data','-v7.3');
        
        clear data;
        
    end
end