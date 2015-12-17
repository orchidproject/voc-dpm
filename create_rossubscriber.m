startup;
rosinit('http://127.0.0.1:11311');
%sub = rossubscriber('/ardrone/throttled/image_raw','sensor_msgs/Image',@cascade_image_callback, 'BufferSize', 2);
sub = rossubscriber('/ardrone/throttled/ground_truth/image','sensor_msgs/Image',@cascade_image_callback, 'BufferSize', 2);
