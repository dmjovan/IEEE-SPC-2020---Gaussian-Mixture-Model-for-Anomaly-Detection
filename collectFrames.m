function frames = collectFrames(bags)
%COLLECTFRAMES Extracts frames from cell array of bag objects
%   Extracts frames from passed ROS bag objects and contcatenates them into one cell array

    frames={};
    for b = 1:length(bags)
       bag_frames=extractImages(bags{b});
       frames(length(frames) + (1:+length(bag_frames)), 1) = bag_frames;
    end

end

