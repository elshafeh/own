function ade_present_text(P,text2write)

ade_DarkBackground(P);

Screen(P.window,'TextSize',P.TextSize);
DrawFormattedText(P.window, text2write, 'center', 'center', P.TextColor); % Display task instructions
Screen('Flip', P.window);
