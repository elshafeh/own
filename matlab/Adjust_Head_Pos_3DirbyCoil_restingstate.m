function Adjust_Head_Pos_3DirbyCoil_restingstate(suj)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cd Y:\\Epilepto\CAT_Aurelie\MEG\
% 
% 
% EX: DSpath{1} =  'Y:\Epilepto\Data_Meg\Grije\300Hz\300Hz_grije_Epi-001_20090506_01.ds';
%     DSpath{2} =  'Y:\Epilepto\Data_Meg\Grije\300Hz\300Hz_grije_Epi-001_20090506_02.ds';
%     Adjust_Head_Pos_3DirbyCoil(DSpath)
%     
% % necessaire pour les fonction d'exportation CTF
% 
% MAJ
% - 15/07/15    RB
%     ajout des ZOOM
%
% - 12/11/15    RB
%     ajout du lancement avec une liste de .ds � visualiser
% 
% - 27/07/16    RB
%     ajout de l'affichage des coils contenus dans le
%     fichier .hc
%
% - 27/07/16    RB
%     ajout de la possibilit� de calcul� automatiquement les r�f�rences
%     uniquement sur les coordonn�es contenues dans les fichier .hc
%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('/dycog/matlab/prog/spm12'))

%% Init

clc

if ispc 
    separator = '\';
else
    separator = '/';
end
    
clear global
global Header y_ref

Header             = {};
Header.blockoffset = [];
GUI = {};
% DSpath = {};

pos_ref = 1;   % sample de reference
delta_mov = .05;  % mouvement acceptable en cm

%% Select data

direc_ds            = ['../data/' suj '/ds/'];
DSpath = {};

check = [];

DSpath{end+1}   =  [direc_ds suj '.pat2.restingstate.thrid_order.ds'];
hc              = read_ctf_hc([direc_ds suj '.pat2.restingstate.thrid_order.ds/' suj '.pat2.restingstate.thrid_order.hc']);

