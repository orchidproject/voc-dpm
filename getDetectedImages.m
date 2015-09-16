function [detections,scores] = getDetectedImages( images, regions )
detections={};
scores={};
for i = 1:numel(images)
    for j = 1:numel(regions{i})/5
        next_annotated_image = imcrop(images{i},[regions{i}(j,1) regions{i}(j,2) (regions{i}(j,3)-regions{i}(j,1)) (regions{i}(j,4)-regions{i}(j,2))]);
        scores = [scores; regions{i}(j,5)];
        detections = [detections; {next_annotated_image}];
    end
end
end