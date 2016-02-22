% main appleFlowerLabeller

% 9 Jan 2014
% calvin hung
% this works by 
% 1: user labels the rough outline of the objects, single
% click to place new vertice and doulbe click to finish drawing the
% polygons. press entre for next polygon, entre any keys then entre to end
% 2: use interactive graphcut to refine the segmentation
% 3: the output image and labels are saved to the same format defined by 
% InteractLabeler1_2_1. so can refine segmentation using InteractLabeler1_2_1

% it's works fine but i still need to clean up afterward, it's faster to
% just do per pixel labelling for now, this function might be useful in
% other applications i can't think of at the moment

dbstop if error

%% Initialisation
currentPath = cd;
% rootPath = currentPath(1:13);

rootPath = currentPath(1:(strfind(currentPath,'work')+4)); % to work/

dataPath = ['C:\work\data\raw\2013-10-08-melbourne-apples\shrimp\e8s-e9n-pollinator-plady\bumblebee\L\'];

outputPath = ['C:\Users\khun7630\Dropbox\work\code\Projects\labelAssist\labelledData\'];



% image segmentation common
addpath( [rootPath 'code\Projects\imageClassSeg\']);
addpath( [rootPath 'code\GrabCut\']);



%% 0 Initialisation

imgFolderName = dataPath;
imgList = dir([imgFolderName '*.png']);

imNo = 100;
fprintf('image:%i/%i\n',imNo, length(imgList))
imageName = imgList(imNo).name;
orginImage = im2double(imread([[imgFolderName imageName]]));

% figure;imagesc(orginImage);axis image

[imDim1 imDim2 imDim3] = size(orginImage);
labels = zeros(imDim1, imDim2);
[initMap] = collectSeedPoints(orginImage, labels);

figure;subplot(1,2,1);imagesc(orginImage);axis image
subplot(1,2,2);imagesc(initMap);axis image


%%
fpritnf('Go Go :Iterative Graphcut\n')
MaxItr = 10;               
K = 4;
INF = 1000000;
Gamma = 20;

colorTransform = makecform('srgb2lab');
labim = applycform(orginImage, colorTransform);
% labim = orginImage;

[hC vC] = SmoothnessTerm(labim);
sc = Gamma.*[0 1; 1 0];

certain_fg = initMap == 1;
certain_bg = initMap == -1;
% 
% surf([0 templateHW(2); 0 templateHW(2)]+templatePosition(1),...
%      [0 0;  templateHW(1)  templateHW(1)]+templatePosition(2), [0 0;0 0],...
%      'facecolor','texturemap','cdata', classTemplateFinal{templateSizeIndex}, ...
%      'facealpha','texture','alphadata',alpha,'edgecolor',edgecolorSetting{templateSizeIndex})

oL = initMap;

% how to label all the uncertain pixels?
if (sum(sum(abs(certain_fg))) == 0)
    oL(initMap==0) = 1;
else
    oL(initMap==0) = -1;
end

done_suc = false;

sE = 0;
dE = 0;
for itr=1:MaxItr,
    
    % GMM for foreground and background - global model
    logpFG = LocalColorModel(labim, K, oL==1); 
    logpBG = LocalColorModel(labim, K, oL==-1); 

    % force labeling of certain labeling
    logpBG(certain_fg) = INF;
    logpFG(certain_bg) = INF;
    
    dc = cat(3, logpBG, logpFG);

    gch = GraphCut('open', dc , sc, vC, hC);  
    gch = GraphCut('set', gch, int32(oL==1)); % initial guess - previous result
    [gch L] = GraphCut('expand', gch);
    L = (2*L-1); % convert {0,1} to {-1,1} labeling
    [gch se de] = GraphCut('energy', gch);
    
    gch = GraphCut('close', gch);

    itr
    if sE ==0;
        sE = se;
        dE = de;
    else
        sE = [sE se];
        dE = [dE de];
    end
    % stop if converged
    if sum(oL(:)~=L(:)) < .001*numel(L)
        done_suc = true;
        break;
    end
    oL = L;
end
if ~done_suc
    warning('GrabCut:GrabCut','Failed to converge after %d iterations', itr);
end

figure;imagesc(L)
% L = (L+1)/2;
currentImageGC = zeros(size(orginImage));
for i = 1:3
    orginImageTmp = orginImage(:,:,i);
    orginImageTmp(L==-1)=0;
%     currentImageGC(:,:,i) = (uint8(L).*uint8(orginImage(:,:,i)));
%     currentImageGC(:,:,i) = (double(L).*(orginImage(:,:,i)));
    currentImageGC(:,:,i) = orginImageTmp;
end

figure;plot(sE+dE);
figure;hsp1 = subplot(1,2,1);imagesc(orginImage);axis image
hsp2 = subplot(1,2,2);imagesc((currentImageGC));axis image
linkaxes([hsp1 hsp2])

%% output images and labels


colorFileDefPath = [outputPath 'DefaultLabelNames.txt'];
[className, classColor] = getLabelColorCode(colorFileDefPath); 
label = (L+1)/2+1;
[labelledImage] = labelNo2labelImg(label, classColor);
% figure;imagesc(labelledImage)


imwrite(orginImage, [outputPath 'Images\' imageName], 'png');
imwrite(labelledImage, [outputPath 'Labels\' imageName(1:(end-4)) '_L.png'], 'png');
