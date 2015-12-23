classdef CustomMsgConsts
    %CustomMsgConsts This class stores all message types
    %   The message types are constant properties, which in turn resolve
    %   to the strings of the actual types.
    
    %   Copyright 2015 The MathWorks, Inc.
    
    properties (Constant)
        mosaic_msgs_ClassifierInfo = 'mosaic_msgs/ClassifierInfo'
        mosaic_msgs_Detections = 'mosaic_msgs/Detections'
        mosaic_msgs_Observation = 'mosaic_msgs/Observation'
        mosaic_msgs_ObservationList = 'mosaic_msgs/ObservationList'
    end
    
    methods (Static, Hidden)
        function messageList = getMessageList
            %getMessageList Generate a cell array with all message types.
            %   The list will be sorted alphabetically.
            
            persistent msgList
            if isempty(msgList)
                msgList = cell(4, 1);
                msgList{1} = 'mosaic_msgs/ClassifierInfo';
                msgList{2} = 'mosaic_msgs/Detections';
                msgList{3} = 'mosaic_msgs/Observation';
                msgList{4} = 'mosaic_msgs/ObservationList';
            end
            
            messageList = msgList;
        end
        
        function serviceList = getServiceList
            %getServiceList Generate a cell array with all service types.
            %   The list will be sorted alphabetically.
            
            persistent svcList
            if isempty(svcList)
                svcList = cell(0, 1);
            end
            
            % The message list was already sorted, so don't need to sort
            % again.
            serviceList = svcList;
        end
    end
end
