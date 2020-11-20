clear ; clc ;
addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;

global ft_default
ft_default.spmversion = 'spm12';

[~,suj_list,~]              = xlsread('../../documents/PrepAtt22_PreProcessingIndex.xlsx','A:B');
suj_list                    = suj_list(2:22,2);

ilu                         = 0;

for sb = 1:21
    
    suj                     = suj_list{sb};
    list_cond               = {'DIS','fDIS'};
    
    for ncond = 1:length(list_cond)
        
        ext_vrbl1           = 'mgranger';
        
        %         ext_vrbl2           = 'broad';
        %         ext_name            = ['AudTPFC.1t120Hz.m200p800msCov.' ext_vrbl1 '.averaged'];
        
        ext_vrbl2           = 'narrow';
        ext_name            = ['AudTPFCAveraged.40t120Hz.m200p800msCov.' ext_vrbl1];
        
        fname               = ['../../data/scnd_round/' suj '.' list_cond{ncond} '.' ext_name '.mat'];
        
        fprintf('Loading %20s\n',fname); load(fname);
        
        fwin                = 10;
        fstart              = 60;
        fend                = 90;
        
        mgranger.grangerspctrm = 5.*log((1+mgranger.grangerspctrm)./(1-mgranger.grangerspctrm)); clear data;
        
        ext_name            = [num2str(fstart) 't' num2str(fend) 'Hz' num2str(fwin) 'step'];
        
        for nfreq = fstart:fwin:fend
            
            ix1                 = find(mgranger.freq == nfreq);
            ix2                 = find(mgranger.freq == nfreq+fwin);
            
            dataF               = squeeze(mean(mgranger.grangerspctrm(:,:,ix1:ix2),3));
            
            for seed = 1:length(mgranger.label)
                for target = 1:length(mgranger.label)
                    
                    if seed ~= target
                        
                        ilu                             = ilu + 1;
                        
                        grng                            = dataF(seed,target);
                        comb_name                       = [mgranger.label{seed} '_t_' mgranger.label{target}];
                        
                        table_summary(ilu).sub          = suj;
                        table_summary(ilu).cond         = list_cond{ncond};
                        table_summary(ilu).chn          = comb_name;
                        table_summary(ilu).freq         = [num2str(nfreq) 'Hz'];
                        table_summary(ilu).grng         = grng;
                        
                        clear grng;
                        
                    end
                    
                end
            end
            
            clear dataF
            
        end
        
    end
end

clearvars -except table_summary ext_name ext_vrbl*;

table_summary           = struct2table(table_summary);
fname_out               = ['../../data/r_data/Scndround_pat22DIS.' ext_vrbl1 '.' ext_vrbl2 '.' ext_name '.txt'];
writetable(table_summary,fname_out);