% Make ver 1.1 sequence configs.
%
% http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/
%
% Biker Bird1 BlurBody BlurCar2 BlurFace BlurOwl Car1 Crowds Diving Dragonbaby Human3 Human4.2 Human6 Human9 Jump Panda Redteam
% Biker Bird1 BlurBody BlurCar2 BlurFace BlurOwl Car1 Crowds Diving Dragonbaby Human3 Human4 Human6 Human9 Jump Panda Redteam


SaveSequenceConfig('Biker', 'img/%04d.jpg', '1:142', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Biker.zip', {'OPR', 'SV', 'OCC', 'MB', 'FM', 'OV', 'LR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Bird1', 'img/%04d.jpg', '1:408', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Bird1.zip', {'DEF', 'FM', 'OV'}, 'groundtruth_rect.txt');
SaveSequenceConfig('BlurBody', 'img/%04d.jpg', '1:334', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/BlurBody.zip', {'SV', 'DEF', 'MB', 'FM', 'IPR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('BlurCar2', 'img/%04d.jpg', '1:585', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/BlurCar2.zip', {'SV', 'MB', 'FM'}, 'groundtruth_rect.txt');
SaveSequenceConfig('BlurFace', 'img/%04d.jpg', '1:493', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/BlurFace.zip', {'MB', 'FM', 'IPR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('BlurOwl', 'img/%04d.jpg', '1:631', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/BlurOwl.zip', {'SV', 'MB', 'FM', 'IPR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Car1', 'img/%04d.jpg', '1:1020', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Car1.zip', {'IV', 'SV', 'BC', 'LR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Crowds', 'img/%04d.jpg', '1:347', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Crowds.zip', {'IV', 'DEF', 'BC'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Diving', 'img/%04d.jpg', '1:215', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Diving.zip', {'SV', 'DEF', 'IPR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('DragonBaby', 'img/%04d.jpg', '1:113', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/DragonBaby.zip', {'OPR', 'SV', 'OCC', 'MB', 'FM', 'IPR', 'OV'}, 'groundtruth_rect.txt');

SaveSequenceConfig('Human3', 'img/%04d.jpg', '1:1698', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Human3.zip', {'OPR', 'SV', 'OCC', 'DEF', 'BC'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Human4.2', 'img/%04d.jpg', '1:667', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Human4.zip', {'IV', 'SV', 'OCC', 'DEF'}, 'groundtruth_rect.2.txt');
SaveSequenceConfig('Human6', 'img/%04d.jpg', '1:792', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Human6.zip', {'OPR', 'SV', 'OCC', 'DEF', 'FM', 'OV'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Human9', 'img/%04d.jpg', '1:305', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Human9.zip', {'IV', 'SV', 'DEF', 'MB', 'FM'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Jump', 'img/%04d.jpg', '1:122', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Jump.zip', {'OPR', 'SV', 'OCC', 'DEF', 'MB', 'IPR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Panda', 'img/%04d.jpg', '1:1000', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Panda.zip', {'OPR', 'SV', 'OCC', 'DEF', 'IPR', 'OV', 'LR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('RedTeam', 'img/%04d.jpg', '1:1918', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/RedTeam.zip', {'OPR', 'SV', 'OCC', 'IPR', 'LR'}, 'groundtruth_rect.txt');

SaveSequenceConfig('Board', 'img/%04d.jpg', '1:698', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Board.zip', {'OPR', 'SV', 'MB', 'FM', 'OV', 'BC'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Box', 'img/%04d.jpg', '1:1161', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Box.zip', {'IV', 'OPR', 'SV', 'OCC', 'MB', 'IPR', 'OV', 'BC'}, 'groundtruth_rect.txt');
SaveSequenceConfig('ClifBar', 'img/%04d.jpg', '1:472', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/ClifBar.zip', {'SV', 'OCC', 'MB', 'FM', 'IPR', 'OV', 'BC'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Rubik', 'img/%04d.jpg', '1:1997', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Rubik.zip', {'OPR', 'SV', 'OCC', 'IPR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Skating2.1', 'img/%04d.jpg', '1:473', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Skating2.zip', {'OPR', 'SV', 'OCC', 'DEF', 'FM'}, 'groundtruth_rect.1.txt');
SaveSequenceConfig('Skating2.2', 'img/%04d.jpg', '1:473', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Skating2.zip', {'OPR', 'SV', 'OCC', 'DEF', 'FM'}, 'groundtruth_rect.2.txt');
SaveSequenceConfig('Surfer', 'img/%04d.jpg', '1:376', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Surfer.zip', {'OPR', 'SV', 'FM', 'IPR', 'LR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Toy', 'img/%04d.jpg', '1:271', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Toy.zip', {'OPR', 'SV', 'FM', 'IPR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Twinning', 'img/%04d.jpg', '1:472', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Twinning.zip', {'OPR', 'SV'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Vase', 'img/%04d.jpg', '1:271', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Vase.zip', {'SV', 'FM', 'IPR'}, 'groundtruth_rect.txt');

SaveSequenceConfig('Twinnings', 'img/%04d.jpg', '1:472', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Twinnings.zip', {'OPR', 'SV'}, 'groundtruth_rect.txt');

%% dummy

SaveSequenceConfig('Bird2', 'img/%04d.jpg', '1:99', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Bird2.zip', {'OPR', 'OCC', 'DEF', 'FM', 'IPR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('BlurCar1', 'img/%04d.jpg', '1:742', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/BlurCar1.zip', {'MB', 'FM'}, 'groundtruth_rect.txt');
SaveSequenceConfig('BlurCar3', 'img/%04d.jpg', '1:357', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/BlurCar3.zip', {'MB', 'FM'}, 'groundtruth_rect.txt');
SaveSequenceConfig('BlurCar4', 'img/%04d.jpg', '1:380', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/BlurCar4.zip', {'MB', 'FM'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Bolt2', 'img/%04d.jpg', '1:293', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Bolt2.zip', {'DEF', 'BC'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Car2', 'img/%04d.jpg', '1:913', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Car2.zip', {'IV', 'BC'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Car24', 'img/%04d.jpg', '1:3059', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Car24.zip', {'IV', 'SV', 'BC'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Coupon', 'img/%04d.jpg', '1:327', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Coupon.zip', {'OCC', 'BC'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Dancer', 'img/%04d.jpg', '1:225', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Dancer.zip', {'OPR', 'SV', 'DEF', 'IPR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Dancer2', 'img/%04d.jpg', '1:150', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Dancer2.zip', {'DEF'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Dog', 'img/%04d.jpg', '1:127', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Dog.zip', {'OPR', 'SV', 'DEF'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Girl2', 'img/%04d.jpg', '1:1500', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Girl2.zip', {'OPR', 'SV', 'OCC', 'DEF', 'MB'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Gym', 'img/%04d.jpg', '1:767', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Gym.zip', {'OPR', 'SV', 'DEF', 'IPR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Human2', 'img/%04d.jpg', '1:1128', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Human2.zip', {'IV', 'OPR', 'SV', 'MB'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Human5', 'img/%04d.jpg', '1:713', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Human5.zip', {'SV', 'OCC', 'DEF'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Human7', 'img/%04d.jpg', '1:250', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Human7.zip', {'IV', 'SV', 'OCC', 'DEF', 'MB', 'FM'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Human8', 'img/%04d.jpg', '1:128', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Human8.zip', {'IV', 'SV', 'DEF'}, 'groundtruth_rect.txt');
SaveSequenceConfig('KiteSurf', 'img/%04d.jpg', '1:84', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/KiteSurf.zip', {'IV', 'OPR', 'OCC', 'IPR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Man', 'img/%04d.jpg', '1:134', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Man.zip', {'IV'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Skater', 'img/%04d.jpg', '1:160', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Skater.zip', {'OPR', 'SV', 'DEF', 'IPR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Skater2', 'img/%04d.jpg', '1:435', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Skater2.zip', {'OPR', 'SV', 'DEF', 'FM', 'IPR'}, 'groundtruth_rect.txt');
SaveSequenceConfig('Trans', 'img/%04d.jpg', '1:124', 'http://cvlab.hanyang.ac.kr/tracker_benchmark/seq/Trans.zip', {'IV', 'SV', 'OCC', 'DEF'}, 'groundtruth_rect.txt');
