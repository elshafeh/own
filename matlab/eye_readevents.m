clear;

% suj                 = 'pilot01';
% log_dir             = '../data/pilot01/log/pilot01*block*log';
% ds_name             = '../data/pilot01/raw/pilot01_3015000.01_20191007_01.ds';
% bloc_order          = [1,2,1,2,1,2,1,2];

suj                 = 'pilot02';
log_dir             = '../data/pilot02/log/pilot02*block*log';
ds_name             = '../data/pilot02/raw/pilot02_3015000.01_20191017_01.ds';
bloc_order          = [2,1,2,1,2,1,2,1];

bloc_length         = 76;

trl_ds              = e_func_extract_behav_from_ds(ds_name,bloc_order,bloc_length);
[trl_log,data_log]  = e_func_extract_behav_from_log(log_dir,bloc_order,bloc_length);

chk_rt              = [data_log.RT' trl_ds(:,9)*1000];
chk_rt(:,3)         = chk_rt(:,2) - chk_rt(:,1);
plot([chk_rt(:,3)]');