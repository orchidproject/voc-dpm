function shutdown_callback( ~, ~ )
% Callback to shutdown ROS node cleanly.
fprintf('Shutting down ROS matlab node\n\n');
rosshutdown;
exit;


