function [ analyzed, thickness ] = DetectLines( img )
%DETECTLINES Use an appropriately sized template to find lines in an image.
%This will be used later on to categorize the found lines as either region
%edges or independent lines.
%   NOTES! The input here is as it was when it was loaded.

img = rgb2gray(img);
img = imcomplement(img);
thickness = FindLineThickness(img);
%template = ones(thickness); %HANG ON. Shoudn't this be gaussian!?
template = fspecial('gaussian',thickness);

filtered = imfilter(img, template);

%imshow(label2rgb(filtered, @jet, [.5 .5 .5])) %For debugging.

%threshold = 0.9*(thickness.^2); %0,9 may not be ideal! TODO: Investigate.
threshold = 255;

analyzed = filtered >= threshold;

