function func_plotstatanova(cfg_in,data_in,stat_in)

for ncluster = 1:length(stat_in.posclusters)
    
    nw_mat                          = stat_in.posclusterslabelmat;
    nw_mat(nw_mat ~= ncluster)      = 0;
    nw_mat(nw_mat == ncluster)      = 1;
    
    vct                             = nw_mat .* stat_in.mask .* stat_in.stat;
    vct(vct ~= 0)                   = 1;
    
    list_chan                       = {};
    
    for nchan = 1:length(stat_in.label)
        if max(vct(nchan,:)) > 0
            list_chan{end+1}        = stat_in.label{nchan};
        end
    end
    
    if length(unique(vct)) > 1
        
        data_plot                   = [];
        
        for nsub = 1:size(data_in,1)
            for ncond = 1:size(data_in,2)
                
                t1                  = nearest(data_in{nsub,ncond}.time , stat_in.time(1));
                t2              	= nearest(data_in{nsub,ncond}.time , stat_in.time(end));
                
                find_chan_in_data   = [];
                find_chan_in_stat   = [];
                
                for nc = 1:length(list_chan)
                    find_chan_in_data            	= [find_chan_in_data; find(strcmp(list_chan{nc},data_in{nsub,ncond}.label))];
                    find_chan_in_stat            	= [find_chan_in_stat; find(strcmp(list_chan{nc},stat_in.label))];
                end
                
                vct_y                   = data_in{nsub,ncond}.avg(find_chan_in_data,t1:t2);
                data_plot(nsub,ncond)   = mean(mean(vct(find_chan_in_stat,:) .* vct_y));
                
                clear vct_y t1 t2 find_chan_in_data
                
            end
        end
        
        mean_data                   = nanmean(data_plot,1);
        bounds                      = nanstd(data_plot, [], 1);
        bounds_sem                  = bounds ./ sqrt(size(data_plot,1));
        
        subplot(cfg_in.nrow,cfg_in.ncol,cfg_in.start+ncluster);
        errorbar(mean_data,bounds_sem,'-ks');
        
        nb_con                      = size(data_in,2);
        
        xlim([0 nb_con+1]);
        xticks(1:nb_con);
        xticklabels(cfg_in.list_cond);
        
        vct_test                    = {[1 2] [1 3] [2 4] [3 4]};
        vct_p                       =[];
        
        for nt = 1:length(vct_test)
            [h_lu,p_lu]             = ttest(data_plot(:,vct_test{nt}(1)),data_plot(:,vct_test{nt}(2)));
            vct_p                	= [vct_p p_lu]; clear h_lu p_lu
        end
        
        vct_p                       = vct_p .* length(vct_test);
        fnd_sig                     = find(vct_p < 0.05);
        
        vct_p                       = vct_p(fnd_sig);
        vct_test                	= vct_test(fnd_sig);
     
        if isfield(cfg_in,'z_limit')
            ylim(cfg_in.z_limit);
            yticks(cfg_in.z_limit);
        end
        
        if isfield(cfg_in,'hline')
            hline(cfg_in.hline,'--r');
        end
        
        sigstar(vct_test,vct_p);
        set(gca,'FontSize',12,'FontName', 'Calibri','FontWeight','Light');

    end
end