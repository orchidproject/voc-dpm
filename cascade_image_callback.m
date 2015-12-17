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
global rosparam_tree;
if isempty(rosparam_tree)
    rosparam_tree = rosparam;
end

% get interval
global interval;
if isempty(interval)
    if has(rosparam_tree,'interval')
        interval = get(rosparam_tree,'interval');
    else
        interval = 5;
    end
end

% get threshold
global threshold;
if isempty(threshold)
    if has(rosparam_tree,'detection_threshold')
        threshold = get(rosparam_tree,'detection_threshold');
    else
        threshold = -0.5;
    end
end

% get publish_annotations flag
global publish_annotations;
if isempty(publish_annotations)
    if has(rosparam_tree,'publish_annotations')
        publish_annotations = get(rosparam_tree,'publish_annotations');
    else
        publish_annotations = false;
    end
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
DETECTION_TOPIC = '/ardrone/throttled/detections';
DETECTION_TYPE = 'mosaic_msgs/Detections';
if isempty(detection_pub) || ~strcmp(detection_pub.TopicName,DETECTION_TOPIC) || ~strcmp(detection_pub.MessageType,DETECTION_TYPE)
    fprintf('initialised detection publisher\n');
    detection_pub = rospublisher(DETECTION_TOPIC,DETECTION_TYPE);
end
if publish_annotations
    global annotated_img_pub;
    ANNOTATED_TOPIC = '/ardrone/bottom/annotated_image';
    IMAGE_TYPE = 'sensor_msgs/Image';
    if isempty(annotated_img_pub) || ~strcmp(annotated_img_pub.TopicName,ANNOTATED_TOPIC) || ~strcmp(annotated_img_pub.MessageType,IMAGE_TYPE)
        fprintf('initialised annotated image publisher\n');
        annotated_img_pub = rospublisher(ANNOTATED_TOPIC,IMAGE_TYPE);
    end
end
detection_msg = rosmessage(detection_pub);

% Populating output messages.
roi_array = [];
scores_array = [];
fprintf('number of detections = %d\n',size(detections,1));
for i = 1:size(detections,1)
    roi_array_element = rosmessage('sensor_msgs/RegionOfInterest');
    roi_array_element.XOffset = round(detections(i,1));
    roi_array_element.Width = round(detections(i,2));
    roi_array_element.YOffset = round(detections(i,3)-detections(i,1));
    roi_array_element.Height = round(detections(i,4)-detections(i,2));
    roi_array = [roi_array; roi_array_element];
    scores_array = [scores_array; detections(i,5)];
    if publish_annotations
        image = drawRect_colourByScore(image,detections(i,5),detections(i,1),detections(i,2),detections(i,3),detections(i,4),2);
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
detection_msg.Detections_ = roi_array;
detection_msg.Scores = scores_array;
send(detection_pub,detection_msg);

fprintf('callback took %f\n',toc(cb_time));
fprintf('--finished--\n\n');
end


