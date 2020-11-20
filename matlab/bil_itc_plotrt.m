clear; clc;
close all;

if isunix
    project_dir             = '/project/3015079.01/data/';
else
    project_dir             = 'P:/3015079.01/data/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

alldata                     = [];

for nsuj = 1:length(suj_list)
    
    sujName                 = suj_list{nsuj};
    list_cue                = {'pre' 'retro'};
    
    for ncue = 1:2
        fname               = [project_dir sujName '/tf/' sujName '.' list_cue{ncue} 'cuelock.itc.5binned.withEvoked.withIncorrect.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        for nbin = 1:length(phase_lock)
            alldata(nsuj,ncue,nbin)  = phase_lock{nbin}.mean_rt;
        end
        
        clear phase_lock nbin
        
    end
    
    clear sujName ncue
    fprintf('\n');
    
end

keep alldata list_cue

% save('D:/Dropbox/project_me/data/bil/itc.perc.with.cue.mat','alldata');

%%

figure;
hold on;

list_color          = {'blue' 'magenta'};
list_addon          = [0 0.2];

for ncue = 1:size(alldata,2)
    
    tmp         	= squeeze(alldata(:,ncue,:));
    mean_data    	= mean(tmp,1);
    bounds       	= std(tmp, [], 1);
    bounds_sem     	= bounds ./ sqrt(size(tmp,1));
    
    x             	= [1:size(tmp,2)] + list_addon(ncue);
    y             	= mean_data;
    errorbar(x,y,bounds_sem,['-' list_color{ncue}(1) 's'],'LineWidth',2,'MarkerSize',10,'MarkerEdgeColor',list_color{ncue},'MarkerFaceColor',list_color{ncue});
    
end

xlim([0 size(alldata,3)+1])
xticks([1 3 5]);
xticklabels({'Fastest' 'Median' 'Slowest'});
ylim([0 2.5]);
yticks([0 0.5 1 1.5 2 2.5]);
grid on;

ylabel('mean RT')
xlabel('RT Bins')
legend(list_cue);

set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','Light');