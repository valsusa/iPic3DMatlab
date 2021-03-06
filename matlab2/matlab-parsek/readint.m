%addpath '/u/gianni/matlab/parsek/matlab-parsek'
%addpath '/home/gianni/matlab-parsek'
%addpath '/home/gianni/matlab/parsek/matlab-parsek'
addpath '/home/gianni/simulations/matlab2/matlab-parsek'

close all

global results_dir variable_list


variable_list='E B rho J pressure';
%variable_list='E B rho J';

parsek2D_select_pt1
parsek2D_select_pt2

skippa=1
if(skippa)
if(Ns>2) 
%Correct pressure for average drift
pxx=(pxx0+pxx2-(Jxs0+Jxs2).^2./(rhos0+rhos2))./qom(1);%./(rhos0+rhos2);
pxy=(pxy0+pxy2-(Jxs0+Jxs2).*(Jys0+Jys2)./(rhos0+rhos2))./qom(1);%./(rhos0+rhos2); 
pxz=(pxz0+pxz2-(Jxs0+Jxs2).*(Jzs0+Jzs2)./(rhos0+rhos2))./qom(1);%./(rhos0+rhos2); 

pyy=(pyy0+pyy2-(Jys0+Jys2).^2./(rhos0+rhos2))./qom(1);%./(rhos0+rhos2);
pyz=(pyz0+pyz2-(Jys0+Jys2).*(Jzs0+Jzs2)./(rhos0+rhos2))./qom(1);%./(rhos0+rhos2); 

pzz=(pzz0+pzz2-(Jzs0+Jzs2).^2./(rhos0+rhos2))./qom(1);%./(rhos0+rhos2);

else

pxx=(pxx0-Jxs0.^2./rhos0)./qom(1);%./(rhos0);
pxy=(pxy0-Jxs0.*Jys0./rhos0)./qom(1);%./(rhos0); 
pxz=(pxz0-Jxs0.*Jzs0./rhos0)./qom(1);%./(rhos0); 

pyy=(pyy0-Jys0.^2./rhos0)./qom(1);%./(rhos0);
pyz=(pyz0-Jys0.*Jzs0./rhos0)./qom(1);%./(rhos0); 

pzz=(pzz0-Jzs0.^2./rhos0)./qom(1);%./(rhos0);
end

end

skippa=1
if(skippa)
%Correct pressure for average drift
if(Ns>2) 
pxxi=(pxx1+pxx3-(Jxs1+Jxs3).^2./(rhos1+rhos3))./qom(2);%./(rhos1+rhos3);
pxyi=(pxy1+pxy3-(Jxs1+Jxs3).*(Jys1+Jys3)./(rhos1+rhos3))./qom(2);%./(rhos1+rhos3); 
pxzi=(pxz1+pxz3-(Jxs1+Jxs3).*(Jzs1+Jzs3)./(rhos1+rhos3))./qom(2);%./(rhos1+rhos3); 

pyyi=(pyy1+pyy3-(Jys1+Jys3).^2./(rhos1+rhos3))./qom(2);%./(rhos1+rhos3);
pyzi=(pyz1+pyz3-(Jys1+Jys3).*(Jzs1+Jzs3)./(rhos1+rhos3))./qom(2);%./(rhos1+rhos3); 

pzzi=(pzz1+pzz3-(Jzs1+Jzs3).^2./(rhos1+rhos3))./qom(2);%./(rhos1+rhos3);

else

pxxi=(pxx1-Jxs1.^2./rhos1)./qom(2);%./(rhos1);
pxyi=(pxy1-Jxs1.*Jys1./rhos1)./qom(2);%./(rhos1); 
pxzi=(pxz1-Jxs1.*Jzs1./rhos1)./qom(2);%./(rhos1); 

pyyi=(pyy1-Jys1.^2./rhos1)./qom(2);%./(rhos1);
pyzi=(pyz1-Jys1.*Jzs1./rhos1)./qom(2);%./(rhos1); 

pzzi=(pzz1-Jzs1.^2./rhos1)./qom(2);%./(rhos1);

end 
end


wci=max([Bx0 By0 Bz0])
L=1

[nx ny nt]=size(Bx);

it=nt

iy=2;

vthe=uth(1)
vthi=uth(2)
va=wci;

time=double(Bx_time)*wci*Dt;
