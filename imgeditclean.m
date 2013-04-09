%Originally by Andy Rae. Added size adjustment as an if statement; the 400 is kind of
%arbitrary though. Enlarging small pics leads to major errors. Don't do it!

function[imgreturn] = imgeditclean(img)

imgur = imread(img);
imgybr = rgb2ycbcr(imgur);
imgy = imgybr(:,:,1);

imgyx = size(imgy,1);
if imgyx >= 400
    scon = 400/imgyx;
    imgy = imresize(imgy, scon, 'bicubic');
end


imgreturn = imgy > 140;

%Stuff below is unused now, but imtool can be uncommented for debugging.

%imgreturn = imresize(imgreturn, [400, 400]);
%imgreturn = im2bw(imgreturn);
%imtool(imgreturn);
