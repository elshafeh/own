clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

allindex                = [];

for nsuj = 1:length(suj_list)
    
    subjectName         = suj_list{nsuj};
    
    if isunix
        subject_folder  = ['/project/3015079.01/data/' subjectName '/'];
    else
        subject_folder  = ['P:/3015079.01/data/' subjectName '/'];
    end
    
    fname_in            = [subject_folder 'tf/' subjectName '.allbandbinning.alpha.band.preCue1.window.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allindex        	= [allindex;info.bin_summary.bins];
    %     allindex        	= [allindex;mean(info.bin_summary.bins,1)];
    
end

keep allindex;

mean_data        	= mean(allindex,1);
bounds           	= nanstd(allindex, [], 1);
errorbar(mean_data,bounds,'-s','MarkerSize',10,'MarkerEdgeColor','red','MarkerFaceColor','red')
xlim([0 6]);
xticks([1 2 3 4 5])
xticklabels({'b1' 'b2' 'b3' 'b4' 'b5'}); 
ylabel('Trial indices');
ylim([1 400]);
yticks([1 400]);

[list(1).h,list(1).p]  	= ttest(allindex(:,1),allindex(:,2));
list(1).test            = 'b1 v b2';

[list(3).h,list(3).p]  	= ttest(allindex(:,1),allindex(:,3));
list(3).test            = 'b1 v b3';

[list(4).h,list(4).p]  	= ttest(allindex(:,1),allindex(:,4));
list(4).test            = 'b1 v b4';

[list(5).h,list(5).p]  	= ttest(allindex(:,1),allindex(:,5));
list(5).test            = 'b1 v b5';

[list(6).h,list(6).p]  	= ttest(allindex(:,2),allindex(:,3));
list(6).test            = 'b2 v b3';

[list(7).h,list(7).p]  	= ttest(allindex(:,2),allindex(:,4));
list(7).test            = 'b2 v b4';

[list(8).h,list(8).p]  	= ttest(allindex(:,2),allindex(:,5));
list(8).test            = 'b2 v b5';

[list(9).h,list(9).p]  	= ttest(allindex(:,3),allindex(:,4));
list(9).test            = 'b3 v b4';

[list(10).h,list(10).p] = ttest(allindex(:,3),allindex(:,5));
list(10).test       	= 'b3 v b5';

[list(11).h,list(11).p] = ttest(allindex(:,4),allindex(:,5));
list(11).test          	= 'b4 v b5';