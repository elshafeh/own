clear  ; clc ;

tname = '~/Dropbox/Fieldtripping/R/txt/PrepAtt22_behav_table4R.csv';
behav_in = readtable(tname);

i        = 0 ;

for g = 1:4
    
    figure;
    group_table = behav_in(behav_in.DIS ==0 & behav_in.CORR==1 & behav_in.idx_group ==g,:);
    suj_list    = unique(group_table.sub_idx);
    
    for sb = 1:length(suj_list)
        
        i = i +1 ;
        
        data_suj = group_table(group_table.sub_idx==sb,:);
        
        cue_inf  = data_suj(data_suj.CUE ~= 0,11);
        cue_unf  = data_suj(data_suj.CUE == 0,11);
        
%         calc_tukey(
        
        fprintf('Randomising\n');
        
        lmt      = min([size(cue_inf.RT,1) size(cue_unf.RT,1)]);
        trl_inf  = PrepAtt2_fun_create_rand_array(1:size(cue_inf.RT,1),lmt);
        trl_unf  = PrepAtt2_fun_create_rand_array(1:size(cue_unf.RT,1),lmt);
        
        cue_inf  = cue_inf.RT(trl_inf);
        cue_unf  = cue_unf.RT(trl_unf);
        
        [h,p]    = ttest(cue_inf,cue_unf);
        
        if length(suj_list) < 8
            subplot(4,2,sb)
        else
            subplot(7,2,sb)
        end
        
        boxplot([cue_inf cue_unf],'labels',{'INF','UNF'});
        
        if p < 0.11
            title('***')
        end
        %         title(['p = ' num2str(p)]);
        
    end
end