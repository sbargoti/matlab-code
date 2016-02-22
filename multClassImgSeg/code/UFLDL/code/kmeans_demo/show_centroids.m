function image = show_centroids(centroids, H, W)
  if (nargin < 3)
    W = H;
  end
  N=size(centroids,2)/(H*W);
%   assert(N == 3 || N == 1);  % color and gray images
  assert(N == 4 || N == 3 || N == 1);  % RGBIR, color and gray images

  
  K=size(centroids,1);
  COLS=round(sqrt(K));
  ROWS=ceil(K / COLS);
  COUNT=COLS * ROWS;

  clf; hold on;
  image=ones(ROWS*(H+1), COLS*(W+1), N)*100;
  for i=1:size(centroids,1)
    r= floor((i-1) / COLS);
    c= mod(i-1, COLS);
    image((r*(H+1)+1):((r+1)*(H+1))-1,(c*(W+1)+1):((c+1)*(W+1))-1,:) = reshape(centroids(i,1:W*H*N),H,W,N);
  end

  mn=-1.5;
  mx=+1.5;
  image = (image - mn) / (mx - mn);
%   imshow(image);
if N<=3
      imshow(image);
elseif N>=3
      imshow(image(:,:,1:3));
end

  
  
%   patchsize = 8;
%   W_white = centroids;
% W_R = W_white(:,1+patchsize^2*0:patchsize^2);
% W_G = W_white(:,1+patchsize^2*1:patchsize^2*2);
% W_B = W_white(:,1+patchsize^2*2:patchsize^2*3);
% W_IR = W_white(:,1+patchsize^2*3:patchsize^2*4);
% 
% figure;
% W_RGB = [W_R W_G W_B];
% displayColorNetwork(W_RGB');
% 
% figure;
% W_IRGB = [W_IR W_G W_B];
% displayColorNetwork(W_IRGB');