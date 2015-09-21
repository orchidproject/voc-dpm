startup;
rosinit('http://127.0.0.1:11311');
sub = rossubscriber('/ardrone/bottom/image_raw','sensor_msgs/Image',@cascade_image_callback, 'BufferSize', 2);
