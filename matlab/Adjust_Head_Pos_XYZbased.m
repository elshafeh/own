function Adjust_Head_Pos_XYZbased(Header, meanref)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% 
% necessaire pour les fonction d'exportation CTF
% addpath(genpath('C:\\Data\Sauvegarde\Programmes_Matlab\spm12\'))
% 
% MAJ
% 
% - 15/07/15   RB
%     Correction du pb entraine par le rejet d'aucun bad segments
%     Ajout des ZOOM
%
% - 26/07/16   RB
%     Correction du pb d'enregistrement sous linux ou mac : sortie de la
%     commande ls (sting ou cell)
%
% - 27/07/16   AC
%     Correction du pb de matrice de passage. Les coordonn�e dans le rep�re
%     t�te �taient mauvaises car la matrice hogenous �tait calcul�e sur les
%     ancienne coordonn�es de coils (que l'on a justement chang�...)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Init
separator = '\';

global Header
global D_eucl_nas D_eucl_eleft D_eucl_eright
global D_eucl_X D_eucl_Y D_eucl_Z

GUI = {};
DSpath = {};

pos_ref = 1;   % sample de reference
delta_mov = .5;  % mouvement acceptable en cm


%% Import data
fprintf('Importation...\n')
data = [];
for xi_dsfile = 1 : length(Header.filename)
    
    DS = readCTFds(Header.filename{xi_dsfile});
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
    data = [data; getCTFdata(DS, [], IndexHC(1:9), 'ft', 'double')];

    % extraction des events
    if xi_dsfile == 1
        events = extract_events(DS, CharLabel);
    else
        events = [events; extract_events(DS, CharLabel)+Header.blockoffset(xi_dsfile-1)];
    end

    clear DS CharLabel IndexHC
    
end

fprintf('Done\n\n')
fprintf('Total data lenght : %s s\n', num2str(Header.blockoffset(end)/Header.sample_rate))

% mesure sont en metre, transformation en cm
fprintf('Conversion   m -> cm\n\n')
data = data*100;
time = [1:size(data, 1)]/ Header.sample_rate;

% position par raport au sample de ref
fprintf('Position centered on the mean_ref\n')
data = data-repmat(data(pos_ref,:),size(data,1),1);
pos_ref = [meanref.X(1) meanref.Y(1) meanref.Z(1) meanref.X(2) meanref.Y(2) meanref.Z(2) meanref.X(3) meanref.Y(3) meanref.Z(3)];

fprintf('Comput distances\n')
D_eucl_X = sqrt((data(:,1)-pos_ref(1)).^2 + (data(:,4)-pos_ref(4)).^2 + (data(:,7)-pos_ref(7)).^2);
D_eucl_Y = sqrt((data(:,2)-pos_ref(2)).^2 + (data(:,5)-pos_ref(5)).^2 + (data(:,8)-pos_ref(8)).^2);
D_eucl_Z = sqrt((data(:,3)-pos_ref(3)).^2 + (data(:,6)-pos_ref(6)).^2 + (data(:,9)-pos_ref(9)).^2);

D_eucl_nas    = sqrt((data(:,1)-pos_ref(1)).^2 + (data(:,2)-pos_ref(2)).^2 + (data(:,3)-pos_ref(3)).^2);
D_eucl_eleft  = sqrt((data(:,4)-pos_ref(4)).^2 + (data(:,5)-pos_ref(5)).^2 + (data(:,6)-pos_ref(6)).^2);
D_eucl_eright = sqrt((data(:,7)-pos_ref(7)).^2 + (data(:,8)-pos_ref(8)).^2 + (data(:,9)-pos_ref(9)).^2);


fprintf('\nTrend\n\tX: %s cm\n\tY: %s cm\n\tZ: %s cm\n ', num2str(D_eucl_X(end)-D_eucl_X(1)), num2str(D_eucl_Y(end)-D_eucl_Y(1)), num2str(D_eucl_Z(end)-D_eucl_Z(1)))
fprintf('\nJump\n\tX: %s cm\n\tY: %s cm\n\tZ: %s cm\n\n ', num2str(max(abs(D_eucl_X))-D_eucl_X(1)), num2str(max(abs(D_eucl_Y))-D_eucl_Y(1)), num2str(max(abs(D_eucl_Z))-D_eucl_Z(1)))

%% Display

y_mean = 0;

GUI.f = figure('Position', [100 100 1000 1000], 'Color', [1 1 1]);

subplot(3,1,1)
hold on
GUI.X.goodarea = fill([1 time(end) time(end) 1], [y_mean+delta_mov y_mean+delta_mov 0 0], 'r');
GUI.X.goodarea.Tag = 'goodarea_D1';
GUI.X.goodarea.EdgeAlpha = 0;
GUI.X.goodarea.FaceAlpha = .05;
GUI.X.plot_X = plot(time, D_eucl_nas, 'k', 'Tag', 'plot_D1');
GUI.X.meanref = plot([1 time(end)], [y_mean y_mean], 'b:');
GUI.X.meanref.Tag = 'meanref_D1';
GUI.X.plot_X.Parent.YLim = [min(D_eucl_nas)-delta_mov max(D_eucl_nas)+delta_mov];
GUI.X.plot_X.Parent.XLim = [0 time(end)];
GUI.X.plot_X.Parent.Position(1) = GUI.X.plot_X.Parent.Position(1)+0.075;
events_toplot     = [events'; events'; nan(1,length(events))];
GUI.X.events      = plot(events_toplot(:)/Header.sample_rate, repmat([GUI.X.plot_X.Parent.YLim(1) GUI.X.plot_X.Parent.YLim(2) NaN], 1,length(events)), ':r',...
    'Linewidth', 0.01, 'Tag', 'D_events_X', 'Visible', 'off');
title('Distance Nasion')

subplot(3,1,2)
hold on
GUI.Y.goodarea = fill([1 time(end) time(end) 1], [y_mean+delta_mov y_mean+delta_mov 0 0], 'r');
GUI.Y.goodarea.Tag = 'goodarea_D2';
GUI.Y.goodarea.EdgeAlpha = 0;
GUI.Y.goodarea.FaceAlpha = .05;
GUI.Y.plot_Y = plot(time, D_eucl_eleft, 'k', 'Tag', 'plot_D2');
GUI.Y.meanref = plot([1 time(end)], [y_mean y_mean], 'b:');
GUI.Y.meanref.Tag = 'meanref_D2';
GUI.Y.plot_Y.Parent.YLim = [min(D_eucl_eleft)-delta_mov max(D_eucl_eleft)+delta_mov];
GUI.Y.plot_Y.Parent.XLim = [0 time(end)];
GUI.Y.plot_Y.Parent.Position(1) = GUI.Y.plot_Y.Parent.Position(1)+0.075;
GUI.Y.events      = plot(events_toplot(:)/Header.sample_rate, repmat([GUI.Y.plot_Y.Parent.YLim(1) GUI.Y.plot_Y.Parent.YLim(2) NaN], 1,length(events)), ':r',...
    'Linewidth', 0.01, 'Tag', 'D_events_Y', 'Visible', 'off');
title('Distance Ear Left')

subplot(3,1,3)
hold on
GUI.Z.goodarea = fill([1 time(end) time(end) 1], [y_mean+delta_mov y_mean+delta_mov 0 0], 'r');
GUI.Z.goodarea.Tag = 'goodarea_D3';
GUI.Z.goodarea.EdgeAlpha = 0;
GUI.Z.goodarea.FaceAlpha = .05;
GUI.Z.plot_Z = plot(time, D_eucl_eright, 'k', 'Tag', 'plot_D3');
GUI.Z.meanref = plot([1 time(end)], [y_mean y_mean], 'b:');
GUI.Z.meanref.Tag = 'meanref_D3';
GUI.Z.plot_Z.Parent.YLim = [min(D_eucl_eright)-delta_mov max(D_eucl_eright)+delta_mov];
GUI.Z.plot_Z.Parent.XLim = [0 time(end)];
GUI.Z.plot_Z.Parent.Position(1) = GUI.Z.plot_Z.Parent.Position(1)+0.075;
GUI.Z.events      = plot(events_toplot(:)/Header.sample_rate, repmat([GUI.Z.plot_Z.Parent.YLim(1) GUI.Z.plot_Z.Parent.YLim(2) NaN], 1,length(events)), ':r',...
    'Linewidth', 0.01, 'Tag', 'D_events_Z', 'Visible', 'off');
title('Distance Ear Right')


% changement de la nature des datas 
GUI.plot_coils = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', 'Coils',...
    'Position', [100 900 40 20], 'FontSize', 8, 'FontWeight','bold',...
    'Units', 'normalized', 'Callback', @chg_plot_coil);

GUI.plot_XYZ = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', 'XYZ',...
    'Position', [50 900 40 20], 'FontSize', 8, 'FontWeight','bold',...
    'Units', 'normalized', 'Callback', @chg_plot_XYZ);


% reglage de la position de reference et du delta acceptable
uicontrol('Parent', GUI.f, 'Style', 'text', 'String', 'Delta move (cm)',...
     'Position', [60 80 70 20],'Units', 'normalized',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [.5 0 0], 'BackgroundColor', [1 1 1])
 
GUI.chg_delta_mov = uicontrol('Parent', GUI.f, 'Style', 'edit', 'String', '0.5',...
     'Position', [100 35 30 20],'Units', 'normalized', 'Tag', 'D_chg_delta_mov',...
     'FontSize', 8, 'FontWeight','bold',...
     'Callback', @chg_delta_mov);
 
GUI.slide_delta_mov = uicontrol('Style', 'slider', 'Min', 0,'Max', 1, 'Value', delta_mov,...      
    'Position', [25 60 160 20],'SliderStep',[.001 .1], 'Units', 'normalized',...
    'BackgroundColor', [0 0 0], 'Tag', 'D_slide_delta_mov',...
    'Callback', @slidy);



% ZOOM
% pour X
GUI.zoom.D1.plus = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', '+',...
    'position', [130 750 20 20], 'Units', 'normalized', 'Tag', 'plus_D1',...
     'FontSize', 10, 'FontWeight','bold','BackgroundColor', [1 1 1],...
    'Callback', @zoom_adapt);
