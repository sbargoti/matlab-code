function [linePos, lineEnds, lineLength, lineAngles, linePointsIdx] = HoughLineFit(points2D,row_type)
% function [linePos, lineEnds, lineLength, lineAngles, linePointsIdx] = HoughLinesFit(points2D)
% Given a 2d point cloud, fit lines using the matlab build in hough
% transform function. 
disp('Applying Hough Transformation')

% The point cloud needs to be converted into an image file for it to be fed
% into the hough function
% Define image resolution
imageRes = 0.05;
mfactor = 0.02/imageRes;

% Round the pointCloud to the given resolution
points2D = round(points2D/imageRes)*imageRes;

% Convert to an image
pointsAsImage = PointCloud2Image(points2D,imageRes);

% Since we are locating trunks which are vertical, an angle threshold is
% applied on the fitted lines
thetaLimits = -15:15;

% Obtain the Hough Transform Matrix
[H,theta,rho] = hough(pointsAsImage,'theta',thetaLimits);

% Find the peaks
switch row_type
    case 'v-structure'
        numPeaksParam = 2000;
    case 'i-structure'
        numPeaksParam = 4000;
end
numPeaks = round(numPeaksParam*range(points2D(:,1))/80); % as a function of the total x-length of the data (2000 per 80m)
peakThresh = ceil(0.1*max(H(:))); % 10% of maxima
nhoodSize = ceil([15 5]*mfactor); if ~mod(nhoodSize(1),2), nhoodSize = nhoodSize+1; end 
peaks = houghpeaks(H,numPeaks,'threshold',peakThresh,'nhoodsize',nhoodSize);

% Fit lines back to the original data
lines = ModHoughLines(pointsAsImage,points2D,imageRes,theta,rho,peaks,ceil(5*mfactor),ceil(9*mfactor));

% Allocate line indices in cells
linePointsIdx = cell(length(lines),1);
for i = 1:length(lines)
    linePointsIdx{i} = lines(i).IDX';
end

% Convert back from image space to metric space
% Line end points
endPoint1 = [lines.point1];
endPoint1 = reshape(endPoint1,2,length(lines))';
endPoint2 = [lines.point2];
endPoint2 = reshape(endPoint2,2,length(lines))';
lineEnds = [endPoint1 endPoint2];
% Line Length
lineLength = sqrt(sum((endPoint1-endPoint2).^2,2));
% Line Midpoint
lineMidPoint = (endPoint1+endPoint2)/2;
% Angles
lineAngles = [lines.theta]';

% Covert to metric space
linePos = Image2Metric(lineMidPoint,imageRes,min(points2D,[],1));
lineEnds = Image2Metric(lineEnds,imageRes,[min(points2D,[],1) min(points2D,[],1)]);
lineLength = Image2Metric(lineLength,imageRes,0);

% Remove mid points that are not around the middle
% pointsNotInMiddle_IDX = linePos(:,2)<0.15 | linePos(:,2)>0.45;

% Output
% linePos(pointsNotInMiddle_IDX,:) = [];
% lineEnds(pointsNotInMiddle_IDX,:) = [];
% lineLength(pointsNotInMiddle_IDX) = [];
% lineAngles(pointsNotInMiddle_IDX,:) = [];
% linePointsIdx(pointsNotInMiddle_IDX,:) = [];
end

function imagePoints = PointCloud2Image(points2D,imageRes)
% Convert from points to an bit wise image
% Limits and range of the metric point cloud
pcRange = range(points2D,1);
pcLims = [min(points2D,[],1) max(points2D,[],1)];

% Limits and range of the transformed image
imRange = round(pcRange/imageRes);

% Rescale the point cloud
for i = 1:2
    scaledPoints(:,i) = (points2D(:,i)-pcLims(i))/pcRange(i) * imRange(i) + 1;
end

% Initialise image matrix
imagePoints = zeros(imRange(2)+1,imRange(1)+1,'uint8');
index = sub2ind(size(imagePoints),scaledPoints(:,2)',scaledPoints(:,1)');
imagePoints(int32(index)) = 255;

end

function metricPos = Image2Metric(imagePos,imageRes,metricOffset)
% Convert back to metric coordinates

metricPos = (imagePos-1) * imageRes + repmat(metricOffset,size(imagePos,1),1);
end


