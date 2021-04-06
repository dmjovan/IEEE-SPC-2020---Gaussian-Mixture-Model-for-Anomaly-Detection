%% IEEE Signal Processing Cup 2020 - Qualifications
% % 
% student:
% 
% Miloš Pivaš 
% 
% 2015/0107
%% Report
% Defining the problem
% 5 normal and 5 abnormal recordings are given as ROS .bag files.
% 
% The task is to implement models which will give a prediction wheter the recording 
% is normal/abnormal based on measurements from .bag files.
% 
% Visualization:
% Images were extracted from "/pylon_camera_node/image_raw" topic, rotated 180 
% degrees and saved as video files with 4fps framerate.
% 
% From extracted videos we see that the recordings come from some UAV, where 
% the normal recordings were made during stable flight without fast movement while 
% abnormal recordings were made during very unstable flight with sudden movements.
% 
% % Preanalysis
% Every recording has around hundred mesurements but the task isn't the classification 
% of measurements but the classification of whole recordings.
% 
% => We can't use classic classification because we don't have the lables for 
% measurements.
% 
% => Possible solution: learn the distributions of normal data measurements 
% unsupervised, with abnormal data used to tune the parameters of the distributions. 
% To classify the recording, detect anomalous measurements, and based on number 
% of anomalies classify it as normal/abnormal.
% 
% We assume:
% 
% - A normal recording doesn't contain abnormal measurements.
% 
% - An abnormal recording contains some abnormal measurements.
% 
% - Features are independent.
% 
% Model:
% 
% - We assume Gaussian distribution for all measurements
% 
% - We transform the data if it isn't Gaussian (log-transformation etc.)
% 
% - From independence of features, we have that for feature vector x the probability 
% is p(x) = p(x(1)) * p(x(2)) * ... * p(x(n))
% 
% - We fit the Gaussian parameters mu and sigma on the training set.
% 
% - We classify the measurement x as abnormal if $p\left(x\right)<\epsilon$.
% 
% - We classify the recording as abnormal if it contains more than $\alpha \;$ 
% (adjacent?) abnormal measurements
% 
% For the training, cross-validation, test-sets we have:
% 
% Training set:   3 normal recordings, 0 abnormal       for fitting the distributions
% 
% CV set:        1 normal recording, 2 abnormals,         for tuning $\epsilon$ 
% and $\alpha$.
% 
% Test set:      1 normal recording, 3 abnormals,         for final model evaluation
% 
% % 
% We use F_1 score as model evaluation metric.
% 
% Since the normal class is in minority in the test set, we set it to be the 
% positive class.
% 
% TP - #true positive,    FP - #false positive,   FN - #false negative
% 
% precision: P = TP/(TP + FP),    recall: R = TP/(TP + FN),   F_1 skor: F_1 
% = 2*P*R/(P + R)
% 
% % Measurement analysis
% Based on extracted videos, the following measurements were chosen as relevant 
% for analysis:
% 
% "/mavros/global_position/local"
% 
% "/mavros/imu/data"
% 
% "/mavros/imu/mag"
% 
% "/mavros/global_position/compass_hdg"
% 
% The oscillations of some measurements are much larger on abnormal recordings 
% than normal ones.
% 
% That means that the derivatives of those signals reach higher absolute values 
% on abnormal recordings, which means that variances of those measurements are 
% larger than on normal recordings so they can be used as features for classical 
% classification.
% 
% => So we can ignore the preanalysis above
% 
% % 
% Physical quantities that satisfy the above description are orientation, linear 
% velocity, magnetic field and compass heading.
% 
% Their derivatives are angular velocity, linear acceleration (already available 
% from IMU), and derivatives of magnetic field and compass heading (which can 
% be calculated from measurements), labeled as:
% 
% "IMUAngularVelocity", "IMULinearAcceleration", "MagneticFieldDerivative", 
% "compassHdgDerivative".
% 
% First three quantities are 3D, the fourth one is scalar, so the feature vectore 
% is 10D.
% 
% % Classification
% Based on this data, a data matrix X is formed with added label column y.
% 
% I used Matlab Classification Learner.
% 
% I also used PCA with 99% variance retained via 2 predictors.
% 
% Several models were produced, all with 100% accuracy (which isn't surprising 
% considering the small size of the data set):
% 
% - Logistic regression
% 
% - SVM (works with every kernel; linear kernel version was saved)
% 
% - Naive Bayes Gaussian model
% 
% - K-Nearest Neighbours (Fine KNN)
% 
% - Linear Discriminant Classifier
% 
% - Ensamble method (Bagged Trees)
% 
% % Overview of functions:

