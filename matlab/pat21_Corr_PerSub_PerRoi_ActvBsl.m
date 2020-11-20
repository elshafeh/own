clear ; clc ;

ix_f = 0 ;

for ext_freq = {'12t14Hz'};
    
    load ../data/template/source_struct_template_MNIpos.mat
    indx_tot = h_createIndexfieldtrip(source); clear source ;
    
    for cnd_filt = {'Free','Fixed','FreeAvg','FixedAvg'}
        
        ix_f = ix_f + 1;
        
        for sb = 1:14
            
            suj_list = [1:4 8:17];
            
            suj = ['yc' num2str(suj_list(sb))];
            
            sourceAppend{1} = [];
            sourceAppend{2} = [];
            
            list_time = {'bsl','actv'};
            
            for cnd = 1:2
                
                sourceAppend{cnd} = [];
                
                for prt = 1:3
                    
                    fname = dir(['../data/' suj '/source/*.pt' num2str(prt) ...
                        '*.CnD.KT.*' ext_freq{:} '*' list_time{cnd} ...
                        '*' cnd_filt{:} '*mat']);
                    
                    fname = fname.name;
                    
                    fprintf('Loading %50s\n',fname);
                    
                    load(['../data/' suj '/source/' fname]);
                    
                    sourceAppend{cnd} = [ sourceAppend{cnd} source]; clear source ;
                    
                end
                
                load ../data/yctot/rt/rt_CnD_adapt.mat
                
                fprintf('Calculating Correlation\n');
                
                load ../data/yctot/rt/rt_CnD_adapt.mat
                
                r_list = unique(indx_tot(:,2));
                
                for roi = 1:length(unique(indx_tot(:,2)))
                    
                    indx        = indx_tot(indx_tot(:,2)==r_list(roi),1);
                    avg         = nanmean(sourceAppend{cnd}(indx,:),1)';
                    
                    [rho,p]     = corr(avg,rt_all{sb} , 'type', 'Spearman');
                    
                    rho_mask    = p < 0.05 ;
                    
                    rhoM        = rho .* rho_mask ;
                    
                    rhoF        = .5.*log((1+rho)./(1-rho));
                    rhoMF       = .5.*log((1+rhoM)./(1-rhoM));
                    
                    
                    source_avg{sb,ix_f,cnd,roi,1} = rhoF ;
                    source_avg{sb,ix_f,cnd,roi,2} = rhoMF ;
                    
                end
                
            end
            
        end
    end
    
    
end

clearvars -except source_avg

atlas           = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii'); clc ;
clear summary ; ix = 0 ;

cnd_filt = {'Free','Fixed','FreeAvg','FixedAvg'};
cnd_m    = {'masked','unmasked'};


for f = 1:size(source_avg,2)
    
    for ex_m = 1:2
        
        for n = 1:size(source_avg,4)
            
            X = [source_avg{:,f,2,n,ex_m}];
            Y = [source_avg{:,f,1,n,ex_m}];
            
            t = X(isnan(X));
            
            if isempty(t)
                
                [h,p] = ttest(X',Y','alpha',0.05);
                
                if p < 0.05
                    
                    ix = ix + 1;
                    
                    summary(ix).roi     = atlas.tissuelabel{n};
                    summary(ix).filt    = cnd_filt{f};
                    summary(ix).mask    = cnd_m{ex_m};
                    summary(ix).rhoMEA  = mean(X)-mean(Y);
                    summary(ix).rhoMED  = median(X)-median(Y);
                    summary(ix).p       = p;
                    
                end
                
            end
            
        end
        
    end
    
end

summary = struct2table(summary);


clearvars -except source_avg summary