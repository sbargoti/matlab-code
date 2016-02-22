function [patches,meanPatch ,ZCAWhite] = ZCAwhitening(patches, epsilon)

% [imDim1 imDim2 imDim3 numpatches] = size(patches);
[vecLength numpatches] = size(patches);

%% Subtract mean patch (hence zeroing the mean of the patches)
% % found two ways of centring the data
% 1: Centre by calculate the mean of the entire dataset, then subtract this
% value from every patches, therefore centre the entire dataset.
% standard approach but not applicable to vision data because each pixel
% should have the same statistic already (but andrew's group did anyway)

% patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,1)), sqrt(var(patches,[],1)+10));
% patches =  bsxfun(@minus, patches, mean(patches,1)); % this somehow makes the result worse


% % % % test to normalise correlatino to 1 (Lecun told me so)
% stdPatches = std(patches(:));
% patches = patches/stdPatches;
% ZCAWhite = ZCAWhite*stdPatches; % do i need this??

% 2: Centre by calculating the mean of each patches, and subtract this set
% of values (different for differret patch) from individual patches, for
% vision application this removes the intensity variation from the patches.
% contrast normalisation

meanPatch = mean(patches, 2);  
patches = bsxfun(@minus, patches, meanPatch);

%% Apply ZCA whitening
sigma = patches * patches' / numpatches;
[u, s, v] = svd(sigma);
ZCAWhite = u * diag(1 ./ sqrt(diag(s) + epsilon)) * u';
patches = ZCAWhite * patches;
% patches = ZCAWhite * bsxfun(@minus, patches, meanPatch);
% patches = bsxfun(@minus, patches, M) * P;


