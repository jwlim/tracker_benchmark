function   [d, Do, a, e, xi, numIterOuter, numIterInner] = oria(currentImage,A,init_xi, para)

lambda = para.lambda;

inv_A=pinv(A);

I0=currentImage;
% I0x = imfilter( currentImage, (-fspecial('sobel')') / 8 );
% I0y = imfilter( currentImage,  -fspecial('sobel')   / 8 );
[I0x,I0y]=gradient(currentImage);

imgSize = para.canonicalImageSize ;

init_T = parameters_to_projective_matrix(para.transformType,init_xi);

%% start the main loop
T_ds = [ 0.5,   0, -0.5; ...
    0,   0.5, -0.5   ];
T_ds_hom = [ T_ds; [ 0 0 1 ]];

numIterOuter = 0 ;
numIterInner = 0 ;

iterNum = 0 ;  % iteration number of outer loop in each scale
converged = 0 ;
prevObj = inf ; % previous objective function value

T_in = init_T;

fr = [1 1          imgSize(2) imgSize(2) 1; ...
    1 imgSize(1) imgSize(1) 1          1; ...
    1 1          1          1          1 ];

frOrig = T_in * fr;

dim=imgSize(1)*imgSize(2);
e_old=zeros(dim,1);

d=[]; Do=[]; a=[]; e=[]; xi=[]; 
% tic % time counting start
while ~converged
    
    iterNum = iterNum + 1 ;
    numIterOuter = numIterOuter + 1 ;
    
    % transformed image and derivatives with respect to affine parameters
    Tfm = fliptform(maketform('projective',T_in'));
    %    imshow(imtransform(I0{scaleIndex,fileIndex}, Tfm,'bicubic','XData',[1 imgSize(2)],'YData',[1 imgSize(1)],'Size',imgSize),[])
    d   = vec(imtransform(I0, Tfm,'bicubic','XData',[1 imgSize(2)],'YData',[1 imgSize(1)],'Size',imgSize));
    Iu  = vec(imtransform(I0x,Tfm,'bicubic','XData',[1 imgSize(2)],'YData',[1 imgSize(1)],'Size',imgSize));
    Iv  = vec(imtransform(I0y,Tfm,'bicubic','XData',[1 imgSize(2)],'YData',[1 imgSize(1)],'Size',imgSize));

    norm_d=norm(d);
    
    if norm(d) < eps
        xi = [];
        break;
    end
    norm_d = norm_d+eps;
    Iu = (1/norm_d)*Iu - ( (d'*Iu)/norm_d^3 )*d ;
    Iv = (1/norm_d)*Iv - ( (d'*Iv)/norm_d^3 )*d ;

    d=preprocess(d,para.preprocessType);

    % transformation matrix to parameters
    xi = projective_matrix_to_parameters(para.transformType,T_in) ;
    
    % Compute Jacobian
    J = image_Jaco(Iu, Iv, imgSize, para.transformType, xi);
      
    % inner loop
    % -----------------------------------------------------------------
    % -----------------------------------------------------------------
    % using QR to orthogonalize the Jacobian matrix
    
    [Q, R] = qr(J,0);    
    
    [a, e, delta_xi, numIterInnerEach] = oria_inner(d, A,inv_A,Q,lambda, para.inner_tol, para.inner_maxIter);
    
    delta_xi = pinv(R)*delta_xi;
    
    % -----------------------------------------------------------------
    
    numIterInner = numIterInner + numIterInnerEach ;
    
    %         curObj = norm(e-e_old);
    curObj=norm(e,1);
    e_old = e;
    %         disp(['  Iter ' num2str(iterNum)]) ;
    %         disp(['previous objective function: ' num2str(prevObj) ]);
    %         disp([' current objective function: ' num2str(curObj) ]);
    
    % step in paramters
    
    xi = xi + delta_xi;
    T_in = parameters_to_projective_matrix(para.transformType,xi);
        
    if para.bSaveImage > 0
        
        figure(1); clf ;
        imshow(I0,[],'Border','tight');
        hold on;
        
        Tfm = fliptform(maketform('projective',inv(T_in')));
        curFrame = tformfwd(fr(1:2,:)', Tfm )';
        plot( frOrig(1,:),   frOrig(2,:),   'g-', 'LineWidth', 2 );
        plot( curFrame(1,:), curFrame(2,:), 'r-', 'LineWidth', 2 );
        %                 hold off;
        %                 print('-f1', '-dbmp', fullfile(destDir, num2str(i))) ;
    end
    
    if ( (abs(prevObj - curObj) < para.stoppingDelta) || iterNum >= para.maxIter )
        converged = 1;
        if ( abs(prevObj - curObj) >= para.stoppingDelta )
            disp('Maximum iterations reached') ;
        end
    else
        prevObj = curObj;
    end    
end

Tfm = fliptform(maketform('projective',T_in'));

Do   = vec(imtransform(I0, Tfm,'bicubic','XData',[1 imgSize(2)],'YData',[1 imgSize(1)],'Size',imgSize));

Do=preprocess(Do,para.preprocessType);





