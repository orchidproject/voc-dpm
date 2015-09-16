function [annotated_images] = runDrawRectLoop( images, detections )
annotated_images={};
for i = 1:numel(images)
%     if ~isempty(detections{i})
    next_annotated_image = images{i};
    for j = 1:numel(detections{i})/5
        next_annotated_image = drawRect(next_annotated_image,detections{i}(j,1),detections{i}(j,2),detections{i}(j,3),detections{i}(j,4));
    end
    annotated_images = [annotated_images; {next_annotated_image}];
%     else
%         annotated_images=[annotated_images; images(i)];
%     end
end
end