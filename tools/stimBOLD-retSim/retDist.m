function [dist] = retDist(Zi,Zj)
% for i = 1 : size(D,1)
%     for j = 1 : size(D,1)
%         D(i,j) = sqrt(ecc(i).^2 + ecc(j).^2 - 2.*ecc(i).*ecc(j).*cos(pol(i) - pol(j)))';
%     end
% end

ecc_a = Zi(1);
pol_a = wrapTo2Pi(Zi(2));

ecc_b = Zj(1);
pol_b = wrapTo2Pi(Zj(2));

dist = sqrt(ecc_a.^2 + ecc_b.^2 - 2.*ecc_a.*ecc_b.*cos(pol_a - pol_b))';

        
% for i = 1 : size(D,1)
%     for j = 1 : size(D,1)
%         dist(i,j) = sqrt(ecc_a.^2 + ecc_b.^2 - 2.*ecc_a.*ecc_b.*cos(pol_a - pol_b))';
%     end
% end

return
