
% declare global variables shared with subscriber callback
global detection_pub;
global annotated_img_pub;
global publish_annotations;

fprintf('reading configuration\n');
startup;
ros_config = readtable('ros_config.txt');

fprintf('initialising ROS\n');
rosinit(ros_config.ROS_MASTER_URI{1});

% create publishers
fprintf('initialising publishers\n');
SHUTDOWN_TOPIC = ros_config.SHUTDOWN_TOPIC{1};
DETECTION_TOPIC = ros_config.DETECTION_TOPIC{1};
DETECTION_TYPE = 'mosaic_msgs/Detections';
ANNOTATED_TOPIC = ros_config.ANNOTATED_TOPIC{1};
IMAGE_TYPE = 'sensor_msgs/Image';
detection_pub = rospublisher(ros_config.DETECTION_TOPIC{1},DETECTION_TYPE);
annotated_img_pub = rospublisher(ANNOTATED_TOPIC,IMAGE_TYPE);

% Obtaining parameters from ros parameter server, if they're not present
% then defaults are used. Accessing the ros parameter server is slow so
% these would ideally be stored somewhere after they're initialised.
fprintf('reading ROS parameters\n');
rosparam_tree = rosparam;

% get interval
if has(rosparam_tree,'interval')
    interval = get(rosparam_tree,'interval');
else
    interval = 5;
end


% get threshold
global threshold;
if has(rosparam_tree,'detection_threshold')
    threshold = get(rosparam_tree,'detection_threshold');
else
    threshold = -1.0;
end

% get publish_annotations flag
if has(rosparam_tree,'publish_annotations')
    publish_annotations = get(rosparam_tree,'publish_annotations');
else
    publish_annotations = false;
end
if publish_annotations
    disp('Annotated Image publication enabled');
else
    disp('Annotated Images disabled');
end

% Initialise cascade detection model
global casc_model;
load('INRIA/inriaperson_final');
fprintf('loaded model\n');
casc_model = model;
casc_model.interval = interval;

% ROS_PARAMETERS
display(threshold);
display(publish_annotations);
display(interval);

% start subscribing to shutdown requests
shutdown_sub = rossubscriber(SHUTDOWN_TOPIC,'std_msgs/Empty', ...
    @shutdown_callback, 'BufferSize', 2);

% start subscribing to images for detection
disp('subscribing to messages');
sub = rossubscriber(ros_config.INPUT_TOPIC{1},IMAGE_TYPE, ...
    @cascade_image_callback, 'BufferSize', 2);


