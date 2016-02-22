% collect multiple regions for grab cut

% figure(1);imagesc(currentImage);
% 
function [initMap] = collectSeedPoints(currentImage, labels)
reply = [];
grabCutRegion = zeros(size(labels));

while isempty(reply)
    
    oldGrabCutRegion = grabCutRegion;
    grabCutRegion = roipoly(currentImage); 
    grabCutRegion = grabCutRegion + oldGrabCutRegion;
    grabCutRegion(grabCutRegion>1) = 1;
    
    figure(2);imagesc(grabCutRegion);
    reply = input('Type anything to Stop the loop\n','s');
       
    
end

grabCutRegion = grabCutRegion -1;

initMap = grabCutRegion;

% % use this to plot the grabcut boundary over the original image
% figure;imagesc(currentImage);hold on
% % gcBoxBound = bwboundaries(initMap);
% gcBoxBound = bwboundaries(grabCutRegion);
% 
% for i = 1:length(gcBoxBound)
%     plot(gcBoxBound{i}(:,2), gcBoxBound{i}(:,1),'r')
% end
% hold off
%     
% 
% figure;imagesc(currentImage);hold on
% gcBoxBound = bwboundaries(certain_fg);
% for i = 1:length(gcBoxBound)
%     plot(gcBoxBound{i}(:,2), gcBoxBound{i}(:,1),'g')
% end
% 
% gcBoxBound = bwboundaries(certain_bg);
% for i = 1:length(gcBoxBound)
%     plot(gcBoxBound{i}(:,2), gcBoxBound{i}(:,1),'r')
% end
% hold off
% 
% fgPixelPts = [];
% bgPixelPts = [];
% % figure;imagesc(currentImage);
% figure(3)
% fgPixelPts = ginput(inf);
% % figure;plot(fgPixelPts(:,1),fgPixelPts(:,2),'ko')
% 
% bgPixelPts = ginput(inf);
% % plot(bgPixelPts(:,1),bgPixelPts(:,2),'ro')
% 
% fg_hard = zeros(size(labels));
% fgPixelInd = sub2ind(size(labels),round(fgPixelPts(:,2)), round(fgPixelPts(:,1)));
% fg_hard(fgPixelInd) = 1;
% % figure;imagesc(fg_hard);
% 
% 
% bg_hard = zeros(size(labels));
% bgPixelInd = sub2ind(size(labels),round(bgPixelPts(:,2)), round(bgPixelPts(:,1)));
% bg_hard(bgPixelInd) = 1;
% % figure;imagesc(bg_hard);
% 
% 
% initMap = initMap + fg_hard;
% initMap = initMap - bg_hard;
% 
% figure;imagesc(initMap)
% 
% figure;imagesc(currentImage);axis image; hold on
% plot(fgPixelPts(:,1),fgPixelPts(:,2),'g.')
% plot(bgPixelPts(:,1),bgPixelPts(:,2),'r.')
% hold off
% 
