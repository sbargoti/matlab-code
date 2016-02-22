function patches = sampleIMAGESRGBNIR(resizeF, patchsize, imageChannels, numpatches, imagePath, fileName)

%% Internal Paramters

% imagePath = 'D:\Work\dataSet\VOC2011\JPEGImages'; %(on my comp)
% imagePath = '/nethome/calvin/dataSet/VOC2011/JPEGImages';  % (on archipelago)


% imagePath = VOCopts.imgpath;
% imagePath = 'H:\Work\dataSet\juliaCreekImage\flight12_2009_18_7';
% imagePath = 'H:\Work\dataSet\googleEarth';

% fileName = dir([imagePath '/*.jpg'])
% numImages = length(fileName);

% entropy rejection

% if imageChannels == 3
%     entThreshold = 4;
% elseif imageChannels == 1
%     entThreshold = 0.5;
% end

entThreshold = 5;
% entThreshold = 6;


%% trainImages arrary

% initialise arrary

patches = zeros(patchsize*patchsize*imageChannels, numpatches);

numPatchesPerImage = numpatches/length(fileName);

tic
for i = 1:length(fileName)
      
    
    %     RGBImage = im2double(imread([imagePath fileName(i).name]));
    %     NIRImage = im2double(imread([imagePath strrep(fileName(i).name, 'rgb', 'nir')]));
    %
    %     currentImage = cat(3, RGBImage, NIRImage);
    %     currentImage = imresize(currentImage, resizeF, 'cubic');
    %     currentImage(currentImage>1) = 1;
    %     currentImage(currentImage<0) = 0;
    
    [currentImage] = loadRGBNIRImage(imagePath, fileName, resizeF);
    

    
    
    [dim1 dim2 dim3] = size(currentImage);
    
    % valid image range
    dim1Lim = dim1 - patchsize;
    dim2Lim = dim2 - patchsize;
    
    for j=1:numPatchesPerImage
        
        ent = 0;
        
        while ent < entThreshold
            coord1 = ceil(rand*dim1Lim);   % randomly start coordinate 1
            coord2 = ceil(rand*dim2Lim);   % randomly start coordinate 2
            coord1END = coord1 + patchsize -1;
            coord2END = coord2 + patchsize -1;
            
            imagePatch = currentImage(coord1:coord1END, ...
                coord2:coord2END,1:imageChannels);
            
            ent = entropy(imagePatch);
            
            if toc > 5 % if takes no patches reach the entropy condition load another image
                [currentImage] = loadRGBNIRImage(imagePath, fileName, resizeF);
                [dim1 dim2 dim3] = size(currentImage);
                disp('reload Image')
                % valid image range
                dim1Lim = dim1 - patchsize;
                dim2Lim = dim2 - patchsize;
                fprintf('%i/%i \n', k,numpatches);
                tic;
            end
        end
        
        k = (i-1)*numPatchesPerImage +j;
        patches(:,k) = imagePatch(:);
        
    end
    
    if toc>5
        %         fprintf('test confusion: %d/%d\n',i,length(gtids));
        fprintf('%i/%i \n', k,numpatches);
        drawnow;
        tic;
    end
    %     if rem(i,10) == 0
    %         fprintf('%i/%i \n', i,numTrainImage);
    %     end
end
disp('Done collecting training images from RGBNIR image data set (nirscene1)')


reshuffleOrder = randperm(size(patches,2));
patches = patches(:,reshuffleOrder);
% displayColorNetwork(patches(:, 1:100));
% display_network(patches(:, 1:100));
% save patchTest patches
end

% % % patchsize = 6;
%
% test = double(round(patches*255));
%
% testR = test(1+patchsize^2*0+1:patchsize^2*1,:);
% testG = test(1+patchsize^2*1+1:patchsize^2*2,:);
% testB = test(1+patchsize^2*2+1:patchsize^2*3,:);
% % testIR = test(patchsize^2*3+1:patchsize^2*4,:);
%
% % figure;hist(testIR(:))
% figure;hist(testR(:));title('R');
% figure;hist(testG(:));title('G');
% figure;hist(testB(:));title('B');
function [currentImage] = loadRGBNIRImage(imagePath, fileName, resizeF)

numImg = length(fileName);
iImg = ceil(rand*numImg);
RGBImage = im2double(imread([imagePath fileName(iImg).name]));
NIRImage = im2double(imread([imagePath strrep(fileName(iImg).name, 'rgb', 'nir')]));

% plot for fun
figure(1);
subplot(1,2,1);imagesc(RGBImage); axis image%RGB
subplot(1,2,2);imagesc(cat(3, NIRImage, RGBImage(:,:,2:3))); axis image %NIRGB

currentImage = cat(3, RGBImage, NIRImage);
currentImage = imresize(currentImage, resizeF, 'cubic');
currentImage(currentImage>1) = 1;
currentImage(currentImage<0) = 0;



end