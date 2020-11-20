clear ; close all;

suj_list                                      = [1:4 8:17];

for ns = 1:length(suj_list)

    for ndata = 1:2

        for nfeat = 1:2

            list_data                           = {'eeg','meg'};
            list_feat                           = {'inf.unf','left.right'};
            list_part                           = {{'CnD'},{'pt1.CnD','pt2.CnD','pt3.CnD'}

            for np = 1:length(list_part{ndata})

              fname                             = ['../data/decode/timegen/yc' num2str(suj_list(ns)) '.' list_part{ndata}{np} '.' list_data{ndata} '.' list_feat{nfeat} 'timegen.mat'];
              fprintf('loading %s\n',fname);
              load(fname);

              p_carr(np,:,:)                    = scores; clear scores;

            end

            f_carr(nfeat,:,:)                   = squeeze(mean(p_carr,1)); clear p_carr;

        end

        freq                            = [];
        freq.time                       = time_axis;
        freq.freq                       = time_axis;
        freq.label                      = {'INF VS UNF','LEFT VS RIGHT'};
        freq.dimord                     = 'chan_freq_time';
        freq.powspctrm                  = f_carr; clear f_carr;

        clear tmp;

        alldata{ns,ndata}               = freq; clear freq;

    end
end
