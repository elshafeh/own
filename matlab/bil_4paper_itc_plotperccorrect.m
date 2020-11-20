clear; clc;
close all;

if isunix
    project_dir             = '/project/3015079.01/data/';
else
    project_dir             = 'P:/3015079.01/data/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

alldata                     = [];
data4reg                    = [];

for nsuj = 1:length(suj_list)
    
    sujName                 = suj_list{nsuj};
    list_cue                = {''};
    
    fname                   = [project_dir sujName '/tf/' sujName '.cuelock.itc.5binned.withEvoked.withIncorrect.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nbin = 1:length(phase_lock)
        alldata(nsuj,nbin)  = phase_lock{nbin}.perc_corr;
        data4reg         	= [data4reg; nbin phase_lock{nbin}.perc_corr];
    end
    
    clear phase_lock nbin sujName ncue
    
end

keep alldata list_cue data4reg

% save('D:/Dropbox/project_me/data/bil/itc.perc.with.cue.mat','alldata');

%%

figure;
subplot(2,2,1)
hold on;

list_addon          = [0 0.2];

mean_data    	= mean(alldata,1);
bounds       	= std(alldata, [], 1);
bounds_sem     	= bounds ./ sqrt(size(alldata,1));

x             	= [1:size(alldata,2)];
y             	= mean_data;
errorbar(x,y,bounds_sem,['-ks'],'LineWidth',2,'MarkerSize',10,'MarkerEdgeColor','black','MarkerFaceColor','white');


xlim([0 size(alldata,2)+1])
xticks([1 3 5]);
xticklabels({'Fastest' 'Median' 'Slowest'});
ylim([0.6 1]);
yticks([0.6 0.7 0.8 0.9 1]);
grid on;
ylabel('% Correct')
xlabel('RT Bins')
set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','Light');

%%

mdl = fitlm(data4reg(:,1),data4reg(:,2))