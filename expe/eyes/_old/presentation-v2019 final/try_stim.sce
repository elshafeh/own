# header
scenario = "stim_choose";

write_codes 					= true; # send codes to output port

active_buttons 				= 2;
button_codes   				= 4, 8;

default_font_size 			= 30;
default_text_color		 	= 255,255,255; # white
default_background_color 	= 0,0,0;  # black

$set_comb 						= 4;

# SDL code
begin;

########################################
### define  auditory cues/isntruct	 ###
########################################
TEMPLATE "sound.tem";
TEMPLATE "audio_instruct.tem";

########################################
### define all the required pictures ###
########################################

TEMPLATE "picture.tem" {
name 						colour				content;
default					"255,255,255"		"+";		# default picture: fixation cross
};

######################################
### define all the required trials ###
######################################

# instruction trials, use template
TEMPLATE "trial.tem" {
name 						trlcode				content;
example					"example"			"Here follows an example of the stimuli.\n\nPush a button to start.";
};

trial example;

TEMPLATE "audcue_tactstimEX.tem" {          
cue					cue_code 	stim	 resp	comb; 
cue_left  	  		64			 2 		1	$set_comb;
cue_left  			64		 	 2 		2 	$set_comb; 
cue_right 			128		 1 		1 	$set_comb; 
cue_right 			128		 1 		2	$set_comb;  
};

# the end #
trial end;