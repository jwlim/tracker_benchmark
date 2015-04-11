function [samples init_T]= init(img, objRect, numBasis, szBasis, refPts, transformType, preprocessType)

% init_T = [1,0,objRect(1);0,1,objRect(2)];
points=[objRect(1),objRect(1)+objRect(3)-1;objRect(2),objRect(2)];
init_T = TwoPointSimilarity( refPts, points(:,1:2) );
    
sampleNum = numBasis;
imgSize = szBasis; 
% %% prepare templates geometric parameters
% if numBasis == 10
% r{1} = objRect;
% r{2} = objRect + [-1;-1;0;0];
% r{3} = objRect + [-1;0;0;0];
% r{4} = objRect + [-1;1;0;0];
% r{5} = objRect + [0;-1;0;0];
% r{6} = objRect + [0;1;0;0];
% r{7} = objRect + [1;-1;0;0];
% r{8} = objRect + [1;0;0;0];
% r{9} = objRect + [1;1;0;0];
% r{10} = objRect + [2;0;0;0];
% elseif numBasis == 1
%     r{1} = objRect;
% end
% %% Initializating templates and image
% samples	= zeros(prod(szBasis), sampleNum);
% 
% %% cropping and normalizing templates
% for n=1:sampleNum
%     rect = r{n};
%     %if paraT.typeSample=0, the sample is not normalized
%     imgPatch = img(rect(2):rect(2)+rect(4)-1, rect(1):rect(1)+rect(3)-1);
% %     imwrite(uint8(imgPatch), [num2str(n) '_Basis.png']);
%     imgPatch = imresize(imgPatch, szBasis);
% %     imwrite(uint8(imgPatch), [num2str(n) '_BasisSmall.png']);
%     samples(:,n) =  imgPatch(:);   
% end
% 
% samples=preprocess(samples,preprocessType);



init_xi = projective_matrix_to_parameters( transformType, init_T);

basis	= zeros(prod(szBasis), sampleNum);
% basis=zeros(imgSize(1)*imgSize(2),num);
sigma=[0.01;0.001;0.3;0.001;0.01;0.3];

T_in = parameters_to_projective_matrix(transformType,init_xi);
Tfm = fliptform(maketform('projective',T_in'));
basis(:,1)=vec(imtransform(img, Tfm,'bicubic','XData',[1 imgSize(2)],'YData',[1 imgSize(1)],'Size',imgSize));
% basis(:,1)=preprocess(basis(:,1),preprocessType);
    
for i=2:numBasis
    xi=init_xi+randn(length(init_xi),1).*sigma(length(init_xi),1);
    T_in = parameters_to_projective_matrix(transformType,xi);
    Tfm = fliptform(maketform('projective',T_in'));
    basis(:,i)=vec(imtransform(img, Tfm,'bicubic','XData',[1 imgSize(2)],'YData',[1 imgSize(1)],'Size',imgSize));
%     basis(:,i)=preprocess(basis(:,i),preprocessType);
end
samples=preprocess(basis,preprocessType);
