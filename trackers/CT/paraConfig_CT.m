function para=paraConfig_CT(title)

para.lRate = 0.85;

%----------------------------------------------------------------
trparams.init_negnumtrain = 50;%number of trained negative samples
trparams.init_postrainrad = 4.0;%radical scope of positive samples

trparams.srchwinsz = 15;%20;% size of search window

%-------------------------
% feature parameters
% number of rectangle
ftrparams.minNumRect = 2;
ftrparams.maxNumRect = 4;

para.ftrparams=ftrparams;

para.trparams =trparams;

%-------------------------
para.M = 150;% number of all weaker classifiers, i.e,feature pool


% switch (title)    
% 
% end