GUI.zoom.D1.moins = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', '-',...
    'position', [130 730 20 20], 'Units', 'normalized', 'Tag', 'moins_D1',...
     'FontSize', 10, 'FontWeight','bold','BackgroundColor', [1 1 1],...
    'Callback', @zoom_adapt);
% pour Y
GUI.zoom.D2.plus = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', '+',...
    'position', [130 460 20 20], 'Units', 'normalized', 'Tag', 'plus_D2',...
     'FontSize', 10, 'FontWeight','bold','BackgroundColor', [1 1 1],...
    'Callback', @zoom_adapt);
GUI.zoom.D2.moins = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', '-',...
    'position', [130 440 20 20], 'Units', 'normalized', 'Tag', 'moins_D2',...
     'FontSize', 10, 'FontWeight','bold','BackgroundColor', [1 1 1],...
    'Callback', @zoom_adapt);
% pour Z
GUI.zoom.D3.plus = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', '+',...
    'position', [130 150 20 20], 'Units', 'normalized', 'Tag', 'plus_D3',...
     'FontSize', 10, 'FontWeight','bold','BackgroundColor', [1 1 1],...
    'Callback', @zoom_adapt);
GUI.zoom.D3.moins = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', '-',...
    'position', [130 130 20 20], 'Units', 'normalized', 'Tag', 'moins_D3',...
     'FontSize', 10, 'FontWeight','bold','BackgroundColor', [1 1 1],...
    'Callback', @zoom_adapt);


