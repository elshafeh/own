function nb_plot = h_howmanyplots(stat,plimit)

nb_plot                                     = 0;

if ~iscell(stat)
    tmp                                     = stat; clear stat;
    stat{1}                                 = tmp; clear tmp;
end

for nstat = 1:length(stat)
    
    stat{nstat}.mask                        = stat{nstat}.prob < plimit;
    stat2plot                               = h_plotStat(stat{nstat},10e-13,plimit,'stat');
    
    for nchan = 1:length(stat{nstat}.label)
        
        tmp                                 = stat{nstat}.mask(nchan,:,:) .* stat{nstat}.prob(nchan,:,:);
        ix                                  = unique(tmp);
        ix                                  = ix(ix~=0);
        
        if ~isempty(ix)
            nb_plot                         = nb_plot + 1;
        end
    end
end
