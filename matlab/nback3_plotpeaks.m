clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

suj_list               	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname         = ['sub' num2str(suj_list(nsuj))];
    
    % load peak
    fname               = ['/Volumes/heshamshung/nback/peak/' subjectname '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    %     bn_width            = 1;
    dataplot(nsuj,1)    = apeak;%-bn_width;
    %     dataplot(nsuj,2)    = apeak+bn_width;
    
    %     bn_width            = 3;
    dataplot(nsuj,2)    = bpeak;%-bn_width;
    %     dataplot(nsuj,4)    = bpeak+bn_width;
    
end

keep dataplot

figure;
hold on;

for n = 1:2
    x_axes  = repmat(n,length(dataplot),1) + [1.1e-2*(1:length(dataplot))]';
    scatter(x_axes,dataplot(:,n),100);
end

xticks([1.2 2.3]);
xlim([0.9 2.5]);
ylim([5 30]);
xticklabels({'ALPHA','BETA'});
set(gca,'FontSize',20,'FontName', 'Calibri');
ylabel('Peak Frequency Hz');