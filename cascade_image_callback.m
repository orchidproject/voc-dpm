function cascade_image_callback( src, msg )
% Callback for an image subscriber.
% Runs a cascade by-parts classifier then publishes detections.
% Requires functions cascade_getboxes.m and cascade_test.m.
fprintf('--started--\n');
cb_time = tic;

image = readImage(msg);

% Obtaining parameters from ros parameter server, if they're not present
% then defaults are used. Accessing the ros parameter server is slow so
% these would ideally be stored somewhere after they're initialised.
rosparam_tree = rosparam;
if has(rosparam_tree,'interval')
    interval = get(rosparam_tree,'interval');
else
    interval = 5;
end
if has(rosparam_tree,'detection_threshold')
    threshold = get(rosparam_tree,'detection_threshold');
else
    threshold = -0.5;
end

% Checking if the global cascade model is initialised and if not then
% initialising it. Then runs cascade over image.
global casc_model;
if isempty(casc_model) || ~strcmp(casc_model.class,'inriaperson')
    load('INRIA/inriaperson_final');
    fprintf('loaded model\n');
    casc_model = model;
end
casc_model.interval = interval;
det_time = tic;
detections = cascade_test(image,casc_model,threshold);
fprintf('detection took %f with threshold %f\n', toc(det_time), threshold);

% Checking if global publisher objects are initialised and if not then
% initialising them.
global detection_pub;
if isempty(detection_pub) || ~strcmp(detection_pub.TopicName,'/detections') || ~strcmp(detection_pub.MessageType,'mosaic_msgs/Detections')
    fprintf('initialised detection publisher\n');
    detection_pub = rospublisher('/ardrone/throttled/detections','mosaic_msgs/Detections');
end
global annotated_img_pub;
if isempty(annotated_img_pub) || ~strcmp(annotated_img_pub.TopicName,'/annotated_image') || ~strcmp(annotated_img_pub.MessageType,'sensor_msgs/Image')
    fprintf('initialised annotated image publisher\n');
    annotated_img_pub = rospublisher('/ardrone/bottom/annotated_image','sensor_msgs/Image');
end
detection_msg = rosmessage(detection_pub);
annotated_img_msg = rosmessage(annotated_img_pub);

% Populating output messages.
roi_array_element = rosmessage('sensor_msgs/RegionOfInterest');
roi_array = [];
scores_array = [];
fprintf('number of detections = %d\n',size(detections,1));
for i = 1:size(detections,1)
    roi_array_element.XOffset = round(detections(i,1));
    roi_array_element.Width = round(detections(i,2));
    roi_array_element.YOffset = round(detections(i,3)-detections(i,1));
    roi_array_element.Height = round(detections(i,4)-detections(i,2));
    roi_array = [roi_array; roi_array_element];
    scores_array = [scores_array; detections(i,5)];
    image = drawRect_colourByScore(image,detections(i,5),detections(i,1),detections(i,2),detections(i,3),detections(i,4),2);
end
writeImage(annotated_img_msg,image);
annotated_img_msg.Header = msg.Header;
detection_msg.Header = msg.Header;
detection_msg.Detections_ = roi_array;
detection_msg.Scores = scores_array;

% Publishing detections.
send(detection_pub,detection_msg);
send(annotated_img_pub,annotated_img_msg);

fprintf('callback took %f\n',toc(cb_time));
fprintf('--finished--\n\n');
end


