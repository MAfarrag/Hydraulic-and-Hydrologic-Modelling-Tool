function plott(R)
%% plotting
plot(R(2,:),R(5,:),'-','LineWidth',2); % plotting water level
hold on
plot(R(2,:),R(4,:),'-','LineWidth',2); % % plotting bed level
plot(R(2,:),R(3,:),'--','LineWidth',1); % % plotting water depth
title('Water level Profile ','FontSize',12,'FontWeight','bold','Color','c')             
xlabel('Distance m','FontSize',12,'FontWeight','bold','Color','c');
ylabel('Level m','FontSize',12,'FontWeight','bold','Color','c');
legend('Water level','Bed level','Water depth','Location','east')
