clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

for sb = 1:21
    
    suj         = ['yc' num2str(sb)];
    lst_cnd     = {'NLCnD','NRCnD','LCnD','RCnD'};
    
    lst_mth     = {'PLV'};
    lst_chn     = {'audR'};
    lst_tme     = {'m350m200','p200p350','p350p500','p500p650','p650p800','p800p950','p950p1100'};
    
    
    for cnd = 1:length(lst_cnd)
        for chn = 1:length(lst_chn)
            for nmethod = 1:length(lst_mth)
                for ntime = 1:length(lst_tme)
                    
                    fname   = ['../data/new_rama_data/' suj '.' lst_cnd{cnd} '.NewRama3Cov.' lst_tme{ntime} '.' lst_chn{chn} '.' lst_mth{nmethod} 'PAC.mat'];
                    
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    % 8-11 55-75
                    
                    x1                       = find(seymour_pac.amp_freq_vec==55);
                    x2                       = find(seymour_pac.amp_freq_vec==75);
                    y1                       = find(seymour_pac.pha_freq_vec==8);
                    y2                       = find(seymour_pac.pha_freq_vec==11);
                    
                    tmp                      = seymour_pac.mpac_norm(x1:x2,y1:y2);
                    data(ntime)              = mean(mean(tmp));
                    
                    clear tmp
                    
                end
                
                data = data-data(1);
                data = data(2:end);
                
                grand_avg{sb,cnd,chn,nmethod}.avg(1,:)    = data;
                grand_avg{sb,cnd,chn,nmethod}.time        = 0.2:0.15:1;
                grand_avg{sb,cnd,chn,nmethod}.label       = {'MI'};
                grand_avg{sb,cnd,chn,nmethod}.dimord      = 'chan_time';
                
                clear data
                
            end
        end
    end
end

clearvars -except grand_avg lst_* ; clc ;

fout =  '../R/doc/PrepAtt22_TimeResolvedPAC.txt';
fid  = fopen(fout,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n','SUB','CUE_CAT','CUE_SIDE','CHAN','METHOD','TIME','PAC');
                    
for sb = 1:21
    
    
    suj         = ['yc' num2str(sb)];
    lst_cnd     = {'NLCnD','NRCnD','LCnD','RCnD'};
    
    lst_mth     = {'PLV'};
    lst_chn     = {'audR'};
    lst_tme     = {'p200p350','p350p500','p500p650','p650p800','p800p950','p950p1100'};
    
    
    for cnd = 1:length(lst_cnd)
        for chn = 1:length(lst_chn)
            for nmethod = 1:length(lst_mth)
                for ntime = 1:length(lst_tme)
                    
                    data = grand_avg{sb,cnd,chn,nmethod}.avg(ntime);
                    
                    sub_list_1 = {'uninformative','uninformative','informative','informative'};
                    sub_list_2 = {'Left','Right','Left','Right'};

                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.2f\n',suj,sub_list_1{cnd},sub_list_2{cnd},lst_chn{chn},lst_mth{nmethod},lst_tme{ntime},data);
                    
                end
            end
        end
    end
end

fclose(fid);

%
% for chn = 1:length(lst_chn)
%     for nmethod = 1:length(lst_mth)
%
%         stat{chn,nmethod,1}         = ft_timelockstatistics(cfg,grand_avg{:,3,chn,nmethod}, grand_avg{:,1,chn,nmethod});
%         stat{chn,nmethod,2}         = ft_timelockstatistics(cfg,grand_avg{:,4,chn,nmethod}, grand_avg{:,2,chn,nmethod});
%
%         stat{chn,nmethod,1}.label   =  {[lst_chn{chn} '.' lst_mth{nmethod} '.LvNL']};
%         stat{chn,nmethod,2}.label   =  {[lst_chn{chn} '.' lst_mth{nmethod} '.RvNR']};
%
%     end
% end
%
% close(h_wait) ;
%
% clearvars -except grand_avg lst_* stat; clc ;
%
% for chn = 1:length(lst_chn)
%     for nmethod = 1:length(lst_mth)
%
%         figure;
%         for ntest = 1:2
%
%             subplot(1,2,ntest)
%             stat{chn,nmethod,ntest}.mask = stat{chn,nmethod,ntest}.prob < 0.2;
%
%             stoplot.avg    = stat{chn,nmethod,ntest}.mask .* stat{chn,nmethod,ntest}.stat;
%             stoplot.time   = stat{chn,nmethod,ntest}.time;
%             stoplot.dimord = stat{chn,nmethod,ntest}.dimord;
%             stoplot.label  = stat{chn,nmethod,ntest}.label;
%
%             ft_singleplotER([],stoplot);
%             ylim([-2 2]);
%
%         end
%     end
% end