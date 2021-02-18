clear;

alldata                                 = [];
i                                       = 0;

for nsuj = [1:33 35:36 38:44 46:51]
    
    ext_bin_name                        = 'exl500concat3bins';
    fname                               = ['~/Dropbox/project_me/data/nback/bin/sub' num2str(nsuj) '.' ext_bin_name '.binsummary.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    bin_summary                         = struct2table(bin_summary);
    
    list_band                           = {'slow' 'alpha' 'beta' 'gamma1' 'gamma2'};
    list_bin                            = {'b1' 'b2' 'b3'};
    list_cond                           = {'1back' 5; '2back' 6};
    
    for nband = 1:length(list_band)
        for nbin = 1:length(list_bin)
            for nback = 1:length(list_cond)
                
                flg                     = find(strcmp(bin_summary.band,list_band{nband}) & ... 
                    strcmp(bin_summary.bin,list_bin{nbin}));
                
                trialinfo               = bin_summary(flg,:).trialinfo{:};
                trialinfo               = trialinfo(trialinfo(:,1) == list_cond{nback,2},:);
                
                if isempty(trialinfo)
                    error('');
                end
                
                vct_target              = trialinfo(:,[2 4 5]);
                vct_target              = vct_target(vct_target(:,1) == 2,[2 3]); % choose targets
                
                vct_resp                = vct_target(:,1);
                vct_resp(vct_resp == 1 | vct_resp == 3) = 1;
                vct_resp(vct_resp == 2 | vct_resp == 4) = 0;
                
                vct_rt                	= vct_target(:,2);
                vct_rt(vct_rt == 0)     = NaN;
                
                val_corr             	= sum(vct_resp)/length(vct_resp); % corr
                val_rt                  = nanmedian(vct_rt) ./ 1000; % rt
           
                i = i + 1;
                alldata(i).sub          = ['sub' num2str(nsuj)];
                alldata(i).band       	= list_band{nband};
                alldata(i).bin       	= list_bin{nbin};
                alldata(i).cond       	= list_cond{nback,1};
                alldata(i).acc          = val_corr;
                alldata(i).rt           = val_rt;
                
                clear vct_* trialinfo val_*
                
            end
        end
    end
end

keep alldata ext_bin_name

alldata                                 = struct2table(alldata);

suj_list                                = unique(alldata.sub);
excl_suj_list                           = unique(alldata(find(isnan(alldata.rt) | isnan(alldata.acc)),:).sub);
new_data                                = [];
for nsuj = 1:length(suj_list)
    if ~ismember(suj_list{nsuj},excl_suj_list)
        flg                             = find(strcmp(alldata.sub,suj_list{nsuj}));
        new_data                        = [new_data; alldata(flg,:)];
    end
end

writetable(new_data,['../doc/nback_binning_behavior_' ext_bin_name '_withback.txt']);