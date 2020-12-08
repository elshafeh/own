function PrepAtt2_fun_eeg2field_disfdis(suj,lock,time_pre,time_post)

elan_file   = ['/Volumes/PAT_MEG2/Fieldtripping/data/eeg/' suj '.pat2.fin.eeg.eeg'];
pos_orig    = load(['/Volumes/PAT_MEG2/Fieldtripping/data/pos/' suj '.pat2.fin.fDisMirror.pos']);

% Load Pos Files
% Creates a fourth column with Cue_Side

pos_orig                    = pos_orig(pos_orig(:,3)==0,:);
pos_orig                    = pos_orig(floor(pos_orig(:,2)/1000)==lock,1:2);
pos_orig(:,3)               = pos_orig(:,2) - (lock*1000);
pos_orig(:,4)               = floor(pos_orig(:,3)/100);
pos_orig(:,5)               = floor((pos_orig(:,3)-100*pos_orig(:,4))/10);     % Determine the DIS latency

Ds_Name = dir(['/Volumes/PAT_MEG2/Fieldtripping/data/ds/' suj '.pat2.*.ds']);
Ds_Name = ['/Volumes/PAT_MEG2/Fieldtripping/data/ds/' Ds_Name(1).name];

cfg         = [];
cfg.dataset = Ds_Name ;

cfg.trialdef.eventtype  = 'UPPT001';
cfg.trialdef.eventvalue = 101 ;
cfg.trialdef.prestim    =  time_pre;
cfg.trialdef.poststim   =  time_post;

cfg             = ft_definetrial(cfg);
cfg.channel     = 'EEG';
template        = ft_preprocessing(cfg);

Fs = template.hdr.Fs ;

nsmp_before = Fs * time_pre  ;
nsmp_after  = Fs * time_post - 1 ;

dir_field     =    ['../data/'];
dir_mat       =    [dir_field 'elan/'];

load('elan_sens.mat');

for cond = {''}
    
    data_elan = template ;
    
    pos = pos_orig ;
    
    data_elan.cfg.trl    = [];
    data_elan.sampleinfo = [];
    data_elan.trial      = [];
    data_elan.time       = [];
    
    data_elan.cfg.trl    = [pos(:,1)-nsmp_before pos(:,1)+nsmp_after repmat(-(Fs*time_pre),size(pos,1),1) pos(:,3)];
    data_elan.sampleinfo = [pos(:,1)-nsmp_before pos(:,1)+nsmp_after];
    
    data_elan.trialinfo = pos(:,2);
    
    for n=1:size(pos,1)
        
        data_elan.time{n}  =  template.time{1} ;
        
        idx_start       =  data_elan.sampleinfo(n,1);
        idx_end         =  data_elan.sampleinfo(n,2);
        
        data_elan.trial{n}=eeg2mat(elan_file,idx_start,idx_end,1:54);
        
        fprintf('Processing Trial %4d out of %4d\n',n,size(pos,1));
        
    end
    
    data_elan       = rmfield(data_elan,'cfg');
    data_elan.label = sens.label;
    
    if lock == 2
        mat_name_out=[dir_mat suj '.' cond{:} 'DIS.eeg.mat'];
    else
        mat_name_out=[dir_mat suj '.' cond{:} 'fDIS.eeg.mat'];
    end
    
    fprintf('Saving: %s\n',mat_name_out);
    save(mat_name_out,'data_elan','-v7.3')
    fprintf('%s\n','Done!');
    
end