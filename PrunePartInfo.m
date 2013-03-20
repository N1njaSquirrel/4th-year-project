function [ newinfo ] = PrunePartInfo( partinfo )
%PRUNEPARTINFO Remove superfluous containment info.
%   Look down the chain of containment and remove everything unneeded. For
%   example if 6 is part of 5 and 5 is part of 1, we do not need to know
%   that 6 is part of 1.

toremove = [];

for rule=1:numel(partinfo)/2
    links = partinfo(rule,2);
    while numel(find(partinfo(:,1)==links(numel(links)))) > 0
        %While there is another rule to carry on from...
        test1 = find(partinfo(:,1)==links(numel(links)));
        test2 = numel(find(partinfo(:,1)==links(numel(links))));
        links = [links; partinfo(find(partinfo(:,1)==links(numel(links)),2),2)];
    end
    if numel(links) > 1
        %Then everything beyond it is irrelevant and should be flagged for
        %removal.
        for i=2:numel(links)
            toremove = [toremove; partinfo(rule,1), links(i)];
        end
    end
end

%Go over everything again and only add rules to the new list if they're not
%blacklisted with the toremove variable.
newinfo = [];

for rule=1:numel(partinfo)/2
    removeflag = 0;
    for rm=1:numel(toremove)/2
        if partinfo(rule,:)== toremove(rm,:)
            removeflag = 1;
        end
    end
    if removeflag == 0
        newinfo = [newinfo; partinfo(rule,:)];
    end

end

