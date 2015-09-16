function [detections] = cascade_image( image )
load('INRIA/inriaperson_final');
model.interval = 10;
[img detections] = test(image,model);
end

function [annotated, det] = test(im, model)

name = model.class;

clf;
fprintf('\n///// Running demo for %s /////\n\n', name);

subplot(1,2,1);
imagesc(im);
axis image;
axis off;

fprintf('Compute cascade thresholds');
fprintf('...done\n');

thresh = -0.5;
pca = 5;
orig_model = model;
csc_model = cascade_model(model, '2007', pca, thresh);
orig_model.thresh = csc_model.thresh;

fprintf('Building the feature pyramid...');
th = tic();
pyra = featpyramid(double(im), csc_model);
tF = toc(th);
fprintf('done\n');

fprintf('Computing detections with star-cascade...');
th = tic;
[dCSC, bCSC] = cascade_detect(pyra, csc_model, csc_model.thresh);
tCSC = toc(th);
fprintf('done\n');
fprintf('  --> Cascade detection took %f seconds\n', tCSC);

[b, det] = getboxes(csc_model, im, dCSC, bCSC);
subplot(1,2,2);
annotated = showboxes(im, b);
title('star-cascade detections');

end

function [b, det] = getboxes(model, image, det, all)
b = [];
if ~isempty(det)
    try
        % attempt to use bounding box prediction, if available
        bboxpred = model.bboxpred;
        [det, all] = clipboxes(image, det, all);
        [det, all] = bboxpred_get(bboxpred, det, all);
    catch
        warning('no bounding box predictor found');
    end
    [det, all] = clipboxes(image, det, all);
    I = nms(det, 0.5);
    det = det(I,:);
    all = all(I,:);
    if ~isempty(det)
        b = [det(:,1:4) all];
    else
        b = []; 
    end
end
end

function [im] = showboxes(im, boxes, out)
% Draw bounding boxes on top of an image.
%   showboxes(im, boxes, out)
%
%   If out is given, a pdf of the image is generated (requires export_fig).

% AUTORIGHTS
% -------------------------------------------------------
% Copyright (C) 2011-2012 Ross Girshick
% Copyright (C) 2008, 2009, 2010 Pedro Felzenszwalb, Ross Girshick
% Copyright (C) 2007 Pedro Felzenszwalb, Deva Ramanan
% 
% This file is part of the voc-releaseX code
% (http://people.cs.uchicago.edu/~rbg/latent/)
% and is available under the terms of an MIT-like license
% provided in COPYING. Please retain this notice and
% COPYING if you use this file (or a portion of it) in
% your project.
% -------------------------------------------------------

if nargin > 2
  % different settings for producing pdfs
  print = true;
  %wwidth = 2.25;
  %cwidth = 1.25;
  cwidth = 1.4;
  wwidth = cwidth + 1.1;
  imsz = size(im);
  % resize so that the image is 300 pixels per inch
  % and 1.2 inches tall
  scale = 1.2 / (imsz(1)/300);
  im = imresize(im, scale, 'method', 'cubic');
  %f = fspecial('gaussian', [3 3], 0.5);
  %im = imfilter(im, f);
  boxes = (boxes-1)*scale+1;
else
  print = false;
  cwidth = 2;
end

image(im); 
if print
  truesize(gcf);
end
axis image;
axis off;
set(gcf, 'Color', 'white');

if ~isempty(boxes)
  numfilters = floor(size(boxes, 2)/4);
  if print
    % if printing, increase the contrast around the boxes
    % by printing a white box under each color box
    for i = 1:numfilters
      x1 = boxes(:,1+(i-1)*4);
      y1 = boxes(:,2+(i-1)*4);
      x2 = boxes(:,3+(i-1)*4);
      y2 = boxes(:,4+(i-1)*4);
      % remove unused filters
      del = find(((x1 == 0) .* (x2 == 0) .* (y1 == 0) .* (y2 == 0)) == 1);
      x1(del) = [];
      x2(del) = [];
      y1(del) = [];
      y2(del) = [];
      if i == 1
        w = wwidth;
      else
        w = wwidth;
      end

%      if i ==  13+1 || i == 14+1
%        c = 'k';
%        w = cwidth + 0.5;
%      else
        c = 'w';
%      end

      line([x1 x1 x2 x2 x1]', [y1 y2 y2 y1 y1]', 'color', c, 'linewidth', w);
    end
  end
  % draw the boxes with the detection window on top (reverse order)
  for i = numfilters:-1:1
    x1 = boxes(:,1+(i-1)*4);
    y1 = boxes(:,2+(i-1)*4);
    x2 = boxes(:,3+(i-1)*4);
    y2 = boxes(:,4+(i-1)*4);
    % remove unused filters
    del = find(((x1 == 0) .* (x2 == 0) .* (y1 == 0) .* (y2 == 0)) == 1);
    x1(del) = [];
    x2(del) = [];
    y1(del) = [];
    y2(del) = [];
    if i == 1
      c = 'r'; %[160/255 0 0];
      s = '-';
%    elseif i ==  13+1 || i == 14+1
%      c = 'c';
%      s = '--';
    else
      c = 'b';
      s = '-';
    end
    line([x1 x1 x2 x2 x1]', [y1 y2 y2 y1 y1]', 'color', c, 'linewidth', cwidth, 'linestyle', s);
  end
end

% save to pdf
if print
  % requires export_fig from http://www.mathworks.com/matlabcentral/fileexchange/23629-exportfig
  export_fig([out]);
end
im = getframe();
end
