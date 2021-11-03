clear;clc;

suj_list                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname                 = ['sub' num2str(suj_list(nsuj))];
    dir_files               = '~/Dropbox/project_me/data/nback/'; %'P:/3035002.01/nback/';
    
    % load bin information
    ext_bin_name            = 'exl500concat2bins.prepost';
    fname                   = [dir_files 'bin/' sujname '.' ext_bin_name '.binsummary.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    bin_summary             = struct2table(bin_summary);
    
    list_band               = {'slow' 'alpha' 'beta'};
    list_window             = {'pre' 'post'};
    list_bin                = {'b1' 'b2'};
    
    for nband = 1:length(list_band)
        for nwin = 1:length(list_window)
            for nbin = 1:length(list_bin)
                
                flg         = find(strcmp(bin_summary.band,list_band{nband}) & ...
                    strcmp(bin_summary.bin,list_bin{nbin}) & ...
                    strcmp(bin_summary.win,list_window{nwin}));
                
                
                index       = bin_summary(flg,:).index{:};
                trialinfo   = bin_summary(flg,:).trialinfo{:};
                
                ext_name    = [list_band{nband} '.' list_window{nwin} '.' list_bin{nbin}];
                
                fname_out   = [dir_files 'bin_index/' sujname '.' ext_name '.index.mat'];
                fprintf('Saving %s\n',fname_out);
                save(fname_out,'index');
                
                fname_out   = [dir_files 'bin_index/' sujname '.' ext_name '.trialinfo.mat'];
                fprintf('Saving %s\n',fname_out);
                save(fname_out,'trialinfo');
                
                clear flg trialinfo index ext_name
                
            end
        end
    end
end