% affichage des statistiques
% pour X
uicontrol('Parent', GUI.f, 'Style', 'text', 'String', 'Data rejected',...
     'Position', [20 850 90 20],'Units', 'normalized',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1])
GUI.stat.X.data_pct = uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '0',...
     'Position', [40 830 20 20],'Units', 'normalized', 'HorizontalAlignment', 'right', 'Tag', 'text_X_data_pct',...
     'FontSize', 8, 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1]);
uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '/100',...
     'Position', [60 830 25 20],'Units', 'normalized', 'HorizontalAlignment', 'left',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1])
GUI.stat.X.data_time = uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '0',...
     'Position', [110 830 20 20],'Units', 'normalized','Tag', 'text_X_data_time',...
     'FontSize', 8, 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1], 'HorizontalAlignment', 'right');
uicontrol('Parent', GUI.f, 'Style', 'text', 'String', 's',...
     'Position', [130 830 55 20],'Units', 'normalized', 'HorizontalAlignment', 'left',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1])

uicontrol('Parent', GUI.f, 'Style', 'text', 'String', 'Events rejected', 'Tag', 'text_ev_x_1',...
     'Position', [20 800 90 20],'Units', 'normalized', 'Visible', 'off',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1])
GUI.stat.X.ev_pct = uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '0', 'Visible', 'off',...
     'Position', [40 780 20 20],'Units', 'normalized', 'HorizontalAlignment', 'right', 'Tag', 'text_X_ev_pct',...
     'FontSize', 8, 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1], 'HorizontalAlignment', 'right');
uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '/100', 'Visible', 'off',...
     'Position', [60 780 25 20],'Units', 'normalized', 'HorizontalAlignment', 'left', 'Tag', 'text_ev_x_2',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1])
GUI.stat.X.ev_time = uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '0',...
     'Position', [110 780 20 20],'Units', 'normalized','Tag', 'text_X_ev_nb',...
     'FontSize', 8, 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1], 'Visible', 'off');

 
% pour Y
uicontrol('Parent', GUI.f, 'Style', 'text', 'String', 'Data rejected',...
     'Position', [20 550 90 20],'Units', 'normalized',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1])
GUI.stat.Y.data_pct = uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '0',...
     'Position', [40 530 20 20],'Units', 'normalized', 'HorizontalAlignment', 'right', 'Tag', 'text_Y_data_pct',...
     'FontSize', 8, 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1]);
uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '/100',...
     'Position', [60 530 25 20],'Units', 'normalized', 'HorizontalAlignment', 'left',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1])
GUI.stat.Y.data_time = uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '0',...
     'Position', [110 530 20 20],'Units', 'normalized','Tag', 'text_Y_data_time',...
     'FontSize', 8, 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1], 'HorizontalAlignment', 'right');
uicontrol('Parent', GUI.f, 'Style', 'text', 'String', 's',...
     'Position', [130 530 55 20],'Units', 'normalized', 'HorizontalAlignment', 'left',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1])

uicontrol('Parent', GUI.f, 'Style', 'text', 'String', 'Events rejected', 'Tag', 'text_ev_y_1',...
     'Position', [20 500 90 20],'Units', 'normalized', 'Visible', 'off',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1])
GUI.stat.Y.ev_pct = uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '0',...
     'Position', [40 480 20 20],'Units', 'normalized', 'HorizontalAlignment', 'right', 'Tag', 'text_Y_ev_pct',...
     'FontSize', 8, 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1], 'Visible', 'off');
uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '/100', 'Visible', 'off', 'Tag', 'text_ev_y_2',...
     'Position', [60 480 25 20],'Units', 'normalized', 'HorizontalAlignment', 'left',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1])
