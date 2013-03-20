function [ lines ] = DescribeImage( imgname )
%DESCRIBEIMAGE Interpret diagram.
%   Started 15/3. Uses function DistinguishFeatures2 to extract image info
%   and then interprets it. The idea is that if this works it'll be easier
%   to map to code.

%% Extract info
%Note: There's loads of image display commands in the functions used here.
[analyzedpic, pointorder, partsinfo, linkedregions] = DistinguishFeatures2(imgname);

%% Trying to describe by substituting letters for region numbers.

l = ['abcdefghijklmnopqrstuvwxyz'];

regioncount = numel(pointorder)/2;
linkcount = numel(linkedregions)/2;
lines = [];
%What leads to each region?
for region=1:regioncount
    line = [];
    connected = [];
    for link=1:linkcount
        if linkedregions(link,2) == pointorder(region,2)
            %Then linkedregions(link,2) leads to the region.
            connected = [connected; linkedregions(link,1)];
        end
    end
    line = int2str(pointorder(region,2));
    if numel(connected) > 0
        line = strcat(line, ' = ', int2str(connected(1)));
    end
    for i=2:numel(connected)
        line = strcat(line, ' + ', int2str(connected(i)));
    end
    lines = char(lines, line);
end

%What about stuff that is inside other regions? Subtract, right?
% Problem here! partsinfo contains all containing regions, however we're
% only actually concerned with the immediate containing region. So we need
% to remove the unneded info...
[ prunedinfo ] = PrunePartInfo( partsinfo );

for i=1:numel(prunedinfo)/2
    if prunedinfo(i,2) ~= 1 %We don't care about 'contained by background'
        line = int2str(prunedinfo(i,2));
        line = strcat(line, ' - ', int2str(prunedinfo(i,1)));
        lines = char(lines, line);
    end
end



end

