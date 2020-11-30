# header
scenario = "spatial attention block";

write_codes 					= true; # send codes to output port

active_buttons 				= 2;
button_codes   				= 4, 8;

default_font_size 			= 30;
default_text_color		 	= 255,255,255; # white
default_background_color 	= 0,0,0;  # black

$set_comb 						= 5;
$eye_cond 						= eye_open;

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
instruction				"instruct"			"Instruction:\nIndicate as fast as possible whether the stimulus frequency was low or high.\n Low = left button\n High = right button\n\nPush a button to continue.";
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

trial example;
	
TEMPLATE "audcue_tactstimEX.tem" {          
cue					cue_code 	stim	 resp comb; 
cue_left  	  		64			 2 		1 $set_comb;
cue_left  			64		 	 2 		2 $set_comb; 
cue_right 			128		 1 		1 $set_comb; 
cue_right 			128		 1 		2 $set_comb;  
};

###################
# practice	 		#
# condition: 100%	#
###################

trial instruction;
trial $eye_cond;

# block - NO DISTRACTOR
TEMPLATE "audcue_tactstimPR.tem"  randomize {          
cue		cue_code 	stim		resp comb; 
LOOP $i 19; # 19*4 = 76 trials (4 blocks)
cue_left  	64			 2 		 1 $set_comb; # cue left   stim left	 	low
cue_left  	64			 2 		 2 $set_comb; # cue left   stim left	 	high
cue_right 	128		 1 		 1 $set_comb; # cue right  stim right 	low
cue_right 	128		 1 		 2 $set_comb; # cue right  stim right 	high
ENDLOOP;
};

# the end #
trial end;