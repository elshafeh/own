clear;clc;

suj_list                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname                 = ['sub' num2str(suj_list(nsuj))];
    
    dir_files           	= '~/Dropbox/project_me/data/nback/';
    
    % load bin information
    ext_bin_name            = 'preconcat2bins.0back.equalhemi';
    fname                   = [dir_files 'bin/' sujname '.' ext_bin_name '.binsummary.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    bin_summary             = struct2table(bin_summary);
    
    list_band               = {'alpha' 'beta'};
    
    for nband = 1:length(list_band)
        
        for nbin = [1 2]
            
            flg             = find(strcmp(bin_summary.band,list_band{nband}) & ...
                strcmp(bin_summary.bin,['b' num2str(nbin)]) & ...
                strcmp(bin_summary.win,'pre'));
            
            trialinfo       = bin_summary(flg,:).trialinfo{:};
            
            for nback = [1 2]
               
                nb_back                         = length(find(trialinfo(:,1) == nback +4));
                perc_back                       = nb_back ./ length(trialinfo);
                
                alldata(nsuj,nband,nbin,nback)  = perc_back; clear nb_back perc_back
                
            end
    
        end
        
    end
            
end

keep alldata list_band

for nband = [1 2]
    
    x                       = alldata(:,nband,1);
    y                       = alldata(:,nband,2);
    
    [h,p]                   = ttest(x,y);
    
    subplot(1,2,nband)
    boxplot([x y])
    
    title([list_band{nband} ' p = ' num2str(round(p,3))]);
    
    xticklabels({'1back' '2back'});
    ylabel('% trials');
    
    ylim([0.4 1])
    
    set(gca,'FontSize',20,'FontName', 'Calibri','FontWeight','normal');

    
end