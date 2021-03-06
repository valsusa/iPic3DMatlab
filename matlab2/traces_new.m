addpath 'matlab-parsek'

close all
clear all

%results_dir='/www/shared/gianni/run99b/';
results_dir='/shared/gianni/laila11b/';
%results_dir='/shared/gianni/run100.2/';

filename=[results_dir 'settings.hdf']
Lx=hdf5read(filename,'/collective/Lx')
Ly=hdf5read(filename,'/collective/Ly')
B0x=hdf5read(filename,'/collective/B0x')
Dt=hdf5read(filename,'/collective/Dt')
XLEN=hdf5read(filename,'/topology/XLEN')
YLEN=hdf5read(filename,'/topology/YLEN')
Nprocs=hdf5read(filename,'/topology/Nprocs')
mr=abs(hdf5read(filename,'/collective/species_0/qom'))
vthr=hdf5read(filename,'/collective/species_0/uth');

ipx=XLEN/2+6;
ipy=YLEN/2+1;
ip=(ipx-1)*YLEN+ipy;

nome=[results_dir 'VirtualSatelliteTraces' num2str(ip) '.txt']
system(['gunzip ' nome])

fid=fopen(nome);
for i=1:16
x=fscanf(fid,'%f',2); 
xp(i)=x(1)-0*Lx/2;
yp(i)=x(2)-0*Ly/2;
end


a=fscanf(fid,'%f',[14 inf])';

fclose(fid);
skip=0;
bx=a(:,1+skip);
by=a(:,2+skip);
bz=a(:,3+skip);
ex=a(:,4+skip);
ey=a(:,5+skip);
ez=a(:,6+skip);
jxe=a(:,7+skip);
jye=a(:,8+skip);
jze=a(:,9+skip);
jxi=a(:,10+skip);
jyi=a(:,11+skip);
jzi=a(:,12+skip);
rhoe=a(:,13+skip)*4*pi;
rhoi=a(:,14+skip)*4*pi;

n0=mean(rhoi-rhoe)/2;
b0=sqrt(mean(bx.^2+by.^2+bz.^2));
wci=b0;
wpi=1*sqrt(n0);
wpe=wpi*sqrt(mr);
wce=wci*mr;
wlh=1/sqrt(1/wce/wci+1/wpi^2);
%wpi=1 %apparently the plasma oscillations are generated elsewhere where n0=1
wRcut=.5*(wce+sqrt(wce^2+4*wpe^2));
wLcut=.5*(-wce+sqrt(wce^2+4*wpe^2));

[n m]=size(bx);
bx=reshape(bx,16,n/16);
by=reshape(by,16,n/16);
bz=reshape(bz,16,n/16);
ex=reshape(ex,16,n/16);
ey=reshape(ey,16,n/16);
ez=reshape(ez,16,n/16);
t=linspace(0,100,n/16)*Dt*wci;
b=sqrt(bx.*bx+by.*by+bz.*bz);
epar=(ex.*bx+ey.*by+ez.*bz)./b;

