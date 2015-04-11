function [particles_geo, candidates] = sampling(pre_result, numsample, affsig)
particles_geo = repmat(affparam2geom(pre_result(:)), [1,numsample]);
randomnum = randn(6,numsample);
particles_geo = particles_geo + (randomnum).*repmat(affsig(:),[1,numsample]);%按照事先设定的affsig



