function sm_value = sem(vector)

mn_value    = mean(vector);
st_value    = std(vector);
sm_value    = st_value ./ sqrt(length(vector));

disp(['mean = ' num2str(round(mn_value,2)) ' ± ' num2str(round(sm_value,2)) ' SEM']);