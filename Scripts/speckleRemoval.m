function [fimg, img] = speckleRemoval(img, M, alpha, h)
%SPECKLEREMOVAL Speckle removal using Bayesian Filter
%   parameters:
%   M: search area size (2*M + 1)^2
%   alpha: patch size (2*alpha + 1)^2
%   h: smoothing parameter [0-infinite].


offset = 100; % to avoid Nan in Pearson divergence computation
% According to the gain used by your US device this offset can be adjusted.

[dimxy dimt] = size(size(img));
if (dimt > 2)
    img = rgb2gray(img);
end

% Intensity normalization
imgd = double(img);
mini = (min(imgd(:)));
imgd = (imgd - mini);
maxi = max(imgd(:));
imgd = (imgd / maxi) * 255;
imgd = imgd + offset; % add offset to enable the pearson divergence computation (i.e. avoid division by zero).
s = size(imgd);

% Padding
imgd = padarray(imgd,[alpha alpha],'symmetric');
fimgd=bnlm2D(imgd,M,alpha,h);
fimgd = fimgd - offset;
imgd = imgd - offset;
imgd = imgd(alpha+1: s(1)+alpha, alpha+1: s(2)+alpha);
fimgd = fimgd(alpha+1: s(1)+alpha, alpha+1: s(2)+alpha);

% Display
minds = min(imgd(:));
maxds = max(imgd(:));
figure;
imagesc(imgd,[minds maxds]);
title('Original')
colormap(gray);
colorbar;
figure;
colormap(gray);
imagesc(fimgd,[minds maxds]);
title('Denoised by Bayesian NLM')
colorbar;
figure;
colormap(gray);
speckle = abs(imgd(:,:) - fimgd(:,:));
imagesc(speckle);
title('Residual image')
colorbar;

fimg = uint8(fimgd);
img = uint8(imgd);
%speckle = uint8(speckle);

end

