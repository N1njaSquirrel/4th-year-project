function [ new ] = RemoveContainingRegion( regions, partsinfo )

    %13/3 - Are these regions parts of another region (aside from background
    %1)? They will show up as connected to both - we need to disregard the
    %containing region. But ONLY the first, otherwise nested stuff will
    %break!
new = [];
for i=1:numel(regions)-1
    for j=2:numel(regions)
        %compare pairs of endpoints. If one is inside another,
        %disregard the 'another'
        removeflag = 0;
        for k=1:numel(partsinfo)/2
            if partsinfo(k,1) == i && partsinfo(k,2) == j
                %Then we want to remove j as i is inside it...
                removeflag = 1;
            end
        end
        if removeflag == 0
           new = [new; regions(j)];
        end
    end
end

end

