function A=updateTemplates(A, Do, e, index)

if index<=10
    A(:,index)=Do;
elseif (index >10 && index <= 101)% & norm(e,1)>10
    A=[A Do];
elseif index > 101% & norm(e,1)>10
%     A(:, mod(index-1,100-30)+2+30) = Do;
    A(:, mod(index-1,100)+2) = Do;
end




    
%     if norm(e,1)>10
%         A=[A Do];
%     end