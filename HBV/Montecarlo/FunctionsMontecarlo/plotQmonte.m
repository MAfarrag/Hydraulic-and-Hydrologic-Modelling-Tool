function plotQmonte(Q)
%% plotting
plot(1:length(Q(:,1)),Q(:,1),'LineWidth',1); % plotting water level
hold on
title('Observed Flow')             
%xlabel('Distance m');
ylabel('Discharge 10^3 m3/sec');
%legend('Water level')
% ax = gca;
% ax.XAxisLocation = 
% ax.Box = 'off';
% ax.Layer = 'top';
h = get(gca,'ytick');
set(gca,'yticklabel',h/10^3)
