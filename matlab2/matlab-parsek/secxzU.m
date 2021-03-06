
aver=0;

recon=[];
tslice=[];

indexf=indexg
%for it=1:round(nt/10):nt
for it=1:nt
    
campi_electron

[xx yy]=meshgrid(1:ny,1:nx);

xx=xx/ny*Lx;
yy=yy/nx*Ly;
ay=vecpot(xx,yy,bbx,bby);

limits

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,upar,ay,'x/d_i','y/d_i',['u_{e||}(\omega_{ci}t=' num2str(time(it)) ')'],lmt)
%F1(indexf)=getframe(gcf);
set(gcf, 'Renderer', 'zbuffer');
%set(gcf,'fontsize',18)
print('-dpng',['Ufilm1/' num2str(indexf,'%8.8i')])
saveas(gcf,['Ufilm1/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,uperp,ay,'x/d_i','y/d_i',['u_{e\perp}(\omega_{ci}t=' num2str(time(it)) ')'],lmt)
%F1(indexf)=getframe(gcf);
set(gcf, 'Renderer', 'zbuffer');
%set(gcf,'fontsize',18)
print('-dpng',['Ufilm2/' num2str(indexf,'%8.8i')])
saveas(gcf,['Ufilm2/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,uperpx,ay,'x/d_i','y/d_i',['u_{e\perp,x}(\omega_{ci}t=' num2str(time(it)) ')'],lmt)
%F1(indexf)=getframe(gcf);
set(gcf, 'Renderer', 'zbuffer');
%set(gcf,'fontsize',18)
print('-dpng',['Ufilm3/' num2str(indexf,'%8.8i')])
saveas(gcf,['Ufilm3/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,uperpy,ay,'x/d_i','y/d_i',['u_{e\perp,y}(\omega_{ci}t=' num2str(time(it)) ')'],lmt)
%F1(indexf)=getframe(gcf);
set(gcf, 'Renderer', 'zbuffer');
%set(gcf,'fontsize',18)
print('-dpng',['Ufilm4/' num2str(indexf,'%8.8i')])
saveas(gcf,['Ufilm4/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,uperpz,ay,'x/d_i','y/d_i',['u_{e\perp,z}(\omega_{ci}t=' num2str(time(it)) ')'],lmt)
%F1(indexf)=getframe(gcf);
set(gcf, 'Renderer', 'zbuffer');
%set(gcf,'fontsize',18)
print('-dpng',['Ufilm5/' num2str(indexf,'%8.8i')])
saveas(gcf,['Ufilm5/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,ohmz,ay,'x/d_i','y/d_i',['(E+u_{e}\times B)_z(\omega_{ci}t=' num2str(time(it)) ')'],lmt)
%F1(indexf)=getframe(gcf);
set(gcf, 'Renderer', 'zbuffer');
%set(gcf,'fontsize',18)
print('-dpng',['Ufilm6/' num2str(indexf,'%8.8i')])
saveas(gcf,['Ufilm6/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,ohmy,ay,'x/d_i','y/d_i',['(E+u_{e}\times B)_y(\omega_{ci}t=' num2str(time(it)) ')'],lmt)
%F1(indexf)=getframe(gcf);
set(gcf, 'Renderer', 'zbuffer');
%set(gcf,'fontsize',18)
print('-dpng',['Ufilm7/' num2str(indexf,'%8.8i')])
saveas(gcf,['Ufilm7/' num2str(indexf,'%8.8i') '.fig'])
close all

disp('f1')
h=figure(1);
set(h,'Position' , [5 5 560 420]);
coplot(xx,yy,ohmx,ay,'x/d_i','y/d_i',['(E+u_{e}\times B)_x(\omega_{ci}t=' num2str(time(it)) ')'],lmt)
%F1(indexf)=getframe(gcf);
set(gcf, 'Renderer', 'zbuffer');
%set(gcf,'fontsize',18)
print('-dpng',['Ufilm8/' num2str(indexf,'%8.8i')])
saveas(gcf,['Ufilm8/' num2str(indexf,'%8.8i') '.fig'])
close all

indexf=indexf+1


end

return
