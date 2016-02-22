% mainMakeMovieFrame

%% Initialisation
currentPath = cd;
rootPath = currentPath(1:(strfind(currentPath,'work')+4)); % to work/

dataPath = ['C:\work\data\raw\2013-12-04-mareeba-lychees\lychees-1\ladybug\13\']; %train data path
classifierOutputPath = ['C:\work\data\processed\2013-12-04-mareeba-lychees\lychees-1\ladybug\13\'];
outputPath = ['C:\work\data\processed\2013-12-04-mareeba-lychees\lychees-1\ladybug\13\movieFrames\'];

%% 0 Initialisation

imgFolderName = dataPath;

imgList = dir([imgFolderName '*.png']);
classImgList = dir([classifierOutputPath '*.png']);

%%

for imNo = 1:length(imgList)

fprintf('image:%i/%i\n',imNo, length(imgList))

orginImage = im2double(imread([[imgFolderName imgList(imNo).name]]));
classImage = im2double(imread([[classifierOutputPath classImgList(imNo).name]]));

appleSeg = classImage>0.95;

% % clean up noise
% se = strel('disk',5);
% appleSeg = imerode(appleSeg,se);
% se = strel('disk',5);
% appleSeg = imdilate(appleSeg,se);

outputImage = repmat(appleSeg, [1 1 3]);

imwrite(cat(2,orginImage, outputImage), [outputPath imgList(imNo).name(1:end-4) '_Seg.png'], 'png');


end




