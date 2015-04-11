function basis=genBasis(I0,init_xi,num,imgSize,transformType,preprocessType)

basis=zeros(imgSize(1)*imgSize(2),num);
sigma=[0.01;0.001;0.3;0.001;0.01;0.3];

T_in = parameters_to_projective_matrix(transformType,init_xi);
Tfm = fliptform(maketform('projective',T_in'));
basis(:,1)=vec(imtransform(I0, Tfm,'bicubic','XData',[1 imgSize(2)],'YData',[1 imgSize(1)],'Size',imgSize));
basis(:,1)=preprocess(basis(:,1),preprocessType);
    
for i=2:num
    xi=init_xi+randn(length(init_xi),1).*sigma;
    T_in = parameters_to_projective_matrix(transformType,xi);
    Tfm = fliptform(maketform('projective',T_in'));
    basis(:,i)=vec(imtransform(I0, Tfm,'bicubic','XData',[1 imgSize(2)],'YData',[1 imgSize(1)],'Size',imgSize));
    basis(:,i)=preprocess(basis(:,i),preprocessType);
end