%h=figure(1);
%%set(h,'Position' , [5 5 560 820]);
%plot(t,ex,'b',t,ey,'r',t,ez,'g')
%ylabel('B')
%    %title(['x=' num2str(xp(ix,iy) '  y=' num2str(yp2) '   blue=x, red=y green=z (not GSM)']) 

ez=ez(:,1:end/2);
ey=ey(:,1:end/2);
epar=epar(:,1:end/2);
by=by(:,1:end/2+1);by=diff(by,[],2)/Dt;
n=max(size(ez));

NFFT=n;
w=hamming(NFFT);
t=wci*(0:NFFT-1)*Dt;
T=max(t);
Fs=2*pi/T;
%The FFT already has the 2pi, so f is really omega, the circular frequency
f = Fs*(0:ceil(NFFT/2));

eavg=ez;
for i=2:n
eavg(:,i)=ez(:,i)*.01+eavg(:,i-1)*.99;
end

eyavg=ey;
for i=2:n
eyavg(:,i)=ey(:,i)*.01+eyavg(:,i-1)*.99;
end

byavg=by;
for i=2:n
byavg(:,i)=by(:,i)*.01+byavg(:,i-1)*.99;
end

faisvd=0
if(faisvd)
[u,s,v]=svd(ez');
end
%plot(u(:,1)*s(1,1)*max(v(1,:)))
%title('topos')

figure(1)
subplot(2,1,1)
if(faisvd)
plot(t,eavg(1,:), t,u(:,1)*s(1,1)*max(v(1,:)),'r')
title(['xsat=' num2str(p(1)) '  ysat=',num2str(yp(1))])
else
plot(t,eavg(1:3,:),'b', t,eavg(9:11,:),'r')
title(['xsat=' num2str(max(xp(:))) ', ' num2str(min(xp(:))) '  ysat=',num2str(yp(1)) ', ' num2str(yp(9)) ])
end
ylabel('Ez')
xlabel('\omega_{ci}t')
subplot(2,1,2)
plot(t,ez-eavg)
ylabel('Ez')
xlabel('\omega_{ci}t')
set(gcf,'Renderer','zbuffer')
print('-dpng','fig1.png')


if(faisvd)
[u,s,v]=svd(ez');
end

			
			figure(10)
			subplot(2,1,1)
			if(faisvd)
			plot(t,eyavg(1,:), t,u(:,1)*s(1,1)*max(v(1,:)),'r')
			title(['xsat=' num2str(xp(1)) '  ysat=',num2str(yp(1))])
			else
			plot(t,eyavg(1:3,:),'b', t,eyavg(9:11,:),'r')
			title(['xsat=' num2str(xp(1)) ', ' num2str(xp(9)) '  ysat=',num2str(yp(1)) ', ' num2str(yp(9)) ])
			end
			ylabel('Ey')
			xlabel('\omega_{ci}t')
			subplot(2,1,2)
			plot(t,ey-eyavg)
			ylabel('Ey')
			xlabel('\omega_{ci}t')
			set(gcf,'Renderer','zbuffer')
			print('-dpng','fig10.png')			

if(faisvd)
[u,s,v]=svd(by');
end

%byavg=u(:,1)*s(1,1)*v(1,:);byavg=byavg';



figure(2)
subplot(2,1,1)
if(faisvd)
plot(t,byavg(1,:), t,u(:,1)*s(1,1)*max(v(1,:)),'r')
title(['xsat=' num2str(xp(1)) '  ysat=',num2str(yp(1))])
else
plot(t,byavg(1:3,:), 'b',t,byavg(9:11,:),'r')
title(['xsat=' num2str(xp(1)) ', ' num2str(xp(9)) '  ysat=',num2str(yp(1)) ', ' num2str(yp(9)) ])
end
ylabel('dBy/dt')
xlabel('\omega_{ci}t')
subplot(2,1,2)
plot(t,by-byavg)
ylabel('dBy/dt')
xlabel('\omega_{ci}t')
set(gcf,'Renderer','zbuffer')
print('-dpng','fig2.png')

figure(3)
%subplot(2,1,1)
y=zeros(size(ez));
for i=1:16
y(i,:)=w'.*(ez(i,:)-eavg(i,:));
end
Y = fft2(y);
loglog(f*wci,2*abs(Y(1,1:ceil(NFFT/2+1))))
xlabel('\omega/ (\omega_{pi})')
hold on
loglog([wpi wpi],[1e-6, 1e0],'g')
loglog(sqrt(1836)*[wpi wpi],[1e-6, 1e0],'g--')
loglog([wlh wlh],[1e-6, 1e0],'r')
loglog([wce wce],[1e-6, 1e0],'m--')
loglog([wci wci],[1e-6, 1e0],'m')
loglog([wRcut wRcut],[1e-6, 1e0],'k')
loglog([wLcut wLcut],[1e-6, 1e0],'k--')
wh=(10:.1:50)*wci;
k=wh.*sqrt(1-(wpe^2./wh.^2)./(1-wce./wh));
plot(wh,k,'c','LineWidth',2)

%semilogy(f,2*abs(Y(1,1:NFFT/2+1)))
%xlim([0,600])
%xlim([0,600*sqrt(wci)])
title(['xsat=' num2str(xp(1)) '  ysat=',num2str(yp(1))])
ylabel('FFT(Ez)')
%xlabel('\omega/ (\omega_{ci})')
%subplot(2,1,2)
set(gcf,'Renderer','zbuffer')
print('-dpng','fig3.png')

figure(100)
wh=f*wci;
k=wh.*sqrt(1-(wpe^2./wh.^2)./(1-wce./wh));
[AX,H1,H2] =plotyy(wh,2*abs(Y(1,1:round(NFFT/2+1))),wh,k,'loglog')
hold on
loglog([wpi wpi],[1e-6, 1e-1],'g')
loglog(sqrt(1836)*[wpi wpi],[1e-6, 1e-1],'g--')
loglog([wlh wlh],[1e-6, 1e-1],'r')
loglog([wce wce],[1e-6, 1e-1],'m--')
%loglog([wci wci],[1e-6, 1e-1],'m')
loglog([wRcut wRcut],[1e-6, 1e-1],'k')
loglog([wLcut wLcut],[1e-6, 1e-1],'k--')
set(get(AX(1),'Ylabel'),'String','FFT(Ez)') 
set(get(AX(2),'Ylabel'),'String','k_{whistler}') 
set(gcf,'Renderer','zbuffer')
print('-dpng','fig3b.png')

figure(11)
%subplot(2,1,1)
y=zeros(size(ey));
for i=1:16
y(i,:)=w'.*(ey(i,:)-eyavg(i,:));
end
Y = fft2(y);
loglog(f*wci,2*abs(Y(1,1:ceil(NFFT/2+1))))
xlabel('\omega/ (\omega_{pi})')
hold on
loglog([wpi wpi],[1e-6, 1e0],'g')
loglog(sqrt(1836)*[wpi wpi],[1e-6, 1e0],'g--')
loglog([wlh wlh],[1e-6, 1e0],'r')
loglog([wce wce],[1e-6, 1e0],'m--')
loglog([wci wci],[1e-6, 1e0],'m')
loglog([wRcut wRcut],[1e-6, 1e0],'k')
loglog([wLcut wLcut],[1e-6, 1e0],'k--')
wh=(10:.1:50)*wci;
k=wh.*sqrt(1-(wpe^2./wh.^2)./(1-wce./wh));
plot(wh,k,'c','LineWidth',2)

%semilogy(f,2*abs(Y(1,1:NFFT/2+1)))
%xlim([0,600])
%xlim([0,600*sqrt(wci)])
title(['xsat=' num2str(xp(1)) '  ysat=',num2str(yp(1))])
ylabel('FFT(Ey)')
%xlabel('\omega/ (\omega_{ci})')
%subplot(2,1,2)
set(gcf,'Renderer','zbuffer')
print('-dpng','fig11.png')

figure(111)
wh=f*wci;
k=wh.*sqrt(1-(wpe^2./wh.^2)./(1-wce./wh));
[AX,H1,H2] =plotyy(wh,2*abs(Y(1,1:round(NFFT/2+1))),wh,k,'loglog')
hold on
loglog([wpi wpi],[1e-6, 1e-1],'g')
loglog(sqrt(1836)*[wpi wpi],[1e-6, 1e-1],'g--')
loglog([wlh wlh],[1e-6, 1e-1],'r')
loglog([wce wce],[1e-6, 1e-1],'m--')
%loglog([wci wci],[1e-6, 1e-1],'m')
loglog([wRcut wRcut],[1e-6, 1e-1],'k')
loglog([wLcut wLcut],[1e-6, 1e-1],'k--')
set(get(AX(1),'Ylabel'),'String','FFT(Ey)') 
set(get(AX(2),'Ylabel'),'String','k_{whistler}') 
set(gcf,'Renderer','zbuffer')
print('-dpng','fig11b.png')



figure(4)
%subplot(2,1,1)
y=zeros(size(epar));
for i=1:16
y(i,:)=w'.*epar(i,:);
end
Y = fft2(y);
loglog(f*wci,2*abs(Y(1,1:ceil(NFFT/2+1))))
xlabel('\omega/ (\omega_{pi})')
hold on
loglog([wpi wpi],[1e-6, 1e0],'g')
loglog(sqrt(1836)*[wpi wpi],[1e-6, 1e0],'g--')
loglog([wlh wlh],[1e-6, 1e0],'r')
loglog([wce wce],[1e-6, 1e0],'m--')
loglog([wci wci],[1e-6, 1e0],'m')
loglog([wRcut wRcut],[1e-6, 1e-0],'k')
loglog([wLcut wLcut],[1e-6, 1e-0],'k--')
%semilogy(f,2*abs(Y(1,1:NFFT/2+1)))
%xlim([0,600])
%xlim([0,600*sqrt(wci)])
title(['xsat=' num2str(xp(1)) '  ysat=',num2str(yp(1))])
ylabel('FFT(E||)')
%xlabel('\omega/ (\omega_{ci})')
%subplot(2,1,2)
set(gcf,'Renderer','zbuffer')
print('-dpng','fig4.png')


figure(5)
y=zeros(size(by));
for i=1:16
y(i,:)=w'.*(by(i,:)-0*byavg(i,:));
end
Y = fft2(y);
loglog(f*wci,2*abs(Y(1,1:ceil(NFFT/2+1))))
hold on
loglog([wpi wpi],[1e-6, 1e0],'g')
loglog(sqrt(1836)*[wpi wpi],[1e-6, 1e0],'g--')
loglog([wlh wlh],[1e-6, 1e0],'r')
loglog([wce wce],[1e-6, 1e0],'m--')
loglog([wci wci],[1e-6, 1e0],'m')
loglog([wRcut wRcut],[1e-6, 1e-0],'k')
loglog([wLcut wLcut],[1e-6, 1e-0],'k--')
ylabel('FFT(dBy/dt)')
xlabel('\omega/ (\omega_{pi})')
title('g:wp, r:wlh, m:wc')
%xlim([0,600*wci])
set(gcf,'Renderer','zbuffer')
print('-dpng','fig5.png')

figure(101)
wh=f*wci;
k=wh.*sqrt(1-(wpe^2./wh.^2)./(1-wce./wh));
[AX,H1,H2] =plotyy(wh,2*abs(Y(1,1:round(NFFT/2+1))),wh,k,'loglog')
hold on
loglog([wpi wpi],[1e-6, 1e-1],'g')
loglog(sqrt(1836)*[wpi wpi],[1e-6, 1e-1],'g--')
loglog([wlh wlh],[1e-6, 1e-1],'r')
loglog([wce wce],[1e-6, 1e-1],'m--')
%loglog([wci wci],[1e-6, 1e-1],'m')
loglog([wRcut wRcut],[1e-6, 1e-1],'k')
loglog([wLcut wLcut],[1e-6, 1e-1],'k--')
set(get(AX(1),'Ylabel'),'String','FFT(dBy/dt)') 
set(get(AX(2),'Ylabel'),'String','k_{whistler}') 
set(gcf,'Renderer','zbuffer')
print('-dpng','fig5b.png')

figure(6)
Y = fft2(ez(1:8,:)-eavg(1:8,:));
pcolor(1:5,f(1:300)*wci,log(abs(Y(1:5,1:300)')))
shading interp
xlabel('m_y')
ylabel('\omega/\omega_{pi}')
set(gcf,'Renderer','zbuffer')
print('-dpng','fig6.png')
