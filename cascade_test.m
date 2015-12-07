function det = cascade_test(im, model,threshold)
pca = 5;
orig_model = model;
csc_model = cascade_model(model, '2007', pca, threshold);
orig_model.thresh = csc_model.thresh;

pyra = featpyramid(double(im), csc_model);
[dCSC, bCSC] = cascade_detect(pyra, csc_model, csc_model.thresh);
det = cascade_getboxes(csc_model, im, dCSC, bCSC);
end
