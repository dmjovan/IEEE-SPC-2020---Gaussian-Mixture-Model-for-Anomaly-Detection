function images = extractImages(bag)
%EXTRACTIMAGES Extracts images from bag file
%   Forms a set of all images from one bag file
    bSel = select(bag,'Topic','/pylon_camera_node/image_raw');
    images = readMessages(bSel); %,'DataFormat','struct');

    for i=1:length(images)
        images{i} = readImage(images{i});
        images{i} = imrotate(images{i}, 180);
    end

end

