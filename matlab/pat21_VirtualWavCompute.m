clear; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_list = {'DIS','fDIS'};
    
    for cnd = 1:length(cnd_list)
        
        fname_in = [suj '.' cnd_list{cnd} '.VirtTimeCourse'];
        fprintf('\nLoading %50s \n\n',fname_in);
        load(['../data/pe/' fname_in '.mat'])
        
        cfg                 = [];
        cfg.method          = 'wavelet';
        cfg.output          = 'pow';
        cfg.width           =  7 ;
        cfg.gwidth          =  4 ;
        cfg.toi             = -1.5:0.01:1.5;
        cfg.foi             =  1:1:90;
        cfg.keeptrials      = 'no';
        freq                = ft_freqanalysis(cfg,virtsens);
        freq                = rmfield(freq,'cfg');
        
        if strcmp(cfg.keeptrials,'yes');ext_trials = 'KeepTrial';else ext_trials = 'all';end
        if strcmp(cfg.method,'wavelet'); ext_method = 'wav';else ext_method = 'conv';end;
        
        ext_time = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
        ext_freq = [num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz'];
        
        fname_out = ['../data/tfr/' suj '.' cnd_list{cnd} '.' ext_trials '.' ext_method '.' ext_freq '.' ext_time '.mat'];
        fprintf('\nSaving %50s \n\n',fname_out);
        save(fname_out,'freq','-v7.3');
        
    end
end
% end

% i = 0 ; list_total = {};
% list_cue = {'U','L','R'};
% for cnd_cue = 1:4
%     for cnd_delay = 1:4
%         i = i + 1;
%         if cnd_delay == 4
%             idis    = 1:3;
%             ext_dis = '';
%         else
%             idis    = cnd_delay;
%             ext_dis = num2str(idis);
%         end
%         if cnd_cue == 4
%             icue    = 0:2;
%             ext_cue = '';
%         else
%             icue    = cnd_cue-1;
%             ext_cue = list_cue{cnd_cue};
%         end
%         list_total{i}       = [ext_cue cond_list{cnd} ext_dis];
%         itrl                = h_chooseTrial(data,icue,idis,1:4);
%         template.time           = freq.time ;
%         template.freq           = freq.freq ;
%         template.label          = freq.label ;
%         template.condarrange    = list_total;
%         allsuj{sb,i}            = squeeze(mean(freq.powspctrm(itrl,:,:,:),1));
%         clear itrl
%     end
% end
% clearvars -except allsuj ext template cnd cond_list suj_list sb