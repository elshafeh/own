function P = ade_parameters(Info)
%% display , sound and Bisti

P       = ade_param_screen_and_sound(Info); 
P       = ade_startBitsi(P);

%% structure
P       = ade_param_structure(P,Info); 

%% Response Keys

KbName('UnifyKeyNames');

P.key1  = ('1!'); % to check the key code (e.g. '1!' when you press 1), run KbName and then run the key of interest. The output will tell you the corresponding keycode for your computer.
P.key2  = KbName('2@');
P.key3  = KbName('3#');
P.key4  = KbName('4$');

%% Target Parameters
P       = ade_param_target(P,Info);

HideCursor;