% if nbloc == 1
    stndrd_block = [hc.standard.nas';hc.standard.lpa';hc.standard.rpa';hc.dewar.nas';hc.dewar.lpa';hc.dewar.rpa';hc.head.nas';hc.head.lpa';hc.head.rpa'];
% else
%     new_block = [hc.standard.nas';hc.standard.lpa';hc.standard.rpa';hc.dewar.nas';hc.dewar.lpa';hc.dewar.rpa';hc.head.nas';hc.head.lpa';hc.head.rpa'];
%     check = [check stndrd_block-new_block];
% end


fprintf('%s\t\tSelected\n', DSpath{end})


% double_check = check(check~=0);
% 
% if isempty(double_check)
%     error(sprintf('CAREFUL !! hc files have already been processed'));
% end

% if nargin < 1
%     DSpath = {};
%     fprintf('Select DS directory\n')
%     [Path] = uigetdir('.', 'Select DS directory');
%     [a, b, c] = fileparts(Path);
%     clear Path
%     
%     while strcmp(c, '.ds')
%         DSpath{end+1} = [a separator b c];
%         fprintf('%s\t\tSelected\n', DSpath{end})
%         [Path] = uigetdir(a, 'Select DS directory');
%         [a, b, c] = fileparts(Path);
%         clear Path
%     end
%     clear a b c
% end

%% Import data
fprintf('Importation...\n')
data = [];
for xi_dsfile = 1 : length(DSpath)
    
    % lecture des headers
    Header.filename{xi_dsfile} = DSpath{xi_dsfile};
    DS = readCTFds(DSpath{xi_dsfile});
    [~, filefind, ~] = fileparts(DSpath{xi_dsfile});
    if ispc
        HC = read_ctf_hc([DSpath{xi_dsfile} separator ls([DSpath{xi_dsfile}, separator, filefind, '*.hc'])]);
    else
        HC = read_ctf_hc(deblank(ls([DSpath{xi_dsfile}, separator, filefind, '*.hc'])));
    end
    clear filefind
    Header.HC_raw{xi_dsfile} = HC;
    clear HC
    CharLabel = DS.res4.chanNames;
    CharLabel = deblank(CharLabel);
    
    % recherche des indexs des coils
    IndexHC = [];
    IndexHC(1) = strmatch('HLC0011', CharLabel);
    IndexHC(2) = strmatch('HLC0012', CharLabel);
    IndexHC(3) = strmatch('HLC0013', CharLabel);
    IndexHC(4) = strmatch('HLC0021', CharLabel);
    IndexHC(5) = strmatch('HLC0022', CharLabel);
    IndexHC(6) = strmatch('HLC0023', CharLabel);
    IndexHC(7) = strmatch('HLC0031', CharLabel);
    IndexHC(8) = strmatch('HLC0032', CharLabel);
    IndexHC(9) = strmatch('HLC0033', CharLabel);
    % standard nasion coil position relative to dewar (m): x, y et z
    % standard left ear coil position relative to dewar (m): x, y et z
    % standard right ear coil position relative to dewar (m): x, y et z
    
    % extraction des datas
    data = [data; getCTFdata(DS, [], IndexHC, 'ft', 'double')];

    % extraction des events
    if isempty(Header.blockoffset)
        events = extract_events(DS, CharLabel);
    else
        events = [events; extract_events(DS, CharLabel)+Header.blockoffset(end)];
    end
    
    Header.blockoffset(end+1) = length(data);
    Header.sample_rate = DS.res4.sample_rate;
    
    clear DS HC CharLabel IndexHC   
end
clear xi_dsfile

fprintf('Done\n\n')
fprintf('Total data lenght : %s s\n', num2str(Header.blockoffset(end)/Header.sample_rate))

% mesure sont en m�tre, transformation en cm
fprintf('Conversion   m -> cm\n\n')
data = data*100;

Header.start_pos.nas = data(1,1:3)';
Header.start_pos.lpa = data(1,4:6)';
Header.start_pos.rpa = data(1,7:9)';
Header.unit          = 'cm';
Header.HClabel       = {'Nasion_X'; 'Nasion_Y'; 'Nasion_Z'; 'LeftEar_X'; 'LeftEar_Y'; 'LeftEar_Z'; 'RightEar_X'; 'RightEar_Y'; 'RightEar_Z'};

fprintf('Initial position\n')
for xi_ds = 1 : length(Header.HC_raw)
    fprintf('DS file #%s:\n', num2str(xi_ds))
    position = Header.HC_raw{xi_ds};
    clear position
end
clear xi_ds

% position par raport au 1er sample
% sinon c'est illisible
fprintf('Position centered on the 1st sample\n')
data_ref = data-repmat(data(1,:),size(data,1),1);
time = [1:size(data_ref, 1)]/ Header.sample_rate;


% Calcul les references automatiques possibles
comp_ref_auto(data_ref, Header.HC_raw, data(1,:));

%% Display

GUI.f = figure('Position', [100 100 1000 1000], 'Color', [1 1 1],...
    'MenuBar', 'none');

subplot(3,1,1)
hold on
GUI.X.goodarea = fill([1 time(end) time(end) 1], [y_ref.ref(1)+delta_mov y_ref.ref(1)+delta_mov y_ref.ref(1)-delta_mov y_ref.ref(1)-delta_mov], 'r');
GUI.X.goodarea.Tag = 'goodarea_X_coil';
GUI.X.goodarea.EdgeAlpha = 0;
GUI.X.goodarea.FaceAlpha = .05;
GUI.X.plot_nas    = plot(time, data_ref(:,1), 'Color', [.2 .2 .2], 'Tag', 'plot_X_nasio');
GUI.X.plot_eleft  = plot(time, data_ref(:,4), 'Color', [0 .5 0], 'Tag', 'plot_X_eleft');
GUI.X.plot_eright = plot(time, data_ref(:,7), 'Color', [0.2 0 .7], 'Tag', 'plot_X_erigh');
for xi_ds = 1 : length(Header.HC_raw)
    pos_x = [];
    if xi_ds == 1
        pos_x = 1;
    else
        pos_x = Header.blockoffset(xi_ds-1)/Header.sample_rate;
    end
    GUI.X.plot_HC_nas{xi_ds}    = plot([pos_x pos_x+14], repmat(Header.HC_raw{xi_ds}.dewar.nas(1)-data(1,1), 1, 2), '-k', 'Linewidth', 5, 'Tag', 'plot_X_HC_nasio');
    GUI.X.plot_HC_eleft{xi_ds}  = plot([pos_x pos_x+ 12], repmat(Header.HC_raw{xi_ds}.dewar.lpa(1)-data(1,4), 1, 2), '-g', 'Linewidth', 5, 'Tag', 'plot_X_HC_elet');
    GUI.X.plot_HC_eright{xi_ds} = plot([pos_x pos_x+ 10], repmat(Header.HC_raw{xi_ds}.dewar.rpa(1)-data(1,7), 1, 2), '-b', 'Linewidth', 5, 'Tag', 'plot_X_HC_eright');
end, clear xi_ds pos_x
GUI.X.meanref = plot([1 time(end)], [y_ref.ref(1) y_ref.ref(1)], 'b:');
GUI.X.meanref.Tag = 'meanref_X_coil';
GUI.X.plot_nas.Parent.ButtonDownFcn = @clicy;
%GUI.X.plot_nas.Parent.YLim          = [min(min(data_ref(:,[1 4 7])))-delta_mov max(max(data_ref(:,[1 4 7])))+delta_mov];
GUI.X.plot_nas.Parent.XLim          = [0 max(time)];
GUI.X.plot_nas.Parent.Tag           = 'plot_X'; 
GUI.X.plot_nas.Parent.Position(1)   = GUI.X.plot_nas.Parent.Position(1)+0.075;
GUI.X.goodarea.ButtonDownFcn = @clicy;
events_toplot     = [events'; events'; nan(1,length(events))];
GUI.X.events      = plot(events_toplot(:)/Header.sample_rate, repmat([GUI.X.plot_eleft.Parent.YLim(1) GUI.X.plot_eleft.Parent.YLim(2) NaN], 1,length(events)), ':k',...
    'Linewidth', 0.01, 'Tag', 'events_X', 'Visible', 'off');
title('Coo along X (dewar)')
legend({''; 'Nasion'; 'Ear Left'; 'Ear Right'}, 'Location', 'best')

subplot(3,1,2)
hold on
GUI.Y.goodarea = fill([1 time(end) time(end) 1], [y_ref.ref(2)+delta_mov y_ref.ref(2)+delta_mov y_ref.ref(2)-delta_mov y_ref.ref(2)-delta_mov], 'r');
GUI.Y.goodarea.Tag = 'goodarea_Y_coil';
GUI.Y.goodarea.EdgeAlpha = 0;
GUI.Y.goodarea.FaceAlpha = .05;
GUI.Y.plot_nas    = plot(time, data_ref(:,2), 'color', [.2 .2 .2], 'Tag', 'plot_Y_nasio');
GUI.Y.plot_eleft  = plot(time, data_ref(:,5), 'Color', [0 .5 0], 'Tag', 'plot_Y_eleft');
GUI.Y.plot_eright = plot(time, data_ref(:,8), 'Color', [.2 0 .7], 'Tag', 'plot_Y_erigh');
for xi_ds = 1 : length(Header.HC_raw)
    pos_x = [];
    if xi_ds == 1
        pos_x = 1;
    else
        pos_x = Header.blockoffset(xi_ds-1)/Header.sample_rate;
    end
    GUI.Y.plot_HC_nas{xi_ds}    = plot([pos_x pos_x+14], repmat(Header.HC_raw{xi_ds}.dewar.nas(2)-data(1,2), 1, 2), '-k', 'Linewidth', 5, 'Tag', 'plot_Y_HC_nasio');
    GUI.Y.plot_HC_eleft{xi_ds}  = plot([pos_x pos_x+12], repmat(Header.HC_raw{xi_ds}.dewar.lpa(2)-data(1,5), 1, 2), '-g', 'Linewidth', 5, 'Tag', 'plot_Y_HC_elet');
    GUI.Y.plot_HC_eright{xi_ds} = plot([pos_x pos_x+10], repmat(Header.HC_raw{xi_ds}.dewar.rpa(2)-data(1,8), 1, 2), '-b', 'Linewidth', 5, 'Tag', 'plot_Y_HC_eright');
end, clear xi_ds pos_x
GUI.Y.meanref = plot([1 time(end)], [y_ref.ref(2) y_ref.ref(2)], 'b:');
GUI.Y.meanref.Tag = 'meanref_Y_coil';
GUI.Y.plot_nas.Parent.ButtonDownFcn = @clicy;
%GUI.Y.plot_nas.Parent.YLim          = [min(min(data_ref(:,[2 5 8])))-delta_mov max(max(data_ref(:,[2 5 8])))+delta_mov];
GUI.Y.plot_nas.Parent.XLim          = [0 time(end)];
GUI.Y.plot_nas.Parent.Tag           = 'plot_Y';
GUI.Y.plot_nas.Parent.Position(1)   = GUI.Y.plot_nas.Parent.Position(1)+0.075;
GUI.Y.goodarea.ButtonDownFcn = @clicy;
GUI.Y.events      = plot(events_toplot(:)/Header.sample_rate, repmat([GUI.Y.plot_eleft.Parent.YLim(1) GUI.Y.plot_eleft.Parent.YLim(2) NaN], 1,length(events)), ':k',...
    'Linewidth', 0.01, 'Tag', 'events_Y', 'Visible', 'off');
title('Coo along Y (dewar)')

subplot(3,1,3)
hold on
GUI.Z.goodarea = fill([1 time(end) time(end) 1], [y_ref.ref(3)+delta_mov y_ref.ref(3)+delta_mov y_ref.ref(3)-delta_mov y_ref.ref(3)-delta_mov], 'r');
GUI.Z.goodarea.Tag = 'goodarea_Z_coil';
GUI.Z.goodarea.EdgeAlpha = 0;
GUI.Z.goodarea.FaceAlpha = .05;
GUI.Z.plot_nas    = plot(time, data_ref(:,3), 'Color', [.2 .2 .2], 'Tag', 'plot_Z_nasio');
GUI.Z.plot_eleft  = plot(time, data_ref(:,6), 'Color', [0 .5 0], 'Tag', 'plot_Z_eleft');
GUI.Z.plot_eright = plot(time, data_ref(:,9), 'Color', [.2 0 .7], 'Tag', 'plot_Z_erigh');
for xi_ds = 1 : length(Header.HC_raw)
    pos_x = [];
    if xi_ds == 1
        pos_x = 1;
    else
        pos_x = Header.blockoffset(xi_ds-1)/Header.sample_rate;
    end
    GUI.Z.plot_HC_nas{xi_ds}    = plot([pos_x pos_x+14], repmat(Header.HC_raw{xi_ds}.dewar.nas(3)-data(1,3), 1, 2), '-k', 'Linewidth', 5, 'Tag', 'plot_Z_HC_nasio');
    GUI.Z.plot_HC_eleft{xi_ds}  = plot([pos_x pos_x+12], repmat(Header.HC_raw{xi_ds}.dewar.lpa(3)-data(1,6), 1, 2), '-g', 'Linewidth', 5, 'Tag', 'plot_Z_HC_elet');
    GUI.Z.plot_HC_eright{xi_ds} = plot([pos_x pos_x+10], repmat(Header.HC_raw{xi_ds}.dewar.rpa(3)-data(1,9), 1, 2), '-b', 'Linewidth', 5, 'Tag', 'plot_Z_HC_eright');
end, clear xi_ds pos_x
GUI.Z.meanref = plot([1 time(end)], [y_ref.ref(3) y_ref.ref(3)], 'b:');
GUI.Z.meanref.Tag = 'meanref_Z_coil';
GUI.Z.plot_nas.Parent.ButtonDownFcn = @clicy;
%GUI.Z.plot_nas.Parent.YLim          = [min(min(data_ref(:,[3 6 9])))-delta_mov max(max(data_ref(:,[3 6 9])))+delta_mov];
GUI.Z.plot_nas.Parent.XLim          = [0 time(end)];
GUI.Z.plot_nas.Parent.Tag           = 'plot_Z';
GUI.Z.plot_nas.Parent.Position(1)   = GUI.Z.plot_nas.Parent.Position(1)+0.075;
GUI.Z.goodarea.ButtonDownFcn = @clicy;
GUI.Z.events      = plot(events_toplot(:)/Header.sample_rate, repmat([GUI.Z.plot_eleft.Parent.YLim(1) GUI.Z.plot_eleft.Parent.YLim(2) NaN], 1,length(events)), ':k',...
    'Linewidth', 0.01, 'Tag', 'events_Z', 'Visible', 'off');
title('Coo along Z (dewar)')




% reglage de la position de reference et du delta acceptable
uicontrol('Parent', GUI.f, 'Style', 'text', 'String', 'Delta move (cm)',...
     'Position', [60 80 70 20],'Units', 'normalized',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [.5 0 0], 'BackgroundColor', [1 1 1])
 
GUI.chg_delta_mov = uicontrol('Parent', GUI.f, 'Style', 'edit', 'String', '0.05',...
     'Position', [100 35 30 20],'Units', 'normalized', 'Tag', 'chg_delta_mov',...
     'FontSize', 8, 'FontWeight','bold',...
     'Callback', @chg_delta_mov);
 
GUI.slide_delta_mov = uicontrol('Style', 'slider', 'Min', 0,'Max', 1, 'Value', 0.05,...      
    'Position', [25 60 160 20],'SliderStep',[.001 .1], 'Units', 'normalized',...
    'BackgroundColor', [0 0 0], 'Tag', 'slide_delta_mov',...
    'Callback', @slidy_delta);


% ZOOM
% pour X
GUI.zoom.X.plus = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', '+',...
    'position', [130 750 20 20], 'Units', 'normalized', 'Tag', 'plus_X',...
     'FontSize', 10, 'FontWeight','bold','BackgroundColor', [1 1 1],...
    'Callback', @zoom_adapt);
GUI.zoom.X.moins = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', '-',...
    'position', [130 730 20 20], 'Units', 'normalized', 'Tag', 'moins_X',...
     'FontSize', 10, 'FontWeight','bold','BackgroundColor', [1 1 1],...
    'Callback', @zoom_adapt);