%     addDerivative      - calculates derivatives of selected columns of the table and adds the derivative columns.
%     bag2table          - Extracts '/mavros/imu/data', '/mavros/imu/mag', '/mavros/global_position/local'
%                           and '/mavros/global_position/compass_hdg' Topics from ROS .bag file and turns the data into a table.
%     bag2video          - Extracts images from ROS .bag file and saves the stream as video with given parameters.
%     bagCell2table      - Applies bag2table() on bag objects from given cell array and joins the results in one table.
%     bagSplit           - Unused function for splitting the cell array of bag objects into training, CV and test arrays.
%     bags2video         - Applies bag2video on all bag files from a given directory.
%     compassCell2table  - Converts a cell array of ROS bag 'std_msgs/Float64' type message into a table.
%     files2bag          - Loads all .bag files from given directory into a cell array of bag objects.
%     getFeatureTable    - Final data extraction. Applies bag2table() on bag objects from a given cell array,
%                         adds derivatives of magnetic field and compass heading columns, extracts relevant columns and calculates the variances.
%     imu2table          - Converts a ROS bag 'sensor_msgs/Imu' type message into a table.
%     imuCell2table      - Applies imu2table() on elements of a cell array of 'sensor_msgs/Imu' type messages and joins them into a table.
%     mag2table          - Converts ROS bag 'sensor_msgs/MagneticField' type messages into a table.
%     magCell2table      - Applies mag2table() on elements of a cell array of 'sensor_msgs/MagneticField' type messages and joins them into a table.
%     main_en            - Main program.
%     odom2table         - Converts ROS bag 'nav_msgs/Odometry' type messages into a table.
%     odomCell2table     - Applies odom2table() on elements of a cell array of 'nav_msgs/Odometry' type messages and joins them into a table.
%     plotData           - Plots chosen columns from a pair of tables as signals in time and their histograms.
%                         Used for measurement analysis.
%     tableVar           - Calculates variances of tables columns and returns them in a new table with same column names.
%% 
% %% Implementation    
% Work directories for normal and abnormal data.

clear;

% change if needed
workDirNormal = '03_normal';
workDirAbnormal = '04_abnormal';
%% 1. Video visualisation
% Common parameters for video recording

imageTopic = "/pylon_camera_node/image_raw";
FrameRate = 4;
rotAngle = 180;
ext = '.avi';
% Video extraction

bags2video(workDirNormal, imageTopic, FrameRate, rotAngle, ext)
bags2video(workDirAbnormal, imageTopic, FrameRate, rotAngle, ext)
%% 2. The structure of data
% Loading .bag files, selecting relevant measurements and converting into tables.

bagsNormal = files2bag(workDirNormal);
bagsAbnormal = files2bag(workDirAbnormal);

jointTableNormal = bagCell2table(bagsNormal);
jointTableAbnormal = bagCell2table(bagsAbnormal);
% Data analysis on joint data from all recordings and choosing predictor features.

% close all
Vector3Suffixes = ["X" "Y" "Z"];
QuaternionSuffixes = ["X" "Y" "Z" "W"];

plotData(jointTableNormal, jointTableAbnormal, "odomPosition", Vector3Suffixes, figure(1), figure(2));
% doesn't look useful

plotData(jointTableNormal, jointTableAbnormal, "odomOrientation", QuaternionSuffixes, figure(3), figure(4));
% high frequency oscillations on the abnormal data
% first derivative would be a very useful feature
% angular velocity? 

plotData(jointTableNormal, jointTableAbnormal, "odomTwistLinear", Vector3Suffixes, figure(5), figure(6));
% looks like first derivative would be very useful
% linear acceleration?

plotData(jointTableNormal, jointTableAbnormal, "IMUOrientation", QuaternionSuffixes, figure(7), figure(8));
% this looks identical to odomOrientation

plotData(jointTableNormal, jointTableAbnormal, "IMUAngularVelocity", Vector3Suffixes, figure(9), figure(10));
% just as anticipated, abnormals have much higher variance

plotData(jointTableNormal, jointTableAbnormal, "IMULinearAcceleration", Vector3Suffixes, figure(11), figure(12));
% just as anticipated, abnormals have much higher variance

plotData(jointTableNormal, jointTableAbnormal, "MagneticField", Vector3Suffixes, figure(13), figure(14));
% high frequency oscillations on the abnormal data
% first derivative would be a useful feature

plotData(jointTableNormal, jointTableAbnormal, "compassHdg", "", figure(15), figure(16));
% high frequency oscillations on the abnormal data
% first derivative would be a useful feature

jointTableNormalAddDer = addDerivative(jointTableNormal, "MagneticField", Vector3Suffixes);
jointTableAbnormalAddDer = addDerivative(jointTableAbnormal, "MagneticField", Vector3Suffixes);

jointTableNormalAddDer = addDerivative(jointTableNormalAddDer, "compassHdg");
jointTableAbnormalAddDer = addDerivative(jointTableAbnormalAddDer, "compassHdg");

plotData(jointTableNormalAddDer, jointTableAbnormalAddDer, "MagneticFieldDerivative", Vector3Suffixes, figure(17), figure(18));
% just as anticipated, abnormals have much higher variance

plotData(jointTableNormalAddDer, jointTableAbnormalAddDer, "compassHdgDerivative", "", figure(19), figure(20));
% just as anticipated, abnormals have much higher variance
%% 3. Classification
% Generating data for classification

tableNormal = getFeatureTable(bagsNormal);
tableNormal = [tableNormal, table(zeros(5,1), 'VariableNames', "y")];
tableAbnormal = getFeatureTable(bagsAbnormal);
tableAbnormal = [tableAbnormal, table(ones(5,1), 'VariableNames', "y")];

tableXy = [tableNormal; tableAbnormal];
% Launching Classification Learner app

classificationLearner
% Saving the models

filenames = [
"modelEnsembleBaggedTrees",...
"modelKNNFine",...
"modelLinearDiscriminant",...
"modelLogisticRegression",...
"modelNaiveBayesGaussian",...
"modelSVMLinear"...
];
% save models separately
for m = filenames
    save(m+".mat", m);
end
% save all variables with model in their names in one file via regex
save models.mat -regexp 'model'