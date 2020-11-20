function PrepAtt2_fun_construct_fieldstruct_custom_hc_bp(suj,lock,time_pre,time_post)

elan_file = ['../data/eeg/' suj '.pat2.fin.meg.eeg'];
pos_orig = load(['../data/pos/' suj '.pat2.fin.pos']);

% Load Pos Files
% Creates a fourth column with Cue_Side

pos_orig            = pos_orig(pos_orig(:,3)==0,:);
pos_orig            = pos_orig(floor(pos_orig(:,2)/1000)==lock,1:2);
pos_orig(:,3)       = pos_orig(:,2) - (lock*1000);
pos_orig(:,4)       = floor(pos_orig(:,3)/100);
pos_orig(:,5)       = floor((pos_orig(:,3)-100*pos_orig(:,4))/10);     % Determine the DIS latency

pos_orig            = pos_orig(pos_orig(:,5) == 0,:);

% Define width of a bloc

tmp = load(['../data/log/' suj '.dsheader.log']);
dur = tmp(1);

for b = 1:15
    bloc_dur(b,1) = 600 * dur * (b-1) ;
    bloc_dur(b,2) = 600 * dur * b ;  
end

PrepAtt2_gp_build

clear tmp

cnd     = {'pt1','pt2','pt3'};

% Creating A Fieldtrip Template

for b = 1:3
    
    pos_trans = [];
    
    for n = 1:length(blc_grp{b})
        
        lim1 = bloc_dur(blc_grp{b}(n),1);
        lim2 = bloc_dur(blc_grp{b}(n),2);
        
        pos_trans = [pos_trans ; pos_orig(pos_orig(:,1) > lim1 & pos_orig(:,1) < lim2,:)];
        
    end
    
    Ds_Name = ['../data/ds/' suj '.pat2.b' num2str(blc_grp{b}(1)) '.ds'];
    
    cfg                     =[];
    cfg.dataset             = Ds_Name ;
    cfg.trialfun            = 'ft_trialfun_general';
    cfg.trialdef.eventtype  = 'UPPT001';
    cfg.trialdef.eventvalue = 251 ;
    cfg.trialdef.prestim    =  time_pre;
    cfg.trialdef.poststim   =  time_post;
    
    cfg                     =ft_definetrial(cfg);
    cfg.channel             ='MEG';
    template                =ft_preprocessing(cfg);
    Fs                      =template.hdr.Fs ;
    
    nsmp_before     = Fs * time_pre  ;
    nsmp_after      = Fs * time_post - 1 ;
    
    dir_field       =    '../data/';
    dir_mat         =    [dir_field 'elan/'];
    
    for cond = {''}
        
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
        
        for n=1:size(pos,1)
            
            data_elan.time{n}  =  template.time{1} ;
            
            idx_start       =  data_elan.sampleinfo(n,1);
            idx_end         =  data_elan.sampleinfo(n,2);
            
            data_elan.trial{n}=eeg2mat(elan_file,idx_start,idx_end,1:275);
            
        end
        
        mat_name_out            =[dir_mat suj '.' cnd{b} '.' cond{:} 'bp.mat'];
        data_elan.cfg.cache_pos = pos_orig(:,1);
        
        fprintf('Saving: %s\n',mat_name_out);
        
        save(mat_name_out,'data_elan','-v7.3')
        fprintf('%s\n','Done!');
        
        
    end
end