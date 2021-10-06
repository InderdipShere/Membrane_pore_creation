!!! This program randomly creates pore in the membrane
!!! MEMBRANE FILE IS IN .xyz FORMAT

PROGRAM CREATE_PORE
  IMPLICIT NONE
  REAL*8, ALLOCATABLE, DIMENSION(:):: RX,RY,RZ, RPX, RPY
  REAL*8:: RAND_NUM, PORE_SIZE, MIN_PORE_SEP, PORE_RAD,    &
           RX_MIN, RY_MIN, RX_MAX, RY_MAX, AREA, AREA_MEM, &
           RX_DIS, RY_DIS, DIS_CUT2, X, Y, RIJ(2)
  INTEGER:: NATOM_OLD, NATOM_REM, NATOM, I, J, ISTAT,&
           NPORE, NPORE_CREAT
  CHARACTER*50:: MEMBRANE_FILE, NEW_FILE
  CHARACTER, ALLOCATABLE:: LAB(:)*5
  LOGICAL, ALLOCATABLE::ACTIVE(:)
  LOGICAL::  ACCEPT
  
  
  OPEN(21, FILE="input_CREATE_PORE.dat", STATUS='OLD', IOSTAT=ISTAT)
  IF (ISTAT /= 0) THEN
    PRINT*, "ERROR WITH INPUT FILE"
    STOP
  END IF
  READ(21,*) NATOM_OLD
  READ(21,*) NPORE
  READ(21,*) PORE_SIZE
  READ(21,*) MIN_PORE_SEP
  READ(21,*) MEMBRANE_FILE
  CLOSE(21)
  
  OPEN(21,FILE=TRIM(MEMBRANE_FILE),  STATUS='OLD', IOSTAT=ISTAT)
  IF (ISTAT /= 0) THEN
    PRINT*, "ERROR WITH MEMBRANE FILE"
    STOP
  END IF
  READ(21,*) NATOM 
  IF (NATOM /= NATOM_OLD) THEN
    PRINT*, "THE INPUT ATOMS AND MEMBRANE ATOMS MISMATCH"
    STOP
  END IF
  READ(21,*) 
  ALLOCATE( RX(NATOM),RY(NATOM),RZ(NATOM), LAB(NATOM), ACTIVE(NATOM)) 
  DO I = 1, NATOM
    READ(21,*) LAB(I), RX(I), RY(I), RZ(I)
  END DO
  CLOSE(21)
  
  RX_MIN = MINVAL(RX) ;  RX_MAX =  MAXVAL(RX)
  RY_MIN = MINVAL(RY) ;  RY_MAX =  MAXVAL(RY)
  AREA_MEM =  (RX_MAX-RX_MIN)* (RY_MAX-RY_MIN)
  PORE_RAD =  PORE_SIZE*0.50D0
  RX_MIN = RX_MIN + PORE_RAD + MIN_PORE_SEP
  RX_MAX = RX_MAX - PORE_RAD 
  RY_MIN = RY_MIN + PORE_RAD + MIN_PORE_SEP
  RY_MAX = RY_MAX - PORE_RAD 
  
  RX_DIS =  RX_MAX-RX_MIN
  RY_DIS =  RY_MAX-RY_MIN
  ! AREA OF PORE AND MIN_DIS
  AREA =  DATAN(1.0D0)*(PORE_SIZE + MIN_PORE_SEP)**2 * DBLE(NPORE)
  IF(AREA_MEM < AREA) THEN
    PRINT*, "MEMBRANE NOT ABLE TO ACCOMODATE ALL THE PORES"
    PRINT*, "AREA OF MEMBRANE", AREA_MEM
    PRINT*, "AREA OF ALL THE PORES", AREA
    STOP
  END IF
  ALLOCATE(RPX(NPORE), RPY(NPORE) )
  DIS_CUT2 =  PORE_SIZE + MIN_PORE_SEP
  DIS_CUT2 = DIS_CUT2*DIS_CUT2
  NPORE_CREAT = 0
  DO 
    IF (NPORE_CREAT == NPORE) EXIT
    X =  RX_DIS* RAND()+ RX_MIN
    Y =  RY_DIS* RAND()+ RY_MIN
    ACCEPT = .TRUE.
    DO I = 1, NPORE_CREAT
      RIJ(1)= RPX(I)- X
      RIJ(2)= RPY(I)- Y
      IF (DOT_PRODUCT(RIJ, RIJ)< DIS_CUT2) THEN
        ACCEPT = .FALSE.
        EXIT
      END IF       
    END DO
    IF (ACCEPT) THEN
      NPORE_CREAT = NPORE_CREAT + 1
      RPX(NPORE_CREAT) = X
      RPY(NPORE_CREAT) = Y
    END IF  
  END DO 
  DIS_CUT2 = PORE_RAD*PORE_RAD
  ACTIVE   = .TRUE. 
  DO I = 1, NATOM_OLD
    IF (.NOT. ACTIVE(I)) CYCLE
    X = RX(I)
    Y = RY(I)
    DO J = 1, NPORE
      RIJ(1) = RPX(J) - X
      RIJ(2) = RPY(J) - Y
      IF (DOT_PRODUCT(RIJ,RIJ) < DIS_CUT2) THEN
        ACTIVE(I) = .FALSE.
        NATOM = NATOM - 1
        EXIT
      END IF
    END DO 
  END DO
  WRITE(NEW_FILE,'(2A)') "NEW_", TRIM(MEMBRANE_FILE)
  OPEN(31,FILE=TRIM(NEW_FILE))
  WRITE(31,*) NATOM, NPORE, PORE_SIZE
  WRITE(31,*) "PORE CREATED IN MEMBRANE BY INDERDIP"
  DO I = 1, NATOM_OLD
    IF (.NOT. ACTIVE(I)) CYCLE
    WRITE(31,*) LAB(I), RX(I), RY(I), RZ(I)    
  END DO
  CLOSE(31)
END PROGRAM CREATE_PORE
