%HW5

% Note. You can use the code readIlastikFile.m provided in the repository to read the output from
% ilastik into MATLAB.

%% Problem 1. Starting with Ilastik

% Part 1. Use Ilastik to perform a segmentation of the image stemcells.tif
% in this folder. Be conservative about what you call background - i.e.
% don't mark something as background unless you are sure it is background.
% Output your mask into your repository. What is the main problem with your segmentation?  

% If we use the simple segmentation without spending much effort on defining the background, 
% many cells in the picture will connect with each other and cannot be separated completely.
% In the left bottom of the picture, there is a large overlapping area.

% Part 2. Read you segmentation mask from Part 1 into MATLAB and use
% whatever methods you can to try to improve it. 
seg=h5read('stemcells_Simple Segmentation.h5','/exported_data');
seg=squeeze(seg);
I=seg;
img = imclose(I, strel('disk', 5));
BW = im2bw(img, graythresh(img));
CC = bwconncomp(BW);
stats = regionprops(CC, 'Area');
area = [stats.Area];
fused = area > mean(area) + std(area);
fused1 = CC.PixelIdxList(fused);
fused1 = cat(1, fused1{:});
Mask = false(size(img));
Mask(fused1) = 1;

img=seg==2;
img1=im2double(img);
imgbright=uint16((2^16-1)*(img1/max(max(img1))));
imgbright1=im2bw(imgbright,0.5);
imshow(imgbright1,[])
dist=bwdist(~imgbright1);
dist=-dist;
dist(~imgbright1)=-Inf;
L2=watershed(dist);
L2(~imgbright1)=0;
rgb=label2rgb(L2,'jet',[.5 .5 .5]);
imshow(rgb);

imgf=L2>1|(imgbright1-Mask);
imshow(imgf,[]);

%Although some overplaping on the left side was separated after watershed,
%the result is not satisfactory since the overlaping region is too large.
%Left top corner was also accidentally took as 'cells' by matlab. Extra
%effort need to be taken in the initial segmentation in order to improve the picture.

% Part 3. Redo part 1 but now be more aggresive in defining the background.
% Try your best to use ilastik to separate cells that are touching. Output
% the resulting mask into the repository. What is the problem now?

%Although the condensed part of the cell is separated, some other cells that
%was originally dim was now recognized as 'background' and
%disappeared.There are also some cells that are still connected with each
%other and cannot be separated (shown in yellow), unless we sacrifices more
%cells.

% Part 4. Read your mask from Part 3 into MATLAB and try to improve
% it as best you can.
seg=h5read('Segmentation.h5','/exported_data');
seg=squeeze(seg);
I=seg;
img = imopen(I, strel('disk', 5));
BW = im2bw(img, graythresh(img));
CC = bwconncomp(BW);
stats = regionprops(CC, 'Area');
area = [stats.Area];
fused = area > mean(area) + std(area);
fused1 = CC.PixelIdxList(fused);
fused1 = cat(1, fused1{:});
Mask = false(size(img));
Mask(fused1) = 1;
%Prepare basin for watershed
s = round(1.2*sqrt(mean(area))/pi);
nucmin = imerode(Mask, strel('disk',s));
outside = ~imdilate(Mask, strel('disk',1));
basin = imcomplement(bwdist(outside));
basin = imimposemin(basin, nucmin | outside);
L = watershed(basin);
rgb = label2rgb(L,'jet',[.5 .5 .5]);
imshow(rgb);
%combining the pictures.
imgf = L > 1 | (BW - Mask);
imshow(imgf,'InitialMagnification','fit');

% The result after watershed is satisfactory. Most overlapping cells are
% not separated.


%% Problem 2. Segmentation problems.

% The folder segmentationData has 4 very different images. Use
% whatever tools you like to try to segement the objects the best you can. Put your code and
% output masks in the repository. If you use Ilastik as an intermediate
% step put the output from ilastik in your repository as well as an .h5
% file. Put code here that will allow for viewing of each image together
% with your final segmentation. 
seg=h5read('yeast.h5','/exported_data');
seg=squeeze(seg);
imshow(seg,[]);
img=imdilate(seg,strel('disk',2));
img=imerode(img,strel('disk',3));
imshow(img,[]);

% Segmentation of yeast.tif was performed in Ilastik. Ilastik did a
% great job in segmenting the file. imdilate was used to clear tiny dots in
% the background and imerode was used to fill the hole generated by the imdilate. resulting segmented image.

seg=h5read('bacteria.h5','/exported_data');
seg=squeeze(seg);
imshow(seg,[]);
img=imerode(seg,strel('disk',1));
imshow(img,[]);

% Segmentation of bacteria.tif was performed in Ilastik. Ilastik did a
% great job in segmenting the file. imdilate was used to clear tiny dots in
% the background and imerode was used to fill the hole generated by the imdilate.
seg=h5read('worms.h5','/exported_data');
seg=squeeze(seg);
imshow(seg,[]);
img=imdilate(seg,strel('disk',1));
img=imerode(img,strel('disk',3));
imshow(img,[]);
% Segmentation of worms.tif was performed in Ilastik. Ilastik did a
% great job in segmenting the file. imdilate was used to clear tiny dots in
% the background and imerode was used to fill the hole generated by the imdilate.
seg=h5read('cell.h5','/exported_data');
seg=squeeze(seg);
I=seg;
img = imclose(I, strel('disk', 5));
BW = im2bw(img, graythresh(img));
CC = bwconncomp(BW);
stats = regionprops(CC, 'Area');
area = [stats.Area];
fused = area > mean(area) + std(area);
fused1 = CC.PixelIdxList(fused);
fused1 = cat(1, fused1{:});
Mask = false(size(img));
Mask(fused1) = 1;
%watershed
img=seg==2;
img1=im2double(img);
imgbright=uint16((2^16-1)*(img1/max(max(img1))));
imgbright1=im2bw(imgbright,0.5);
imshow(imgbright1,[])
dist=bwdist(~imgbright1);
dist=-dist;
dist(~imgbright1)=-Inf;
L2=watershed(dist);
L2(~imgbright1)=0;
rgb=label2rgb(L2,'jet',[.5 .5 .5]);
imshow(rgb);

imgf=L2>1|(imgbright1-Mask);
imshow(imgf,[]);

%Ilastik was used to perform the segmentation. But the result does not
%looks satisfied.In order to improve the result, watershed is used to make
%furthur segmentation, by distance.

