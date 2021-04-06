%% IEEE Signal Processing Cup 2020 - Kvalifikacije
% % 
% student:
% 
% Milo� Piva� 
% 
% 2015/0107
%% Izve�taj
% Definisanje problema
% Dato je 5 normalnih i 5 abnormalnih snimaka merenja.
% 
% Zadatak je da se implementiraju modeli koji ?e na osnovu merenja iz .bag fajlova 
% dati predikciju da li je snimak normal/abnormal.
% 
% Zatim predikcije uporediti sa pravom klasom kojoj snimak pripada i na taj 
% na?in odrediti ta?nost modela.
% 
% % Vizualizacija:
% Iz topic-a "/pylon_camera_node/image_raw" su izvu?ene slike, rotirane za 180 
% stepeni i sa?uvane u video fajlove sa framerate-om 4fps.
% 
% Iz izvu?enih videa se vidi da snimci poti?u sa neke bespilotne letilice,
% 
% gde su normalni snimci snimljeni pri stabilnom letu bez mnogo pomeranja,
% 
% dok su abnormalni snimljeni pri izrazito nestabilnom letu.
% 
% % Predanaliza
% U svakom snimku ima stotinak merenja, ali zadatak nije klasifikacija merenja 
% nego klasifikacija snimaka.
% 
% => Ne mo�emo da koristimo klasi?nu klasifikaciju jer nemamo labele za sama 
% merenja.
% 
% => Mogu?e re�enje: nenadgledano u?imo raspodele merenja normalnih podataka, 
% detektujemo anomalije, na osvnovu broja anomalija klasifikujemo snimak kao normalni/abnormalni.
% 
% Usvajamo slede?e pretpostavke:
% 
% - Normalni snimak ne sadr�i abnormalna merenja.
% 
% - Abnormalni snimak sadr�i neka abnormalna merenja.
% 
% - Obele�ja su nezavisna.
% 
% Model:
% 
% - Usvajamo da Gauss-ovu raspodelu za merenja
% 
% - Transformi�emo podatke ako nisu Gauss-ovski
% 
% - Kako su obele�ja nezavisna, za vektor obele�ja x va�i: p(x) = p(x(1)) * 
% p(x(2)) * ... * p(x(n))
% 
% - Fitujemo parametre za Gauss-ovu raspodelu, vektore mu i sigma, na trening 
% skupu.
% 
% - Klasifikujemo merenje x kao abnormalno ako je p(x) < Epsilon
% 
% - Klasifikujemo snimak kao abnormalan ako sadr�i vi�e od Alfa (uzastopnih?) 
% abnormalnih merenja
% 
% Po�to podatke treba podeliti na trening, CV i test skupove, imamo:
% 
% Trening skup:   3 normalna snimka, 0 abnormalnih    za fitovanje raspodela
% 
% CV skup:        1 normalni snimak, 2 abnormalna     za pode�avanje parametra 
% Epsilon i Alfa
% 
% Test skup:      1 normalni snimak, 3 abnormalna     za kona?nu evaluaciju 
% modela
% 
% % 
% Za evaluaciju klasifikacije koristimo F_1 skor.
% 
% Po�to je u test skupu normalna klasa u manjini, progla�avamo nju za pozitivnu 
% klasu.
% 
% TP - #true positive,    FP - #false positive,   FN - #false negative
% 
% precision: P = TP/(TP + FP),    recall: R = TP/(TP + FN),   F_1 skor: F_1 
% = 2*P*R/(P + R)
% 
% % Analiza merenja
% Na osnovu izvu?enih videa, izabrana su slede?a merenja kao relevantna za analizu:
% 
% "/mavros/global_position/local"
% 
% "/mavros/imu/data"
% 
% "/mavros/imu/mag"
% 
% "/mavros/global_position/compass_hdg"
% 
% Do�lo se do zaklju?ka da je su oscilacije odre?enih merenja kod abnormalnih 
% snimaka zna?ajno ve?e nego kod normalnih.
% 
% To zna?i da izvodi tih veli?ina dosti�u ve?e apsolutne vrednosti kod abnormalnih 
% snimaka,
% 
% �to zna?i da su varijanse tih merenja ve?e nego kod normalnih pa se mogu koristiti 
% kao obele�ja za klasi?nu klasifikaciju.
% 
% => Zanemariti predanalizu gore
% 
% % 
% Veli?ine koje zadovoljavaju gornji opis su ugaona orijentacija, linearna brzina, 
% ja?ina magnetskog polja i smer kompasa.
% 
% Njihovi izvodi su ugaona brzina i linerno ubrzanje (ve? dostupni sa IMU-a), 
% izvodi magnetskog polja i smera kompasa (izra?unati iz merenja), u kodu ozna?eni 
% kao:
% 
% "IMUAngularVelocity", "IMULinearAcceleration", "MagneticFieldDerivative", 
% "compassHdgDerivative".
% 
% Prve tri veli?ine su trodimenzione, ?etvrta je skalarna, tako da su vektori 
% prediktora 10D.
% 
% % Klasifikacija
% Na osnovu ovih podataka, formira se matrica podataka X, sa dodatom kolonom 
% labela y.
% 
% Kori�?en je Matlab Classification Learner.
% 
% Kori�?en je PCA koji zadr�ava minimum 99% varijanse sa 2 prediktora.
% 
% Dobijeno je vi�e modela sa 100% ta?no�?u (�to i ne ?udi, s obzirom na veli?inu 
% skupa podataka):
% 
% - Logisti?ka regresija
% 
% - SVM (radi sa svakim kernelom, sa?uvan linearni)
% 
% - Naivni Bejz-Gausovski model
% 
% - K-najbli�ih suseda (Fine KNN)
% 
% - Linearni diskriminativni klasifikator
% 
% - Ansambl metoda (Bagged Trees)
% 
% % Pregled funkcija:

