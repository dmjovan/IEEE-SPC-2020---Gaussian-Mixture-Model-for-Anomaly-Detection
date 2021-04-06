function bags2video(workDir, imageTopic, FrameRate, rotAngle, ext)
%BAGS2VIDEO Extracts video from all bags in workDir and stores video files.
%   Detailed explanation goes here
    listing = dir(fullfile(workDir, '*.bag'));
    
    N = size(listing, 1);
    
    for i = 1 : N
        file = listing(i, 1);
        [~,name,~] = fileparts(file.name);

        bag = rosbag(fullfile(workDir, file.name));

        videoFilename = fullfile(workDir, strcat(name, ext));
        bag2video(bag, imageTopic, FrameRate, videoFilename, rotAngle);
    end
end

