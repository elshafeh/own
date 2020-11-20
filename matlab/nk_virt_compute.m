function [data_out] = nk_virt_compute(data_in,index_name,spatialfilter)

% load the atlas being used
load(index_name);

% this makes sure that removed of 'outside' dipoles does not
% mess up our indexing

vox_order                               = 1:length(template_grid.pos);
vox_order                               = vox_order';
vox_order                               = [vox_order template_grid.inside] ;
vox_order                               = vox_order(vox_order(:,2)==1,1);

roi_list                                = unique(index_vox(:,2));

for nroi = 1:length(roi_list)
    
    voxel_index_plus_name{nroi,1}       = index_name{roi_list(nroi)};
    voxel_index_plus_name{nroi,2}       = index_vox(index_vox(:,2)==roi_list(nroi),1);
    
end

ft_progress('init','text',    'Please wait...');

for nt=1:length(data_in.trial)
    
    ft_progress(nt/length(data_in.trial), 'Processing trial %d from %d\n', nt, length(data_in.trial));
    
    tmp_data                                = [];
    
    for nroi = 1:length(roi_list)
        
        tmp_vox                             = [voxel_index_plus_name{nroi,2}];
        
        ix = [];
        
        for i =1:length(tmp_vox)
            ix                              = [ix; find(vox_order==tmp_vox(i))];
        end
        
        clear i ;
        
        filt_slct                           = spatialfilter(ix,:);
        
        multip                              =   filt_slct*data_in.trial{nt};
        multip_avg                          =   squeeze(nanmean(multip,1));
        
        tmp_data                            = [tmp_data; multip_avg]; clear multip* filt_slct tmp_vox ix
        
    end
    
    data_out.trial{nt}                      = tmp_data; clear tmp_data;
    
end

data_out.time                               = data_in.time;
data_out.fsample                            = data_in.fsample;
data_out.label                              = voxel_index_plus_name(:,1);
data_out.trialinfo                          = data_in.trialinfo;