function [patches locations patchLabels]...
    = sampleMultiScalePatchLabelRGBDValidCheck(IMAGES, imgLabels, resizeF, patchsize, validImDim)
% sampleIMAGES
% Returns 10000 patches for training

% Initialize patches with zeros.  Your code will fill in this matrix--one
% column per patch, 10000 columns.
[dim1 dim2 dim3 numImage] = size(IMAGES);

nChannel = dim3;
numDataPClass = 200000;
% nClasses = 20; %voc has 20 classes (excluding void)
% numData = (nClasses + 1) * numDataPClass;
% nClasses = 32; %camVid has 32 classes (including void)
% nClasses = 11; %camVid subset has 11 classes (excluding void)
nClasses = length(unique(imgLabels));

numPatches = (nClasses) * numDataPClass;
nScale = length(resizeF);
patches = zeros(patchsize,patchsize,nChannel,numPatches,nScale);
locations = zeros(2, numPatches);
patchLabels =  zeros(1,numPatches);

[smallestResizeF smallestResizeFidx] = min(resizeF);

% smlestDim1 = dim1*smallestResizeF;
% smlestDim2 = dim2*smallestResizeF;

%%
fprintf('Process IMAGES into different scales\n');
for iScale = 1:nScale
    currentScale = resizeF(iScale);
    
    if currentScale == 1
        currentImageSet{iScale} = IMAGES;
    else
        imagesTemp = zeros(ceil(dim1*currentScale), ceil(dim2*currentScale), dim3, numImage);
        for iImage = 1:numImage
            %             imagesTemp(:,:,:,iImage) = imresize(IMAGES(:,:,:,iImage),currentScale,'nearest');
            tempImg = uint8(IMAGES(:,:,:,iImage)*255);
            imagesTemp(:,:,:,iImage) = double(imresize(tempImg,currentScale))/255; % prevent going out of [0 1] range
            
        end
        currentImageSet{iScale} = imagesTemp;
    end
end


fprintf('Start sampling\n');
tic

% 1: for balanced sample accross classes
% 2: for sample randomly accross dataset, number of sample per class is closer to global class distribution
sampleMethod = 1;

