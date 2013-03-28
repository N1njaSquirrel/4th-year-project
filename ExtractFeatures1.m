function [ f1 f2 f3] = ExtractFeatures1( imgname )
%EXTRACTFEATURES1 Gets features from image of single region.
%   Features are variance of + and X lengths. This is adapted from
%   CircleTestAndInfo. However, it has been reduced significantly because
%   we don't need most of the info as the training data is only of
%   one region. This is probably a good function to look at when learning
%   how the circularness test works.
%   NOTE: Uncomment the drawing things to see what's going on in all its
%   visualized glory.

%% Reduce lines as necessary and find regions.

img = imread(imgname);
[lineimg, thickness] = DetectLines(img);
test = abs(lineimg-1);
test = test'; %Turned sideways for bwboundaries to get point order naturally.
[boundaries,labelled] = bwboundaries(test,'noholes');
labelled = labelled'; %Turn it back!

%imshow(label2rgb(labelled, @jet, [.5 .5 .5]))
%hold on

%% Inspect each region and test for circularness.

kernels = [-1 0; -1 1; 0 1; 1 1; 1 0; 1 -1; 0 -1; -1 -1]; %Clockwise from 12

%Find centrepoint.
[rows, cols] = find(labelled == 2);
c =[round(mean(cols)), round(mean(rows))];

% Calculate lengths from centrepoint at each of the 8 points...
    lengths1 = [];
    lengths2 = [];
    
for kernel=1:8
    n = 0;
    point = c + n*kernels(kernel,:);
    while point(1) >= 1 && point(2) >= 1 && point(1) <= size(labelled,2) && point(2) <= size(labelled,1)
        % While we're still inside the image, see if we can see the region. 
        if labelled(point(2), point(1)) == 2
            loc = point; 
        end
        point = c + n*kernels(kernel,:);
        n = n+1;
    end
    
    length = abs(loc-c);
    length = sqrt(length(1).^2 + length(2).^2);
    if mod(kernel,2) == 1
        lengths1 = [lengths1; length];
        %plot(loc(1),loc(2),'Marker','x','Color',[.88 .48 0],'MarkerSize',20)
    end
    if mod(kernel,2) == 0
        lengths2 = [lengths2; length];
        %plot(loc(1),loc(2),'Marker','o','Color',[.88 .48 0],'MarkerSize',20)
    end
end

%Turn sets of lengths into features by finding the variance.
%f1 is +, f2 is X and f3 is the variance of all 8 lengths. We could get
%other features by messing with different permutations of the lengths.

f1 = var(lengths1);
f2 = var(lengths2);
f3 = var([lengths1;lengths2]);

end

