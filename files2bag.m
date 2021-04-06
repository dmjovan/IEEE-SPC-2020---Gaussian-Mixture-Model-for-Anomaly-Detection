function [bags] = files2bag(workDir)
%FILES2BAG Read a cell array of bag files
%   Detailed explanation goes here
    listing = dir(fullfile(workDir, '*.bag'));
    N = size(listing, 1);
    bags = cell(N, 1);
    for i = 1 : N
        file = listing(i, 1);
        bags{i, 1} = rosbag(fullfile(workDir, file.name));
    end
end

