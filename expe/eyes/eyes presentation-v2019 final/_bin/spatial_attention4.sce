# header
scenario = "spatial attention";

write_codes = true; # send codes to output port

active_buttons = 2;
button_codes   = 1, 2;

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
cue_left					"255,255,255"		"<";		# picture: cue left
cue_right				"255,255,255"		">";		# picture: cue right
feedback_correct 		"0,255,0" 			"+";		# picture: feedback correct (green)
feedback_incorrect 	"255,0,0"			"+";		# picture: feedback incorrect (red)
};


######################################
### define all the required trials ###
######################################

# instruction trials, use template
TEMPLATE "trial.tem" {
name 						trlcode				content;
instruction				"instruct"			"Instruction:\nIndicate as fast as possible whether the stimulus frequency was low or high.\nLow = blue button\nHigh = yellow button\n\nPush a button to continue.";
instruction_cue100	"instruct100"		"Instruction:\nThe cue is correct on 100% of the trials.\n\nPush a button to start.";
instruction_cue75		"instruct75"		"Instruction:\nThe cue is correct on 75% of the trials.\n\nPush a button to start.";
instruction_cue50		"instruct50"		"Instruction:\nThe cue is correct on 50% of the trials.\n\nPush a button to start.";
break						"break"				"You can take a break now. Please don't move.\n\nPush a button to continue.";
the_end					"end"					"The end of the experiment. Please don't move yet.";
};

# trial: feedback correct
trial {
	picture feedback_correct;
	duration = 200;
	code = "correct";
	port_code = 16;
}correct;

# trial: feedback incorrect
trial {
	picture feedback_incorrect;
	duration = 200;
	code = "incorrect";
	port_code = 48;
}incorrect;

# trial: feedback no response (=incorrect)
trial {
	picture feedback_incorrect;
	duration = 200;
	code = "noresp";
	port_code = 80;
}noresp;


#############################
### the actual experiment ###
#############################


###################
# block 2 	   	#
# condition: 75%	#
# trials: 480		#
###################

trial instruction;
trial instruction_cue75;

LOOP $b 3;

	# 3 blocks of 160 trials
	TEMPLATE "viscue_tactstim.tem"  randomize {          
	cue		cue_code 	stim		resp;
	LOOP $i 30; # 30*4 = 120 trials (=75%)
	cue_left  	64			 4 		 1; 	# cue left   stim left	 low
	cue_left  	64			 4 		 2; 	# cue left   stim left	 high
	cue_right 	128		 8 		 1; 	# cue right  stim right  low
	cue_right 	128		 8 		 2; 	# cue right  stim right  high
	ENDLOOP;
	LOOP $i 10; # 10*4 = 40 trials (=25%)
	cue_left  	64			 8 		 1; 	# cue left   stim right	 low
	cue_left  	64			 8 		 2; 	# cue left   stim right	 high
	cue_right 	128		 4 		 1; 	# cue right  stim left 	 low
	cue_right 	128		 4 		 2; 	# cue right  stim left 	 high
	ENDLOOP;
	};
	
	trial break; # break after each block

ENDLOOP;



###################
# block 3 	   	#
# condition: 50%	#
# trials: 200		#
###################

trial instruction;
trial instruction_cue50;

# 1 block of 200 trials
TEMPLATE "viscue_tactstim.tem"  randomize {          
cue		cue_code 	stim		resp; 
LOOP $i 25; # 25*8 = 200 trials
cue_left  	64			 4 		 1; 	# cue left   stim left	 low
cue_left  	64			 4 		 2; 	# cue left   stim left	 high
cue_right 	128		 8 		 1; 	# cue right  stim right  low
cue_right 	128		 8 		 2; 	# cue right  stim right  high
cue_left  	64			 8 		 1; 	# cue left   stim right	 low
cue_left  	64			 8 		 2; 	# cue left   stim right	 high
cue_right 	128		 4 		 1; 	# cue right  stim left 	 low
cue_right 	128		 4 		 2; 	# cue right  stim left 	 high
ENDLOOP;
};

trial break; # break after each block



###################
# block 1 	   	#
# condition: 100%	#
# trials: 200		#
###################

trial instruction;
trial instruction_cue100;

# 1 block of 200 trials
TEMPLATE "viscue_tactstim.tem"  randomize {          
cue		cue_code 	stim		resp; 
LOOP $i 50; # 50*4 = 200 trials
cue_left  	64			 4 		 1; # cue left   stim left	 	low
cue_left  	64			 4 		 2; # cue left   stim left	 	high
cue_right 	128		 8 		 1; # cue right  stim right 	low
cue_right 	128		 8 		 2; # cue right  stim right 	high
ENDLOOP;
};



# the end #
trial the_end;
# the end #


