    function viz(b_i, ims_train,labels_train, nvals)
        % here, b_i is a cell array of size nvals x nvars
        M = 5;
        for n=1:M
            [ly lx lz] = size(ims_train{n});
            subplot(3,M,n    ); miximshow(reshape(b_i{n}',ly,lx,nvals),nvals);
            subplot(3,M,n+  M); imshow(ims_train{n})
            subplot(3,M,n+2*M); miximshow(reshape(labels_train{n},ly,lx),nvals);
            n
        end
        xlabel('top: marginals  middle: input  bottom: labels')
        drawnow
    end