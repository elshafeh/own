scenario = "Determine stimulation intensity";

scenario_type = trials;

default_output_port = 1;             	# hardware setting: port 1
write_codes = true;                 	# Send only user-defined codes to parallel port
  
no_logfile = false;
response_logging = log_active;
active_buttons = 3;
button_codes = 1,2,3;   
default_background_color = 0, 0, 0;  #black background

begin;

trial{
	trial_duration = 6000;
	stimulus_event {
		picture {
				  text  {
							caption = "U kan zo schokjes voelen. 
							Geef aan of u deze gevoeld heeft met de koppen 'j' (ja) en 'n' (nee)";
							font_size = 25;
							font_color = 255,255,255;
				  };
				  x = 0;
				  y = 0;
		} pic_instruction;
      code = "instruction"; 
	}event_instruction;
}instruction;

trial{
   stimulus_event {
      nothing {};
      code = "pulse";
		port_code = 64;   
   }event_trigger;
}triggerpulse;

trial{
   trial_duration = 90000;        	# end at first button press,
   trial_type = first_response;  	# but only wait set amount of ms (trial_duration)
	start_delay = 2000;
	stimulus_event {
		picture {
				  text  {
							caption = "De onderzoeker past de instellingen aan";
							font_size = 25;
							font_color = 255,255,255;
				  };
				  x = 0;
				  y = 0;
		} pic_asksetting;
     code = "wait_for_setting"; 
#port_code = 77;
	}event_waitforsetting;
}waitforsetting;

trial{
   trial_duration = 10000;        	# end at first button press,
   trial_type = first_response;  	#   but only wait 10 sec
	start_delay = 2000;
	stimulus_event {
		picture {
				  text  {
							caption = "Voelde u een schokje (j=ja, n=nee)?";
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

begin_pcl;

output_port oport = output_port_manager.get_port( 1 ); # send codes to bitsi to change pulse width from 30 (default) to 5. 
oport.send_code(0);
oport.send_code(1);
oport.send_code(5);


instruction.present();

loop
	int pulses = 0; # counts all pulses at current intensity
	int felt = 0; # counts the pulses felt on current intensity
	int minpulse = 3; # minimum number of pulses at a set frequency
	int notfelt = 0; # counts the pulses not felt on current intensity
until felt > 9

begin
   triggerpulse.set_start_delay(2000);
	triggerpulse.present();
	pulses = pulses+1;
	askresponse.present();
	if response_manager.last_response() == 2 then #not felt
		felt = 0;
		notfelt = notfelt+1;
		if notfelt > 2 || pulses > 3 then		
			waitforsetting.present();
			notfelt = 0;
			pulses = 0;
		end;
	end;
	if response_manager.last_response() == 1 then #felt
		felt = felt + 1;
		notfelt = 0;
	end;
end;

endtext.present();

oport.send_code(0); # send codes to bitsi to change pulse width back to 30 (default).
oport.send_code(1);
oport.send_code(30);