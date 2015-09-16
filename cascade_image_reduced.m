function detections = cascade_image_reduced( image, interval, threshold )
load('INRIA/inriaperson_final');
model.interval = interval;
detections = test(image,model,threshold);
end

function det = test(im, model,threshold)
pca = 5;
orig_model = model;
csc_model = cascade_model(model, '2007', pca, threshold);
orig_model.thresh = csc_model.thresh;

pyra = featpyramid(double(im), csc_model);
[dCSC, bCSC] = cascade_detect(pyra, csc_model, csc_model.thresh);
det = getboxes(csc_model, im, dCSC, bCSC);
end

function det = getboxes(model, image, det, all)
if ~isempty(det)
    try
        % attempt to use bounding box prediction, if available
        bboxpred = model.bboxpred;
        [det, all] = clipboxes(image, det, all);
        [det, all] = bboxpred_get(bboxpred, det, all);
    catch
        warning('no bounding box predictor found');
    end
    [det, ~] = clipboxes(image, det, all);
    I = nms(det, 0.5);
    det = det(I,:);
end
end

