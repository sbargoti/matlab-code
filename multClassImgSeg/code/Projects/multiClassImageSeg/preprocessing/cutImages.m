% partition the image


% dataPath = 'C:\Work\dataSet\appletrial\shrimp\Run4\ladybug\img\row90\';
% dataPath = 'C:\work\data\raw\apple\ladybug5-7\row150\';
dataPath = 'C:\work\data\raw\2013-10-08-melbourne-apples\shrimp\e20-24-i-row\ladybug\e20_1\labelledData\';


outputPath = [dataPath 'sml\'];

subimDim2 = 1232;
subimDim1 = 808;
outputImage = zeros(subimDim1, subimDim2, 3);

fileList = dir([dataPath, '*png']);

imNo = 1;
subimNo = 1;
currentImage = imread([dataPath fileList(imNo).name]);
[imDim1 imDim2 imDim3] = size(currentImage);
figure;imagesc(currentImage);





for imNo = 1:length(fileList)
%     subimIdx = 1;
    currentImage = imread([dataPath fileList(imNo).name]);  
    imNo
    for i = 1:floor(imDim1/subimDim1)
        
        yInt = (i - 1)*subimDim1 + 1;
        yEnd = i*subimDim1;
        
        for j = 1:floor(imDim2/subimDim2)
%             subimIdx
            xInt = (j - 1)*subimDim2 + 1;
            xEnd = j*subimDim2;
            
            outputImage = currentImage(yInt:yEnd, xInt:xEnd, :);
            
            %         figure;imagesc(outputImage);
            imwrite(outputImage, [outputPath fileList(imNo).name(1:end-4) '_' sprintf('%i',i) sprintf('%i',j) '.png'], 'png');
%             subimIdx = subimIdx + 1;
            i
            j
        end      
    end
end
