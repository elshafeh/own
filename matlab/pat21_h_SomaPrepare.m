function virtsens = h_SomaPrepare(virtsens)

ft_progress('init','text',    'Please wait...');

for xi = 1:length(virtsens.trialinfo)
    
    ft_progress(xi/length(virtsens.trialinfo), 'Processing trial %d from %d\n', xi, length(virtsens.trialinfo));
    
    nw_pow{xi}  = [];
    nw_lab      = {};
    
    for yi = 1:2:length(virtsens.label)
        
        nw_pow{xi}      = [nw_pow{xi}; mean(virtsens.trial{xi}(yi:yi+1,:,:),1)];
        nw_lab{end+1}   = virtsens.label{yi};
        
    end
    
end

virtsens.trial  = nw_pow ; clear nw_pow ;
virtsens.label  = nw_lab ; clear nw_lab ;