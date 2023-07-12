function [iou] = intersectionOverUnion(I1,I2)
%INTERSECTIONOVERUNION Intersection-over-Union of two binary images
%
% ---INPUT---
% I1, I2            - input images
% ---OUTPUT---
% iou               - Intersection-over-Union value between 0 and 1

% intersection
summ = I1 + I2;
summ = summ - 1;
intersection = logical(uint8(summ));

% union
intersection = double(intersection);
union = I1 + I2 - intersection;

% area of overlap and area of union
intSize = find(intersection == 1);
unionSize = find(union == 1);

iou = size(intSize)/size(unionSize);

end

