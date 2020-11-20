clear ; clc ;

clear  ; clc ;

tname = '~/Dropbox/Fieldtripping/R/txt/PrepAtt22_behav_table4R.csv';
behav_in = readtable(tname);

i        = 0 ;

for g = 1:4
    
    %     figure;
    group_table = behav_in(behav_in.DIS ==0 & behav_in.CORR==1 & behav_in.idx_group ==g,:);
    suj_list    = unique(group_table.sub_idx);
    
    for sb = 1:length(suj_list)
        
        i = i +1 ;
        
        data_suj = group_table(group_table.sub_idx==sb,:);
        
        data{1}  = data_suj(data_suj.CUE == 0,11);
        data{2}  = data_suj(mod(data_suj.TAR,2)~= 0 & data_suj.CUE == 0,11);
        data{3}  = data_suj(mod(data_suj.TAR,2)== 0 & data_suj.CUE == 0,11);
        
        data{4}  = data_suj(data_suj.CUE ~= 0,11);
        data{5}  = data_suj(data_suj.CUE == 1,11);
        data{6}  = data_suj(data_suj.CUE == 2,11);
        
        lst_tst  = [1 4;2 5;3 6;1 5; 1 6];
        tst_nme  = {'IvN','LNvL','RNvR','NvL','NvR'};
        
        for ntest = 5%:length(tst_nme)
            
            for xi = 1:2
                tit{xi} = data{lst_tst(ntest,xi)}.RT;
                rt_final{xi}  = calc_tukey(tit{xi});
            end
            
            lmt      = min([size(rt_final{1},1) size(rt_final{2},1)]);
            for xi = 1:2
                trl{xi}  = PrepAtt2_fun_create_rand_array(1:size(rt_final{xi},1),lmt);
            end
            
            summary(i,1)  = (median(rt_final{1}(trl{1}))-median(rt_final{2}(trl{2})))/median(rt_final{2}(trl{2}));
            
            %             lmt      = min([size(rt_final{1},1) size(rt_final{2},1)]);
            %             for xi = 1:2
            %                 trl{xi}  = PrepAtt2_fun_create_rand_array(1:size(rt_final{xi},1),lmt);
            %             end
            %             [h,p]        = ttest(rt_final{1}(trl{1}),rt_final{2}(trl{2}));
            %             summary{i,1} = ['group' num2str(g) 'suj' num2str(sb)];
            %             summary{i,ntest+1} = p;
            
        end
        
        
    end
end

clearvars -except summary ;

plot(summary)