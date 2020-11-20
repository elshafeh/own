function PrepAtt2_fun_eeg2field_cue(suj,time_pre,time_post)

elan_file   = ['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/eeg/' suj '.pat2.fin.eeg.eeg'];
pos_orig    = load(['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/pos/' suj '.pat2.fin.pos']);

% Load Pos Files
% Creates a fourth column with Cue_Side

lock = 1 ;

pos_orig                    = pos_orig(pos_orig(:,3)==0,:);
pos_orig                    = pos_orig(floor(pos_orig(:,2)/1000)==lock,1:2);
pos_orig(:,3)               = pos_orig(:,2) - (lock*1000);
pos_orig(:,4)               = floor(pos_orig(:,3)/100);
pos_orig(:,5)               = floor((pos_orig(:,3)-100*pos_orig(:,4))/10);     % Determine the DIS latency

pos_orig = pos_orig(pos_orig(:,5) == 0,:);

Ds_Name = ['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/ds/' suj '.pat2.b1.ds'];

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

dir_field     =    ['../data/' suj '/'];
dir_mat       =    [dir_field 'elan/'];

load('elan_sens.mat');

for cond = {''}
    
    data_elan = template ;
    
    if strcmp(cond{:},'L')
        pos=pos_orig(pos_orig(:,4)==1,:);
    elseif strcmp(cond{:},'R')
        pos=pos_orig(pos_orig(:,4)==2,:);
    elseif strcmp(cond{:},'V')
        pos=pos_orig(pos_trans(:,4)~=0,:);
    elseif strcmp(cond{:},'N')
        pos=pos_orig(pos_orig(:,4)==0,:);
    else
        pos = pos_orig ;
    end
    
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
    
    mat_name_out=[dir_mat suj '.' cond{:} 'CnD.eeg.mat'];
    
    fprintf('Saving: %s\n',mat_name_out);
    save(mat_name_out,'data_elan','-v7.3')
    fprintf('%s\n','Done!');
    
end