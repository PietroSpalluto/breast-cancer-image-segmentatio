function [img, V_tot, contrastPlot] = contrastStretching(img, r1, s1, r2, s2)
%CONTRASTSTRETCHING Contrast stretching for RGB images
%
% ---INPUT---
% img               - input image
% r1, r2            - values of input intensity level
% s1, s2            - values of output intensity level
% ---OUTPUT---
% img               - enhanced image
% V_tot             - enhanced V level image
% contrastPlot      - plot of the new contrast function

% grayscale to RGB conversion
if(size(img, 3) == 1)
    img(:,:,2)=img(:,:,1);
    img(:,:,3)=img(:,:,1);
end

%figure
%imshow(img);
%title("Original");

% RGB to HSV conversion
img=rgb2hsv(img);

% V level
V=img(:,:,3)*255;

% contrast stretching of the V level using the two points
t1=V>r1;
V1=(s1/r1)*V;
V1(t1==1)=0;

t1=V<=r1;
t2=V>r2;
V2=((s2-s1)/(r2-r1))*(V-r1)+s1;
V2(t1==1)=0;
V2(t2==1)=0;

t2=V<=r2;
V3=((255-s2)/(255-r2))*(V-255)+255;
V3(t2==1)=0;

V_tot=V1+V2+V3;

% contrast function
r=[0:255]; %original array

t1=r>r1;
f1=(s1/r1)*r;
f1(t1==1)=0;
t1=r<=r1;
t2=r>r2;
f2=((s2-s1)/(r2-r1))*(r-r1)+s1;
f2(t1==1)=0;
f2(t2==1)=0;
t2=r<=r2;
f3=((255-s2)/(255-r2))*(r-255)+255;
f3(t2==1)=0;
f=f1+f2+f3;

figure
contrastPlot = plot(f);
xlabel('Input intensity level') 
ylabel('Output intensity level') 
title("Contrast stretching plot");

% conversion from HSV to RGB
img(:,:,3)=mat2gray(V-V_tot);
img=hsv2rgb(img);
img=uint8(img*255);

figure;
imshow(img);
title("Contrast stretching result");

img = uint8(img);
V_tot = uint8(V_tot);

end