GUI.stat.Y.ev_time = uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '0',...
     'Position', [110 480 20 20],'Units', 'normalized','Tag', 'text_Y_ev_nb', 'Visible', 'off',...
     'FontSize', 8, 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1], 'HorizontalAlignment', 'right');

% pour Z
uicontrol('Parent', GUI.f, 'Style', 'text', 'String', 'Data rejected',...
     'Position', [20 250 90 20],'Units', 'normalized',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1])
GUI.stat.Z.data_pct = uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '0',...
     'Position', [40 230 20 20],'Units', 'normalized', 'Tag', 'text_Z_data_pct',...
     'FontSize', 8, 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1]);
uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '/100',...
     'Position', [60 230 25 20],'Units', 'normalized',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1])
GUI.stat.Z.data_time = uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '0',...
     'Position', [110 230 20 20],'Units', 'normalized','Tag', 'text_Z_data_time',...
     'FontSize', 8, 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1], 'HorizontalAlignment', 'right');
uicontrol('Parent', GUI.f, 'Style', 'text', 'String', 's',...
     'Position', [130 230 55 20],'Units', 'normalized', 'HorizontalAlignment', 'left',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1])

uicontrol('Parent', GUI.f, 'Style', 'text', 'String', 'Events rejected', 'Tag', 'text_ev_z_1',...
     'Position', [20 200 90 20],'Units', 'normalized', 'Visible', 'off',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1])
GUI.stat.Z.ev_pct = uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '0',...
     'Position', [40 180 20 20],'Units', 'normalized', 'Tag', 'text_Z_ev_pct', 'Visible', 'off',...
     'FontSize', 8, 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1], 'HorizontalAlignment', 'right');
uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '/100', 'Tag', 'text_ev_z_2',...
     'Position', [60 180 25 20],'Units', 'normalized', 'Visible', 'off',...
     'FontSize', 8, 'FontWeight','bold', 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1])
GUI.stat.Z.ev_time = uicontrol('Parent', GUI.f, 'Style', 'text', 'String', '0',...
     'Position', [110 180 20 20],'Units', 'normalized','Tag', 'text_Z_ev_nb', 'Visible', 'off',...
     'FontSize', 8, 'ForegroundColor', [0 0 0], 'BackgroundColor', [1 1 1], 'HorizontalAlignment', 'right');

 
 % affichage des events
GUI.disp_events = uicontrol('Style', 'radiobutton', 'String', 'Events', 'Value', 0,...
    'Position', [400 30 60 20],'Units', 'normalized', 'BackgroundColor', [1 1 1],...
    'Tag', 'Disp_D_events', 'Callback', @Disp_events); 


% Extract Head Coils AND BadSegments
GUI.comput_distance = uicontrol('Parent', GUI.f, 'Style', 'pushbutton', 'String', 'Extract Head Coils AND BadSegments',...
    'position', [500 30 200 20], 'Units', 'normalized',...
     'FontSize', 8, 'FontWeight','bold','BackgroundColor', [.7 0 .9],...
    'Callback', @Extract_newHC_badsegments);


% display inutil
GUI.HZ = uicontrol('Parent', GUI.f, 'Style', 'text', 'String', num2str(Header.sample_rate),...
     'Position', [40 10 20 20],'Units', 'normalized', 'Tag', 'HZ', ...
     'FontSize', 5, 'ForegroundColor', [.9 .9 .9], 'BackgroundColor', [1 1 1]);

Eval_stats

%%
function zoom_adapt(gcbo, eventdata, handles)

bt = gco;
quel_zoom = bt.Tag(1:end-3);
quel_axe = bt.Tag(end-1:end);
quel_plot = findobj('Tag', ['plot_' quel_axe]);
if bt.String == '+'
    quel_plot.Parent.YLim = quel_plot.Parent.YLim*0.9;
elseif bt.String == '-'
    quel_plot.Parent.YLim = quel_plot.Parent.YLim*1.1;
end




% extractions des events
function trigg_events = extract_events(DS, CharLabel)

    Index_event = strmatch('UPPT', CharLabel);
    if length(Index_event) ~= 1
        trigg_events = [];
        fprintf('Event extraction canceled\nToo many event channel\n')
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

    
    
function slidy(gcbo, eventdata, handles)

sg = findobj('Tag', 'D_slide_delta_mov');
delta_mov = sg.Value;

g = findobj('Tag', 'D_chg_delta_mov');
g.String = num2str(delta_mov);

chg_delta_mov

clear h sh g sg delta_mov pos_ref 


function chg_delta_mov(gcbo, eventdata, handles)

g = findobj('Tag', 'D_chg_delta_mov');
delta_mov = str2num(g.String);

sg = findobj('Tag', 'D_slide_delta_mov');
sg.Value = delta_mov;

set(findobj('Tag', 'goodarea_D1'), 'YData', [delta_mov delta_mov 0 0])
set(findobj('Tag', 'goodarea_D2'), 'YData', [delta_mov delta_mov 0 0])
set(findobj('Tag', 'goodarea_D3'), 'YData', [delta_mov delta_mov 0 0])

