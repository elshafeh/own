scenario = "Temporal_discrimination_threshold";

scenario_type = trials;

default_output_port = 1;             	# hardware setting: port 1
write_codes = true;                 	# Send only user-defined codes to parallel port
  
no_logfile = false;
response_logging = log_active;
active_buttons = 2;
button_codes = 1,2;   
default_background_color = 0, 0, 0;  #black background

begin; 

trial{
	trial_duration = 2000;
	stimulus_event {
		picture {
			text  {
					caption = "U voelt zo 1 schokje als voorbeeld";
					font_size = 25;
					font_color = 255,255,255;
				  }one_text;
				x = 0;
				y = 0;
		} pic_one;
      code = "one"; 
	}event_one;
}instruction_one;

trial{
	trial_duration = 2000;
	stimulus_event {
		picture {
			text  {
					caption = "U voelt zo 2 schokjes als voorbeeld";
					font_size = 25;
					font_color = 255,255,255;
				  }two_text;
				x = 0;
				y = 0;
		} pic_two;
      code = "to"; 
	}event_two;
}instruction_two;

		picture{
			text{
				caption = "*";
				font_size = 25;
				font_color = 255,255,255;
				}defaulttext;
			x = 0;
			y = 0;
		}pic_default;


trial{
   trial_duration = 30000;        	# end at first button press,
   trial_type = first_response;  	#   but only wait certain amount of seconds (trial_duration)
	start_delay = 2000;
	stimulus_event {
		picture {
				  text  {
							caption = "Hoeveel schokjes voelde u? 
											1 of 2?";
							font_size = 25;
							font_color = 255,255,255;
				  };
				  x = 0;
				  y = 0;
		} pic_askresponse;
      code = "ask_response"; 
	}event_askresponse;
}askresponse;

trial{
   stimulus_event {
      nothing {};
      code = "pulse";
		port_code = 64;   
   }event_trigger;
}triggerpulse;

trial{
	trial_duration = 3000;
	stimulus_event {
		picture {
				  text  {
							caption = "Einde blok";
							font_size = 25;
							font_color = 255,255,255;
				  }text_blockdone;
				  x = 0;
				  y = 0;
		} pic_blockdone;
      code = "end_block"; 
	}event_blockdone;
}blockdone;

trial{
	trial_duration = 6000;
	stimulus_event {
		picture {
				  text  {
							caption = "klaar met dit deel";
							font_size = 25;
							font_color = 255,255,255;
				  };
				  x = 0;
				  y = 0;
		} pic_endtext;
      code = "endtext"; 
	}event_endtext;
}endtext;

trial{
   stimulus_event {
      nothing{};
      code = "wilbesetlater";   
   }event_sendtologfile;
}sendtologfile;

begin_pcl;

output_port oport = output_port_manager.get_port( 1 ); # send codes to bitsi to change pulse width from 30 (default) to 5. 
oport.send_code(0);
oport.send_code(1);
oport.send_code(5);

int step = 10; # steps to increase or decrease inter stimulus interval with (in ms)
int delay = 0; #delay at start experiment
int blocks = 3; # number of blocks
int trialnr = 25; # number of trials after first time 2 pulses were felt in each block
int twofelt = 0; #initually 2 pulses are not felt yet


instruction_one.present();
		triggerpulse.set_start_delay(random(-250,250) + 2500);
		triggerpulse.present();
		triggerpulse.set_start_delay(0);
		triggerpulse.present();	
		askresponse.present();
		wait_interval(500);
instruction_one.present();
		triggerpulse.set_start_delay(random(-250,250) + 2500);
		triggerpulse.present();
		triggerpulse.set_start_delay(0);
		triggerpulse.present();	
		askresponse.present();
		wait_interval(500);
instruction_two.present();
		triggerpulse.set_start_delay(random(-250,250) + 2500);
		triggerpulse.present();
		triggerpulse.set_start_delay(350);
		triggerpulse.present();	
		askresponse.present();
		wait_interval(500);
instruction_two.present();
		triggerpulse.set_start_delay(random(-250,250) + 2500);
		triggerpulse.present();
		triggerpulse.set_start_delay(350);
		triggerpulse.present();	
		askresponse.present();	
		wait_interval(500);

endtext.present();

oport.send_code(0); # send codes to bitsi to change pulse width back to 30 (default).
oport.send_code(1);
oport.send_code(30);