clear ; clc ; dleiftrip_addpath ;

%The PLF was derived by first unit normalizing the magnitude of the phase angles (obtained in the
%time requency analysis outlined earlier), then averaging(in the complex domain) across the trials, 
% and getting the absolute value of the average. A PLF value close to 0 reflects
% high variability of phase angles across trials, whereas a PLF
% value of 1 reflects all trials having the same phase angle.
% PLFs were calculated for blank trials at the time of visual
% target/distractor onset. 

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))] ;
    fprintf('Loading\n')
    
    fname       = ['../data/all_data/' suj '.CnD.RamaBigCov.waveletFOURIER.5t15Hz.m3000p3000.mat'];
    load(fname);
   
    cfg         = [];
    cfg.latency = [-0.2 2];
    freq        = ft_selectdata(cfg,freq);
    
    clear *_angle 
    
    ph_angle     = angle(freq.fourierspctrm);
        
    for a = 1:size(ph_angle,1)
        for b = 1:size(ph_angle,2)
            for c = 1:size(ph_angle,3)
                
                mtrx                    = squeeze(ph_angle(a,b,c,:));
                
                flg                     = find(isnan(mtrx));
                
                if length(flg) == 0
                    %                     norm_angle(a,b,c,:) = h_createUnitVector(mtrx);
                    norm_angle(a,b,c,:)     = mtrx/norm(mtrx);
                else
                    norm_angle(a,b,c,:) = mtrx;
                end
                
            end
        end
    end
    
    clear a b c
    
    mean_angle   = squeeze(meanangle(norm_angle,1));
    mean_angle   = abs(mean_angle);
    
    for chan = 88:99
        figure;
        imagesc(freq.time,freq.freq,squeeze(mean_angle(chan,:,:)),[0 0.05]);
        xlim([-0.2 2]);
        ylim([5 15]);
        axis xy
    end
    
end