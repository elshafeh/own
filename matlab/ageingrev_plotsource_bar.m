clear ; clc ; close all;

global ft_default
ft_default.spmversion = 'spm12';

[~,allsuj,~]    = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{2}    = allsuj(2:15,1);
suj_group{1}    = allsuj(2:15,2);

load ../../data/template/template_grid_0.5cm.mat

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    lst_freq    = {'11t15Hz'};
    
    lst_time    = {'p600p1000'};
    
    lst_bsl     = 'm600m200';
    
    ext_comp    = 'dpssFixedCommonDicSourceMinEvoked0.5cm.mat';
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'CnD';
        lst_sub_cond        = {''};
        
        for nf = 1:length(lst_freq)
            for nt = 1:length(lst_time)
                for nc = 1:length(lst_sub_cond)
                    
                    dir_data                                     = '../../data/alpha_source/';
                    fname = [dir_data suj '.' cond_main lst_sub_cond{nc} '.' lst_freq{nf} '.' lst_bsl '.' ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    bsl_source                                    = source; clear source
                    
                    fname = [dir_data suj '.' cond_main lst_sub_cond{nc} '.' lst_freq{nf} '.' lst_time{nt}   '.' ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    act_source                                    = source; clear source
                    pow                                           = (act_source-bsl_source)./bsl_source;
                    pow(isnan(pow))                               = 0;
                    source_avg{ngrp}{sb,nf,nt,nc}.pow             = pow;
                    source_avg{ngrp}{sb,nf,nt,nc}.pos             = template_grid.pos ;
                    source_avg{ngrp}{sb,nf,nt,nc}.dim             = template_grid.dim ;
                    source_avg{ngrp}{sb,nf,nt,nc}.inside          = template_grid.inside;
                    
                    clear act_source bsl_source
                end
            end
        end
    end
end

lst_sub_cond        = {''};

clearvars -except source_avg lst_*; clc ;

[indx,list_H]       = h_createIndexfieldtrip(source_avg{1}{1,1}.pos);

list_roi{1}         = {'Precentral_L','Postcentral_L'};
list_roi{2}         = {'Occipital_Sup_L','Occipital_Sup_R','Occipital_Mid_L','Occipital_Mid_R', ... 
    'Occipital_Inf_L','Occipital_Inf_R','Precuneus_L','Precuneus_R'};


source_to_plot      = [];

for ng = 1:2
    for ns = 1:14
        for nbig = 1:length(list_roi)
            for nsmall = 1:length(list_roi{nbig})
                
                roi                     = list_roi{nbig}{nsmall};
                find_roi                = find(strcmp(list_H,roi));
                find_vox                = indx(indx(:,2) == find_roi,1);
                tmp(nsmall)             = nanmean(source_avg{ng}{ns,1}.pow(find_vox,1));
                
                
            end
            
            source_to_plot(ng,ns,nbig)  = mean(tmp); clear tmp;
            
        end
    end
end

big_name            = {'left motor','occipital'};
list_name           = {'young' 'old'};
figure;

for nbig = 1:2
        
    vct_to_plot     = squeeze(source_to_plot(:,:,nbig));
    nb_suj          = 14;
    
    dim_avg         = 2;
    
    mean_to_plot    = mean(vct_to_plot,dim_avg);
    sem_to_plot     = std(vct_to_plot,[],dim_avg)/sqrt(nb_suj); % calculate sem
    
    subplot(2,2,nbig)
    hold on
    
    bar(mean_to_plot);
    
    er              = errorbar(mean_to_plot,sem_to_plot,'LineWidth',1,'LineStyle','none');
    er.Color        = [0 0 0];
    er.LineStyle    = 'none';
    
    title([big_name{nbig} ' ROIs']);
    
    xticks(0:length(list_name)+1)
    xticklabels([{''} list_name {''}]);
    xlim([0 length(list_name)+1]);
    ylim([-0.3 0.3]);
    
    grid on
    set(gca,'FontSize',14);
    
end