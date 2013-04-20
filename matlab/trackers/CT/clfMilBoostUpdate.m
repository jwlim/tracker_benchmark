function selector = clfMilBoostUpdate(posx,negx,M,NumSel)
%$:%   - Changed by Kaihua Zhang, on May 18th, 2011
% revised by Kaihua Zhang, on Dec 15th, 2011
% Utilize Matrix computation to improve efficiency
[row,numpos] = size(posx.feature);
[row,numneg] = size(negx.feature);
Hpos = zeros(M,numpos);
Hneg = zeros(M,numneg);
count = 1;
selector = zeros(1,NumSel);
likl = zeros(1,M);
%------------------------------------
% for s = 1:NumSel 
%      for m = 1:M          
%          if s>1
%             Pftr = [posx.pospred(selector(1:s-1),:)' posx.pospred(m,:)'];
%             Nftr = [negx.negpred(selector(1:s-1),:)' negx.negpred(m,:)'];
%          else
%             Pftr = posx.pospred(m,:)';%pospred 150x45
%             Nftr = negx.negpred(m,:)';%negpred 150x750   
%          end
%             Hp = Hpos+posx.pospred(m,:);%1x45
%             pf = sigmf(Hp,[-1 0]);
%             pll = 1-prod(pf);
%             poslikl = (1./(pll+eps)-1)*sum(sum((pf*Pftr).^2));
%           
%             Np = Hneg+negx.negpred(m,:);%1x45
%             nf = sigmf(Np,[-1 0]);
%             nll = 1-prod(nf);
%             neglikl= (1./(nll+eps)-1)*sum(sum((nf*Nftr).^2));             
% 
%             likl(m) = poslikl+neglikl;
%      end
% %--------------------------------------------------------------------------
%          [likAsc,ind] = sort(likl,2);           
%          for k=1:length(ind)
%              if ~sum(selector == ind(k))               
%                 selector(count) = ind(k);               
%                 count = count + 1;  
%                 break;           
%              end
%          end
%    
%          Hpos = Hpos + posx.pospred(selector(s),:);
%          Hneg = Hneg + negx.negpred(selector(s),:); 
% end

for s = 1:NumSel 

         if s>1
            Pftr = [posx.pospred(selector(1:s-1),:)' posx.pospred'];
            Nftr = [negx.negpred(selector(1:s-1),:)' negx.negpred'];
         else
            Pftr = posx.pospred';%pospred 150x45
            Nftr = negx.negpred';%negpred 150x750   
         end
            Hp = Hpos+posx.pospred;%1x45
            pf = sigmf(Hp,[-1 0]);
            pll = 1-prod(pf,2)';%1x150
            poslikl = (1./(pll+eps)-1)*((pf*Pftr).^2);
          
            Np = Hneg+negx.negpred;%1x45
            nf = sigmf(Np,[-1 0]);
            nll = 1-prod(nf,2)';
            neglikl = (1./(nll+eps)-1)*((nf*Nftr).^2);

            likl = poslikl(s:end)+neglikl(s:end);
%----------------------------------------------------------------------
         [likAsc,ind] = sort(likl,2,'descend');           
         for k=1:length(ind)
             if ~sum(selector == ind(k))               
                selector(count) = ind(k);               
                count = count + 1;  
                break;           
             end
         end
                  
        Hpos(selector(s),:) = Hpos(selector(s),:) + posx.pospred(selector(s),:);
        Hneg(selector(s),:) = Hneg(selector(s),:) + negx.negpred(selector(s),:);     
end