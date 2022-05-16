        subroutine extra_diag(tistart)
        use iso_c_binding
        implicit none

        integer(C_SIZE_T) :: iaa,iaa2,tistart,tistart2
        integer(C_SIZE_T) :: imat4,jmat4
        integer :: i,ik,iik,j
        integer :: ik1,ik2,IC,k,ikmax,ikmin,count1,count2,detfound2
        integer,allocatable :: ideter2(:)
        real*8 :: dmat4,xmat
        logical :: yw

!---------------------------------------------------------------------
!                  Calcul des elements extradiagonaux
!---------------------------------------------------------------------
!----------boucle premier voisin

      allocate (ideter2(natomax))
      foundet=0
      foundetadr=0
      foundetdmat=0d0
      detfound=0
      detfound2=0
      foundadd=0
      foundaddh=0
      count1=0
      count2=1
      tistart2=tistart
      xmat=0.0d0

      do j=1,nrows
    
        call getdet(tistart,ideter2)
        deter=ideter2
!       print *," j=",tistart
        ideter2=0
        Touch deter

        count1=0
        yw=.FALSE.
        do ik=1,nlientot
          ik1=iliatom1(ik)
          ik2=iliatom2(ik)
          do k=1,natom
	          ideter2(k)=deter(k)
          enddo
	        if(yalt(ik)) then
	           if (deter(ik1).eq.2) then
	              ideter2(ik1)=1
	              ideter2(ik2)=2
	           else
	              ideter2(ik1)=2
	              ideter2(ik2)=1
	           endif
             dmat4=xjz(ik)
             if(dmat4.ne.0d0)then
             count1+=1
             foundet(:,detfound+count1)=ideter2
             foundetdmat(detfound+count1)=dmat4
             endif
          endif
	        if(ytrou(ik)) then
	          if(deter(ik2).eq.3)then
	            if (deter(ik1).eq.1) then
	              ideter2(ik1)=3
	              ideter2(ik2)=1
	            else
	              ideter2(ik1)=3
	              ideter2(ik2)=2
	            endif
	          else
	          if (deter(ik2).eq.1) then
	            ideter2(ik1)=1
	            ideter2(ik2)=3
	          else
	            ideter2(ik1)=2
	            ideter2(ik2)=3
	          endif
          endif
	        ikmin=min(ik1,ik2)
	        ikmax=max(ik1,ik2)
	        IC=0
	        do iik=ikmin+1,ikmax-1
	          if(deter(iik).ne.3)IC=IC+1
	        enddo
          dmat4=(xt(ik))*(-1)**(IC)
          if(dmat4.ne.0d0)then
            count1+=1
            foundet(:,detfound+count1)=ideter2
            foundetdmat(detfound+count1)=dmat4
          endif
        endif
          enddo

          detfound+=count1
          countcolfull(j)=count1
          tistart=tistart+1

        enddo
        
!       Check for large number of extradiagonal terms
        if(detfound + count1 > maxlien)then
            write(6,*)" ===================================================="
            write(6,*)" *****WARNING*****: The number of extradiagonal terms &
               exceedes maximum dimension of :",maxlien,                     &
               " \n The calculation will be unreliable. Decrease the number  &
                of extradiagonal terms (nnz: second row in input) to solve   &
                this problem or increase maxlien."
            write(6,*)" ===================================================="
        endif

        Touch foundet foundetadr detfound foundadd foundaddh foundetdmat det deth
        call adrfull()

        do i=1,detfound
          if(i.eq.1 .or. i-1.eq.detfound2)then
              call getdet(tistart2,ideter2)
              deter=ideter2
!             print *," ----> i=",i
!             write(6,*)(ideter2(iik),iik=1,natom)
              ideter2=0
              Touch deter
              call adr(deter,iaa)
              call elem_diag(xmat)
              countcol+=1
!             print *,"1->id=",iaa," val=",xmat*1.0d0
              col(countcol)=iaa
              val(countcol)=xmat*1.0d0

              tistart2+=1
              detfound2+=countcolfull(count2)
!             if(i.ne.1)then
              count2+=1
!             endif
          endif
	        imat4=iaa+1
	        jmat4=foundetadr(i)
          dmat4=foundetdmat(i)
          if(jmat4.le.(nt1*nt2) .and. dmat4 .ne. 0d0)then
            countcol+=1
!           print *,"2->id=",jmat4," val=",dmat4
            col(countcol)=jmat4
            val(countcol)=dmat4
          endif
        enddo

!   do i=0,200
!     print *,i," det=",det(i,1)," add=",det(i,2)
!   enddo
    

    return
    end