if sampleMethod == 1 % balanced sample accross classes
    for iClass = 1:nClasses
        desiredClass = iClass;
        %         iClass
        for iPClass = 1:numDataPClass
            % for i=1:numPatches
            i = (iClass-1)*numDataPClass + iPClass;
            correctClassFlag = 0;
            
            while correctClassFlag == 0
                % valid image range
                
                

                imageNo = ceil(rand*numImage);% randomly select image
                dim1 = validImDim(1,imageNo);
                dim2 = validImDim(2,imageNo);
                smlestDim1 = dim1*smallestResizeF;
                smlestDim2 = dim2*smallestResizeF;

                coord1 = ceil(rand*dim1);   % randomly start coordinate 1
                coord2 = ceil(rand*dim2);                
                
                
                patchLabelstmp = imgLabels(coord1,coord2,imageNo);
                
                dim1check = ((round(coord1*smallestResizeF) - ceil(patchsize/2))>0) && ...
                    ((round(coord1*smallestResizeF) + patchsize/2)<smlestDim1);
                dim2check = ((round(coord2*smallestResizeF) - ceil(patchsize/2))>0) && ...
                    ((round(coord2*smallestResizeF) + patchsize/2)<smlestDim2);
                
                
                if (patchLabelstmp == desiredClass)&& dim1check && dim2check
                    correctClassFlag = 1;
                    locations(:,i) = [coord1/dim1 coord2/dim2];
                    patchLabels(i) = imgLabels(coord1,coord2,imageNo);
                end
                
                if toc > 5
                    %             fprintf('%i/%i\n',i,numPatches);
                    fprintf('Class: %i Patch: %i/%i\n',iClass,iPClass, numDataPClass);
                    fprintf('Coord1: %4.4f Coord2: %4.4f ImageNo: %i\n',coord1/dim1,coord2/dim2,imageNo);                    
                    tic;
                end
                
                
            end
            
            for iScale = 1:nScale
                
                currentScale = resizeF(iScale);
                
                coord1INT = round(coord1*currentScale) - ceil(patchsize/2);
                coord2INT = round(coord2*currentScale) - ceil(patchsize/2);
                
                coord1END = coord1INT + patchsize -1;
                coord2END = coord2INT + patchsize -1;
                
                imagePatch = currentImageSet{iScale}(coord1INT:coord1END, ...
                    coord2INT:coord2END, ...
                    :,imageNo);
                
                %                 figure;imagesc(currentImageSet{iScale}(:,:,:,imageNo));hold on
                %                 plot(coord2*currentScale,coord1*currentScale,'ro');
                %                 plot(coord2INT,coord1INT,'rx');
                %                 plot(coord2END,coord1END,'rx');hold off
                
                patches(:,:,:,i,iScale) = imagePatch;
                
                
            end
            
            
        end
    end
    %     for iClass = 1:nClasses
    %         desiredClass = iClass;
    %         for iPClass = 1:numDataPClass
    %             % for i=1:numPatches
    %             i = (iClass-1)*numDataPClass + iPClass;
    %             correctClassFlag = 0;
    %
    %             while correctClassFlag == 0
    %                 % valid image range
    %                 %     dim1Lim = dim1 - patchsize;
    %                 %     dim2Lim = dim2 - patchsize;
    %                 dim1Lim = smlestDim1 - patchsize;
    %                 dim2Lim = smlestDim1 - patchsize;
    %
    %                 coord1 = ceil(rand*dim1Lim);   % randomly start coordinate 1
    %                 coord2 = ceil(rand*dim2Lim);   % randomly start coordinate 2
    %                 coord1END = coord1 + patchsize -1;
    %                 coord2END = coord2 + patchsize -1;
    %                 coord1MID = ceil((coord1+coord1END)/2);
    %                 coord2MID = ceil((coord2+coord2END)/2);
    %
    %                 imageNo = ceil(rand*numImage);% randomly select image
    %
    %                 coord1MIDtmp = ceil((coord1+coord1END)/2)/smallestResizeF;
    %                 coord2MIDtmp = ceil((coord2+coord2END)/2)/smallestResizeF;
    %                 patchLabelstmp = imgLabels(coord1MIDtmp,coord2MIDtmp,imageNo);
    %
    %                 if patchLabelstmp == desiredClass
    %                     correctClassFlag = 1;
    %                 end
    %             end
    %
    %             for iScale = 1:nScale
    %
    %                 currentScale = resizeF(iScale);
    %                 scaleDiff = currentScale/smallestResizeF;
    %
    %                 coord1 = round(coord1MID*scaleDiff) - ceil(patchsize/2);
    %                 coord2 = round(coord2MID*scaleDiff) - ceil(patchsize/2);
    %                 coord1END = coord1 + patchsize -1;
    %                 coord2END = coord2 + patchsize -1;
    %
    %                 imagePatch = currentImageSet{iScale}(coord1:coord1END, ...
    %                     coord2:coord2END, ...
    %                     :,imageNo);
    %
    %
    %                 patches(:,:,:,i,iScale) = imagePatch;
    %
    %                 if currentScale == 1
    %                     coord1MIDtmp = ceil((coord1+coord1END)/2);
    %                     coord2MIDtmp = ceil((coord2+coord2END)/2);
    %                     locations(:,i) = [coord1MIDtmp/dim1 coord2MIDtmp/dim2];
    %                     patchLabels(i) = imgLabels(coord1MIDtmp,coord2MIDtmp,imageNo);
    %                 end
    %
    %             end
    %
    %             if toc > 5
    %                 %             fprintf('%i/%i\n',i,numPatches);
    %                 fprintf('Class: %i Patch: %i/%i\n',iClass,iPClass, numDataPClass);
    %
    %                 tic;
    %             end
    %             % end
    %         end
    %     end
