      program metcoord

!===========================================
! DETECT METAL-COORDINATING RESIDUES
!===========================================

      character(80)::pdbf
      character(4)::atag
      character(3)::atype,rtype
      character(3)::patom(20000),pres(20000),matom(100),mres(100)
      character(3)::prs,mco(30)
      real::xp1(30),yp1(30),zp1(30)
      integer::ipres(20000),imres(100)
      real::xp(20000),yp(20000),zp(20000),xm(100),ym(100),zm(100)
      integer::imco(30)
      

      call getarg(1,pdbf)

      open (unit=1,file=pdbf,status='old')
      open (unit=67,file='met.cores',status='new')

      ic1 = 0
      ic2 = 0

9     read(1,34,end=30)atag,atype,rtype,irn,xn,yn,zn
          if (atag.eq.'ATOM')then
              if (atype(1:1).ne.'H')then
              ic1 = ic1 + 1
              patom(ic1) = atype
              pres(ic1) = rtype
              ipres(ic1) = irn
              xp(ic1) = xn
              yp(ic1) = yn
              zp(ic1) = zn
              endif
           elseif(atag.eq.'HETA')then
           ic2 = ic2 + 1
           matom(ic2) = atype
           mres(ic2) = rtype
           imres(ic2) = irn
           xm(ic2) = xn
           ym(ic2) = yn
           zm(ic2) = zn
           endif
       goto 9
30     continue

34     format(a4,9x,a3,1x,a3,3x,i3,4x,3f8.3)

!       print*,ic1,ic2

!================================================
!      CONTACNT CUTOFF 4 Angstrom
!================================================

       ir1 = ipres(1)
       irl = ipres(ic1)

       do j = 1,ic2             ! On Metal ions
          do k = ir1,irl        ! On residues
          ik = 0
             do i = 1,ic1       ! On protein atoms
               if (k==ipres(i))then
               ik = ik + 1
               prs = pres(i)
               xp1(ik) = xp(i)
               yp1(ik) = yp(i)
               zp1(ik) = zp(i)
               endif
             enddo
       ircon = 0
!============= Howmany atoms of the iith residue does a metal coordinate to =============
             do ii = 1,ik          
             dist = sqrt((xp1(ii)-xm(j))**2 + (yp1(ii)-ym(j))**2 + 
     &(zp1(ii)-zm(j))**2)
                if (dist <= 4.0)then
                ircon = ircon + 1
                imco(ircon) = imres(j)
                mco(ircon) = mres(j)
                endif
             enddo             
             if (ircon >= 1)then
            write(67,57)imco(ircon),'-',mco(ircon),'<=>',k,'-',prs,ircon
             endif
          enddo
       enddo

57     format(i3,a1,a3,1x,a3,1x,i3,a1,a3,2x,i5)


      endprogram metcoord
