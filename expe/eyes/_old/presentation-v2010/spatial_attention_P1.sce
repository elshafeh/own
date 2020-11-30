# header
scenario = "spatial attention PRACTISE SESSION 1";

write_codes = true; # send codes to output port

active_buttons = 2;
button_codes   = 1, 2;

default_font_size 			= 30;
default_text_color		 	= 255,255,255; # white
default_background_color 	= 0,0,0;  # black


# SDL code
begin;


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
example_leftlow		"255,255,255"		"Left hand, low frequency.";
example_lefthigh		"255,255,255"		"Left hand, high frequency.";
example_rightlow		"255,255,255"		"Right hand, low frequency.";
example_righthigh		"255,255,255"		"Right hand, high frequency.";
};


######################################
### define all the required trials ###
######################################

# instruction trials, use template
TEMPLATE "trial.tem" {
name 						trlcode				content;
instruction				"instruct"			"Instruction:\nIndicate as fast as possible whether the stimulus frequency was low or high.\nLow = blue button\nHigh = yellow button\n\nPush a button to continue.";
instruction_cue100	"instruct100"		"Instruction:\nThe cue is correct on 100% of the trials.\n\nPush a button to continue.";
instruction_cue75		"instruct75"		"Instruction:\nThe cue is correct on 75% of the trials.\n\nPush a button to continue.";
example					"example"			"Here follows an example of the stimuli.\n\nPush a button to start.";
the_end					"end"					"The end of the practise session.";
nodis						"nodis"				"Instruction:\nThis block is WITHOUT distractor.\n\nPush a button to start.";
withdis					"withdis"			"Instruction:\nThis block is WITH distractor.\n\nPush a button to start.";
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
# example	 		#
# left/right		#
# low/high			#
###################

trial example;
	
TEMPLATE "viscue_tactstimEX.tem" {          
cue					cue_code 	stim	 resp; 
example_leftlow  	  	64			 4 		1;
example_lefthigh  	64		 	 4 		2; 
example_rightlow 		128		 8 		1; 
example_righthigh 	128		 8 		2; 
};


###################
# practice	 		#
# condition: 100%	#
# trials: 104		#
###################

trial instruction;
trial instruction_cue100;


# block of 52 trials - NO DISTRACTOR
trial nodis;
TEMPLATE "viscue_tactstimPRAC.tem"  randomize {          
cue		cue_code 	stim		resp; 
LOOP $i 13; # 13*4 = 52 trials
cue_left  	64			 4 		 1; # cue left   stim left	 	low
cue_left  	64			 4 		 2; # cue left   stim left	 	high
cue_right 	128		 8 		 1; # cue right  stim right 	low
cue_right 	128		 8 		 2; # cue right  stim right 	high
ENDLOOP;
};


# block of 52 trials - WITH DISTRACTOR
trial withdis;
TEMPLATE "viscue_tactstim.tem"  randomize {          
cue		cue_code 	stim		resp; 
LOOP $i 13; # 13*4 = 52 trials
cue_left  	64			 4 		 1; # cue left   stim left	 	low
cue_left  	64			 4 		 2; # cue left   stim left	 	high
cue_right 	128		 8 		 1; # cue right  stim right 	low
cue_right 	128		 8 		 2; # cue right  stim right 	high
ENDLOOP;
};



###################
# practice	 		#
# condition: 75%	#
# trials: 96		#
###################

trial instruction;
trial instruction_cue75;

# block of 48 trials - NO DISTRACTOR
trial nodis;
TEMPLATE "viscue_tactstimPRAC.tem"  randomize {          
cue		cue_code 	stim		resp; 
LOOP $i 9; # 9*4 = 36 trials (=75%)
cue_left  	64			 4 		 1; # cue left   stim left	 	low
cue_left  	64			 4 		 2; # cue left   stim left	 	high
cue_right 	128		 8 		 1; # cue right  stim right 	low
cue_right 	128		 8 		 2; # cue right  stim right 	high
ENDLOOP;
LOOP $i 3; # 3*4 = 12 trials (=25%)
cue_left  	64			 8 		 1; # cue left   stim right	low
cue_left  	64			 8 		 2; # cue left   stim right	high
cue_right 	128		 4 		 1; # cue right  stim left 	low
cue_right 	128		 4 		 2; # cue right  stim left 	high
ENDLOOP;
};


# block of 48 trials - WITH DISTRACTOR
trial withdis;
TEMPLATE "viscue_tactstim.tem"  randomize {          
cue		cue_code 	stim		resp; 
LOOP $i 9; # 9*4 = 36 trials (=75%)
cue_left  	64			 4 		 1; # cue left   stim left	 	low
cue_left  	64			 4 		 2; # cue left   stim left	 	high
cue_right 	128		 8 		 1; # cue right  stim right 	low
cue_right 	128		 8 		 2; # cue right  stim right 	high
ENDLOOP;
LOOP $i 3; # 3*4 = 12 trials (=25%)
cue_left  	64			 8 		 1; # cue left   stim right	low
cue_left  	64			 8 		 2; # cue left   stim right	high
cue_right 	128		 4 		 1; # cue right  stim left 	low
cue_right 	128		 4 		 2; # cue right  stim left 	high
ENDLOOP;
};


# the end #
trial the_end;
# the end #