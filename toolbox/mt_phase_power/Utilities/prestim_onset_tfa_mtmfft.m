function [tfa_hit, tfa_miss]=prestim_onset_tfa_mtmfft(TFA_st,input_data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mireia Torralba 2017 (MRG group)
%
% Perform TFA
%
% Inputs
%  TFA_st:      Structure containing definitions for analysis
%  input_data:  Fieldrip-formatted dataset to analyze
% Outputs
%   tfa:        Fieldtrip-formatted TFA data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch TFA_st.output
    case 'pow'
        param='powspctrm';
    case 'fourier'
        param='fourierspctrm';
end

samples=round((TFA_st.Num_cycles./TFA_st.FOI)*input_data.fsample);
timwin=samples./input_data.fsample;

cfg=[];
cfg.toilim=[-timwin(1) 0];
tmp=ft_redefinetrial(cfg,input_data);
%timwin=length(tmp.time{1,1})/tmp.fsample;
cfg=[];
cfg.method='mtmfft';
cfg.pad='maxperlen';
cfg.foi=TFA_st.Num_cycles/timwin(1);
cfg.taper=TFA_st.Taper;
cfg.output=TFA_st.output;
cfg.keeptrials='yes';
tfa=ft_freqanalysis(cfg,tmp);


for i=2:length(TFA_st.FOI)
    
    cfg=[];
    cfg.toilim=[-timwin(i) 0];
    tmp=ft_redefinetrial(cfg,input_data);
    
    %Here, to avoid fieldtrip doing weird stuff with frequencies!!!!
    %timwin=length(tmp.time{1,1})/tmp.fsample;
    
    
    cfg=[];
    cfg.method='mtmfft';
    cfg.pad='maxperlen';
    cfg.foi=TFA_st.Num_cycles/timwin(i);
    cfg.taper=TFA_st.Taper;
    cfg.output=TFA_st.output;
    cfg.keeptrials='yes';
    tmp_tfa=ft_freqanalysis(cfg,tmp);
    
   tfa.freq(1,i)=tmp_tfa.freq;
   switch TFA_st.output
       case 'pow'
           tfa.powspctrm(:,:,i)=squeeze(tmp_tfa.powspctrm);
       case 'fourier'
           tfa.fourierspctrm(:,:,i)=squeeze(tmp_tfa.fourierspctrm);
   end
end

%Perform TFA analysis
%Now select only the windows corresponding to N cycles before stim at each
%frequency (these coincide with the diagonal term)

% switch TFA_st.output
%     case 'pow'
%         toi_matrix=nan(size(tfa.powspctrm,1),size(tfa.powspctrm,2),size(tfa.powspctrm,3));
%         for fr=1:length(TFA_st.FOI)
%             toi_matrix(:,:,fr)=squeeze(tfa.powspctrm(:,:,fr,fr));
%         end
%         tfa.powspctrm=toi_matrix;
%     case 'fourier'
%         toi_matrix=nan(size(tfa.fourierspctrm,1),size(tfa.fourierspctrm,2),size(tfa.fourierspctrm,3));
%         for fr=1:length(TFA_st.FOI)
%             toi_matrix(:,:,fr)=squeeze(tfa.fourierspctrm(:,:,fr,fr));
%         end
%         tfa.fourierspctrm=toi_matrix;
%         
% end

%Now select hits (1) and misses (0)

cfg=[];
if isfield(TFA_st,'Avg_trials')
    cfg.avgoverrpt=TFA_st.Avg_trials;
end
cfg.trials=(tfa.trialinfo(:,1)==1);
tfa_hit=ft_selectdata(cfg,tfa);
cfg.trials=(tfa.trialinfo(:,1)==0);
tfa_miss=ft_selectdata(cfg,tfa);

clearvars -except tfa_*