%     addDerivative      - ra?una izvode selektovanih kolona tabele i dodaje kolone sa izvodima na tabelu.
%     bag2table          - Izvla?i '/mavros/imu/data', '/mavros/imu/mag', '/mavros/global_position/local'
%                           i '/mavros/global_position/compass_hdg' iz ROS bag fajla i pretvara u tabelu
%     bag2video          - Izvla?i snimke iz ROS bag fajla i ?uva kao video sa zadatim parametrima.
%     bagCell2table      - Primenjuje bag2table() na bag promenjive iz datog cell niza i objedinjuje rezultate u jednu tabelu.
%     bagSplit           - Nekori�?ena funkcija za deljenje cell nizova bag promenljivih na trening, CV i test nizove.
%     bags2video         - Primenjuje bag2video na sve bag fajlove iz zadatog direktorijuma.
%     compassCell2table  - Konvertuje cell niz ROS bag poruka tipa 'std_msgs/Float64' u tabelu.
%     files2bag          - U?itava sve bag fajlove iz datog direktorijuma u cell niz bag promenjivih.
%     getFeatureTable    - Finalno izvla?enje podataka. Primenjuje bag2table() na bag promenjive iz datog cell niza,
%                         dodaje izvode na kolone magnetskog polja i smera kompasa, izvla?i relevantne kolone i ra?una varijansu.
%     imu2table          - Konvertuje ROS bag poruku tipa 'sensor_msgs/Imu' u tabelu.
%     imuCell2table      - Primenjuje imu2table() na elemente cell niza poruka tipa 'sensor_msgs/Imu' i objedinjuje u tabelu.
%     mag2table          - Konvertuje ROS bag poruku tipa 'sensor_msgs/MagneticField' u tabelu.
%     magCell2table      - Primenjuje mag2table() na elemente cell niza poruka tipa 'sensor_msgs/MagneticField' i objedinjuje u tabelu.
%     main               - Glavni program.
%     odom2table         - Konvertuje ROS bag poruku tipa 'nav_msgs/Odometry' u tabelu.
%     odomCell2table     - Primenjuje imu2table() na elemente cell niza poruka tipa 'nav_msgs/Odometry' i objedinjuje u tabelu.
%     plotData           - Prikazuje odabrane kolone iz para tabela kao signale u vremenu i njihove histograme.
%                         Koristi se za analizu merenja.
%     tableVar           - Ra?una varijanse kolona tabele i vra?a kao novu tabelu sa istim imenima kolona.
%% 
% %% Implementacija    
% Radni direktorijumi za normalne i abnormalne podatke.

clear;

% change if needed
workDirNormal = "03_normal";
workDirAbnormal = "04_abnormal";
%% 1. Video vizualizacija
% Zajedni?ki parametri za video snimke

imageTopic = "/pylon_camera_node/image_raw";
FrameRate = 4;
rotAngle = 180;
ext = ".avi";
% Ekstraktovanje videa

bags2video(workDirNormal, imageTopic, FrameRate, rotAngle, ext)
bags2video(workDirAbnormal, imageTopic, FrameRate, rotAngle, ext)
%% 2. Struktura podataka
% U?itavanje .bag fajlova, izdvajanje relevantnih merenja, pretvaranje u tabele.

bagsNormal = files2bag(workDirNormal);
bagsAbnormal = files2bag(workDirAbnormal);

jointTableNormal = bagCell2table(bagsNormal);
jointTableAbnormal = bagCell2table(bagsAbnormal);
% Analiza podataka na zdru�enim podacima iz svih snimaka i biranje obele�ja prediktora

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
%% 3. Klasifikacija
% Generisanje podataka za klasifikaciju

tableNormal = getFeatureTable(bagsNormal);
tableNormal = [tableNormal, table(zeros(5,1), 'VariableNames', "y")];
tableAbnormal = getFeatureTable(bagsAbnormal);
tableAbnormal = [tableAbnormal, table(ones(5,1), 'VariableNames', "y")];

tableXy = [tableNormal; tableAbnormal];
% Pokretanje Classification Learner aplikacije

classificationLearner
% ?uvanje modela

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
% save all variables with model in their names in one file
save models.mat -regexp 'model'