clear;

for nsuj = 2:21
    
    sujname                     = ['yc' num2str(nsuj)];
    
    fname                       = ['~/Dropbox/project_me/data/pam/virt/' sujname '.CnD.virtualelectrode.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    
    % just cause im lacking the data locked to button-presses i'll manually
    % change the lock using the .pos files
    pos_in                      = load(['~/Dropbox/project_me/data/pam/pos/' sujname '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos']);
    pos_in                      = pos_in(pos_in(:,3) == 0,[1 2]);
    pos_in(:,3)                 = floor(pos_in(:,2) / 1000);
    pos_in                      = pos_in(pos_in(:,3) == 1 | pos_in(:,3) == 9,:); % keep targets and presses
    
    pos_in(:,4)                 = pos_in(:,2) - pos_in(:,3)*1000; % get code
    pos_in(:,5)                 = floor(pos_in(:,4)/100); % get cue
    pos_in(:,6)                 = floor((pos_in(:,4)-100*pos_in(:,5))/10); % dis
    pos_in(:,7)                 = mod(pos_in(:,4),10); % target
    
    pos_in                      = pos_in(pos_in(:,6) == 0,:); % keep no dis only
    
    % choose cues and responses within same trial
    pos_final                   = [];
    
    for n = 1:length(pos_in)
        if pos_in(n,3) == 1 && pos_in(n+1,3) == 9
            if pos_in(n,4) == pos_in(n+1,4)
                pos_final       = [pos_final;pos_in(n:n+1,:)];
            end
        end
    end
    
    % get samples of cue and response
    sample_cue                  = pos_final(pos_final(:,3) == 1,1);
    sample_response             = pos_final(pos_final(:,3) == 9,1);
    
    sample_diff                 = sample_response - sample_cue;
    sample_diff                 = round(sample_diff / 6);
    
    cfg                         = [];
    cfg.window                  = [0.5 0.4];
    cfg.begsample               = sample_diff;
    data_response               = h_redefinetrial(cfg,data);
    
    avg                         = ft_timelockanalysis([],data_response);
    
    avg.avg                     = abs(avg.avg);
    
    ix1                         = nearest(avg.time,-0.4);
    ix2                         = nearest(avg.time,-0.2);
    bsl                         = mean(avg.avg(:,ix1:ix2),2);
    act                         = avg.avg;
    
    avg.avg                     = act - bsl;
    
    alldata{nsuj-1,1}           = avg; clear avg;
    
end

%%

clc;

list_type                       = {'atlas' 'loc'};

for ntype = [1 2]
    
    subplot(2,1,ntype) % subplot(1,2,ntype) % 
    hold on
    
    list_mod                    = {'vis' 'aud' 'mot'};
    list_color                	= 'brg';

    for nmod = [1 2 3]
        
        mtrx_data               = [];
        
        for nsuj = 1:size(alldata,1)
            flg_chan            = find(contains(alldata{nsuj}.label,[list_mod{nmod} ' ' list_type{ntype}]));
            mtrx_data(nsuj,:)  	= mean((alldata{nsuj}.avg(flg_chan,:)),1);
        end
        
        time_axis               = alldata{1}.time;
        
        % Use the standard deviation over trials as error bounds:
        mean_data               = nanmean(mtrx_data,1);
        bounds                  = nanstd(mtrx_data, [], 1);
        bounds_sem              = bounds ./ sqrt(size(mtrx_data,1));
        
        boundedline(time_axis, mean_data, bounds_sem,['-' list_color(nmod)],'alpha'); % alpha makes bounds transparent
        
    end
    
    %     xlim([-0.1 2]);
    
    y_lim                       = [-3e10 10e10];
    
    ylim(y_lim);
    yticks(y_lim);
    
    xticks([-0.5 0 0.4]);
    xticklabels({'-0.5' 'response' '0.4'});
    
    vline([0],'--k');
    hline(0,'--k');
    
    legend({list_mod{1} '' list_mod{2} '' list_mod{3}});
    
    title(list_type{ntype});
    
    set(gca,'FontSize',16)
    
end