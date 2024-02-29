% Choose layout 2 graphes
tiledlayout(2,1)

% Define variables for plot 1
x = 1:numel(result.temp_foot1)
y1 = result.temp_foot1;
y2 = result.temp_hand1;
y12 = result.delta_temp_hand_foot;

% Plot 1
ax1=nexttile;
plot(ax1,x,y1,x,y2)
yyaxis right
plot(ax1,x,y12(1:numel(result.temp_foot1)))
title(ax1,'SOLENN SESSION 1 Hand-foot')
legend('Foot','Hand', 'Delta')

% Define variables for plot 2
x = 1:numel(result.temp_foot2)
y3 = result.temp_foot2
y4 = result.temp_hand2;
y34 = result.delta_temp_foot_hand;

% Plot 2
ax2=nexttile;
plot(ax2,x,y3,x,y4)
yyaxis right
plot(ax2,x,y34(1:numel(result.temp_foot2)))
title(ax2,'SOLENN SESSION 1 Foot-Hand')
legend('Foot','Hand','Delta')
