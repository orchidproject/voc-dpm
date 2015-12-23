function cascade_image_callback( ~, msg )
% Callback for an image subscriber.
% Runs a cascade by-parts classifier then publishes detections.
% Requires functions cascade_getboxes.m and cascade_test.m.
fprintf('--started--\n');
cb_time = tic;

% Get global variables
global detection_pub;
global annotated_img_pub;
global publish_annotations;
global threshold;
global casc_model;

% read image from ROS message
image = readImage(msg);

% perform detection
det_time = tic;
detections = cascade_test(image,casc_model,threshold);
fprintf('detection took %f with threshold %f\n', toc(det_time), threshold);


% Populating output messages.
detection_msg = rosmessage(detection_pub);
roi_array = cell(1,size(detections,1));
scores_array = cell(1,size(detections,1));
fprintf('number of detections = %d\n',size(detections,1));
for i = 1:size(detections,1)
    roi_array_element = rosmessage('sensor_msgs/RegionOfInterest');
    roi_array_element.XOffset = round(detections(i,1));
    roi_array_element.Width = round(detections(i,2));
    roi_array_element.YOffset = round(detections(i,3)-detections(i,1));
    roi_array_element.Height = round(detections(i,4)-detections(i,2));
    roi_array{i} = roi_array_element;
    scores_array{i} = detections(i,5);
    if publish_annotations
        image = drawRect_colourByScore(image,detections(i,5),...
            detections(i,1),detections(i,2),detections(i,3),...
            detections(i,4),2);
    end
end

% optionally publish annotated images
if publish_annotations
    annotated_img_msg = rosmessage(annotated_img_pub);
    annotated_img_msg.Encoding = 'rgb8';
    writeImage(annotated_img_msg,image);
    annotated_img_msg.Header = msg.Header;
    send(annotated_img_pub,annotated_img_msg);
end

% Publishing detections.
detection_msg.Header = msg.Header;
detection_msg.Detections_ = [roi_array{:}];
detection_msg.Scores = [scores_array{:}];
send(detection_pub,detection_msg);

fprintf('callback took %f\n',toc(cb_time));
fprintf('--finished--\n\n');
end


