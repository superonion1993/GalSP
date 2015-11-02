subroutine galaxyGenerate(nstar,radius,xystar,sern)
implicit none
 real,parameter :: pi=acos(-1.)
 integer,intent(in) :: nstar
 real,intent(in) :: radius,sern
 real :: rstar,thetastar,xg,yg,sx,sy,xo,yo,xg0,yg0
 real,external :: random_range
 real,intent(out) :: xystar(nstar,3)
 integer :: ig
xystar=0.
sx=0.
sy=0.
xg0=0.
yg0=0.
do ig=1,nstar
	rstar=random_range(0.,radius)
	thetastar=random_range(0.0,2.*pi)
	xg=rstar*cos(thetastar)
	yg=rstar*sin(thetastar)
	xg0=xg
	yg0=yg
	xystar(ig,1)=xg0
	xystar(ig,2)=yg0
	xystar(ig,3)=rstar*exp(-1*(rstar*25.)**(1./sern))
	sx=sx+xg0
	sy=sy+yg0
end do
xo=sx/nstar
yo=sy/nstar
do ig=1,nstar
	xystar(ig,1)=xystar(ig,1)-xo
	xystar(ig,2)=xystar(ig,2)-yo	
end do

return
end subroutine

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
function random_range(lowbound,upbound)
implicit none
real,intent(in) :: lowbound,upbound
real :: lenrandom
real :: random_range
real :: t
lenrandom=upbound-lowbound
call random_number(t)
random_range=lowbound+lenrandom*t
return
end function

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine galaxyRot(nstar,theta,xystarr)
implicit none
integer,intent(in) :: nstar
real,intent(in) :: theta
real,intent(inout) :: xystarr(nstar,3)
real :: xystarr2(nstar,3)
integer :: ig


do ig=1,nstar
	xystarr2(ig,1)=cos(theta)*xystarr(ig,1)-sin(theta)*xystarr(ig,2)
	xystarr2(ig,2)=sin(theta)*xystarr(ig,1)+cos(theta)*xystarr(ig,2)
	xystarr2(ig,3)=xystarr(ig,3)
end do
xystarr=xystarr2

return
end subroutine



!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine galaxyShear(nstar,gamma1,gamma2,xystars,xystars2)
implicit none
integer,intent(in) :: nstar
real,intent(in) :: gamma1
real,intent(in) ::gamma2
real,intent(in) :: xystars(nstar,3)
real,intent(out) :: xystars2(nstar,3)
integer :: ig


do ig=1,nstar
	xystars2(ig,1)=(1+gamma1)*xystars(ig,1)+gamma2*xystars(ig,2)
	xystars2(ig,2)=gamma2*xystars(ig,1)+(1-gamma1)*xystars(ig,2)
	xystars2(ig,3)=xystars(ig,3)
end do


return
end subroutine

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

subroutine galaxyinGrid(nstar,ngrid,x,y,rPSF1,rPSF2,xystar,galaxy)
implicit none
integer,intent(in) :: nstar,ngrid
integer :: i,j,k,t1,t2,xi,yi,r1,r2
real,intent(in) :: x,y,rPSF1,rPSF2
real,intent(in) :: xystar(nstar,3)
real,intent(out) :: galaxy(ngrid,ngrid)
real :: xp,yp,lum,xs,ys
real,external :: gauss
real,external :: modffat
galaxy=0.
xi=aint(x)
yi=aint(y)
r1=aint(rPSF1*2+3)
r2=aint(rPSF2*2+3)
do i=1,nstar
	xs=xystar(i,1)
	ys=xystar(i,2)
	t1=anint(xystar(i,1))
	t2=anint(xystar(i,2))
	do k=yi+t2-r2,yi+t2+r2
	do j=xi+t1-r1,xi+t1+r1
		
		if(k<ngrid+1 .and. k>0 .and. j<ngrid+1 .and. j>0)then
			xp=x+xs-j
			yp=y+ys-k
			galaxy(j,k)=galaxy(j,k)+xystar(i,3)*modffat(rPSF1,rPSF2,xp,yp)!gauss(rPSF1,rPSF2,xp,yp)!
		end if
	end do
	end do
end do

