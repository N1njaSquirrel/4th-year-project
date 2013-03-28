function [ c ] = ClassifyRegions( datacount )
%CLASSIFYREGIONS Does what it says on the tin. Makes nice graphs and
%stuff. Input is training data size; make sure there's enough examples in
%the folder for the function to use!
%   Some of the syntax is slightly different because I'm pre allocating
%   matrix sizes here, apparently it's good practice.

%% Extract training data from pos and neg examples.

samples = floor(datacount/2);
featurespos = zeros(samples,3);
featuresneg = featurespos;
class = ones(samples*2,1);

for n = 0:samples-1
    name1 = strcat('TrainingPos/Pic', int2str(n), '.png');
    name2 = strcat('TrainingNeg/Pic', int2str(n), '.png');
    [f1, f2, f3] = ExtractFeatures1(name1);
    featurespos(n+1,:) = [f1 f2 f3];
    [f1, f2, f3] = ExtractFeatures1(name2);
    featuresneg(n+1,:) = [f1 f2 f3];
    class(n*2+2) = 0;
end

% 3d plotting for when 3 features are being used.
%figure
%scatter3(featurespos(:,1), featurespos(:,2),featurespos(:,3), 'rx')
%hold on
%scatter3(featuresneg(:,1), featuresneg(:,2),featuresneg(:,3), 'bx')

% 2d plots, for 2 features.
hold on
plot(featurespos(:,1), featurespos(:,2), 'rx')
plot(featuresneg(:,1), featuresneg(:,2), 'bx')

allf = [featurespos; featuresneg];

%% Everything below is broken. There wasn't much point looking into this
% without a decent amount of training data anyway.

[c,err,post,logl,str] = classify(allf(:,1:2),allf(:,1:2),class, 'linear');
K = str(1,2).const;
L = str(1,2).linear;
%Q = str(1,2).quadratic;

% This is only available in matlab R2013 :(
%c = ClassificationDiscriminant.fit(allf,class,...
 %   'DiscrimType','quadratic');


end

