clc;clear;

suj_list                                        = dir('../data/sub*');

for ns = 1:length(suj_list)
    
    suj                                         = suj_list(ns).name;
    
    new_suj_list{ns}                            = suj;
    
    sub_struct{ns}                              = [];
    
    dir_data                                    = ['../data/' suj '/log/'];
    fileName                                    = dir([dir_data '*_JYcent_block_Logfile.mat']);
    
    fileName                                    = [fileName.folder '/' fileName.name];
    
    fprintf('Loading %s\n',fileName);
    load(fileName);
    
    for ntrial = 1:height(Info.TrialInfo)
        
        sub_struct{ns}(ntrial,1)                = Info.TrialInfo(ntrial,:).nbloc;
        
        chk_rt                                  = cell2mat(Info.TrialInfo(ntrial,:).repRT) * 1000;
        chk_rp                                  = cell2mat(Info.TrialInfo(ntrial,:).repCorrect);
        
        if isempty(chk_rp)
            sub_struct{ns}(ntrial,2)            = NaN;
        else
            sub_struct{ns}(ntrial,2)            = chk_rp;
        end
        
    end
    
end

clearvars -except sub_struct list_* new_suj_list

figure;
hold on

data_plot               = [];

for ns = 1:length(new_suj_list)
    
    data_all            = sub_struct{ns};
    bloc_numbers        = unique(data_all(:,1));
    
    for yi =  1:length(bloc_numbers)
        
        data_sub            = data_all(data_all(:,1) == bloc_numbers(yi),2);
        prc_corrct          = length(data_sub(data_sub ==1)) / length(data_sub);
        
        data_plot(ns,yi)    = prc_corrct;
        
        clear prc_corrct data_sub
        
    end
end

data_plot(data_plot == 0)   = NaN;

dat_x                       = 1:8;
dat_y                       = nanmean(data_plot,1);

dat_err                     = nanstd(data_plot',[],2) ./ sqrt(size(data_plot,1));

errorbar(dat_x,dat_y,dat_err,'-k','LineWidth',2);

xticks(0:9)
xticklabels({'','b1','b2','b3','b4','b5','b6','b7','b8',''});
xlim([0 9]);

ylim([0.6 1]);

grid on
set(gca,'FontSize',14);