% pour Y
GUI.zoom.Y.plus = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', '+',...
    'position', [130 460 20 20], 'Units', 'normalized', 'Tag', 'plus_Y',...
     'FontSize', 10, 'FontWeight','bold','BackgroundColor', [1 1 1],...
    'Callback', @zoom_adapt);
GUI.zoom.Y.moins = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', '-',...
    'position', [130 440 20 20], 'Units', 'normalized', 'Tag', 'moins_Y',...
     'FontSize', 10, 'FontWeight','bold','BackgroundColor', [1 1 1],...
    'Callback', @zoom_adapt);
% pour Z
GUI.zoom.Z.plus = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', '+',...
    'position', [130 150 20 20], 'Units', 'normalized', 'Tag', 'plus_Z',...
     'FontSize', 10, 'FontWeight','bold','BackgroundColor', [1 1 1],...
    'Callback', @zoom_adapt);
GUI.zoom.Z.moins = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', '-',...
    'position', [130 130 20 20], 'Units', 'normalized', 'Tag', 'moins_Z',...
     'FontSize', 10, 'FontWeight','bold','BackgroundColor', [1 1 1],...
    'Callback', @zoom_adapt);

% selection des traces a afficher
% pour X
GUI.select_curve.X.nas = uicontrol('Style', 'radiobutton', 'String', 'Nasion', 'Value', 1,...
    'Position', [130 850 60 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_X_nasio', 'Callback', @select_coil_plot); 
GUI.select_curve.X.eleft = uicontrol('Style', 'radiobutton', 'String', 'Ear Left', 'Value', 1,...
    'Position', [130 825 60 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_X_eleft', 'Callback', @select_coil_plot); 
GUI.select_curve.X.eright = uicontrol('Style', 'radiobutton', 'String', 'Ear Right', 'Value', 1,...
    'Position', [130 800 60 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_X_erigh', 'Callback', @select_coil_plot); 
% pour Y
GUI.select_curve.Y.nas = uicontrol('Style', 'radiobutton', 'String', 'Nasion', 'Value', 1,...
    'Position', [130 560 60 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_Y_nasio', 'Callback', @select_coil_plot); 
GUI.select_curve.Y.eleft = uicontrol('Style', 'radiobutton', 'String', 'Ear Left', 'Value', 1,...
    'Position', [130 535 60 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_Y_eleft', 'Callback', @select_coil_plot); 
GUI.select_curve.Y.eright = uicontrol('Style', 'radiobutton', 'String', 'Ear Right', 'Value', 1,...
    'Position', [130 510 60 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_Y_erigh', 'Callback', @select_coil_plot); 
% pour z
GUI.select_curve.Z.nas = uicontrol('Style', 'radiobutton', 'String', 'Nasion', 'Value', 1,...
    'Position', [130 250 60 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_Z_nasio', 'Callback', @select_coil_plot); 
GUI.select_curve.Z.eleft = uicontrol('Style', 'radiobutton', 'String', 'Ear Left', 'Value', 1,...
    'Position', [130 225 60 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_Z_eleft', 'Callback', @select_coil_plot); 
GUI.select_curve.Z.eright = uicontrol('Style', 'radiobutton', 'String', 'Ear Right', 'Value', 1,...
    'Position', [130 200 60 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_Z_erigh', 'Callback', @select_coil_plot); 


% slider des meanref
% pou X
GUI.slide_meanref.X = uicontrol('Style', 'slider', 'Min', min(GUI.X.plot_nas.Parent.YLim)*1.5 , 'Max', max(GUI.X.plot_nas.Parent.YLim)*1.5, 'Value', y_ref.ref(1),...      
    'Position', [25 750 10 150],'SliderStep',[.001 .1], 'Units', 'normalized',...
    'BackgroundColor', [0 0 0], 'Tag', 'slide_meanref_X',...
    'Callback', @slidy_meanref);

GUI.chg_meanref_X.nas = uicontrol('Parent', GUI.f, 'Style', 'edit', 'String', num2str(y_ref.ref(1)),...
     'Position',  [40 850 40 20], 'Units', 'normalized', 'Tag', 'chg_meanref_X_nasio',...
     'FontSize', 8, 'FontWeight','bold',...
     'Callback', @enter_meanref);
GUI.select_meanref.X.nas = uicontrol('Style', 'radiobutton', 'String', '', 'Value', 1,...
    'Position', [85 850 20 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_meanref_X_nasio', 'Callback', @select_mean_plot); 

GUI.chg_meanref_X.eleft = uicontrol('Parent', GUI.f, 'Style', 'edit', 'String', num2str(y_ref.ref(4)),...
     'Position',  [40 825 40 20], 'Units', 'normalized', 'Tag', 'chg_meanref_X_eleft',...
     'FontSize', 8, 'FontWeight','bold',...
     'Callback', @enter_meanref);
GUI.select_meanref.X.eleft = uicontrol('Style', 'radiobutton', 'String', '', 'Value', 0,...
    'Position', [85 825 20 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_meanref_X_eleft', 'Callback', @select_mean_plot); 

GUI.chg_meanref_X.eright = uicontrol('Parent', GUI.f, 'Style', 'edit', 'String', num2str(y_ref.ref(7)),...
     'Position',  [40 800 40 20], 'Units', 'normalized', 'Tag', 'chg_meanref_X_erigh',...
     'FontSize', 8, 'FontWeight','bold',...
     'Callback', @enter_meanref);
GUI.select_meanref.X.eright = uicontrol('Style', 'radiobutton', 'String', '', 'Value', 0,...
    'Position', [85 800 20 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_meanref_X_erigh', 'Callback', @select_mean_plot); 


% slider des meanref
% pou Y
GUI.slide_meanref.Y = uicontrol('Style', 'slider', 'Min', min(GUI.Y.plot_nas.Parent.YLim)*1.5 , 'Max', max(GUI.Y.plot_nas.Parent.YLim)*1.5, 'Value', y_ref.ref(2),...      
    'Position', [25 460 10 150],'SliderStep',[.001 .1], 'Units', 'normalized',...
    'BackgroundColor', [0 0 0], 'Tag', 'slide_meanref_Y',...
    'Callback', @slidy_meanref);

GUI.chg_meanref_Y.nas = uicontrol('Parent', GUI.f, 'Style', 'edit', 'String', num2str(y_ref.ref(2)),...
     'Position',  [40 560 40 20], 'Units', 'normalized', 'Tag', 'chg_meanref_Y_nasio',...
     'FontSize', 8, 'FontWeight','bold',...
     'Callback', @enter_meanref);
GUI.select_meanref.Y.nas = uicontrol('Style', 'radiobutton', 'String', '', 'Value', 1,...
    'Position', [85 560 20 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_meanref_Y_nasio', 'Callback', @select_mean_plot); 

GUI.chg_meanref_Y.eleft = uicontrol('Parent', GUI.f, 'Style', 'edit', 'String', num2str(y_ref.ref(5)),...
     'Position',  [40 535 40 20], 'Units', 'normalized', 'Tag', 'chg_meanref_Y_eleft',...
     'FontSize', 8, 'FontWeight','bold',...
     'Callback', @enter_meanref);
GUI.select_meanref.Y.eleft = uicontrol('Style', 'radiobutton', 'String', '', 'Value', 0,...
    'Position', [85 535 20 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_meanref_Y_eleft', 'Callback', @select_mean_plot); 

GUI.chg_meanref_Y.eright = uicontrol('Parent', GUI.f, 'Style', 'edit', 'String', num2str(y_ref.ref(8)),...
     'Position',  [40 510 40 20], 'Units', 'normalized', 'Tag', 'chg_meanref_Y_erigh',...
     'FontSize', 8, 'FontWeight','bold',...
     'Callback', @enter_meanref);
GUI.select_meanref.Y.eright = uicontrol('Style', 'radiobutton', 'String', '', 'Value', 0,...
    'Position', [85 510 20 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_meanref_Y_erigh', 'Callback', @select_mean_plot); 


% slider des meanref
% pou Z
GUI.slide_meanref.Z = uicontrol('Style', 'slider', 'Min', min(GUI.Z.plot_nas.Parent.YLim)*1.5 , 'Max', max(GUI.Z.plot_nas.Parent.YLim)*1.5, 'Value', y_ref.ref(3),...      
    'Position', [25 150 10 150],'SliderStep',[.001 .1], 'Units', 'normalized',...
    'BackgroundColor', [0 0 0], 'Tag', 'slide_meanref_Z',...
    'Callback', @slidy_meanref);

GUI.chg_meanref_Z.nas = uicontrol('Parent', GUI.f, 'Style', 'edit', 'String', num2str(y_ref.ref(3)),...
     'Position',  [40 250 40 20], 'Units', 'normalized', 'Tag', 'chg_meanref_Z_nasio',...
     'FontSize', 8, 'FontWeight','bold',...
     'Callback', @enter_meanref);
GUI.select_meanref.Z.nas = uicontrol('Style', 'radiobutton', 'String', '', 'Value', 1,...
    'Position', [85 250 20 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_meanref_Z_nasio', 'Callback', @select_mean_plot); 

GUI.chg_meanref_Z.eleft = uicontrol('Parent', GUI.f, 'Style', 'edit', 'String', num2str(y_ref.ref(6)),...
     'Position',  [40 225 40 20], 'Units', 'normalized', 'Tag', 'chg_meanref_Z_eleft',...
     'FontSize', 8, 'FontWeight','bold',...
     'Callback', @enter_meanref);
GUI.select_meanref.Z.eleft = uicontrol('Style', 'radiobutton', 'String', '', 'Value', 0,...
    'Position', [85 225 20 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_meanref_Z_eleft', 'Callback', @select_mean_plot); 

GUI.chg_meanref_Z.eright = uicontrol('Parent', GUI.f, 'Style', 'edit', 'String', num2str(y_ref.ref(9)),...
     'Position',  [40 200 40 20], 'Units', 'normalized', 'Tag', 'chg_meanref_Z_erigh',...
     'FontSize', 8, 'FontWeight','bold',...
     'Callback', @enter_meanref);
GUI.select_meanref.X.eright = uicontrol('Style', 'radiobutton', 'String', '', 'Value', 0,...
    'Position', [85 200 20 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Select_meanref_Z_erigh', 'Callback', @select_mean_plot); 


% afficher references differentes
GUI.auto_meanref.zeros = uicontrol('Style', 'radiobutton', 'String', 'Zero', 'Value', 1,...
    'Position', [30 10 30 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'meanref_auto_zero', 'Callback', @select_meanref_auto); 
GUI.auto_meanref.mean = uicontrol('Style', 'radiobutton', 'String', 'Mean', 'Value', 0,...
    'Position', [70 10 30 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'meanref_auto_mean', 'Callback', @select_meanref_auto); 
GUI.auto_meanref.median = uicontrol('Style', 'radiobutton', 'String', 'Median', 'Value', 0,...
    'Position', [110 10 30 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'meanref_auto_median', 'Callback', @select_meanref_auto); 
GUI.auto_meanref.minmax = uicontrol('Style', 'radiobutton', 'String', 'MinMax', 'Value', 0,...
    'Position', [150 10 30 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'meanref_auto_minmax', 'Callback', @select_meanref_auto); 


% choix des mesures qui serviront a calculer la reference, data ou HC ?
GUI.auto_meanref.HC = uicontrol('Style', 'checkbox', 'String', 'ref on HC', 'Value', 0,...
    'Position', [190 5 40 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'HCref_auto', 'Callback', @select_dataref_auto); 
GUI.auto_meanref.data = uicontrol('Style', 'checkbox', 'String', 'ref on DATAS', 'Value', 1,...
    'Position', [190 25 40 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'dataref_auto', 'Callback', @select_dataref_auto); 


% afficher les distance sur la base des meanref selectionn�s
GUI.comput_distance = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', 'Visualize Distances',...
    'position', [500 30 200 20], 'Units', 'normalized',...
     'FontSize', 8, 'FontWeight','bold','BackgroundColor', [.7 0 .9],...
    'Callback', @Comput_distances);


% affichage des events
GUI.disp_events = uicontrol('Style', 'radiobutton', 'String', 'Events', 'Value', 0,...
    'Position', [400 30 60 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Disp_events', 'Callback', @Disp_events); 



%%
%%



function zoom_adapt(gcbo, eventdata, handles)

bt = gco;
quel_zoom = bt.Tag(1:end-2);
quel_axe = bt.Tag(end);
quel_plot = findobj('Tag', ['plot_' quel_axe]);
if bt.String == '+'
    quel_plot.YLim = quel_plot.YLim*0.9;
elseif bt.String == '-'
    quel_plot.YLim = quel_plot.YLim*1.1;
end



% extractions des events
function trigg_events = extract_events(DS, CharLabel)

    Index_event = strmatch('UPPT', CharLabel);
    if length(Index_event) ~= 1
        trigg_events = [];
        fprintf('Event extraction canceled\n')
        return
    end
        
    data = getCTFdata(DS, [], Index_event, 'ft', 'double');
    if ~isempty(data)
        trigg_events = find((data(2:end)-data(1:end-1))>0);
        trigg_events = trigg_events+1;
    else
        trigg_events = [];
        fprintf('There is not events on the UPPT channel\n')
    end


% extraction des marker file
function Header = add_marker(Header, DS)

if ~isfield(Header, 'marker')
    Header.marker       = {};
    Header.marker.name  = {};
    Header.marker.trigg = [];
end

% si des marqueurs existent dans le .ds
if isfield(DS, 'mrk')
    
    % si le Header ne contient pas encore de marqueurs
    if isempty(Header.marker.name)
       for xi_mkr = 1 : length(DS.mrk)
           % si le mkr n'est pas vide
           if ~isempty(DS.mrk(xi_mkr).time)
               Header.marker.name{end+1}    = DS.mrk(xi_mkr).Name;
               Header.marker.trigg{end+1} = DS.mrk(xi_mkr).time*Header.sample_rate;
           end
       end
       clear xi_mkr
       
    % si le Header contient d�j� des marqueurs   
    else
        for xi_mkr = 1 : length(DS.mrk)
            % si le mkr n'est pas vide
            if ~isempty(DS.mrk(xi_mkr).time)
                quel_marqueur = find(strcmp(DS.mrk(xi_mkr).Name, Header.marker.name));
                % si un marqueur d�j� import� correspond
                if ~isempty(quel_marqueur)
                    Header.marker.trigg{quel_marqueur} = [Header.marker.trigg{quel_marqueur} (DS.mrk(xi_mkr).time*Header.sample_rate)+Header.blockoffset(end-1)];
                else
                    Header.marker.name{end+1}  = DS.mrk(xi_mkr).Name;
                    Header.marker.trigg{end+1} = (DS.mrk(xi_mkr).time*Header.sample_rate)+Header.blockoffset(end-1);
                end
                
            end
            clear xi_mkr
        end
        
    end
end


function clicy(gcbo, eventdata, handles)

h = gca;

% change le slider
s = findobj('Tag', ['slide_meanref_', h.Tag(end)]);
s.Value = h.CurrentPoint(1,2);

% change la valeur de meanref pour le coil selectionn�
coil = {'nasio'; 'eleft'; 'erigh'};
for xi_coil = 1 : 3
   obj_interest = findobj('Tag', ['Select_meanref_', h.Tag(end), '_' coil{xi_coil}]);
   if obj_interest.Value == 1
       obj_modif = findobj('Tag', ['chg_meanref_', h.Tag(end), '_', coil{xi_coil}]);
       obj_modif.String = num2str(h.CurrentPoint(1,2));
       break
   end
   clear obj_interest obj_modif
end

% refresh the display
plot_change_meanref([h.Tag(end), '_', coil{xi_coil}]);


clear h k sh



function slidy_delta(gcbo, eventdata, handles)

mX = findobj('Tag', 'meanref_X_coil');
mY = findobj('Tag', 'meanref_Y_coil');
mZ = findobj('Tag', 'meanref_Z_coil');

gX = findobj('Tag', 'goodarea_X_coil');
gY = findobj('Tag', 'goodarea_Y_coil');
gZ = findobj('Tag', 'goodarea_Z_coil');

sd = findobj('Tag', 'slide_delta_mov');

g = findobj('Tag', 'chg_delta_mov');
g.String = num2str(sd.Value);

gX.YData = [mX.YData(1)+sd.Value mX.YData(1)+sd.Value mX.YData(1)-sd.Value mX.YData(1)-sd.Value];
gY.YData = [mY.YData(1)+sd.Value mY.YData(1)+sd.Value mY.YData(1)-sd.Value mY.YData(1)-sd.Value];
gZ.YData = [mZ.YData(1)+sd.Value mZ.YData(1)+sd.Value mZ.YData(1)-sd.Value mZ.YData(1)-sd.Value];

clear mX mY mZ gX gY gZ sh g  


function chg_delta_mov(gcbo, eventdata, handles)

mX = findobj('Tag', 'meanref_X_coil');
mY = findobj('Tag', 'meanref_Y_coil');
mZ = findobj('Tag', 'meanref_Z_coil');

gX = findobj('Tag', 'goodarea_X_coil');
gY = findobj('Tag', 'goodarea_Y_coil');
gZ = findobj('Tag', 'goodarea_Z_coil');

bd = findobj('Tag', 'chg_delta_mov');

sd = findobj('Tag', 'slide_delta_mov');
sd.Value = str2num(bd.String);


gX.YData = [mX.YData(1)+sd.Value mX.YData(1)+sd.Value mX.YData(1)-sd.Value mX.YData(1)-sd.Value];
gY.YData = [mY.YData(1)+sd.Value mY.YData(1)+sd.Value mY.YData(1)-sd.Value mY.YData(1)-sd.Value];
gZ.YData = [mZ.YData(1)+sd.Value mZ.YData(1)+sd.Value mZ.YData(1)-sd.Value mZ.YData(1)-sd.Value];


clear g h sh sg pos_ref delta_mov


function select_coil_plot(gcbo, eventdata, handles)

coil = eventdata.Source.Tag(end-4:end);
direc = eventdata.Source.Tag(end-6);

plot_interst = findobj('Tag', ['plot_' direc '_' coil]);
if eventdata.Source.Value
    plot_interst.Visible = 'on';
else
    plot_interst.Visible = 'off';
end


function slidy_meanref(gcbo, eventdata, handles)

coil = {'nasio'; 'eleft'; 'erigh'};
for xi_coil = 1 : 3
   obj_interest = findobj('Tag', ['Select_meanref_', eventdata.Source.Tag(end), '_' coil{xi_coil}]);
   if obj_interest.Value == 1
       obj_modif = findobj('Tag', ['chg_meanref_', eventdata.Source.Tag(end), '_', coil{xi_coil}]);
       obj_modif.String = num2str(eventdata.Source.Value);
       break
   end
   clear obj_interest obj_modif
end

% refresh the display
plot_change_meanref([eventdata.Source.Tag(end), '_' coil{xi_coil}]);

clear xi_coil obj_interest obj_modif

% entrer de la meanref a la main
function enter_meanref(gcbo, eventdata, handles)


s = findobj('Tag', ['slide_meanref_', eventdata.Source.Tag(end-6)]);
s.Value = str2double(eventdata.Source.String);

% refresh the display
plot_change_meanref(eventdata.Source.Tag(end-6:end));

clear s



% deselectionne tous les autres bouttons
function select_mean_plot(gcbo, eventdata, handles)

% changer les values
% je met tout a 0
sn = findobj('Tag', ['Select_meanref_', eventdata.Source.Tag(end-6), '_nasio']);
sn.Value = 0;
sl = findobj('Tag', ['Select_meanref_', eventdata.Source.Tag(end-6), '_eleft']);
sl.Value = 0;
sr = findobj('Tag', ['Select_meanref_', eventdata.Source.Tag(end-6), '_erigh']);
sr.Value = 0;
clear sn sl sr
% reactive le boutton selectionne
eventdata.Source.Value = 1;

% refresh the display
plot_change_meanref(eventdata.Source.Tag(end-6:end));



% rafraichi l'affichage de la moyenne selon l'axe e le coil selectionn�
function plot_change_meanref(axe_coil_name)

% quel delat mean ?
delat_mean = findobj('Tag', 'chg_delta_mov');

% quel mean ref ?
mean_ref = findobj('Tag', ['chg_meanref_', axe_coil_name]);

% cherche quel plot doit �tre modifi� (X, y ou Z)
m = findobj('Tag', ['meanref_', axe_coil_name(1), '_coil']);
g = findobj('Tag', ['goodarea_', axe_coil_name(1), '_coil']);

% modification du plot
m.YData = [str2double(mean_ref.String) str2double(mean_ref.String)];
g.YData = [str2double(mean_ref.String)+str2double(delat_mean.String) str2double(mean_ref.String)+str2double(delat_mean.String) str2double(mean_ref.String)-str2double(delat_mean.String) str2double(mean_ref.String)-str2double(delat_mean.String)];




function Comput_distances(gcbo, eventdata, handles)

global Header

cxn = findobj('Tag', 'chg_meanref_X_nasio');
cxl = findobj('Tag', 'chg_meanref_X_eleft');
cxr = findobj('Tag', 'chg_meanref_X_erigh');

cyn = findobj('Tag', 'chg_meanref_Y_nasio');
cyl = findobj('Tag', 'chg_meanref_Y_eleft');
cyr = findobj('Tag', 'chg_meanref_Y_erigh');

czn = findobj('Tag', 'chg_meanref_Z_nasio');
czl = findobj('Tag', 'chg_meanref_Z_eleft');
czr = findobj('Tag', 'chg_meanref_Z_erigh');

meanref = {};
meanref.X = [str2double(cxn.String) str2double(cxl.String) str2double(cxr.String)];
meanref.Y = [str2double(cyn.String) str2double(cyl.String) str2double(cyr.String)];
meanref.Z = [str2double(czn.String) str2double(czl.String) str2double(czr.String)];

Adjust_Head_Pos_XYZbased(Header, meanref)



function Disp_events(gcbo, eventdata, handles)

ex = findobj('Tag', 'events_X');
ey = findobj('Tag', 'events_Y');
ez = findobj('Tag', 'events_Z');
de = findobj('Tag', 'Disp_events');

% si il n'y a pas d'events
if isempty(ex)
    fprintf('There is no event to dysplay\n')
    return
end

if de.Value == 1
    ex.Visible = 'on';
    ey.Visible = 'on';
    ez.Visible = 'on';
else
    ex.Visible = 'off';
    ey.Visible = 'off';
    ez.Visible = 'off';
end

function select_dataref_auto(gcbo, eventdata, handles)

% tout deselectionne
sdata = findobj('Tag','dataref_auto');
sdata.Value = 0;
sHC   = findobj('Tag','HCref_auto');
sHC.Value = 0;

% reactive le boutton selectionne
eventdata.Source.Value = 1;

clear sdata sHC

function select_meanref_auto(gcbo, eventdata, handles)

global y_ref

% reference sur les datas ou les HC ?
if get(findobj('Tag','HCref_auto'), 'Value')
    fprintf('Reference on HC\n')
    quel_data = 'HC';
elseif get(findobj('Tag','dataref_auto'), 'Value')
    fprintf('Reference on data\n')
    quel_data = 'data';
end

eval(['y_ref.ref = y_ref.', quel_data,'.',eventdata.Source.String, ';'])
clear quel_data

saz = findobj('Tag','meanref_auto_zero');
same = findobj('Tag','meanref_auto_mean');
sama = findobj('Tag','meanref_auto_median');
samm = findobj('Tag','meanref_auto_minmax');

% tout deselectionne
saz.Value = 0;
same.Value = 0;
sama.Value = 0;
samm.Value = 0;
% reactive le boutton selectionne
eventdata.Source.Value = 1;
clear saz same sama samm


% modif l'affichage
slmx = findobj('Tag', 'slide_meanref_X');
cmxn = findobj('Tag', 'chg_meanref_X_nasio');
selxn = findobj('Tag', 'Select_meanref_X_nasio');
cmxel = findobj('Tag', 'chg_meanref_X_eleft');
selxel = findobj('Tag', 'Select_meanref_X_eleft');
cmxer = findobj('Tag', 'chg_meanref_X_erigh');
selxer = findobj('Tag', 'Select_meanref_X_erigh');

slmy = findobj('Tag', 'slide_meanref_Y');
cmyn = findobj('Tag', 'chg_meanref_Y_nasio');
selyn = findobj('Tag', 'Select_meanref_Y_nasio');
cmyel = findobj('Tag', 'chg_meanref_Y_eleft');
selyel = findobj('Tag', 'Select_meanref_Y_eleft');
cmyer = findobj('Tag', 'chg_meanref_Y_erigh');
selyer = findobj('Tag', 'Select_meanref_Y_erigh');

slmz = findobj('Tag', 'slide_meanref_Z');
cmzn = findobj('Tag', 'chg_meanref_Z_nasio');
selzn = findobj('Tag', 'Select_meanref_Z_nasio');
cmzel = findobj('Tag', 'chg_meanref_Z_eleft');
selzel = findobj('Tag', 'Select_meanref_Z_eleft');
cmzer = findobj('Tag', 'chg_meanref_Z_erigh');
selzer = findobj('Tag', 'Select_meanref_Z_erigh');

slmx.Value = y_ref.ref(1);
selxn.Value = 1;
cmxn.String = num2str(y_ref.ref(1));
selxel.Value = 0;
cmxel.String = num2str(y_ref.ref(4));
selxer.Value = 0;
cmxer.String = num2str(y_ref.ref(7));

slmy.Value = y_ref.ref(3);
selyn.Value = 1;
cmyn.String = num2str(y_ref.ref(2));
selyel.Value = 0;
cmyel.String = num2str(y_ref.ref(5));
selyer.Value = 0;
cmyer.String = num2str(y_ref.ref(8));

slmz.Value = y_ref.ref(6);
selzn.Value = 1;
cmzn.String = num2str(y_ref.ref(3));
selzel.Value = 0;
cmzel.String = num2str(y_ref.ref(6));
selzer.Value = 0;
cmzer.String = num2str(y_ref.ref(9));

clear sl* se* cm* 

% modif les plots
gx = findobj('Tag', 'goodarea_X_coil');
mx = findobj('Tag', 'meanref_X_coil');
gy = findobj('Tag', 'goodarea_Y_coil');
my = findobj('Tag', 'meanref_Y_coil');
gz = findobj('Tag', 'goodarea_Z_coil');
mz = findobj('Tag', 'meanref_Z_coil');
% quel delat mean ?
deltat_mean = findobj('Tag', 'chg_delta_mov');
deltat_mean = str2double(deltat_mean.String);

gx.YData = [y_ref.ref(1)+deltat_mean y_ref.ref(1)+deltat_mean y_ref.ref(1)-deltat_mean y_ref.ref(1)-deltat_mean];
mx.YData = [y_ref.ref(1) y_ref.ref(1)];
gy.YData = [y_ref.ref(2)+deltat_mean y_ref.ref(2)+deltat_mean y_ref.ref(2)-deltat_mean y_ref.ref(2)-deltat_mean];
my.YData = [y_ref.ref(2) y_ref.ref(2)];
gz.YData = [y_ref.ref(3)+deltat_mean y_ref.ref(3)+deltat_mean y_ref.ref(3)-deltat_mean y_ref.ref(3)-deltat_mean];
mz.YData = [y_ref.ref(3) y_ref.ref(3)];



function comp_ref_auto(data_ref, HC, data)
%% estimation du ref-start

global y_ref

HC_pos = [];
for xi_ds = 1 : length(HC)
    HC_pos = [HC_pos;HC{xi_ds}.dewar.nas HC{xi_ds}.dewar.lpa HC{xi_ds}.dewar.rpa];
end, clear xi_ds
% reference par rapport � la premiere mesure de data


y_ref.data.Zero   = zeros(1,9);
y_ref.data.Median = median(data_ref);
y_ref.data.Mean   = mean(data_ref);
y_ref.data.MinMax = min(data_ref)+(max(data_ref)-min(data_ref))/2;

y_ref.HC.Zero   = HC_pos(1,:)-data;
y_ref.HC.Median = median(HC_pos)-data;
y_ref.HC.Mean   = mean(HC_pos)-data;
y_ref.HC.MinMax = (min(HC_pos)+(max(HC_pos)-min(HC_pos))/2)-data;

y_ref.ref    = y_ref.data.Zero;
