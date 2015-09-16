function [detections] = get_sorted_detected_regions( rosbag, num_imgs, interval, threshold )
% From rosbag to images to detections to detected regions sorted by score
fprintf('Calculating detections..\n');
indices = floor(linspace(1,rosbag.NumMessages,num_imgs));
detections = {};
images = {};
no_objects = {};
detection_times = [];
for i = 1:num_imgs
    fprintf('For image %d of %d..\n',i,num_imgs);
    next_message = readMessages(rosbag,indices(i));
    next_image = readImage(next_message{1});
    tic;
    next_detection = cascade_image_reduced(next_image,interval,threshold);
    detection_times = [detection_times; toc];
    detections = [detections; {next_detection} i];
    if isempty(next_detection)
        no_objects = [no_objects; next_image];
    end
    images = [images; next_image];
end
[detected_regions scores] = getDetectedImages(images,detections);
sorted_detected_regions = [detected_regions scores];
sorted_detected_regions = sortrows(sorted_detected_regions,2);
fprintf('Detection calculation complete. Average frame detection time = %f\n',mean(detection_times));
fprintf('Showing detected regions: (Press any button to start)\n');
pause;
loop_images(sorted_detected_regions,false);
fprintf('Showing images with no detected objects: (Press any button to start)\n');
pause;
loop_images(no_objects,false);
end