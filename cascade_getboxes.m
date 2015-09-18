function det = cascade_getboxes(model, image, det, all)
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