return
end subroutine
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine mPSF(ngrid,rPSF1,rPSF2,a,b,PSF)
implicit none
integer,intent(in) :: ngrid
real,intent(in) :: a,b,rPSF1,rPSF2
real,intent(out) :: PSF(-1*ngrid/2:ngrid/2-1,-1*ngrid/2:ngrid/2-1)
integer ::ia,ib
real,external :: modffat
PSF=0.
	do ib=-1*ngrid/2,ngrid/2-1
	do ia=-1*ngrid/2,ngrid/2-1
		PSF(ia,ib)=modffat(rPSF1,rPSF2,ia+a,ib+b)
	end do
	end do
return
end subroutine
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine gPSF(ngrid,rPSF1,rPSF2,a,b,PSF)
implicit none
integer,intent(in) :: ngrid
real,intent(in) :: a,b,rPSF1,rPSF2
real,intent(out) :: PSF(-1*ngrid/2:ngrid/2-1,-1*ngrid/2:ngrid/2-1)
integer ::ia,ib
real,external :: gauss
PSF=0.
	do ib=-1*ngrid/2,ngrid/2-1
	do ia=-1*ngrid/2,ngrid/2-1
			PSF(ia,ib)=gauss(rPSF1,rPSF2,ia+a,ib+b)
	end do
	end do
return
end subroutine
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine sPSF(ngrid,rPSF1,rPSF2,a,b,PSF)
implicit none
integer,intent(in) :: ngrid
real,intent(in) :: a,b,rPSF1,rPSF2
real,intent(out) :: PSF(-1*ngrid/2:ngrid/2-1,-1*ngrid/2:ngrid/2-1)
integer ::ia,ib
real,external :: sinc2
PSF=0.
	do ib=-1*ngrid/2,ngrid/2-1
	do ia=-1*ngrid/2,ngrid/2-1
		PSF(ia,ib)=sinc2(rPSF1,rPSF2,ia+a,ib+b)
	end do
	end do
return
end subroutine
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine dPSF(ngrid,beta,a,b,PSF)
implicit none
integer,intent(in) :: ngrid
real,intent(in) :: a,b,beta
real,intent(out) :: PSF(-1*ngrid/2:ngrid/2-1,-1*ngrid/2:ngrid/2-1)
integer ::ia,ib
real,external :: flatdisk
PSF=0.
	do ib=-1*ngrid/2,ngrid/2-1
	do ia=-1*ngrid/2,ngrid/2-1
		PSF(ia,ib)=flatdisk(beta,ia+a,ib+b)
	end do
	end do
return
end subroutine




!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

subroutine fPSF(ngrid,beta,a,b,PSF)
implicit none
integer,intent(in) :: ngrid
real,intent(in) :: a,b,beta
real,intent(out) :: PSF(-1*ngrid/2:ngrid/2-1,-1*ngrid/2:ngrid/2-1)
integer ::ia,ib
real,external :: fang
PSF=0.
	do ib=-1*ngrid/2,ngrid/2-1
	do ia=-1*ngrid/2,ngrid/2-1
		PSF(ia,ib)=fang(beta,ia+a,ib+b)
	end do
	end do
return
end subroutine
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

subroutine qPSF(ngrid,a,b,PSF)
implicit none
integer,intent(in) :: ngrid
real,intent(in) :: a,b
real,intent(out) :: PSF(-1*ngrid/2:ngrid/2-1,-1*ngrid/2:ngrid/2-1)
integer ::ia,ib
real,external :: quadrupole
PSF=0.
	do ib=-1*ngrid/2,ngrid/2-1
	do ia=-1*ngrid/2,ngrid/2-1
		PSF(ia,ib)=quadrupole(ia+a,ib+b)
	end do
	end do
return
end subroutine




!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



subroutine poissonoise(ngrid,seed,pn)
implicit none
integer,intent(in) :: ngrid
integer,intent(inout) :: seed
real,intent(out) :: pn(ngrid,ngrid)
real,external :: gasdev
integer :: i,j
do j=1,ngrid
do i=1,ngrid
	pn(i,j)=gasdev(seed)
end do
end do
seed=seed+1

return
end subroutine

