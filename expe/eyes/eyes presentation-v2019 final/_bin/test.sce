# header
scenario = "spatial attention PRACTISE SESSION 1";

write_codes 					= true; # send codes to output port

active_buttons 				= 2;
button_codes   				= 1, 2;

default_font_size 			= 30;
default_text_color		 	= 255,255,255; # white
default_background_color 	= 0,0,0;  # black

# SDL code
begin;

########################################
### 	define  auditory cues 	 		 ###
########################################
TEMPLATE "sound.tem";

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
instruction				"instruct"			"Instruction:\nIndicate as fast as possible whether the stimulus frequency was low or high.\n Low = blue button\n High = yellow button\n\nPush a button to continue.";
example					"example"			"Here follows an example of the stimuli.\n\nPush a button to start.";
};

# trial: feedback correct
trial {
	sound feedback_correct;
	duration 	= 200;
	code 			= "correct";
	port_code 	= 16;
}correct;

# trial: feedback incorrect

trial {
	sound feedback_incorrect;
	duration 	= 200;
	code 			= "incorrect";
	port_code 	= 48;
}incorrect;

# trial: feedback no response (=incorrect)
trial {
	sound feedback_incorrect;
	duration 	= 200;
	code 			= "noresp";
	port_code 	= 80;
}noresp;


#############################
### the actual experiment ###
#############################

###################
# example	 		#
# left/right		#
# low/high			#
###################

trial example;
	
TEMPLATE "audcue_tactstimEX.tem" {          
cue					cue_code 	stim	 resp; 
cue_left  	  	64			 4 		1;
cue_left  		64		 	 4 		2; 
cue_right 		128		 8 		1; 
cue_right 		128		 8 		2; 
};