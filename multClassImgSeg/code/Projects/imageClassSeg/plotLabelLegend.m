% plot label legend
function []=plotLabelLegend(labelMap)

classNameList = ...
{'Void      ',...
 'leaves	',...
 'almonds	',...
 'trunk     ',...
 'ground	',...
 'sky       '};

classColour = [0 	0 	0
64 128 64
128 0 0
128 128 0
192 192 128
0	0	255];

figure;hold on
for i = 1: length(labelMap)
    currentClr = classColour(labelMap(i),:)/255;
    plot(i,i,'s','MarkerEdgeColor', currentClr, 'MarkerFaceColor', currentClr)
end
hold off
legend(classNameList(labelMap),'Orientation','Horizontal','FontSize',12,'FontWeight','Bold','EdgeColor','w')
end