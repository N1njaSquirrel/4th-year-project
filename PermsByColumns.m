function [ perms ] = PermsByColumns( i1, i2 )
%Very short function to calculate permutations between two inputs as I
%can't find anything appropriate already. Designed for startpoints and
%endpoints in identifying connectedness between regions.

perms = [];
for i = 1:numel(i1)
    for j = 1:numel(i2)
        perms = [perms; i1(i) i2(j)];
    end
end

end

