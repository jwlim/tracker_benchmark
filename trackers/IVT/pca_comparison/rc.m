% Run the comparison 100 times
%
% Author: David Ross, May 2007
% $Id: rc.m,v 1.1 2007-05-25 16:28:18 dross Exp $

N = 100;
times_pca = zeros(1,N);
times_hall = zeros(1,N);
times_ivt = zeros(1,N);
% profile on
for counter = 1:N
    run_comparison;
    times_pca(counter) = runtime_pca;
    times_hall(counter) = runtime_hall;
    times_ivt(counter) = runtime_ivt;
end
% profreport

descstat(times_hall ./ times_ivt)

