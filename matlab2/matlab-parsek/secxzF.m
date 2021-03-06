
aver=0;

recon=[];
tslice=[];

indexf=indexg
%for it=1:round(nt/10):nt
for it=1:nt

EdotJT=0;
EdotJparT=0;
EdotJperp1T=0;
EdotJperp2T=0;

for species=1:2
    
if (species==1) 
campi_electron
limits
else
campi_ion
limits_ion
end

[xx yy]=meshgrid(1:ny,1:nx);

xx=xx/ny*Lx;
yy=yy/nx*Ly;
ay=vecpot(xx,yy,bbx,bby);

deln= double(rrho+rrhob) - spatial_smooth(double(rrho+rrhob),.5);
delex = double(eex) - spatial_smooth(double(eex),.5);
deley = double(eey) - spatial_smooth(double(eey),.5);
delez = double(eez) - spatial_smooth(double(eez),.5);
delbx = double(bbx) - spatial_smooth(double(bbx),.5);
delby = double(bby) - spatial_smooth(double(bby),.5);
delbz = double(bbz) - spatial_smooth(double(bbz),.5);
deljx = double(jsx0+jsxb) - spatial_smooth(double(jsx0+jsxb),.5);
deljy = double(jsy0+jsyb) - spatial_smooth(double(jsy0+jsyb),.5);
deljz = double(jsz0+jszb) - spatial_smooth(double(jsz0+jszb),.5);
delvdelvx = (vdelvx - spatial_smooth(double(vdelvx),.5))./qom(1);
delvdelvy = (vdelvy - spatial_smooth(double(vdelvy),.5))./qom(1);
delvdelvz = (vdelvz - spatial_smooth(double(vdelvz),.5))./qom(1);

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,deln.*delex,ay,'x/d_i','y/d_i',['\delta \rho \delta E_x (\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',[num2str(species,'%1.1i') 'Ffilm1/' num2str(indexf,'%8.8i')])
saveas(gcf,[num2str(species,'%1.1i') 'Ffilm1/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,deln.*deley,ay,'x/d_i','y/d_i',['\delta \rho \delta E_y (\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',[num2str(species,'%1.1i') 'Ffilm2/' num2str(indexf,'%8.8i')])
saveas(gcf,[num2str(species,'%1.1i') 'Ffilm2/' num2str(indexf,'%8.8i') '.fig'])
close all


disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,deln.*delez,ay,'x/d_i','y/d_i',['\delta \rho \delta E_z (\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',[num2str(species,'%1.1i') 'Ffilm3/' num2str(indexf,'%8.8i')])
saveas(gcf,[num2str(species,'%1.1i') 'Ffilm3/' num2str(indexf,'%8.8i') '.fig'])
close all



disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,deljy.*delbz-deljz.*delby,ay,'x/d_i','y/d_i',['(\delta J \times \delta B)_x(\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',[num2str(species,'%1.1i') 'Ffilm4/' num2str(indexf,'%8.8i')])
saveas(gcf,[num2str(species,'%1.1i') 'Ffilm4/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,-deljx.*delbz+deljz.*delbx,ay,'x/d_i','y/d_i',['(\delta J \times \delta B)_y(\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',[num2str(species,'%1.1i') 'Ffilm5/' num2str(indexf,'%8.8i')])
saveas(gcf,[num2str(species,'%1.1i') 'Ffilm5/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,deljx.*delby-deljy.*delbx,ay,'x/d_i','y/d_i',['(\delta J \times \delta B)_z(\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',[num2str(species,'%1.1i') 'Ffilm6/' num2str(indexf,'%8.8i')])
saveas(gcf,[num2str(species,'%1.1i') 'Ffilm6/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,deln.*delvdelvx,ay,'x/d_i','y/d_i',['\delta n  \delta (v \cdot \nabla v)_x(\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',[num2str(species,'%1.1i') 'Ffilm7/' num2str(indexf,'%8.8i')])
saveas(gcf,[num2str(species,'%1.1i') 'Ffilm7/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,deln.*delvdelvy,ay,'x/d_i','y/d_i',['\delta n  \delta (v \cdot \nabla v)_y(\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',[num2str(species,'%1.1i') 'Ffilm8/' num2str(indexf,'%8.8i')])
saveas(gcf,[num2str(species,'%1.1i') 'Ffilm8/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,deln.*delvdelvz,ay,'x/d_i','y/d_i',['\delta n  \delta (v \cdot \nabla v)_z(\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',[num2str(species,'%1.1i') 'Ffilm9/' num2str(indexf,'%8.8i')])
saveas(gcf,[num2str(species,'%1.1i') 'Ffilm9/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,EdotJ,ay,'x/d_i','y/d_i',['E \cdot J (\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',[num2str(species,'%1.1i') 'Ffilm10/' num2str(indexf,'%8.8i')])
saveas(gcf,[num2str(species,'%1.1i') 'Ffilm10/' num2str(indexf,'%8.8i') '.fig'])
close all

EdotJT=EdotJT+EdotJ;
EdotJparT=EdotJparT+EdotJpar;
EdotJperp1T=EdotJperp1T+EdotJperp1;
EdotJperp2T=EdotJperp2T+EdotJperp2;

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,EdotJpar,ay,'x/d_i','y/d_i',['(E \cdot J)_{||} (\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',[num2str(species,'%1.1i') 'Ffilm11/' num2str(indexf,'%8.8i')])
saveas(gcf,[num2str(species,'%1.1i') 'Ffilm11/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,EdotJperp1,ay,'x/d_i','y/d_i',['(E \cdot J)_{perp1} (\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',[num2str(species,'%1.1i') 'Ffilm12/' num2str(indexf,'%8.8i')])
saveas(gcf,[num2str(species,'%1.1i') 'Ffilm12/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,EdotJperp2,ay,'x/d_i','y/d_i',['(E \cdot J)_{perp2} (\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',[num2str(species,'%1.1i') 'Ffilm13/' num2str(indexf,'%8.8i')])
saveas(gcf,[num2str(species,'%1.1i') 'Ffilm13/' num2str(indexf,'%8.8i') '.fig'])
close all

end

limits_ion

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,EdotJT,ay,'x/d_i','y/d_i',['E \cdot J_T (\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',['Ffilm10/' num2str(indexf,'%8.8i')])
saveas(gcf,['Ffilm10/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,EdotJparT,ay,'x/d_i','y/d_i',['(E \cdot J)_{||T} (\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',['Ffilm11/' num2str(indexf,'%8.8i')])
saveas(gcf,['Ffilm11/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,EdotJperp1T,ay,'x/d_i','y/d_i',['(E \cdot J)_{perp1,T} (\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',['Ffilm12/' num2str(indexf,'%8.8i')])
saveas(gcf,['Ffilm12/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,EdotJperp2T,ay,'x/d_i','y/d_i',['(E \cdot J)_{perp2,T} (\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',['Ffilm13/' num2str(indexf,'%8.8i')])
saveas(gcf,['Ffilm13/' num2str(indexf,'%8.8i') '.fig'])
close all

campi_mix
limits

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,EdotJtot,ay,'x/d_i','y/d_i',['(E \cdot J)_{tot} (\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',['Ffilm14/' num2str(indexf,'%8.8i')])
saveas(gcf,['Ffilm14/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,EpdotJp,ay,'x/d_i','y/d_i',['(E^\prime \cdot J^\prime) (\omega_{ci}t=' num2str(time(it)) ')'],lmt)
set(gcf, 'Renderer', 'zbuffer');
print('-dpng',['Ffilm15/' num2str(indexf,'%8.8i')])
saveas(gcf,['Ffilm15/' num2str(indexf,'%8.8i') '.fig'])
close all

indexf=indexf+1

end

