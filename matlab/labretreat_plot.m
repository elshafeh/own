clear;

for nstim = 1:10
   
    load(['D:\Dropbox\project_me\decoding_workshop\sub1.stim' num2str(nstim) '.auc.mat']);
    subplot(5,2,nstim)
    plot(time_axis,scores,'-k');
    hline(0.5,'--k');
    ylim([0.4 0.8]);
    vline(0,'--k');
    
end