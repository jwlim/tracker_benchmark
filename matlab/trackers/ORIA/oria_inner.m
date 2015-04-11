function [a_dual, e_dual, dt_dual, iter] = oria_inner(d,A,inv_A, J,lambda, tol, maxIter)

mu = 1.25/norm(d) ;
rho = 1.25;

% initialize
Y = d;

norm_two = norm(Y, 2);
norm_inf = norm( Y(:), inf) / lambda;
dual_norm = max(norm_two, norm_inf)+eps;
Y = Y / dual_norm;

d_norm = norm(d)+eps;

iter = 0;
converged = false;

m = length(d);
e_dual = zeros( m, 1);
a_dual = A(:,end);


% DISPLAY_EVERY = 10 ;
while ~converged
    iter = iter + 1;
    
    %Update xi
    temp_T = d - e_dual - a_dual + (1/mu)*Y;
    
    dt_dual =  - J'*temp_T;
    dt_dual_matrix = J*dt_dual;
    
    %Update e
    temp_T = d + dt_dual_matrix - a_dual + (1/mu)*Y;
    e_dual = sign(temp_T) .* pos( abs(temp_T) - lambda/mu );
    
    %Update x
    temp_T = d + dt_dual_matrix - e_dual + (1/mu)*Y;
    x=inv_A*temp_T;
    a_dual = A*x;
    
    Z = d + dt_dual_matrix - a_dual - e_dual;
    Y = Y + mu*Z;
    
    %     obj_v = d'*Y;
    
    mu = mu*rho;
    stoppingCriterion = norm(Z, 'fro') / d_norm;
    
    %     if mod( iter, DISPLAY_EVERY) == 0
    %         disp(['#Iteration ' num2str(iter) ' ||E||_0 ' num2str(length(find(abs(e_dual)>0)))...
    %             ' objvalue ' num2str(obj_v) '  Stopping Criterion ' ...
    %             num2str(stoppingCriterion)]);
    %     end
    
    
    if stoppingCriterion <= tol
        %         disp('RASL inner loop is converged at:');
        %         disp(['Iteration ' num2str(iter)  ' ||E||_0 ' num2str(length(find(abs(e_dual)>0)))  '  Stopping Criterion ' ...
        %             num2str(stoppingCriterion)]) ;
        converged = true ;
    end
    
    if ~converged && iter >= maxIter
        disp('Maximum iterations reached') ;
        converged = 1 ;
    end
end


