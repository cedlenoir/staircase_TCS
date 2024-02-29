
% Define variables for plot 1
x = 1:numel(result.temp_foot1)
y1 = result.temp_foot1;
y2 = result.temp_hand1;
y12 = result.delta_temp_hand_foot;

% Plot 1
figure
subplot(2,1,1)
plot(x,y1,'r')
hold
plotyy(x,y2,x,y12(1:numel(result.temp_foot1)))

title('SUBJECT 3 SESSION 2 Hand-foot')
legend('Foot','Hand', 'Delta')

% Define variables for plot 2
x = 1:numel(result.temp_foot2)
y3 = result.temp_foot2
y4 = result.temp_hand2;
y34 = result.delta_temp_foot_hand;

% Plot 2
subplot(2,1,2)
plot(x,y3,'r')
hold
plotyy(x,y4,x,y34(1:numel(result.temp_foot2)))
title('SUBJECT 3 SESSION 2 Foot-Hand')
legend('Foot','Hand','Delta')
