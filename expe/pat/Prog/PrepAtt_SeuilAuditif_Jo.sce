# Audiometry.sce: Audiometry Utilities (Discrimination) #

# header
scenario = "SeuilAuditif";
pcl_file = "Audiometry.pcl";
active_buttons = 1; #*
button_codes = 1; #*

# sound hardware settings
channels = 2;             # stereo
bits_per_sample = 16;
sampling_rate = 44100;    # sample rate (Hz)
#parametres ecran
default_font_size = 30 ;
default_font = "Arial";
default_text_color = 0, 200, 200;   #turquoise
#screen_width = 1024;
#screen_height = 768;
#screen_bit_depth = 32;

# load stimuli
begin;

picture {} default;
       
# load in array of target sounds       
array {  
   sound { wavefile { filename = "tar_1_low.wav"; }; description = "L_tarson"; };
   sound { wavefile { filename = "tar_1_high.wav"; }; description = "H_tarson"; };
} sounds;



# -- Threshold_Test_Bekesy stimuli -- #

$TRIAL_DURATION_TTB = 1000;    # length of sound trial


# New Test Screen
trial {
   trial_duration = $TRIAL_DURATION_TTB;
   picture {
      text {
         caption = " ";
         system_memory = true;
      } newtestText_ttb;
      x = 0; y = 0;
   };
} newtest_ttb;
        
# Prompt For Button Press When Sound Disappears
picture {
   text { 
      caption = "Tirez le joystick vers vous 
dès que 
vous n'entendez plus le son";
      font_color = 255,0,0;
      font_size = 60;	
      system_memory = true; 
   };
   x = 0; y = 0;
} buttonMsg1_ttb;

# Prompt For Button Press When Sound Re-appears
picture {
   text { 
      caption = "Tirez le joystick vers vous
dès que 
vous entendez le son 
à nouveau";
      font_color = 0,255,0;
      font_size = 60;
      system_memory = true; 
   };
   x = 0; y = 0;
} buttonMsg2_ttb;

# Sound Trial
trial {
   trial_duration = $TRIAL_DURATION_TTB;
   stimulus_event {
      picture buttonMsg1_ttb;
	   time = 0;
   } picstim_ttb;
   stimulus_event {
      nothing {};
      time = 0; 
      code = "sound";
   } audstim_ttb;
} audtrial_ttb;


#-------------------------------------------------------------------------------
# Toggle Example/New stimuli
#-------------------------------------------------------------------------------

# input screen
trial {
   trial_duration = 100;
   picture {
      text {
         caption = " ";
         system_memory = true;
      } enterText_sub;
      x = 0; y = 0;
   };
} enterTrial_sub;
