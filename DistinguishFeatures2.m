function [ analyzedpic, pointorder, partsinfo, linkedregions ] = DistinguishFeatures2( imgname )
%DISTINGUISHFEATURES2
%   This function brings together several other functions (and does some
%   preprocessing via CircleTestAndInfo) to identify regions and
%   classify the lines as either bounding lines or individual lines. The
%   info returned can be interpreted as required.


%% Preprocessing

[ labelled, thickness, pointorder, partsinfo ] = CircleTestAndInfo( imgname );

%% Distinguish between lines and edges.

classes = zeros(size(labelled));
lowthresh = 2; %This added to get rid of teeny (single) bits of noise. DO NOT SET TOO HIGH!
threshold = thickness;

%Scan horizontally.
for row = 1:size(labelled,1)
    lastregion = 0;
    count = 0;
    for pixel = 2:size(labelled,2)
        if labelled(row,pixel) ~= 0 && count == 0
            %Does this ever actually happen?
            currentregion = labelled(row,pixel);
            if currentregion ~= lastregion
                lastregion = currentregion;
            end
        end
        if labelled(row,pixel) == 0
            % add to count.
            count = count+1;
        end
        if labelled(row,pixel) ~= 0 && count > 0 && count < threshold
            % Assign previous pixels their values if below threshold
            if lastregion == labelled(row,pixel) %Then it's a line!
                val = 1;
            end
            if lastregion ~= labelled(row,pixel) %Then it's an edge!
                val = 2;
            end
            if count >= lowthresh
                for i=1:count %Scan back
                    classes(row,pixel-i) = val;
                end
            end
            count = 0;
            lastregion = currentregion;
        end
        if labelled(row,pixel) ~= 0 && count > 0 && count > threshold
            count = 0;
            lastregion = currentregion;
        end
    end
end

classes = classes(:,:,1)';
labelled = labelled';
%Scan vertically.
for row = 1:size(labelled,1)
    lastregion = 0;
    count = 0;
    for pixel = 2:size(labelled,2)
        if labelled(row,pixel) ~= 0 && count == 0
            %Does this ever actually happen?
            currentregion = labelled(row,pixel);
            if currentregion ~= lastregion
                lastregion = currentregion;
            end
        end
        if labelled(row,pixel) == 0
            % add to count.
            count = count+1;
        end
        if labelled(row,pixel) ~= 0 && count > 0 && count < threshold %TODO: Incorporate threshold!
            % Assign previous pixels their values if below threshold
            if lastregion == labelled(row,pixel) %Then it's a line!
                val = 1;
            end
            if lastregion ~= labelled(row,pixel) %Then it's an edge!
                val = 2;
            end
            if count >= lowthresh
                for i=1:count %Scan back
                    classes(row,pixel-i) = val;
                end
            end
            count = 0;
            lastregion = currentregion;
        end
        if labelled(row,pixel) ~= 0 && count > 0 && count > threshold %TODO: Incorporate threshold!
            count = 0;
            lastregion = currentregion;
        end
    end
end

analyzedpic=classes(:,:,1)';
%imshow(label2rgb(analyzedpic(:,:,1), @jet, [.5 .5 .5]))

%% Analyze individual lines and link where necessary.

linesimg = zeros(size(analyzedpic));
linesimg(analyzedpic==1)=1;
[boundaries,linespic] = bwboundaries(linesimg,'noholes');

%Take lines at face value to begin with here.
lines = [];

for line = 1:size(boundaries,1)
    current = boundaries{line};
    miny = min(current(:,1));
    maxy = max(current(:,1));
    start = current(current(:,1)==miny,:);
    finish = current(current(:,1)==maxy,:);
    if size(start,1) > 1
        start = min(start);
    end
    if size(finish,1) > 1
        finish = min(finish);
    end
    lines = [lines; start, finish];
end

% Show initial lines, for debugging.
%imshow(label2rgb(analyzedpic(:,:,1), @jet, [.5 .5 .5]))
%hold on
%for i=1:size(lines,1)
%    p = lines(i,1:2);
%    q = lines(i,3:4);
%    plot(p(2),p(1),'Marker','x','Color',[.88 .48 0],'MarkerSize',20,'LineWidth', 2)
%    plot(q(2),q(1),'Marker','o','Color',[.88 .48 0],'MarkerSize',20,'LineWidth', 2)
%end

%Link up close lines, to do this we need to compare the end of one line
%to the start of all the others. NEW 12/3/13
%NEW IN DISTINGUISHFEATURES2: All the junk in DF1 didn't work. New
%strategy: Identify link points and then connect them all in one go.
links = [];
lines = sortrows(lines,2);
for i = 1:size(lines,1)
    lineend = lines(i,3:4);
    for j = 1:size(lines,1)
        if i ~= j
            linestart = lines(j,1:2);
            dist = lineend-linestart;
            dist = sqrt(dist(1).^2+dist(2).^2);
            if dist < 20 %TODO: How to choose threshold?
                links = [links; i, j];
            end
        end
    end
end

%Link up the links!
editedlinks = [];
covered = [];
for i = 1:size(links,1)
    if isempty(covered==i)
        p1 = links(i,1);
        p2 = links(i,2);
        while find(links(:,1)==p2)
            newlink = find(links(:,1)==p2);
            p2 = links(newlink,2);
            covered = [covered; newlink];
        end
        editedlinks = [editedlinks; p1 p2];
    end
end

%Convert edited links into new lines.
editedlines = [];
for i=1:size(editedlinks,1)
    editedlines = [editedlines; lines(editedlinks(i,1),1:2), lines(editedlinks(i,2),3:4)];
end

%Add back lines which are not connected to anything.
for i=1:size(lines,1)
    if isempty(find(links==i))
        editedlines = [editedlines;lines(i,:)];
    end
end

%Editedlines needs reversing; this is a quick fix, maybe sort it properly
%later.
el = [];
for r=1:size(editedlines,1)
    el = [el; editedlines(r,2) editedlines(r,1) editedlines(r,4) editedlines(r,3)];
end
editedlines = el;

%NEW FOR 12/3/13 - Finding connected regions with the lines!
%imshow(label2rgb(labelled(:,:,1), @jet, [.5 .5 .5]))
linkedregions = [];
t = round(thickness*3);
for line=1:size(editedlines,1)
    startp = editedlines(line,1:2);
    endp = editedlines(line,3:4);
    k = labelled(startp(1)-t:startp(1)+t, startp(2)-t:startp(2)+t);
    l = labelled(endp(1)-t:endp(1)+t, endp(2)-t:endp(2)+t);
    startregions = unique(k);
    startregions = startregions(2:numel(startregions)); %Disregard 0
    endregions = unique(l);
    endregions = endregions(2:numel(endregions)); %Disregard 0
    %New function below. Modularity, yay! Info in that function.
    endregions = RemoveContainingRegion(endregions, partsinfo);
    startregions = RemoveContainingRegion(startregions, partsinfo);
    linkedregions = [linkedregions; PermsByColumns(startregions, endregions)];

end

return %Cut out image displaying during debugging if you like.

%% Clean up and display result.
imshow(label2rgb(analyzedpic(:,:,1), @jet, [.5 .5 .5]))

hold on
for i=1:size(editedlines,1)
    p = editedlines(i,1:2);
    q = editedlines(i,3:4);
    plot(p(1),p(2),'Marker','x','Color',[.88 .48 0],'MarkerSize',20,'LineWidth', 2)
    plot(q(1),q(2),'Marker','o','Color',[.88 .48 0],'MarkerSize',20,'LineWidth', 2)
end

end

