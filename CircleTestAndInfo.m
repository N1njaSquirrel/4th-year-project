function [ labelled, thickness, pointorder, partsinfo ] = CircleTestAndInfo( imgname )
%CIRCLETESTANDINFO Scrutinize regions for circularness and extract info.
%   In addition to CircleTest2 functionality, this function returns:
%   Overlap info. Which regions are part of other regions.
%   Top-to-bottom info. The regions ordered from the top of the image to
%   the bottom.


%% Reduce lines as necessary and find regions.

img = imread(imgname);
[lineimg, thickness] = DetectLines(img);
test = abs(lineimg-1);
test = test';
[boundaries,labelled] = bwboundaries(test,'noholes');
labelled = labelled';


%% Inspect each region and test for circularness.

kernels = [-1 0; -1 1; 0 1; 1 1; 1 0; 1 -1; 0 -1; -1 -1]; %Clockwise from 12

clist = [];
pointorder = [];
partsinfo = [];
for region=2:max(unique(labelled)) %0 is lines, 1 is background hence 2 start

    %Find centrepoint.
    [rows, cols] = find(labelled == region);
    c =[round(mean(cols)), round(mean(rows))];
    clist = [clist; c];
    
    % Calculate lengths and get info...
    lengths = []; %Just throw all calculated lengths in a bucket for now.
    partof = [];
    
    for kernel=1:8
        partof2 = [];
        n = 0;
        point = c + n*kernels(kernel,:);
        seenregionflag = 0;
        while point(1) >= 1 && point(2) >= 1 && point(1) <= size(labelled,2) && point(2) <= size(labelled,1)
            
            if labelled(point(2), point(1)) == region
                loc = point; 
            end
            if labelled(point(2), point(1)) == region
                seenregionflag = 1;
            end
            if labelled(point(2), point(1)) ~= region && labelled(point(2), point(1)) ~= 0 && seenregionflag == 1
                %Then it might be part of it
                partof2 = [partof2; region labelled(point(2), point(1))];
            end
            point = c + n*kernels(kernel,:);
            n = n+1;
        end
        length = abs(loc-c);
        plot(loc(1),loc(2),'Marker','p','Color',[.88 .48 0],'MarkerSize',20)
        length = sqrt(length(1).^2 + length(2).^2);
        lengths = [lengths; length];
        if eq(kernels(kernel,:), [-1 0]) %Then it's the topmost point; record it!
            pointorder = [pointorder; loc(2) region];
        end
        
        partof = [partof; unique(partof2, 'rows')];
    end
    
    % Check if region is part of other regions.
    tocheck = unique(partof, 'rows');
    for query = 1:size(tocheck,1)
        count = 0;
        for i=1:size(partof,1)
            if tocheck(query,:) == partof(i,:)
                count = count+1;
            end
        end
        if count == 8 %Then all points agree!
            partsinfo = [partsinfo; tocheck(query,:)];
        end
    end
    
    % Use lengths to decide legitimacy of region...
    score = var(lengths);
    if score >= 20 %TODO: What's a good threshold?
        %Get rid! Reset values to background.
        labelled(find(labelled == region)) = 1;
        %Remove info previously found:
        pointorder = pointorder(1:size(pointorder,1)-1,:);
        partsinfo = partsinfo(1:size(partsinfo,1)-1,:);
    end
    
    
end

return

%% Section here plots centrepoints; uncomment for debugging as necessary.

imshow(label2rgb(labelled, @jet, [.5 .5 .5]))

hold on
for i=1:size(clist,1)
    p = clist(i,:);
    plot(p(1),p(2),'Marker','x','Color',[.88 .48 0],'MarkerSize',20)
end


end

