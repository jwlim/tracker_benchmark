function kcf_params = get_KCF_params(st_tracker_params)


kernel.sigma = 0.5;
kernel.poly_a = 1;
kernel.poly_b = 9;
kernel.type = 'gaussian';
features.gray = false;
features.hog = true;
features.hog_orientations = 9;

kcf_params.kernel = kernel;
kcf_params.features = features;

kcf_params.interp_factor = st_tracker_params.interp_factor;
kcf_params.learning_rate = st_tracker_params.learning_rate;
kcf_params.cell_size = st_tracker_params.cell_size;
kcf_params.padding = st_tracker_params.padding;
kcf_params.output_sigma_factor = st_tracker_params.output_sigma_factor;
kcf_params.scale_sigma_factor = st_tracker_params.scale_sigma_factor;
kcf_params.lambda = st_tracker_params.lambda;
