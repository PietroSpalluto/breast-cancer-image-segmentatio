function [Lrgb, Iobrcbr, I4] = markerControlledWatershed(I,dim)
%MARKERCONTROLLEDWATERSHED Marker controlled watershed
%
% ---INPUT---
% I                 - input image
% dim               - dimension of the structuring element
% ---OUTPUT---
% Lrgb              - labels matrix
% Iobrcbr           - opening-closing by reconstruction
% contrastPlot      - foreground markers, background markers, and segmented object boundaries 

%Gradient of the image
gmag = imgradient(I);
%figure
%imshow(gmag,[])
%title('Gradient Magnitude')

%The watershed of gradient causes an over-segmentation of the image
%L = watershed(gmag);
%Lrgb = label2rgb(L);
%figure
%imshow(Lrgb)
%title('Watershed Transform of Gradient Magnitude')

%Structuring element
se = strel('disk',dim);

%Opening: erosion followed by dilation
%Io = imopen(I,se);
%figure
%imshow(Io)
%title('Opening')

%Opening-by-reconstruction: erosion followed by a morphological reconstruction
Ie = imerode(I,se);
Iobr = imreconstruct(Ie,I);
%figure
%imshow(Iobr)
%title('Opening-by-Reconstruction')

%Opening-closing
%Ioc = imclose(Io,se);
%figure
%imshow(Ioc)
%title('Opening-Closing')

%Opening-closing by reconstruction. The complement is uded
Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
figure
imshow(Iobrcbr)
title('Opening-Closing by Reconstruction')

%The regional maxima is calculated to find foreground markers (regional min
%in the region of interest is dark)
fgm = imregionalmax(Iobrcbr);
%fgm = imregionalmin(Iobrcbr);
%figure
%imshow(fgm)
%title('Regional Maxima of Opening-Closing by Reconstruction')

%Superimposing the markers on the image
%I2 = labeloverlay(I,fgm);
%imshow(I2)

%The markers are shrinked
se2 = strel(ones(5,5));
fgm2 = imclose(fgm,se2);
fgm3 = imerode(fgm2,se2);

%The blob with less than a number of pixel are removed using bwareaopen
fgm4 = bwareaopen(fgm3,dim);
%I3 = labeloverlay(I,fgm4);
%figure
%imshow(I3)
%title('Modified Regional Maxima Superimposed on Original Image')
fgm3 = imerode(fgm2,se2);
%title('Regional Maxima Superimposed on Original Image')

%Tresholding to mark the background pixels
bw = imbinarize(Iobrcbr);
%figure
%imshow(bw)
%title('Thresholded Opening-Closing by Reconstruction')

%The background is thinned
D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
%figure
%imshow(bgm)
%title('Watershed Ridge Lines')

%The gradient magnitude image is modified so that its only regional minima 
%or maxima occur at foreground and background marker pixels
gmag2 = imimposemin(gmag, bgm | fgm4);

%Watershed is applied
L = watershed(gmag2);

%Foreground markers, background markers, and segmented object boundaries 
%are superimposed on the original image
labels = imdilate(L==0,ones(3,3)) + 2*bgm + 3*fgm4;
I4 = labeloverlay(I,labels);
figure
imshow(I4)
title('Markers and Object Boundaries Superimposed on Original Image')

%The label matrix is shown as a color image
Lrgb = label2rgb(L,'jet','w','shuffle');
%Lrgb = label2rgb(L,gray(255),'w','shuffle');
figure
imshow(Lrgb)
title('Colored Watershed Label Matrix')

%Transparency applied to the label matrix
%figure
%imshow(I)
%hold on
%himage = imshow(Lrgb);
%himage.AlphaData = 0.3;
%title('Colored Labels Superimposed Transparently on Original Image')

end