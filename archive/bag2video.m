function [outputVideo] = bag2video(bag, imageTopic, FrameRate, videoFilename, rotAngle)
%BAG2VIDEO Loads video from the bag and stores it.
%   Detailed explanation goes here
    bag_select_image = select(bag, 'Topic', imageTopic);
    messages_image = readMessages(bag_select_image); %, 'DataFormat', 'struct');

    N = bag_select_image.NumMessages;

    outputVideo = VideoWriter(videoFilename);
    outputVideo.FrameRate = FrameRate;
    open(outputVideo)

    for i = 1 : N
        temp = messages_image{i, 1};
        img = readImage(temp);
        img = imrotate(img, rotAngle);
        writeVideo(outputVideo, img)
    end

    close(outputVideo)

end