Eval_stats

clear g h sh sg pos_ref delta_mov


function Eval_stats(gcbo, eventdata, handles)

px = findobj('Tag', 'plot_D1');
py = findobj('Tag', 'plot_D2');
pz = findobj('Tag', 'plot_D3');
g = findobj('Tag', 'D_chg_delta_mov');
t_x_data_p = findobj('Tag', 'text_X_data_pct');
t_x_data_t = findobj('Tag', 'text_X_data_time');
t_y_data_p = findobj('Tag', 'text_Y_data_pct');
t_y_data_t = findobj('Tag', 'text_Y_data_time');
t_z_data_p = findobj('Tag', 'text_Z_data_pct');
t_z_data_t = findobj('Tag', 'text_Z_data_time');
HZ = findobj('Tag', 'HZ');
ev = findobj('Tag', 'D_events_X');
t_x_ev_p = findobj('Tag', 'text_X_ev_pct');
t_y_ev_p = findobj('Tag', 'text_Y_ev_pct');
t_z_ev_p = findobj('Tag', 'text_Z_ev_pct');
t_x_ev_t = findobj('Tag', 'text_X_ev_nb');
t_y_ev_t = findobj('Tag', 'text_Y_ev_nb');
t_z_ev_t = findobj('Tag', 'text_Z_ev_nb');

inter_good = [0 str2num(g.String)];

x_seuil = ones(1, length(px.YData));
x_seuil(px.YData<inter_good(1)) = 0;
x_seuil(px.YData>inter_good(2)) = 0;

y_seuil = ones(1, length(py.YData));
y_seuil(py.YData<inter_good(1)) = 0;
y_seuil(py.YData>inter_good(2)) = 0;

z_seuil = ones(1, length(pz.YData));
z_seuil(pz.YData<inter_good(1)) = 0;
z_seuil(pz.YData>inter_good(2)) = 0;


seuil_event = find(ev.YData== max(ev.YData));
% time_event = ev.XData(seuil_event);
time_event = seuil_event;
ev_X_seuil = ones(1, length(time_event));
tp = px.YData(time_event);
ev_X_seuil(tp>inter_good(2))=0;
ev_X_seuil(tp<inter_good(1))=0;
clear tp seuil_event

ev_Y_seuil = ones(1, length(time_event));
tp = py.YData(time_event);
ev_Y_seuil(tp>inter_good(2))=0;
ev_Y_seuil(tp<inter_good(1))=0;
clear tp

ev_Z_seuil = ones(1, length(time_event));
tp = pz.YData(time_event);
ev_Z_seuil(tp>inter_good(2))=0;
ev_Z_seuil(tp<inter_good(1))=0;
clear tp


t_x_data_p.String = num2str(100-(round(100*mean(x_seuil))));
t_x_data_t.String = num2str((length(px.XData)-sum(x_seuil))/str2num(HZ.String));
t_y_data_p.String = num2str(100-(round(100*mean(y_seuil))));
t_y_data_t.String = num2str((length(px.XData)-sum(y_seuil))/str2num(HZ.String));
t_z_data_p.String = num2str(100-(round(100*mean(z_seuil))));
t_z_data_t.String = num2str((length(px.XData)-sum(z_seuil))/str2num(HZ.String));

t_x_ev_p.String = num2str(100-(round(100*mean(ev_X_seuil))));
t_x_ev_t.String = num2str(sum(ev_X_seuil));
t_y_ev_p.String = num2str(100-(round(100*mean(ev_Y_seuil))));
t_y_ev_t.String = num2str(sum(ev_Y_seuil));
t_z_ev_p.String = num2str(100-(round(100*mean(ev_Z_seuil))));
t_z_ev_t.String = num2str(sum(ev_Z_seuil));

fprintf('\nData rejected:\n')
fprintf('X:\t %s pct \t or \t %s s\n', t_x_data_p.String, t_x_data_t.String)
fprintf('Y:\t %s pct \t or \t %s s\n', t_y_data_p.String, t_y_data_t.String)
fprintf('Z:\t %s pct \t or \t %s s\n', t_z_data_p.String, t_z_data_t.String)

clear p_x_data p_y_data p_z_data x_seuil y_seuil z_seuil inter_good


function chg_plot_coil(gcbo, eventdata, handles)

global D_eucl_nas D_eucl_eleft D_eucl_eright

px = findobj('Tag', 'plot_D1');
py = findobj('Tag', 'plot_D2');
pz = findobj('Tag', 'plot_D3');

g = findobj('Tag', 'D_chg_delta_mov');
delta_mov = str2num(g.String);

px.YData = D_eucl_nas;
px.Parent.YLim = [min(px.YData)-delta_mov max(px.YData)+delta_mov];
px.Parent.Title.String = 'Distance Nasion';
py.YData = D_eucl_eleft;
py.Parent.YLim = [min(py.YData)-delta_mov max(py.YData)+delta_mov];
py.Parent.Title.String = 'Distance Ear Left';
pz.YData = D_eucl_eright;
pz.Parent.YLim = [min(pz.YData)-delta_mov max(pz.YData)+delta_mov];
pz.Parent.Title.String = 'Distance Ear Right';