elseif sampleMethod == 2 % sample randomly accross dataset
    
    for i = 1:numPatches
        
        correctClassFlag = 0;
        
        while correctClassFlag == 0            
            
                imageNo = ceil(rand*numImage);% randomly select image
                dim1 = validImDim(1,imageNo);
                dim2 = validImDim(2,imageNo);
                smlestDim1 = dim1*smallestResizeF;
                smlestDim2 = dim2*smallestResizeF;
            
            coord1 = ceil(rand*dim1);   % randomly start coordinate 1
            coord2 = ceil(rand*dim2);
            
            patchLabelstmp = imgLabels(coord1,coord2,imageNo);
            
            dim1check = ((round(coord1*smallestResizeF) - ceil(patchsize/2))>0) && ...
                ((round(coord1*smallestResizeF) + patchsize/2)<smlestDim1);
            dim2check = ((round(coord2*smallestResizeF) - ceil(patchsize/2))>0) && ...
                ((round(coord2*smallestResizeF) + patchsize/2)<smlestDim2);
            
            
            if (patchLabelstmp < 12 )&& dim1check && dim2check % class 12 is void class
                correctClassFlag = 1;
                locations(:,i) = [coord1/dim1 coord2/dim2];
                patchLabels(i) = imgLabels(coord1,coord2,imageNo);
            end
            
            if toc > 5
                %             fprintf('%i/%i\n',i,numPatches);
                fprintf('numPatches: %i/%i \n',i,numPatches);
                
                tic;
            end
            
        end
        
        for iScale = 1:nScale
            
            currentScale = resizeF(iScale);
            
            coord1INT = round(coord1*currentScale) - ceil(patchsize/2);
            coord2INT = round(coord2*currentScale) - ceil(patchsize/2);
            
            coord1END = coord1INT + patchsize -1;
            coord2END = coord2INT + patchsize -1;
            
            imagePatch = currentImageSet{iScale}(coord1INT:coord1END, ...
                coord2INT:coord2END, ...
                :,imageNo);
            
            %                 figure;imagesc(currentImageSet{iScale}(:,:,:,imageNo));hold on
            %                 plot(coord2*currentScale,coord1*currentScale,'ro');
            %                 plot(coord2INT,coord1INT,'rx');
            %                 plot(coord2END,coord1END,'rx');hold off
            
            patches(:,:,:,i,iScale) = imagePatch;
            
            
        end
        

    end
    %     for i = 1:numPatches
    %
    %         correctClassFlag = 0;
    %
    %         while correctClassFlag == 0
    %             % valid image range
    %             %     dim1Lim = dim1 - patchsize;
    %             %     dim2Lim = dim2 - patchsize;
    %             dim1Lim = smlestDim1 - patchsize;
    %             dim2Lim = smlestDim1 - patchsize;
    %
    %             coord1 = ceil(rand*dim1Lim);   % randomly start coordinate 1
    %             coord2 = ceil(rand*dim2Lim);   % randomly start coordinate 2
    %             coord1END = coord1 + patchsize -1;
    %             coord2END = coord2 + patchsize -1;
    %             coord1MID = ceil((coord1+coord1END)/2);
    %             coord2MID = ceil((coord2+coord2END)/2);
    %
    %             imageNo = ceil(rand*numImage);% randomly select image
    %
    %             coord1MIDtmp = ceil((coord1+coord1END)/2)/smallestResizeF;
    %             coord2MIDtmp = ceil((coord2+coord2END)/2)/smallestResizeF;
    %             patchLabelstmp = imgLabels(coord1MIDtmp,coord2MIDtmp,imageNo);
    %
    %             if patchLabelstmp < 12 % class 12 is void class
    %                 correctClassFlag = 1;
    %             end
    %         end
    %
    %         for iScale = 1:nScale
    %
    %             currentScale = resizeF(iScale);
    %             scaleDiff = currentScale/smallestResizeF;
    %
    %             coord1 = round(coord1MID*scaleDiff) - ceil(patchsize/2);
    %             coord2 = round(coord2MID*scaleDiff) - ceil(patchsize/2);
    %             coord1END = coord1 + patchsize -1;
    %             coord2END = coord2 + patchsize -1;
    %
    %             imagePatch = currentImageSet{iScale}(coord1:coord1END, ...
    %                 coord2:coord2END, ...
    %                 :,imageNo);
    %
    %
    %             patches(:,:,:,i,iScale) = imagePatch;
    %
    %             if currentScale == 1
    %                 coord1MIDtmp = ceil((coord1+coord1END)/2);
    %                 coord2MIDtmp = ceil((coord2+coord2END)/2);
    %                 locations(:,i) = [coord1MIDtmp/dim1 coord2MIDtmp/dim2];
    %                 patchLabels(i) = imgLabels(coord1MIDtmp,coord2MIDtmp,imageNo);
    %             end
    %
    %         end
    %
    %         if toc > 5
    %             %             fprintf('%i/%i\n',i,numPatches);
    %             fprintf('numPatches: %i/%i \n',i,numPatches);
    %
    %             tic;
    %         end
    %         % end
    %     end
    
end
%% ---------------------------------------------------------------
% % see the number in each class
% for iLabel = 1:32
% test(iLabel) = sum(trainPatchLabels==iLabel);
% end
% figure;plot(test)

end



