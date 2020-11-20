clear ; clc ; close all ; dleiftrip_addpath ;

load('../data/yctot/RevNewExtWav.mat');
load('../data/yctot/serenIAF_BslCorrectMinMaxNewIndx.mat');

new_allsuj = allsuj;

orig_list_freq = new_allsuj{1,1}.freq;

for cnd = 1:5
    for sb = 1:14
        
        i = new_allsuj{sb,cnd}.powspctrm;
        
        new_allsuj{sb,cnd}.powspctrm    = zeros(12,size(i,1),9,size(i,3));
        new_allsuj{sb,cnd}.freq         = 9-4:1:9+4;
        new_allsuj{sb,cnd}.dimord       = 'rpt_chan_freq_time';
        
    end
end
    
for cnd = 1:5
    
    for chn = 1:length(new_allsuj{1,1}.label)
        
        for sb = 1:14
            
            for indx_t = 1:6 
                
                for mm = 1:2
                    
                    IAF             = bigassmatrix_freq(cnd,chn,sb,indx_t,mm);
                    fq_ix           = find(round(orig_list_freq)==IAF);
                    
                    tx = indx_t + (6*(mm-1));
                    
                    new_allsuj{sb,cnd}.powspctrm(tx,chn,1:9,:) = allsuj{sb,cnd}.powspctrm(chn,fq_ix-4:fq_ix+4,:);
                    
                end
                
            end
        end
        
    end
end

clearvars -except allsuj new_allsuj

save('../data/yctot/RevFinalAdapt.mat');

% save('../data/yctot/edit_bag.mat','edit_bag');

% nw_powspctrm    = [];
% fq_ix           = find(round(allsuj{sb,cnd}.freq) == round(bigassmatrix_freq(cnd,chn,sb,indx_t)));
% tmp_powspctrm   = allsuj{sb,cnd}.powspctrm(chn,fq_ix-4:fq_ix+4,:);
% nw_powspctrm    = [nw_powspctrm;tmp_powspctrm];