clear px y pz g delta_move


function chg_plot_XYZ(gcbo, eventdata, handles)

global D_eucl_X D_eucl_Y D_eucl_Z

px = findobj('Tag', 'plot_D1');
py = findobj('Tag', 'plot_D2');
pz = findobj('Tag', 'plot_D3');

g = findobj('Tag', 'D_chg_delta_mov');
delta_mov = str2num(g.String);

px.YData = D_eucl_X;
px.Parent.YLim = [min(px.YData)-delta_mov max(px.YData)+delta_mov];
px.Parent.Title.String = 'Distance along X';
py.YData = D_eucl_Y;
py.Parent.YLim = [min(py.YData)-delta_mov max(py.YData)+delta_mov];
py.Parent.Title.String = 'Distance along Y';
pz.YData = D_eucl_Z;
pz.Parent.YLim = [min(pz.YData)-delta_mov max(pz.YData)+delta_mov];
pz.Parent.Title.String = 'Distance along Z';

clear px y pz g delta_move


function Disp_events(gcbo, eventdata, handles)

ex = findobj('Tag', 'D_events_X');
ey = findobj('Tag', 'D_events_Y');
ez = findobj('Tag', 'D_events_Z');
de = findobj('Tag', 'Disp_D_events');
tex1 = findobj('Tag', 'text_ev_x_1');
tex2 = findobj('Tag', 'text_ev_x_2');
tex3 = findobj('Tag', 'text_X_ev_pct');
tex4 = findobj('Tag', 'text_X_ev_nb');
tey1 = findobj('Tag', 'text_ev_y_1');
tey2 = findobj('Tag', 'text_ev_y_2');
tey3 = findobj('Tag', 'text_Y_ev_pct');
tey4 = findobj('Tag', 'text_Y_ev_nb');
tez1 = findobj('Tag', 'text_ev_z_1');
tez2 = findobj('Tag', 'text_ev_z_2');
tez3 = findobj('Tag', 'text_Z_ev_pct');
tez4 = findobj('Tag', 'text_Z_ev_nb');

% si il n'y a pas d'events
if isempty(ex)
    fprintf('There is no event to dysplay\n')
    return
end

if de.Value == 1
    ex.Visible = 'on';
    ey.Visible = 'on';
    ez.Visible = 'on';
    tex1.Visible = 'on';
    tex2.Visible = 'on';
    tex3.Visible = 'on';
    tex4.Visible = 'on';
    tey1.Visible = 'on';
    tey2.Visible = 'on';
    tey3.Visible = 'on';
    tey4.Visible = 'on';
    tez1.Visible = 'on';
    tez2.Visible = 'on';
    tez3.Visible = 'on';
    tez4.Visible = 'on';
else
    ex.Visible = 'off';
    ey.Visible = 'off';
    ez.Visible = 'off';
    tex1.Visible = 'off';
    tex2.Visible = 'off';
    tex3.Visible = 'off';
    tex4.Visible = 'off';
    tey1.Visible = 'off';
    tey2.Visible = 'off';
    tey3.Visible = 'off';
    tey4.Visible = 'off';
    tez1.Visible = 'off';
    tez2.Visible = 'off';
    tez3.Visible = 'off';
    tez4.Visible = 'off';
end


function Extract_newHC_badsegments(gcbo, eventdata, handles)

global Header

% bad segments
px = findobj('Tag', 'plot_D1');
py = findobj('Tag', 'plot_D2');
pz = findobj('Tag', 'plot_D3');
g = findobj('Tag', 'D_chg_delta_mov');

inter_good = [0 str2num(g.String)];

x_seuil = ones(1, length(px.YData));
x_seuil(px.YData<inter_good(1)) = 0;
x_seuil(px.YData>inter_good(2)) = 0;

y_seuil = ones(1, length(py.YData));
y_seuil(py.YData<inter_good(1)) = 0;
y_seuil(py.YData>inter_good(2)) = 0;

z_seuil = ones(1, length(pz.YData));
z_seuil(pz.YData<inter_good(1)) = 0;
z_seuil(pz.YData>inter_good(2)) = 0;

badSegments = unique([find(x_seuil==0) find(y_seuil==0) find(z_seuil==0)]);
clear px py pz g inter_good x_seuil y_seuil z_seuil

write_Badsegments(Header, badSegments)

% coils
cxn = findobj('Tag', 'chg_meanref_X_nasio');
cxl = findobj('Tag', 'chg_meanref_X_eleft');
cxr = findobj('Tag', 'chg_meanref_X_erigh');
cyn = findobj('Tag', 'chg_meanref_Y_nasio');
cyl = findobj('Tag', 'chg_meanref_Y_eleft');
cyr = findobj('Tag', 'chg_meanref_Y_erigh');
czn = findobj('Tag', 'chg_meanref_Z_nasio');
czl = findobj('Tag', 'chg_meanref_Z_eleft');
czr = findobj('Tag', 'chg_meanref_Z_erigh');

