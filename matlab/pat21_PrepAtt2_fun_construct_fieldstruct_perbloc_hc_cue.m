function PrepAtt2_fun_construct_fieldstruct_perbloc_hc_cue(suj,time_pre,time_post)

addpath(genpath('/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.analysis.2/scripts.m/'));

elan_file = ['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/meg/' suj '.pat2.fin.meg.eeg'];
pos_orig = load(['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/pos/' suj '.pat2.fin.pos']);

% Load Pos Files
% Creates a fourth column with Cue_Side

lock = 1 ;

pos_orig        =   pos_orig(pos_orig(:,3)==0,:);
pos_orig        =   pos_orig(floor(pos_orig(:,2)/1000)==lock,1:2);
pos_orig(:,3)   =   pos_orig(:,2) - (lock*1000);
pos_orig(:,4)   =   floor(pos_orig(:,3)/100);
pos_orig(:,5)   =   floor((pos_orig(:,3)-100*pos_orig(:,4))/10);     % Determine the DIS latency

pos_orig        = pos_orig(pos_orig(:,5) == 0,:);

% Define width of a bloc

tmp = load(['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/res/' suj '.dsheader.log']);
dur = tmp(1);

if strcmp(suj,'yc1')
    nseq=14;
else
    nseq=15;
end

for b = 1:nseq
    bloc_dur(b,1) = 600 * dur * (b-1) ;
    bloc_dur(b,2) = 600 * dur * b ;
end

clear tmp

% Creating A Fieldtrip Template

for b = 1:nseq
    
    pos_trans = [];
    
    lim1 = bloc_dur(b,1);
    lim2 = bloc_dur(b,2);
    
    pos_trans = pos_orig(pos_orig(:,1) > lim1 & pos_orig(:,1) < lim2,:);
    
    Ds_Name = ['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/ds/' suj '.pat2.b' num2str(b) '.ds'];
    
    cfg=[];
    
    cfg.dataset = Ds_Name ;
    cfg.trialfun = 'ft_trialfun_general';
    cfg.trialdef.eventtype  = 'UPPT001';
    cfg.trialdef.eventvalue = 101 ;
    cfg.trialdef.prestim    =  time_pre;
    cfg.trialdef.poststim   =  time_post;
    
    cfg             =   ft_definetrial(cfg);
    cfg.channel     =   'MEG';
    template        =   ft_preprocessing(cfg);
    
    Fs = template.hdr.Fs ;
    
    nsmp_before = Fs * time_pre  ;
    nsmp_after  = Fs * time_post - 1 ;
    
    dir_field     =    ['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.field/data/' suj '/'];
    dir_mat       =    [dir_field 'elan/'];
    
    for cond={'V','L','R','N',''}
        
        data_elan = template ;
        
        if strcmp(cond{:},'L')
            pos=pos_trans(pos_trans(:,4)==1,:);
        elseif strcmp(cond{:},'R')
            pos=pos_trans(pos_trans(:,4)==2,:);
        elseif strcmp(cond{:},'V')
            pos=pos_trans(pos_trans(:,4)~=0,:);
        elseif strcmp(cond{:},'N')
            pos=pos_trans(pos_trans(:,4)==0,:);
        else
            pos = pos_trans ;
        end
        
        data_elan.cfg.trl    = [];
        data_elan.sampleinfo = [];
        data_elan.trial      = [];
        data_elan.time       = [];
        
        data_elan.cfg.trl    = [pos(:,1)-nsmp_before pos(:,1)+nsmp_after repmat(-(Fs*time_pre),size(pos,1),1) pos(:,3)];
        data_elan.sampleinfo = [pos(:,1)-nsmp_before pos(:,1)+nsmp_after];
        
        data_elan.trialinfo = pos(:,2);
        
        for n = 1:size(pos,1)
            
            data_elan.time{n}  =  template.time{1} ;
            
            idx_start       =  data_elan.sampleinfo(n,1);
            idx_end         =  data_elan.sampleinfo(n,2);
            
            data_elan.trial{n} = eeg2mat(elan_file,idx_start,idx_end,1:275);
            
        end
        
        mat_name_out=[dir_mat suj '.pat2.' cond{:} 'CnD.b' num2str(b) '.mat'];
        
        fprintf('Saving: %s\n',mat_name_out);
        save(mat_name_out,'data_elan','-v7.3')
        fprintf('%s\n','Done!');
        
        data_elan.cfg.cache_pos     = pos_trans;
        
    end
    
end