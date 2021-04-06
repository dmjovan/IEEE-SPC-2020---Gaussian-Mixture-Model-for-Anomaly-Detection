function [T] = mag2table(magMessage)
%MAG2TABLE Converts a MagneticField message to a table row.
%   Converts a 'sensor_msgs/MagneticField' type message from a ROS bag to a table row.
%   Just the MagneticField Vector3 is preserved.

    MagneticFieldX = magMessage.MagneticField.X;
    MagneticFieldY = magMessage.MagneticField.Y;
    MagneticFieldZ = magMessage.MagneticField.Z;

    T = table(...
        MagneticFieldX,...
        MagneticFieldY,...
        MagneticFieldZ...
    );

end