dewar.nas = [Header.start_pos.nas(1)+str2double(cxn.String) Header.start_pos.nas(2)+str2double(cyn.String) Header.start_pos.nas(3)+str2double(czn.String)];
dewar.lpa = [Header.start_pos.lpa(1)+str2double(cxl.String) Header.start_pos.lpa(2)+str2double(cyl.String) Header.start_pos.lpa(3)+str2double(czl.String)];
dewar.rpa = [Header.start_pos.rpa(1)+str2double(cxr.String) Header.start_pos.rpa(2)+str2double(cyr.String) Header.start_pos.rpa(3)+str2double(czr.String)];

% calcul de la matrice de passage
% compute the direction of the head coordinate axes in dewar coordinates
d_x = dewar.nas - (dewar.lpa + dewar.rpa)/2;
d_z = cross(d_x, dewar.lpa - dewar.rpa);
d_y = cross(d_z, d_x);
d_x = d_x / norm(d_x);
d_y = d_y / norm(d_y);
d_z = d_z / norm(d_z);

% compute the translation and rotation which are neccessary to transform
% any given location from the dewar to the head coordinate system
hc.translation = -(dewar.lpa + dewar.rpa)/2;
hc.rotation = inv([d_x' d_y' d_z']);

% construct the homogenous coordinate transformation matrix
% from the subsequent translation and rotation
hc.homogenous = eye(4,4);
hc.homogenous(1:3,4)   = hc.rotation * hc.translation';
hc.homogenous(1:3,1:3) = hc.rotation;

% construct a vector with the 12 parameters for an affine warp
hc.affine = hc.homogenous';
hc.affine = hc.affine(1:12);



head.nas = [dewar.nas 1] * hc.homogenous';
head.nas = head.nas(1:3);
head.lpa = [dewar.lpa 1] * hc.homogenous';
head.lpa = head.lpa(1:3);
head.rpa = [dewar.rpa 1] * hc.homogenous';
head.rpa = head.rpa(1:3);

clear cx* cy* cz*

write_HC(Header, dewar, head)

% nettoyage brutal
clear -global
close all hidden;
clear functions;
close all

function write_HC(Header, dewar, head)

if ispc
    separator = '\';
else
    separator = '/';
end

for xi_file = 1 : length(Header.filename)
    
    % sauvegarde du vieux
    new_dir = clock;
    new_dir = [date, '_', num2str(new_dir(4)), 'm', num2str(new_dir(5)), 'm'];
    new_dir = [Header.filename{xi_file}, separator, 'BK_HeadCoils_', new_dir];
    mkdir(new_dir)
    clear time
    copy_HC_file = ls([Header.filename{xi_file}, separator, '*.hc']);
    for xi_cp = 1 : size(copy_HC_file,1)
        if ispc
            copyfile([Header.filename{xi_file}, separator, deblank(copy_HC_file(xi_cp, :))], [new_dir, separator ])
        else
            copyfile(deblank(copy_HC_file(xi_cp, :)), [new_dir, separator ])
        end
    end
    clear xi_cp copy_HC_file new_dir 
    
    % creation des nouveaux fichiers
    [~, filename, ~] = fileparts(Header.filename{xi_file});
    fprintf('save file :\n\t\t%s\n', [Header.filename{xi_file}, separator, filename, '.hc'])
    fid = fopen([Header.filename{xi_file}, separator, filename, '.hc'], 'w');
    fprintf(fid, 'standard nasion coil position relative to dewar (cm):\n');
    fprintf(fid, '\tx = %s\n\ty = %s\n\tz = %s\n', num2str(Header.HC_raw{1}.standard.nas(1)), num2str(Header.HC_raw{1}.standard.nas(2)), num2str(Header.HC_raw{1}.standard.nas(3)));
    fprintf(fid, 'standard left ear coil position relative to dewar (cm):\n');
    fprintf(fid, '\tx = %s\n\ty = %s\n\tz = %s\n', num2str(Header.HC_raw{1}.standard.lpa(1)), num2str(Header.HC_raw{1}.standard.lpa(2)), num2str(Header.HC_raw{1}.standard.lpa(3)));
    fprintf(fid, 'standard right ear coil position relative to dewar (cm):\n');
    fprintf(fid, '\tx = %s\n\ty = %s\n\tz = %s\n', num2str(Header.HC_raw{1}.standard.rpa(1)), num2str(Header.HC_raw{1}.standard.rpa(2)), num2str(Header.HC_raw{1}.standard.rpa(3)));
    fprintf(fid, 'measured nasion coil position relative to dewar (cm):\n');
    fprintf(fid, '\tx = %s\n\ty = %s\n\tz = %s\n', num2str(dewar.nas(1)), num2str(dewar.nas(2)), num2str(dewar.nas(3)));
    fprintf(fid, 'measured left ear coil position relative to dewar (cm):\n');
    fprintf(fid, '\tx = %s\n\ty = %s\n\tz = %s\n', num2str(dewar.lpa(1)), num2str(dewar.lpa(2)), num2str(dewar.lpa(3)));
    fprintf(fid, 'measured right ear coil position relative to dewar (cm):\n');
    fprintf(fid, '\tx = %s\n\ty = %s\n\tz = %s\n', num2str(dewar.rpa(1)), num2str(dewar.rpa(2)), num2str(dewar.rpa(3)));
    fprintf(fid, 'measured nasion coil position relative to head (cm):\n');
    fprintf(fid, '\tx = %s\n\ty = %s\n\tz = %s\n', num2str(head.nas(1)), num2str(head.nas(2)), num2str(head.nas(3)));
    fprintf(fid, 'measured left ear coil position relative to head (cm):\n');
    fprintf(fid, '\tx = %s\n\ty = %s\n\tz = %s\n', num2str(head.lpa(1)), num2str(head.lpa(2)), num2str(head.lpa(3)));
    fprintf(fid, 'measured right ear coil position relative to head (cm):\n');
    fprintf(fid, '\tx = %s\n\ty = %s\n\tz = %s\n', num2str(head.rpa(1)), num2str(head.rpa(2)), num2str(head.rpa(3)));
    fclose(fid);
end
clear xi_file


function write_Badsegments(Header, badSegments)

if ispc
    separator = '\';
else
    separator = '/';
end

for xi_file = 1 : length(Header.filename)

    % sauvegarde du vieux
    new_dir = clock;
    new_dir = [date, '_', num2str(new_dir(4)), 'm', num2str(new_dir(5)), 'm'];
    new_dir = [Header.filename{xi_file}, separator, 'BK_BadSegments_', new_dir];
    mkdir(new_dir)
    clear time
    
    if ispc
        copy_BS_file = ls([Header.filename{xi_file}, separator, '*bad.segments*']);
        for xi_cp = 1 : size(copy_BS_file,1)
            copyfile([Header.filename{xi_file} separator deblank(copy_BS_file(xi_cp, :))], [ new_dir, separator ])
        end
    else
        dir_res = dir([Header.filename{xi_file}, separator, '*bad.segments*']);
        copy_BS_file = {};
        for xi_dir = 1 : length(dir_res)
            copy_BS_file{xi_dir} = [Header.filename{xi_file} separator dir_res(xi_dir).name];
        end
        clear xi_dir
        for xi_cp = 1 : size(copy_BS_file,2)
            copyfile(copy_BS_file{xi_cp}, [ new_dir, separator ])
        end
        
    end
    
%     copy_BS_file = ls([Header.filename{xi_file}, separator, '*bad.segments*']);
%     
%     for xi_cp = 1 : size(copy_BS_file,1)
%         if ispc
%             copyfile([Header.filename{xi_file} separator deblank(copy_BS_file(xi_cp, :))], [ new_dir, separator ])
%         else
%             copyfile(deblank(copy_BS_file(xi_cp, :)), [ new_dir, separator ])
%         end
%     end
    
    clear xi_cp copy_BS_file
    

    win_bs = [];
    if ~isempty(badSegments)
        % separation des badsegments par .ds
        % ici les .ds sont concatenes donc ils faut deconcatener
        extract_badSeg = [];
        extract_badSeg = badSegments(badSegments<=Header.blockoffset(xi_file));
        if xi_file > 1
            extract_badSeg = extract_badSeg(extract_badSeg>Header.blockoffset(xi_file-1));
        end
        
        if ~isempty(extract_badSeg)
            % cherche la fin des fenetres
            transition = [find(extract_badSeg(2:end)-extract_badSeg(1:end-1)>1) length(extract_badSeg)];
            win_bs = [extract_badSeg([1 transition(1:end-1)+1])' extract_badSeg(transition)'];
            clear extract_badSeg transition
            if xi_file > 1
                win_bs = win_bs-Header.blockoffset(xi_file-1);
            end
        end
        
    end
        
    % ouverture du fichier badsegments deja existant
    old_bs = textread([Header.filename{xi_file}, separator, 'bad.segments']);
    if ~isempty(old_bs)
        old_bs = old_bs(:,2:3);else
    end
    
    % concat old and new badsegments
    win_bs = [old_bs; win_bs];
    clear old_bs
    
    win_bs = sort(win_bs, 'ascend');
    
    new_bs = [];
    if ~isempty(win_bs)
        % concatenation de badsegments chevauchants
        new_bs = win_bs(1,:);
        for xi_bs = 2 : size(win_bs,1)
            if win_bs(xi_bs,1) > win_bs(xi_bs-1,2)
                new_bs = [new_bs; win_bs(xi_bs,:)];
            else
                if win_bs(xi_bs,2) > win_bs(xi_bs-1,2)
                    new_bs(end,2) = win_bs(xi_bs,2);
                end
            end
        end
        clear xi_bs win_bs
    end
    
    % sauvegarde du nouveau badsegments
    fprintf('Save file :\n\t\t%s\n', [Header.filename{xi_file}, separator, 'bad.segments'])
    fid = fopen([Header.filename{xi_file}, separator, 'bad.segments'], 'w');
    for xi_bs = 1 : size(new_bs,1)
        fprintf(fid, '1\t\t%s\t\t%s\n', num2str(new_bs(xi_bs,1)/Header.sample_rate), num2str(new_bs(xi_bs,2)/Header.sample_rate));
    end
    clear xi_bs
    fclose(fid);
    
    clear win_bs
end


