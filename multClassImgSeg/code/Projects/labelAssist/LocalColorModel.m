function logp = LocalColorModel(labim, K, select)
% estimate global color model
% labim - image patch in Lab space
% K - number of component in mixture model
% select - what pixels in patch belongs to region

imsiz = size(labim);

imR = labim(:,:,1);
imG = labim(:,:,2);
imB = labim(:,:,3);

fullSize = prod(imsiz(1:2));

vectIm = [reshape(imR, [1 fullSize]); reshape(imG, [1 fullSize]); reshape(imB, [1 fullSize])];

selected = find(select);
imR = imR(selected);
imG = imG(selected);
imB = imB(selected);
fg = [imR, imG, imB];
[idx mu] = kmeans(fg, K, 'emptyaction','singleton');

% mu - mean
% cvr - covariance
% wi - component weight

% compute data cost according to model
logp = zeros(prod(imsiz(1:2)),K);
for ki=1:K
    cvr = cov(fg(idx==ki,:));
    if rank(cvr) < imsiz(3)
        logp(:,ki) = inf;
        continue;
    end
    wi = sum(idx==ki)./size(fg,1);

    df = vectIm';
    df(:, 1) = df(:, 1) - mu(ki,1);
    df(:, 2) = df(:, 2) - mu(ki,2);
    df(:, 3) = df(:, 3) - mu(ki,3);

    logp(:,ki) = -log(wi)+.5*log(det(cvr)) + ...
        .5*sum( df*inv(cvr).*df, 2 );
end
logp = min(logp, [], 2);
logp = reshape(logp, imsiz(1:2));
