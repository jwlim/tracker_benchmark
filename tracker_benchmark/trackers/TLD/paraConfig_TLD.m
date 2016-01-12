function opt=paraConfig_TLD(title)

min_win             = 24; % minimal size of the object's bounding box in the scanning grid, it may significantly influence speed of TLD, set it to minimal size of the object
patchsize           = [15 15]; % size of normalized patch in the object detector, larger sizes increase discriminability, must be square
fliplr              = 0; % if set to one, the model automatically learns mirrored versions of the object
maxbbox             = 1; % fraction of evaluated bounding boxes in every frame, maxbox = 0 means detector is truned off, if you don't care about speed set it to 1
update_detector     = 1; % online learning on/off, of 0 detector is trained only in the first frame and then remains fixed

opt.plot            = struct('pex',1,'nex',1,'dt',1,'confidence',1,'target',1,'replace',0,'drawoutput',3,'draw',0,'pts',1,'help', 0,'patch_rescale',1,'save',0); 

opt.model           = struct('min_win',min_win,'patchsize',patchsize,'fliplr',fliplr,'ncc_thesame',0.95,'valid',0.5,'num_trees',10,'num_features',13,'thr_fern',0.5,'thr_nn',0.65,'thr_nn_valid',0.7);
opt.p_par_init      = struct('num_closest',10,'num_warps',20,'noise',5,'angle',20,'shift',0.02,'scale',0.02); % synthesis of positive examples during initialization
opt.p_par_update    = struct('num_closest',10,'num_warps',10,'noise',5,'angle',10,'shift',0.02,'scale',0.02); % synthesis of positive examples during update
opt.n_par           = struct('overlap',0.2,'num_patches',100); % negative examples initialization/update
opt.tracker         = struct('occlusion',10);
opt.control         = struct('maxbbox',maxbbox,'update_detector',update_detector,'drop_img',1,'repeat',1);

opt.medFB_thred = 10; %for the function tldTracking


switch (title)    
    case 'skiing';        
        opt.model.min_win = 12;
    case 'carDark';  
        opt.model.min_win = 23;%[73,126,29,23]
    case 'car4';
        opt.medFB_thred = 15;
    case 'woman';
        opt.model.min_win = 21;%213	121	21	95
    case 'subway';
        opt.model.min_win = 19;%16	88	19	51
    case 'redteam';
        opt.model.min_win = 20;%198,85,35,20
    case 'crossing';
        opt.model.min_win = 17;%205	151	17	50
    case 'car14';
        opt.model.min_win = 19;
    case 'car15';
        opt.model.min_win = 16;
    case 'car24';
        opt.model.min_win = 21;
    case 'freeman3';
        opt.model.min_win = 12;
    case 'freeman4';
        opt.model.min_win = 15;
    case 'human1-1';
        opt.model.min_win = 16;
%     case 'human2-3';
%         opt.model.min_win = 17;
    case 'human3';
        opt.model.min_win = 17;
    case 'human4-1';
        opt.model.min_win = 21;
    case 'human4-2';
        opt.model.min_win = 19;
    case 'human5';
        opt.model.min_win = 9;
    case 'human6';
        opt.model.min_win = 13;
end




