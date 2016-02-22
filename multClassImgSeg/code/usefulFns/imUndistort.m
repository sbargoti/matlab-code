function [imOut] = imUndistort(imIn, undistortMatrix)

imOut = zeros(size(imIn));
    
    [imDim1, imDim2, imDim3] = size(imIn);    
    
    yMap = squeeze(undistortMatrix(:,:,1));
    xMap = squeeze(undistortMatrix(:,:,2));    
    
    for iChannel = 1:imDim3
        for newPixelY = 1:imDim1
            for newPixelX = 1:imDim2
                oldPixelY = round(yMap(newPixelY, newPixelX));
                oldPixelX = round(xMap(newPixelY, newPixelX));
                if oldPixelX > 1 && oldPixelX < (imDim2+1) && oldPixelY > 1 && oldPixelY < (imDim1+1)
                    imOut(newPixelY,newPixelX,iChannel) = imIn(oldPixelY, oldPixelX,iChannel);
                end
            end
        end
    end





end