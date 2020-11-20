%% adds Psychtoolbox behavioral logfile details to .trialinfo

function cfg_out  = h_log2trl(cfg_in,suj_name,session)

beh_perf                            = [] ;

for nblock = 1:10
    
    dir_data                        = ['/project/3015039.04/data/' suj_name '/behav/'];
    filelist                        = dir([dir_data '*' session '*expe_run_' num2str(nblock) '_Logfile.mat']);
    
    if length(filelist) == 1
        fname                       = [dir_data,filelist(1).name];
        fprintf('Loading %s \n',fname);
        load(fname);
        beh_perf                    = [beh_perf Info.block.trial];
    end
    
end

if length(beh_perf) == length(cfg_in.trl)
    
    fprintf('\n Trial Numbers Match \n\n');
    
    trialnumb                       = array2table([1:length(beh_perf)]','VariableNames',{'tot_trials'});
    beh_perf                        = [trialnumb struct2table(beh_perf)];
    
    trialcode                       = cfg_in.trl(:,4);
    trialmod                        = floor(trialcode/100);
    trialnois                       = floor((trialcode - trialmod*100)/10);
    trialtyp                        = trialcode - trialmod*100 - trialnois*10;
    
    trialsid                        = trialtyp;
    trialsid(trialsid < 3)          = 0; % left
    trialsid(trialsid > 2)          = 1; % right
    
    trialstim                       = mod(trialtyp,2);
    
    beh_corr                        = beh_perf.correct;
    beh_corr(beh_corr == -1)        = 0;
    beh_corr(beh_corr == 1)         = 1;
    
    beh_conf                        = beh_perf.confidence;
    beh_conf(beh_conf == -1)        = 0;
    beh_conf(beh_conf == 1)         = 1;
    
    trl_in                          = [cfg_in.trl(:,1:3) beh_perf.tot_trials trialmod trialnois trialsid trialstim beh_corr beh_conf beh_perf.RT beh_perf.response beh_perf.mapping beh_perf.difference];
    
    cfg_out                         = cfg_in;
    cfg_out.trl                     = trl_in;
    
else
    error('Something Wrong Chief!');
end

end
