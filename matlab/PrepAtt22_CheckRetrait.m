clear ; clc ; close all;
addpath(genpath('../../fieldtrip-20151124/'));

[~,suj_list,~] = xlsread('../documents/temp/New_PrepAtt22_Participant_Index_and_Preprocessing_Progress.xlsx','B:B');
suj_list       = suj_list(2:end);

for sb = 1:length(suj_list)
    
    list_channel= { 'MLC11' 'MLC12' 'MLC13' 'MLC14' 'MLC15' 'MLC16' 'MLC17' 'MLC21' 'MLC22' 'MLC23' 'MLC24' 'MLC25' ...
        'MLC31' 'MLC32' 'MLC41' 'MLC42' 'MLC51' 'MLC52' 'MLC53' 'MLC54' 'MLC55' 'MLC61' 'MLC62' 'MLC63' 'MLF11' 'MLF12' ...
        'MLF13' 'MLF14' 'MLF21' 'MLF22' 'MLF23' 'MLF24' 'MLF25' 'MLF31' 'MLF32' 'MLF33' 'MLF34' 'MLF35' 'MLF41' 'MLF42' ...
        'MLF43' 'MLF44' 'MLF45' 'MLF46' 'MLF51' 'MLF52' 'MLF53' 'MLF54' 'MLF55' 'MLF56' 'MLF61' 'MLF62' 'MLF63' 'MLF64' ...
        'MLF65' 'MLF66' 'MLF67' 'MLO11' 'MLO12' 'MLO13' 'MLO14' 'MLO21' 'MLO22' 'MLO23' 'MLO24' 'MLO31' 'MLO32' 'MLO33' ...
        'MLO34' 'MLO41' 'MLO42' 'MLO43' 'MLO44' 'MLO51' 'MLO52' 'MLO53' 'MLP11' 'MLP12' 'MLP21' 'MLP22' 'MLP23' 'MLP31' ...
        'MLP32' 'MLP33' 'MLP34' 'MLP35' 'MLP41' 'MLP42' 'MLP43' 'MLP44' 'MLP45' 'MLP51' 'MLP52' 'MLP53' 'MLP54' 'MLP55' ...
        'MLP56' 'MLP57' 'MLT11' 'MLT12' 'MLT13' 'MLT14' 'MLT15' 'MLT16' 'MLT21' 'MLT22' 'MLT23' 'MLT24' 'MLT25' 'MLT26' ...
        'MLT27' 'MLT31' 'MLT32' 'MLT33' 'MLT34' 'MLT35' 'MLT36' 'MLT37' 'MLT41' 'MLT42' 'MLT43' 'MLT44' 'MLT45' 'MLT46' ...
        'MLT47' 'MLT51' 'MLT52' 'MLT53' 'MLT54' 'MLT55' 'MLT56' 'MLT57' 'MRC11' 'MRC12' 'MRC13' 'MRC14' 'MRC15' 'MRC16' ...
        'MRC17' 'MRC21' 'MRC22' 'MRC23' 'MRC24' 'MRC25' 'MRC31' 'MRC32' 'MRC41' 'MRC42' 'MRC51' 'MRC52' 'MRC53' 'MRC54' ...
        'MRC55' 'MRC61' 'MRC62' 'MRC63' 'MRF11' 'MRF12' 'MRF13' 'MRF14' 'MRF21' 'MRF22' 'MRF23' 'MRF24' 'MRF25' 'MRF31' ...
        'MRF32' 'MRF33' 'MRF34' 'MRF35' 'MRF41' 'MRF42' 'MRF43' 'MRF44' 'MRF45' 'MRF46' 'MRF51' 'MRF52' 'MRF53' 'MRF54'...
        'MRF55' 'MRF56' 'MRF61' 'MRF62' 'MRF63' 'MRF64' 'MRF65' 'MRF66' 'MRF67' 'MRO11' 'MRO12' 'MRO13' 'MRO14' 'MRO21'...
        'MRO22' 'MRO23' 'MRO24' 'MRO31' 'MRO32' 'MRO33' 'MRO34' 'MRO41' 'MRO42' 'MRO43' 'MRO44' 'MRO51' 'MRO52' 'MRO53'...
        'MRP11' 'MRP12' 'MRP21' 'MRP22' 'MRP23' 'MRP31' 'MRP32' 'MRP33' 'MRP34' 'MRP35' 'MRP41' 'MRP42' 'MRP43' 'MRP44'...
        'MRP45' 'MRP51' 'MRP52' 'MRP53' 'MRP54' 'MRP55' 'MRP56' 'MRP57' 'MRT11' 'MRT12' 'MRT13' 'MRT14' 'MRT15' 'MRT16'...
        'MRT21' 'MRT22' 'MRT23' 'MRT24' 'MRT25' 'MRT26' 'MRT27' 'MRT31' 'MRT32' 'MRT33' 'MRT34' 'MRT35' 'MRT36' 'MRT37' ...
        'MRT41' 'MRT42' 'MRT43' 'MRT44' 'MRT45' 'MRT46' 'MRT47' 'MRT51' 'MRT52' 'MRT53' 'MRT54' 'MRT55' 'MRT56' 'MRT57' ...
        'MZC01' 'MZC02' 'MZC03' 'MZC04' 'MZF01' 'MZF02' 'MZF03' 'MZO01' 'MZO02' 'MZO03' 'MZP01' };
    
    suj     = suj_list{sb};
    
    load(['../data/' suj '/res/' suj '_final_ds_list.mat']);
    
    for nbloc = 1:size(final_ds_list,1)
        
        rnd_chan  = PrepAtt22_fun_create_rand_array(1:275,5);
        
        figure;
        
        for ncond = 1:size(final_ds_list,2)
            
            dirDsIn      = ['../data/' suj '/ds/' final_ds_list{nbloc,ncond}];
            cfg          = [];
            cfg.dataset  = dirDsIn;
            cfg.channel  = list_channel(rnd_chan);
            data         = ft_preprocessing(cfg);
            
            if ncond == 1
                lm1 = min(min(data.trial{1}));
                lm2 = max(max(data.trial{1}));
            end
            
            subplot(2,1,ncond)
            plot(data.time{1},data.trial{1});
            xlim([data.time{1}(1) data.time{1}(end)])
            ylim([lm1 lm2]);
            nprts = strsplit(final_ds_list{nbloc,ncond},'.');
            lst_cnd = {'before','after'};
            title([nprts{1} '.' nprts{2} '.' nprts{3} ' ' lst_cnd{ncond}])
            
        end
        
        fnameout = ['../check/retrait/' final_ds_list{nbloc,ncond} '.png'];
        saveas(gcf,fnameout);
        
        clear lm* rnd_* data ; close all ;
        
    end
end