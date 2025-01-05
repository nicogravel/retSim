function [dist] = retDist(Zi,Zj)

ecc_a = Zi(2);
pol_a = Zi(1);

ecc_b = Zj(2);
pol_b = Zj(1);

dist = sqrt(ecc_a.^2 + ecc_b.^2 - 2.*ecc_a.*ecc_b.*cos(pol_a - pol_b))';

       
return
