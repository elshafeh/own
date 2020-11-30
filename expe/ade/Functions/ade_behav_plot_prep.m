function [perc_to_plot] = ade_behav_plot_prep(Info)

for nblock = 1:length(Info.block)
    for nnoise = 1:2
        for nside = 1:2
            
            trial_side                              = [Info.block(nblock).trial.side]';
            trial_nois                              = [Info.block(nblock).trial.nois]';
            trial_corr                              = [Info.block(nblock).trial.correct]';
            trial_conf                              = [Info.block(nblock).trial.confidence]';
            
            trial_conc                              = [trial_side trial_nois trial_corr trial_conf];
            
            trial_sub                               = trial_conc(trial_conc(:,1) == nside & trial_conc(:,2) == nnoise-1,:);
            
            % block,noise,side,measure (corr,conf)
            
            find_corr                               = size(trial_sub(trial_sub(:,3) == 1),1); 
            find_conf                               = size(trial_sub(trial_sub(:,4) == 1),1);  
            tot_len                                 = size(trial_sub,1);
            
            perc_to_plot(nblock,nnoise,nside,1)     = find_corr/tot_len; % perc correct
            perc_to_plot(nblock,nnoise,nside,2)     = find_conf/tot_len; % perc confident
            
        end
    end
end
