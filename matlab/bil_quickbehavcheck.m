clc;clear;

suj_list                                        = dir('../data/sub*/log/*_JYcent_block_Logfile*');

for ns = 1:length(suj_list)
    fname                                       = suj_list(ns).name(1:6);
    list{ns}                                    = fname;
end

[indx,~]                                        = listdlg('ListString',list,'ListSize',[400,400]);

i                                               = 0;

for ns = indx
    
    i                                           = i + 1;
    suj                                         = suj_list(ns).name(1:6);
    
    new_suj_list{i}                             = suj;
    sub_struct{i}                               = [];
    
    dir_data                                    = ['../data/' suj '/log/'];
    fileName                                    = dir([dir_data '*_JYcent_block_Logfile.mat']);
    
    fileName                                    = [fileName.folder '/' fileName.name];
    
    fprintf('Loading %s\n',fileName);
    load(fileName);
    
    for ntrial = 1:height(Info.TrialInfo)
        
        list_cond{1}                            = {'pre','retro'};
        list_cond{2}                            = {'ori','freq'};
        list_cond{3}                            = {'black','white'};
        
        sub_struct{i}(ntrial,1)                 = Info.TrialInfo(ntrial,:).cue; 
        sub_struct{i}(ntrial,2)                 = Info.TrialInfo(ntrial,:).task; 
                
        sub_struct{i}(ntrial,3)                 = Info.TrialInfo(ntrial,:).color; % list_color{Info.TrialInfo(ntrial,:).color};
        
        chk_rt                                  = cell2mat(Info.TrialInfo(ntrial,:).repRT) * 1000;
        chk_rp                                  = cell2mat(Info.TrialInfo(ntrial,:).repCorrect);
        
        if isempty(chk_rt)
            sub_struct{i}(ntrial,4)            = NaN;
        else
            sub_struct{i}(ntrial,4)            = chk_rt;
        end
        
        if isempty(chk_rp)
            sub_struct{i}(ntrial,5)            = NaN;
        else
            sub_struct{i}(ntrial,5)            = chk_rp;
        end
        
        sub_struct{i}(ntrial,6)                 = Info.TrialInfo(ntrial,:).nbloc; 
        
    end
    
end

clearvars -except sub_struct list_* new_suj_list 

figure;

for xi = 1:2 % cue, task, color
    
    subplot(1,2,xi)
    hold on
    
    data_plot                           = [];
    
    for ns = 1:length(new_suj_list)
        
        data_all                        = sub_struct{ns};
        
        nb_block                        = unique(data_all(:,6));
        
        for nb = 1:length(nb_block)
            for yi = 1:2 % types
                
                data_sub                = data_all(data_all(:,xi) == yi & data_all(:,6) == nb_block(nb),5);
                prc_corrct              = length(data_sub(data_sub ==1)) / length(data_sub);
                
                data_plot(ns,yi,nb)     = prc_corrct;
                
                clear prc_corrct data_sub
                
            end
        end
        
    end
    
    %     plot(data_plot','LineWidth',1);
    
    
    
    dat_y                       = squeeze(mean(data_plot,1));
    dat_err                     = squeeze(std(data_plot,[],1)) ./ sqrt(size(data_plot,1));
    
    list_color                  = 'rb';
    
    %     bar(dat_x,dat_y');
    %     er                          = errorbar(dat_y,dat_err','LineWidth',1,'LineStyle','none');
    %     er.Color                    = [0 0 0];
    %     er.LineStyle                = 'none';
    
    for lu = 1:2
        dat_x                    = [1:size(data_plot,3)] + [(lu-1) * 0.2];
        errorbar(dat_x,dat_y(lu,:),dat_err(lu,:),['-' list_color(lu)],'LineWidth',2);
    end
    
    list_name                   = {'b1','b2','b3','b4','b5','b6','b7','b8'};
    
    xticks(0:length(list_name)+1)
    xticklabels([{''} list_name {''}]);
    xlim([0 length(list_name)+1]);
    
    ylim([0 1]);
    
    list_name                   = list_cond{xi};
    legend(list_name);
    
    grid on
    set(gca,'FontSize',14);
    
end