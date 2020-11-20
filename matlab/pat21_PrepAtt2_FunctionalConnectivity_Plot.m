clear ; clc ; dleiftrip_addpath ;

for j = 1:3
    
    gavg{j}.powspctrm = [];
    
    for sb = 1:14
        
        suj_list                    = [1:4 8:17];
        suj                         = ['yc' num2str(suj_list(sb))];
        
        load(['../data/tfr/' suj '.Soma.CohCohImagPLV.AuditoryWithIPSFEF.mat'])
        gavg{j}.powspctrm       = cat(5,gavg{j}.powspctrm ,suj_coh{j}.powspctrm);
        gavg{j}.time            = suj_coh{j}.time;
        gavg{j}.freq            = suj_coh{j}.freq;
        gavg{j}.dimord          = suj_coh{j}.dimord;
        gavg{j}.label           = {'HL1','HR1','LI1','LI2','RI1','RI2','SL1','SR1','RF1'};
        
    end
    
    gavg{j}.powspctrm       = squeeze(mean(gavg{j}.powspctrm,5));
    
    aud_list    = [find(strcmp(gavg{j}.label,'Heschl_L13')) find(strcmp(gavg{j}.label,'Heschl_R2')) find(strcmp(gavg{j}.label,'Temporal_Sup_L144')) find(strcmp(gavg{j}.label,'Temporal_Sup_R79'))];
    chan_list   = 1:length(gavg{j}.label);
    
    for xi = 1:4
        chan_list(chan_list==aud_list(xi))=[];
    end
    
    for x = 1:length(aud_list)
        for y = 1:length(chan_list)
            
            tmp                     = squeeze(gavg{j}.powspctrm(aud_list(x),chan_list(y),:,:,:,:));
            tmp                     = squeeze(mean(tmp,3));
            
            imagesc(gavg{j}.time, gavg{j}.freq, tmp);
            axis xy
            title([gavg{j}.label{aud_list(x)} '-' gavg{j}.label{chan_list(y)}]);
            xlim([-0.5 1.2]);
            ylim([5 15]);
            
        end
    end
    
end

clearvars -except gavg chan_list aud_list

for x = 1:length(aud_list)
    for y = 1:length(chan_list)
        figure;
        for j = 1:3
            subplot(3,1,j)
            
            tmp                     = squeeze(gavg{j}.powspctrm(aud_list(x),chan_list(y),:,:,:,:));
            tmp                     = squeeze(mean(tmp,3));
            
            imagesc(gavg{j}.time, gavg{j}.freq, tmp);
            axis xy
            title([gavg{j}.label{aud_list(x)} '-' gavg{j}.label{chan_list(y)}]);
            xlim([-0.5 1.2]);
            ylim([5 15]);
            
        end
    end
end