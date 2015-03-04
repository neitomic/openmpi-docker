!                    ******************
                     MODULE TOMAWAC_MPI
!                    ******************
!
!
!***********************************************************************
! TOMAWAC
!***********************************************************************
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      INTEGER, PARAMETER :: MAX_BASKET_SIZE=10 ! LARGE
!
!       SEE CALL GET_MPI_PARAMETERS IN SCARACT
      INTEGER MPI_INTEGER,MPI_REAL8,MPI_UB,MPI_COMM_WORLD,MPI_SUCCESS
!
        ! THE TYPE FOR CHARACTERISTICS - LOST TRACEBACKS
        ! DESCRIBES A TRACEBACK LEAVING A PARTITION TO ANOTHER ONE
        ! FOR 2D WE USE 3D -> KNE AND ZP ARE OBSOLETE THEN
!     THIS MUST BE LIKE CHARAC_TYPE IN P_MPI_ALLTOALLV_TOMA1 
      TYPE CHARAC_TYPE
      SEQUENCE
      INTEGER :: MYPID          ! PARTITION OF THE TRACEBACK ORIGIN (HEAD)
      INTEGER :: NEPID          ! THE NEIGHBOUR PARTITION THE TRACEBACK ENTERS TO
      INTEGER :: INE            ! THE LOCAL 2D ELEMENT NR THE TRACEBACK ENTERS IN THE NEIGBOUR PARTITION
      INTEGER :: KNE            ! THE LOCAL LEVEL THE TRACEBACK ENTERS IN THE NEIGBOUR PARTITION
      INTEGER :: IOR            ! THE POSITION OF THE TRAJECTORY -HEAD- IN MYPID [THE 2D/3D NODE OF ORIGIN]
      INTEGER :: ISP,NSP        ! NUMBERS OF RUNGE-KUTTA PASSED AS COLLECTED AND TO FOLLOW AT ALL
      INTEGER :: VOID
      DOUBLE PRECISION :: XP,YP,ZP ! THE (X,Y,Z)-POSITION NOW
      DOUBLE PRECISION :: DX,DY,DZ ! THE (X,Y,Z)-POSITION NOW
      DOUBLE PRECISION :: BASKET(10) ! VARIABLES INTERPOLATED AT THE FOOT
      END TYPE CHARAC_TYPE
        TYPE CHARAC_TYPE_4D
          SEQUENCE
          INTEGER :: MYPID ! PARTITION OF THE TRACEBACK ORIGIN (HEAD)
          INTEGER :: NEPID ! THE NEIGHBOUR PARTITION THE TRACEBACK ENTERS TO
          INTEGER :: INE   ! THE LOCAL 2D ELEMENT NR THE TRACEBACK ENTERS IN THE NEIGBOUR PARTITION
          INTEGER :: KNE   ! THE LOCAL LEVEL THE TRACEBACK ENTERS IN THE NEIGBOUR PARTITION
          INTEGER :: FNE   ! THE LOCAL FREQUENCE LEVEL THE TRACEBACK ENTERS IN THE NEIGBOUR PARTITION
          INTEGER :: IOR   ! THE POSITION OF THE TRAJECTORY -HEAD- IN MYPID [THE 2D/3D NODE OF ORIGIN]
          INTEGER :: ISP,NSP ! NUMBERS OF RUNGE-KUTTA PASSED AS COLLECTED AND TO FOLLOW AT ALL
          DOUBLE PRECISION :: XP,YP,ZP,FP                ! THE (X,Y,Z)-POSITION NOW
          DOUBLE PRECISION :: DX,DY,DZ,DF                ! THE (X,Y,Z)-POSITION NOW
          DOUBLE PRECISION :: BASKET(12) ! VARIABLES INTERPOLATED AT THE FOOT
        END TYPE CHARAC_TYPE_4D
        TYPE FONCTION_TYPE
          SEQUENCE
          INTEGER :: MYPID ! PARTITION OF THE TRACEBACK ORIGIN (HEAD)
          INTEGER :: NEPID ! THE NEIGHBOUR PARTITION THE TRACEBACK ENTERS TO
          INTEGER :: INE   ! THE LOCAL 2D ELEMENT NR THE TRACEBACK ENTERS IN THE NEIGBOUR PARTITION
          INTEGER :: KNE   ! THE LOCAL LEVEL THE TRACEBACK ENTERS IN THE NEIGBOUR PARTITION
          INTEGER :: IOR   ! THE POSITION OF THE TRAJECTORY -HEAD- IN MYPID [THE 2D/3D NODE OF ORIGIN]
          INTEGER :: ISP,NSP ! NUMBERS OF RUNGE-KUTTA PASSED AS COLLECTED AND TO FOLLOW AT ALL
          DOUBLE PRECISION :: XP,YP,ZP                ! THE (X,Y,Z)-POSITION NOW
          DOUBLE PRECISION :: SHP1,SHP2,SHP3,SHZ
          DOUBLE PRECISION :: BP
          DOUBLE PRECISION :: F(6) ! FUNCTION VALUES AT THE 6 POINT OF THE PRISM
        END TYPE FONCTION_TYPE
        TYPE FONCTION_TYPE_4D
          SEQUENCE
          INTEGER :: MYPID ! PARTITION OF THE TRACEBACK ORIGIN (HEAD)
          INTEGER :: NEPID ! THE NEIGHBOUR PARTITION THE TRACEBACK ENTERS TO
          INTEGER :: INE   ! THE LOCAL 2D ELEMENT NR THE TRACEBACK ENTERS IN THE NEIGBOUR PARTITION
          INTEGER :: KNE   ! THE LOCAL LEVEL THE TRACEBACK ENTERS IN THE NEIGBOUR PARTITION
          INTEGER :: FNE   ! THE LOCAL FREQUENCE LEVEL THE TRACEBACK ENTERS IN THE NEIGBOUR PARTITION
          INTEGER :: IOR   ! THE POSITION OF THE TRAJECTORY -HEAD- IN MYPID [THE 2D/3D NODE OF ORIGIN]
          INTEGER :: ISP,NSP ! NUMBERS OF RUNGE-KUTTA PASSED AS COLLECTED AND TO FOLLOW AT ALL
          DOUBLE PRECISION :: XP,YP,ZP,FP               ! THE (X,Y,Z)-POSITION NOW
          DOUBLE PRECISION :: SHP1,SHP2,SHP3,SHZ,SHF
          DOUBLE PRECISION :: BP
          DOUBLE PRECISION :: F(12) ! FUNCTION VALUES AT THE 6 POINT OF THE PRISM
        END TYPE FONCTION_TYPE_4D
!
        ! ARRAY OF BLOCKLENGTHS OF TYPE COMPONENTS, NOTE THE BASKET INITIALISED TO 1
        INTEGER, DIMENSION(15) :: CH_BLENGTH=
     &                               (/1,1,1,1,1,1,1,1,1,1,1,1,1,1,1/)
        ! ARRAY OF DISPLACEMENTS BETWEEN BASIC COMPONENTS, HERE INITIALISED ONLY
        INTEGER, DIMENSION(15) :: CH_DELTA=
     &                               (/0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/)
        ! ARRAY OF COMPONENT TYPES IN TERMS OF THE MPI COMMUNICATION
        INTEGER, DIMENSION(15) :: CH_TYPES
        ! ARRAY OF BLOCKLENGTHS OF TYPE COMPONENTS, NOTE THE BASKET INITIALISED TO 1
        INTEGER, DIMENSION(18) :: CH_BLENGTH_4D=
     &                         (/1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1/)
        ! ARRAY OF DISPLACEMENTS BETWEEN BASIC COMPONENTS, HERE INITIALISED ONLY
        INTEGER, DIMENSION(18) :: CH_DELTA_4D=
     &                         (/0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/)
        ! ARRAY OF COMPONENT TYPES IN TERMS OF THE MPI COMMUNICATION
        INTEGER, DIMENSION(18) :: CH_TYPES_4D
!
        ! ARRAY OF BLOCKLENGTHS OF TYPE COMPONENTS, NOTE THE BASKET INITIALISED TO 1
        INTEGER, DIMENSION(17) :: FC_BLENGTH=
     &                     (/1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1/)
        ! ARRAY OF DISPLACEMENTS BETWEEN BASIC COMPONENTS, HERE INITIALISED ONLY
        INTEGER, DIMENSION(17) :: FC_DELTA=
     &                     (/0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/)
        ! ARRAY OF COMPONENT TYPES IN TERMS OF THE MPI COMMUNICATION
        INTEGER, DIMENSION(17) :: FC_TYPES
        ! ARRAY OF BLOCKLENGTHS OF TYPE COMPONENTS, NOTE THE BASKET INITIALISED TO 1
        INTEGER, DIMENSION(20) :: FC_BLENGTH_4D=
     &                     (/1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1/)
        ! ARRAY OF DISPLACEMENTS BETWEEN BASIC COMPONENTS, HERE INITIALISED ONLY
        INTEGER, DIMENSION(20) :: FC_DELTA_4D=
     &                     (/0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/)
        ! ARRAY OF COMPONENT TYPES IN TERMS OF THE MPI COMMUNICATION
        INTEGER, DIMENSION(20) :: FC_TYPES_4D
        ! THE CORRESPONDING MPI TYPE
        INTEGER :: CHARACTERISTIC,CHARACTER_4D
        INTEGER :: FONCTION,FONCTION_4D
        ! STRUCTURES FOR ALL-TO-ALL COMMUNICATION / SEND AND RECEIVE WITH COUNTERS
        ! HEAP/SEND/RECVCOUNTS : COUNT THE NUMBER OF LOST TRACEBACKS PARTITION-WISE
        ! S/RDISPLS : DISPLACEMENTS IN PARTITION-WISE SORTED SEND/RECVCHARS
        ! HEAPCHAR : FOR SAVING INITIALLY LOST CHARACTERISTICS AND COLLECTING
        !            THE IMPLANTED TRACEBACKS LOCALISED IN MY PARTITION
        ! WHILE COLLECTING IS DONE IN HEAPCHARS, MOST ACTIVE OPERATIONS IN RECVCHAR
        ! SENDCHAR REQUIRED DUE TO THE SPECIFIC SORTING FOR MPI_ALLTOALLV (OPTIMISE?)
        TYPE (CHARAC_TYPE), ALLOCATABLE, DIMENSION(:,:), SAVE ::
     &                                 HEAPCHAR, SENDCHAR, RECVCHAR
        TYPE (CHARAC_TYPE_4D), ALLOCATABLE, DIMENSION(:,:), SAVE ::
     &                            HEAPCHAR_4D, SENDCHAR_4D, RECVCHAR_4D
        INTEGER, ALLOCATABLE, DIMENSION(:,:),SAVE :: SENDCOUNTS,SDISPLS
        INTEGER, ALLOCATABLE, DIMENSION(:,:),SAVE :: RECVCOUNTS,RDISPLS
        INTEGER, ALLOCATABLE, DIMENSION(:,:),SAVE :: HEAPCOUNTS
       !FOR LOOP ON LOST CHARACTERISTICS
        TYPE (CHARAC_TYPE), ALLOCATABLE, DIMENSION(:), SAVE ::
     &                                  SENDAGAIN, RECVAGAIN
        TYPE (CHARAC_TYPE_4D), ALLOCATABLE, DIMENSION(:), SAVE ::
     &                                  SENDAGAIN_4D, RECVAGAIN_4D
        INTEGER, ALLOCATABLE, DIMENSION(:),SAVE :: SENDCOUNTS_AGAIN,
     &                                             SDISPLS_AGAIN
        INTEGER, ALLOCATABLE, DIMENSION(:),SAVE :: RECVCOUNTS_AGAIN,
     &                                             RDISPLS_AGAIN
        TYPE (CHARAC_TYPE), SAVE :: TEMPO
        TYPE (CHARAC_TYPE_4D), SAVE :: TEMPO_4D
!
        ! IF SET TO TRUE, EVERY DETAILED DEBUGGING IS SWITCHED ON
        LOGICAL :: TRACE=.FALSE.
        ! WORK FIELD FOR COUNTING OCCURANCES PRO RANK / SORTING SENDCHAR
        INTEGER, ALLOCATABLE, DIMENSION(:,:), SAVE :: ICHA
        DOUBLE PRECISION, ALLOCATABLE,DIMENSION(:,:), SAVE :: TEST
        INTEGER, SAVE :: NCHDIM
        INTEGER, ALLOCATABLE, DIMENSION(:), SAVE :: NCHARA,NLOSTCHAR,
     &                                              NSEND,NARRV
        INTEGER, SAVE :: IFREQ,NFREQ
        INTEGER, ALLOCATABLE,DIMENSION(:,:),SAVE :: ISPDONE
        TYPE SH_LOCAL
          DOUBLE PRECISION,POINTER,DIMENSION(:)::SHP1,SHP2,SHP3,SHZ
          INTEGER,POINTER,DIMENSION(:) :: ELT,ETA
        END TYPE SH_LOCAL
        TYPE SH_LOCAL_4D
          DOUBLE PRECISION,POINTER,DIMENSION(:)::SHP1,SHP2,SHP3,
     &                                               SHZ,SHF
          INTEGER,POINTER,DIMENSION(:) :: ELT,ETA,FRE
        END TYPE SH_LOCAL_4D
!
        TYPE (SH_LOCAL_4D), ALLOCATABLE, DIMENSION(:),SAVE :: SH_LOC
        TYPE (SH_LOCAL_4D), ALLOCATABLE, DIMENSION(:),SAVE :: SH_LOC_4D
!
        TYPE (FONCTION_TYPE), ALLOCATABLE, DIMENSION(:), SAVE ::
     &                                               F_SEND,F_RECV
        TYPE (SH_LOCAL) ,SAVE   :: SH_AGAIN
        TYPE (FONCTION_TYPE_4D), ALLOCATABLE, DIMENSION(:), SAVE ::
     &                                             F_SEND_4D,F_RECV_4D
        TYPE (SH_LOCAL_4D) ,SAVE   :: SH_AGAIN_4D
!
        CONTAINS
  !---------------------------------------------------------------------
  ! MPI TYPE FOR TYPE CHARAC_TYPE - CHARACTERISTICS / INIT, ETC.
  ! MPI_ADDRESS POSSIBLY MOST PORTABLE THROUGH PLATFORMS
  ! HOWEVER WE APPLY MPI_TYPE_EXTENT TO ESTIMATE THE BASKET FIELD
  !   / UP TO DATE NO CHECKING OF THE MPI ERROR STATUS /
  !---------------------------------------------------------------------

!
        SUBROUTINE DEORG_CHARAC_TYPE
          IMPLICIT NONE
          INTEGER IER
          CALL P_MPI_TYPE_FREE (CHARACTERISTIC,IER)
          CALL P_MPI_TYPE_FREE (FONCTION,IER)
          RETURN
        END SUBROUTINE DEORG_CHARAC_TYPE
!
        SUBROUTINE DEORG_CHARAC_TYPE_4D
          IMPLICIT NONE
          INTEGER IER
          CALL P_MPI_TYPE_FREE (CHARACTER_4D,IER)
          CALL P_MPI_TYPE_FREE (FONCTION_4D,IER)
          RETURN
        END SUBROUTINE DEORG_CHARAC_TYPE_4D
!
        SUBROUTINE COLLECT_CHAR(MYPID,IOR,MYII,IFACE,KNE,
     &                          ISP,NSP,XP,YP,ZP,DX,DY,DZ,IFAPAR,
     &                          NCHDIM,NCHARA,JF)
          IMPLICIT NONE
          INTEGER LNG,LU
          COMMON/INFO/LNG,LU
          INTEGER,  INTENT(IN) :: MYPID,IOR,MYII,IFACE,KNE
          INTEGER,  INTENT(IN) :: ISP,NSP,NCHDIM,JF
          INTEGER,  INTENT(IN) :: IFAPAR(6,*)
          INTEGER,  INTENT(INOUT) :: NCHARA
          DOUBLE PRECISION, INTENT(IN) :: XP,YP,ZP
          DOUBLE PRECISION, INTENT(IN) :: DX,DY,DZ
          INTEGER :: NEPID,II,III
          !
          IF(NCHARA==0) HEAPCOUNTS=0
          NEPID=IFAPAR(IFACE  ,MYII)
          II   =IFAPAR(IFACE+3,MYII)
          NCHARA=NCHARA+1
          IF(NCHARA>NCHDIM) THEN ! PROBABLY EXAGGERATED
            WRITE (LU,*) 'NCHARA=',NCHARA,' NCHDIM=',NCHDIM
            WRITE (LU,*) 'COLLECT_CHAR::NCHARA>NCHDIM, INCREASE NCHDIM'
            CALL PLANTE(1)
            STOP
          ENDIF
          HEAPCHAR(NCHARA,JF)%MYPID=MYPID ! THE ORIGIN PID
          HEAPCHAR(NCHARA,JF)%NEPID=NEPID ! THE NEXT PID
          HEAPCHAR(NCHARA,JF)%INE=II      ! ELEMENT THERE
          HEAPCHAR(NCHARA,JF)%KNE=KNE     ! LEVEL THERE
          HEAPCHAR(NCHARA,JF)%IOR=IOR     ! THE ORIGIN 2D OR 3D NODE
          HEAPCHAR(NCHARA,JF)%ISP=ISP     ! R-K STEP AS COLLECTED
          HEAPCHAR(NCHARA,JF)%NSP=NSP     ! R-K STEPS TO BE DONE
          HEAPCHAR(NCHARA,JF)%XP=XP       ! X-POSITION
          HEAPCHAR(NCHARA,JF)%YP=YP       ! Y-POSITION
          HEAPCHAR(NCHARA,JF)%ZP=ZP       ! Z-POSITION
          HEAPCHAR(NCHARA,JF)%DX=DX       ! DX-POSITION
          HEAPCHAR(NCHARA,JF)%DY=DY       ! DY-POSITION
          HEAPCHAR(NCHARA,JF)%DZ=DZ       ! DZ-POSITION
!         TAGGING THE BASKET FOR DEBUGGING
!           DO III=1,10
!             HEAPCHAR(NCHARA,IFREQ)%BASKET(III)=1000.D0*III+NCHARA
!           ENDDO
          !
          HEAPCOUNTS(NEPID+1,JF)=HEAPCOUNTS(NEPID+1,JF)+1
          !
          RETURN
        END SUBROUTINE COLLECT_CHAR
!
!
        SUBROUTINE COLLECT_CHAR_4D(MYPID,IOR,MYII,IFACE,KNE,FNE,
     &                          ISP,NSP,XP,YP,ZP,FP,DX,DY,DZ,DF,
     &                          IFAPAR,NCHDIM,NCHARA,JF)
          IMPLICIT NONE
          INTEGER LNG,LU
          COMMON/INFO/LNG,LU
          INTEGER,  INTENT(IN) :: MYPID,IOR,MYII,IFACE,KNE,FNE
          INTEGER,  INTENT(IN) :: ISP,NSP,NCHDIM,JF
          INTEGER,  INTENT(IN) :: IFAPAR(6,*)
          INTEGER,  INTENT(INOUT) :: NCHARA
          DOUBLE PRECISION, INTENT(IN) :: XP,YP,ZP,FP
          DOUBLE PRECISION, INTENT(IN) :: DX,DY,DZ,DF
          INTEGER :: NEPID,II,III
          !
          IF(NCHARA==0) HEAPCOUNTS=0
          NEPID=IFAPAR(IFACE  ,MYII)
          II   =IFAPAR(IFACE+3,MYII)
          NCHARA=NCHARA+1
          IF(NCHARA>NCHDIM) THEN ! PROBABLY EXAGGERATED
            WRITE (LU,*) 'NCHARA=',NCHARA,' NCHDIM=',NCHDIM
            WRITE (LU,*) 'COLLECT_CHAR::NCHARA>NCHDIM, INCREASE NCHDIM'
            CALL PLANTE(1)
            STOP
          ENDIF
          HEAPCHAR_4D(NCHARA,JF)%MYPID=MYPID ! THE ORIGIN PID
          HEAPCHAR_4D(NCHARA,JF)%NEPID=NEPID ! THE NEXT PID
          HEAPCHAR_4D(NCHARA,JF)%INE=II      ! ELEMENT THERE
          HEAPCHAR_4D(NCHARA,JF)%KNE=KNE     ! LEVEL THERE
          HEAPCHAR_4D(NCHARA,JF)%FNE=FNE     ! LEVEL THERE
          HEAPCHAR_4D(NCHARA,JF)%IOR=IOR     ! THE ORIGIN 2D OR 3D NODE
          HEAPCHAR_4D(NCHARA,JF)%ISP=ISP     ! R-K STEP AS COLLECTED
          HEAPCHAR_4D(NCHARA,JF)%NSP=NSP     ! R-K STEPS TO BE DONE
          HEAPCHAR_4D(NCHARA,JF)%XP=XP       ! X-POSITION
          HEAPCHAR_4D(NCHARA,JF)%YP=YP       ! Y-POSITION
          HEAPCHAR_4D(NCHARA,JF)%ZP=ZP       ! Z-POSITION
          HEAPCHAR_4D(NCHARA,JF)%FP=FP       ! FREQ-POSITION
          HEAPCHAR_4D(NCHARA,JF)%DX=DX       ! DX-POSITION
          HEAPCHAR_4D(NCHARA,JF)%DY=DY       ! DY-POSITION
          HEAPCHAR_4D(NCHARA,JF)%DZ=DZ       ! DZ-POSITION
          HEAPCHAR_4D(NCHARA,JF)%DF=DF       ! DFREQ-POSITION
!         TAGGING THE BASKET FOR DEBUGGING
!           DO III=1,10
!             HEAPCHAR(NCHARA,IFREQ)%BASKET(III)=1000.D0*III+NCHARA
!           ENDDO
          !
          HEAPCOUNTS(NEPID+1,JF)=HEAPCOUNTS(NEPID+1,JF)+1
          !
          RETURN
        END SUBROUTINE COLLECT_CHAR_4D
!
!
        SUBROUTINE INIT_TOMAWAC(NCHARA,NCHDIM,NOMB,NPOIN,LAST_NOMB)
      USE BIEF
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER NRK,I,II,IPOIN,ISTOP
      DOUBLE PRECISION C
!
!-----------------------------------------------------------------------
!
      LOGICAL :: INIT=.TRUE.
      INTEGER NCHARA
      INTEGER NOMB
      INTEGER LAST_NOMB
!     STATIC DIMENSION FOR HEAPCHAR, SENDCHAR, RECVCHAR (SORRY, STATIC)
      INTEGER NCHDIM
      INTEGER NPOIN
!
      SAVE
!
!
!
      IF(INIT) THEN ! CHECKS THINGS ONCE AND FOREVER
!
!       SEE IN LIBRARY PARALLEL OR PARAVOID (AND INCLUDE 'MPIF.H' OR NOT)
!
        CALL GET_MPI_PARAMETERS(MPI_INTEGER,MPI_REAL8,MPI_UB,
     &                          MPI_COMM_WORLD,MPI_SUCCESS)
!
        INIT=.FALSE.
        LAST_NOMB=NOMB
!
        IF(NCSIZE>1) CALL ORGANISE_CHARS(NPOIN,NOMB,NCHDIM)
!
!
      ENDIF
!
!     CASE OF A CALL FROM DIFFERENT PROGRAMS WITH DIFFERENT NOMB
!     JAJ + JMH 26/08/2008
!
      IF(NCSIZE.GT.1) THEN
        IF(NOMB.NE.LAST_NOMB) THEN
          ! DESTROYS THE CHARACTERISTICS TYPE FOR COMM.
          CALL DEORG_CHARAC_TYPE()
          ! SETS DATA STRUCTURES ACCORDINGLY
          CALL ORGANISE_CHARS(NPOIN,NOMB,NCHDIM)
        ENDIF
!
!       INITIALISES NCHARA (NUMBER OF LOST CHARACTERISTICS)
        NCHARA=0
!
      ENDIF
!
      END SUBROUTINE INIT_TOMAWAC
!
!
        SUBROUTINE INIT_TOMAWAC_4D(NCHARA,NCHDIM,NOMB,NPOIN,LAST_NOMB)
      USE BIEF
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER NRK,I,II,IPOIN,ISTOP
      DOUBLE PRECISION C
!
!-----------------------------------------------------------------------
!
      LOGICAL :: INIT=.TRUE.
      INTEGER NCHARA
      INTEGER NOMB
      INTEGER LAST_NOMB
!     STATIC DIMENSION FOR HEAPCHAR, SENDCHAR, RECVCHAR (SORRY, STATIC)
      INTEGER NCHDIM
      INTEGER NPOIN
!
      SAVE
!
!
!
      IF(INIT) THEN ! CHECKS THINGS ONCE AND FOREVER
!
!       SEE IN LIBRARY PARALLEL OR PARAVOID (AND INCLUDE 'MPIF.H' OR NOT)
!
        CALL GET_MPI_PARAMETERS(MPI_INTEGER,MPI_REAL8,MPI_UB,
     &                          MPI_COMM_WORLD,MPI_SUCCESS)
!
        INIT=.FALSE.
        LAST_NOMB=NOMB
!
        IF(NCSIZE>1) CALL ORGANISE_CHARS_4D(NPOIN,NOMB,NCHDIM)
!
!
      ENDIF
!
!     CASE OF A CALL FROM DIFFERENT PROGRAMS WITH DIFFERENT NOMB
!     JAJ + JMH 26/08/2008
!
      IF(NCSIZE.GT.1) THEN
        IF(NOMB.NE.LAST_NOMB) THEN
          ! DESTROYS THE CHARACTERISTICS TYPE FOR COMM.
          CALL DEORG_CHARAC_TYPE_4D()
          ! SETS DATA STRUCTURES ACCORDINGLY
          CALL ORGANISE_CHARS_4D(NPOIN,NOMB,NCHDIM)
        ENDIF
!
!       INITIALISES NCHARA (NUMBER OF LOST CHARACTERISTICS)
        NCHARA=0
!
      ENDIF
!
      END SUBROUTINE INIT_TOMAWAC_4D
!
!
        SUBROUTINE ORGANISE_CHARS(NPARAM,NOMB,NCHDIM) ! WATCH OUT
          USE BIEF_DEF, ONLY: NCSIZE
          IMPLICIT NONE
          INTEGER, INTENT(IN)  :: NPARAM,NOMB
          INTEGER, INTENT(OUT) :: NCHDIM
          INTEGER I
          IF (.NOT.ALLOCATED(HEAPCOUNTS)) ALLOCATE(HEAPCOUNTS(NCSIZE
     &                                                        ,NFREQ))
          IF (.NOT.ALLOCATED(SENDCOUNTS)) ALLOCATE(SENDCOUNTS(NCSIZE
     &                                                        ,NFREQ))
          IF (.NOT.ALLOCATED(RECVCOUNTS)) ALLOCATE(RECVCOUNTS(NCSIZE
     &                                                        ,NFREQ))
          IF (.NOT.ALLOCATED(SDISPLS))    ALLOCATE(SDISPLS(NCSIZE
     &                                                        ,NFREQ))
          IF (.NOT.ALLOCATED(RDISPLS))    ALLOCATE(RDISPLS(NCSIZE
     &                                                        ,NFREQ))
          IF (.NOT.ALLOCATED(ICHA))       ALLOCATE(ICHA(NCSIZE,NFREQ))
          HEAPCOUNTS=0
          SENDCOUNTS=0
          RECVCOUNTS=0
          SDISPLS=0
          RDISPLS=0
          ICHA=0
          !
          NCHDIM=NPARAM
          IF (.NOT.ALLOCATED(SENDCHAR)) ALLOCATE(SENDCHAR(NCHDIM,NFREQ))
          IF (.NOT.ALLOCATED(RECVCHAR)) ALLOCATE(RECVCHAR(NCHDIM,NFREQ))
          IF (.NOT.ALLOCATED(HEAPCHAR)) ALLOCATE(HEAPCHAR(NCHDIM,NFREQ))
          CALL ORG_CHARAC_TYPE1(NOMB,TRACE,CHARACTERISTIC) ! COMMITS THE CHARACTERISTICS TYPE FOR COMM.
          CALL P_ORG_FONCTION_TYPE(6,TRACE,FONCTION)
          RETURN
        END SUBROUTINE ORGANISE_CHARS
!
!
        SUBROUTINE ORGANISE_CHARS_4D(NPARAM,NOMB,NCHDIM) ! WATCH OUT
          USE BIEF_DEF, ONLY: NCSIZE
          IMPLICIT NONE
          INTEGER, INTENT(IN)  :: NPARAM,NOMB
          INTEGER, INTENT(OUT) :: NCHDIM
          INTEGER I
          IF (.NOT.ALLOCATED(HEAPCOUNTS)) ALLOCATE(HEAPCOUNTS(NCSIZE
     &                                                        ,NFREQ))
          IF (.NOT.ALLOCATED(SENDCOUNTS)) ALLOCATE(SENDCOUNTS(NCSIZE
     &                                                        ,NFREQ))
          IF (.NOT.ALLOCATED(RECVCOUNTS)) ALLOCATE(RECVCOUNTS(NCSIZE
     &                                                        ,NFREQ))
          IF (.NOT.ALLOCATED(SDISPLS))    ALLOCATE(SDISPLS(NCSIZE
     &                                                        ,NFREQ))
          IF (.NOT.ALLOCATED(RDISPLS))    ALLOCATE(RDISPLS(NCSIZE
     &                                                        ,NFREQ))
          IF (.NOT.ALLOCATED(ICHA))       ALLOCATE(ICHA(NCSIZE,NFREQ))
          HEAPCOUNTS=0
          SENDCOUNTS=0
          RECVCOUNTS=0
          SDISPLS=0
          RDISPLS=0
          ICHA=0
          !
          NCHDIM=NPARAM
          IF (.NOT.ALLOCATED(SENDCHAR_4D)) ALLOCATE(
     &                                     SENDCHAR_4D(NCHDIM,NFREQ))
          IF (.NOT.ALLOCATED(RECVCHAR_4D)) ALLOCATE(
     &                                     RECVCHAR_4D(NCHDIM,NFREQ))
          IF (.NOT.ALLOCATED(HEAPCHAR_4D)) ALLOCATE(
     &                                     HEAPCHAR_4D(NCHDIM,NFREQ))
          CALL P_ORG_CHARAC_TYPE_4D(NOMB,TRACE,CHARACTER_4D) ! COMMITS THE CHARACTERISTICS TYPE FOR COMM.
          CALL P_ORG_FONCTION_TYPE_4D(12,TRACE,FONCTION_4D)
          RETURN
        END SUBROUTINE ORGANISE_CHARS_4D
!
!
!                       ************************
                        SUBROUTINE PIEDS_TOMAWAC
!                       ************************
!
     &  (U , V , W , DT , NRK , X , Y , TETA , IKLE2 , IFABOR , ETAS ,
     &   XPLOT , YPLOT , ZPLOT , DX , DY , DZ , SHP1 , SHP2 , SHP3 ,
     &   SHZ , ELT , ETA , NSP , NPLOT , NPOIN2 , NELEM2 , NPLAN ,
     &   IFF , SURDET , SENS , ISO ,IFAPAR, TEST3, NCHDIM,NCHARA,
     &   MESH,GOODELT)
!
!***********************************************************************
!  TOMAWAC  RELEASE 1.0       01/02/95        F MARCOS (LNH) 30 87 72 66
!***********************************************************************
!
!  FUNCTION :
!
!     TRACES IN TIME
!     THE CHARACTERISTICS CURVES
!     FOR TELEMAC-3D PRISMS
!     WITHIN THE TIME INTERVAL DT
!     USING A FINITE ELEMENTS DISCRETISATION
!
!
!  DISCRETISATION :
!
!     THE DOMAIN IS APPROXIMATED USING A FINITE ELEMENT DISCRETISATION.
!     A LOCAL APPROXIMATION IS USED FOR THE VELOCITY :
!     THE VALUE IN ONE POINT OF AN ELEMENT ONLY DEPENDS THE VALUES AT THE
!     NODES OF THIS ELEMENT.
!
!
!  RESTRICTIONS AND ASSUMPTIONS:
!
!     THE ADVECTION FIELD U IS ASSUMED NOT TO VARY WITH TIME
!
!-----------------------------------------------------------------------
!                             ARGUMENTS
! .________________.____.______________________________________________.
! !      NOM       !MODE!                   ROLE                       !
! !________________!____!______________________________________________!
! !    U,V,W       ! -->! COMPOSANTE DE LA VITESSE DU CONVECTEUR       !
! !    DT          ! -->! PAS DE TEMPS.                                !
! !    NRK         ! -->! NOMBRE DE SOUS-PAS DE RUNGE-KUTTA.           !
! !    X,Y,TETA    ! -->! COORDONNEES DES POINTS DU MAILLAGE.          !
! !    IKLE2       ! -->! TRANSITION ENTRE LES NUMEROTATIONS LOCALE    !
! !                !    ! ET GLOBALE DU MAILLAGE 2D.                   !
! !    IFABOR      ! -->! NUMEROS 2D DES ELEMENTS AYANT UNE FACE COMMUNE
! !                !    ! AVEC L'ELEMENT .  SI IFABOR
! !                !    ! ON A UNE FACE LIQUIDE,SOLIDE,OU PERIODIQUE   !
! !    ETAS        !! TABLEAU DE TRAVAIL DONNANT LE NUMERO DE      !
! !                !    ! L'ETAGE SUPERIEUR                            !
! !  X..,Y..,ZPLOT !! POSITIONS SUCCESSIVES DES DERIVANTS.         !
! !    DX,DY,DZ    ! -- ! STOCKAGE DES SOUS-PAS .                      !
! !    SHP1-2-3    !! COORDONNEES BARYCENTRIQUES 2D AU PIED DES    !
! !                !    ! COURBES CARACTERISTIQUES.                    !
! !    SHZ         !! COORDONNEES BARYCENTRIQUES SUIVANT Z DES     !
! !                !    ! NOEUDS DANS LEURS ETAGES "ETA" ASSOCIES.     !
! !    ELT         !! NUMEROS DES ELEMENTS 2D CHOISIS POUR CHAQUE  !
! !                !    ! NOEUD.                                       !
! !    ETA         !! NUMEROS DES ETAGES CHOISIS POUR CHAQUE NOEUD.!
! !    NSP         ! -- ! NOMBRE DE SOUS-PAS DE RUNGE KUTTA.           !
! !    NPLOT       ! -->! NOMBRE DE DERIVANTS.                         !
! !    NPOIN2      ! -->! NOMBRE DE POINTS DU MAILLAGE 2D.             !
! !    NELEM2      ! -->! NOMBRE D'ELEMENTS DU MAILLAGE 2D.            !
! !    NPLAN       ! -->! NOMBRE DE DIRECTIONS                         !
! !    SURDET      ! -->! VARIABLE UTILISEE PAR LA TRANSFORMEE ISOPARAM.
! !    SENS        ! -->! DESCENTE OU REMONTEE DES CARACTERISTIQUES.   !
! !    ISO         !! INDIQUE PAR BIT LA FACE DE SORTIE DE L'ELEMEN!
! !________________!____!______________________________________________!
!  MODE: -->(DONNEE NON MODIFIEE),(DONNEE MODIFIEE)
!-----------------------------------------------------------------------
!     - APPELE PAR : WAC
!     - PROGRAMMES APPELES : NEANT
!
!***********************************************************************
!
      USE BIEF
      IMPLICIT NONE
!
      INTEGER LNG,LU
      COMMON/INFO/ LNG,LU
!
      INTEGER NPOIN2,NELEM2,NPLAN,NPLOT,NSPMAX,NRK,SENS,IFF
!
      DOUBLE PRECISION U(NPOIN2,NPLAN),V(NPOIN2,NPLAN)
      DOUBLE PRECISION W(NPOIN2,NPLAN)
      DOUBLE PRECISION XPLOT(NPLOT),YPLOT(NPLOT),ZPLOT(NPLOT)
      DOUBLE PRECISION SURDET(NELEM2),SHZ(NPLOT)
      DOUBLE PRECISION SHP1(NPLOT),SHP2(NPLOT),SHP3(NPLOT)
      DOUBLE PRECISION X(NPOIN2),Y(NPOIN2),TETA(NPLAN+1)
      DOUBLE PRECISION DX(NPLOT),DY(NPLOT),DZ(NPLOT)
      DOUBLE PRECISION PAS,DT,A1,DX1,DY1,DXP,DYP,DZP,XP,YP,ZP
      DOUBLE PRECISION EPSILO, EPSI, EPM1
!
      INTEGER IKLE2(NELEM2,3),IFABOR(NELEM2,5),ETAS(NPLAN)
      INTEGER ELT(NPLOT),ETA(NPLOT),NSP(NPLOT),ISO(NPLOT),
     &        GOODELT(NPLOT)
      INTEGER IPLOT,ISP,I1,I2,I3,IEL,IET,ISOH,ISOV,IFA,ISUI(3)
!BD_INCKA MODIFICATION FOR PARALLEL MODE
      INTEGER         , INTENT(IN)    :: IFAPAR(6,*)
      DOUBLE PRECISION, INTENT(INOUT) :: TEST3(NPLOT)
      INTEGER                         :: NCHDIM,NCHARA,IPLAN,IPOIN,
     &                                   I10
      LOGICAL                         :: DOSTOP
      INTEGER  P_IMAX, P_ISUM
      EXTERNAL P_IMAX, P_ISUM
      DOUBLE PRECISION :: TES(NPOIN2,NPLAN),DENOM,DET1,DET2
      TYPE(BIEF_MESH)  MESH
!BD_INCKA END OF MODIFICATION FOR PARALLEL MODE
!
      INTRINSIC ABS , INT , MAX , SQRT , DBLE , NINT
!
      DATA ISUI   / 2 , 3 , 1 /
      DATA EPSILO / -1.D-6 /
      DATA EPSI   / 1.D-12 /
!
!-----------------------------------------------------------------------
!    COMPUTES THE NUMBER OF SUB-ITERATIONS
!    (THE SAME AT ALL THE NODES FOR A GIVEN FREQUENCY)
!-----------------------------------------------------------------------
!
      NSPMAX = 1
      EPM1=1.D0-EPSI
!
      DO 10 IPLOT = 1 , NPLOT
!
         TEST3(IPLOT) = 1.D0
         NSP(IPLOT) = 0
         IEL = ELT(IPLOT)
!
         IF (IEL.GT.0) THEN
!
            IET = ETA(IPLOT)
!
            I1 = IKLE2(IEL,1)
            I2 = IKLE2(IEL,2)
            I3 = IKLE2(IEL,3)
!
         DXP = U(I1,IET  )*SHP1(IPLOT)*(1.D0-SHZ(IPLOT))
     &       + U(I2,IET  )*SHP2(IPLOT)*(1.D0-SHZ(IPLOT))
     &       + U(I3,IET  )*SHP3(IPLOT)*(1.D0-SHZ(IPLOT))
     &       + U(I1,ETAS(IET))*SHP1(IPLOT)*SHZ(IPLOT)
     &       + U(I2,ETAS(IET))*SHP2(IPLOT)*SHZ(IPLOT)
     &       + U(I3,ETAS(IET))*SHP3(IPLOT)*SHZ(IPLOT)
!
         DYP = V(I1,IET  )*SHP1(IPLOT)*(1.D0-SHZ(IPLOT))
     &       + V(I2,IET  )*SHP2(IPLOT)*(1.D0-SHZ(IPLOT))
     &       + V(I3,IET  )*SHP3(IPLOT)*(1.D0-SHZ(IPLOT))
     &       + V(I1,ETAS(IET))*SHP1(IPLOT)*SHZ(IPLOT)
     &       + V(I2,ETAS(IET))*SHP2(IPLOT)*SHZ(IPLOT)
     &       + V(I3,ETAS(IET))*SHP3(IPLOT)*SHZ(IPLOT)
!
         DZP = W(I1,IET  )*SHP1(IPLOT)*(1.D0-SHZ(IPLOT))
     &       + W(I2,IET  )*SHP2(IPLOT)*(1.D0-SHZ(IPLOT))
     &       + W(I3,IET  )*SHP3(IPLOT)*(1.D0-SHZ(IPLOT))
     &       + W(I1,ETAS(IET))*SHP1(IPLOT)*SHZ(IPLOT)
     &       + W(I2,ETAS(IET))*SHP2(IPLOT)*SHZ(IPLOT)
     &       + W(I3,ETAS(IET))*SHP3(IPLOT)*SHZ(IPLOT)
!
         NSP(IPLOT)= MAX(INT(NRK*DT*ABS(DZP/(TETA(IET)-TETA(IET+1)))),
     &         INT(NRK*DT*SQRT((DXP*DXP+DYP*DYP)*SURDET(IEL))) )
!
! CHECKS WHETHER THE CORRECT ELEMENT HAS BEEN FOUND (NOT A BOUNDARY ELEMENT
! WHICH WILL BE IGNORED AT A LATER DATE; SEE SUBROUTINE 'INIPIE'
         IF (GOODELT(IPLOT).EQ.0) NSP(IPLOT) = 1
         IF ((GOODELT(IPLOT).EQ.2000).OR.(GOODELT(IPLOT).EQ.1100)
     &  .OR.(GOODELT(IPLOT).EQ.1010).OR.(GOODELT(IPLOT).EQ.1000))
     &                                NSP(IPLOT) = 1
!          IF ((GOODELT(IPLOT).EQ.3000).OR.(GOODELT(IPLOT).EQ.4000))
!      *       NSP(IPLOT)=1
         IF ((1000*(GOODELT(IPLOT)/1000)-GOODELT(IPLOT)).EQ.0)
     &       NSP(IPLOT) = 1
!
            NSP(IPLOT) = MAX (1,NSP(IPLOT))
!
            NSPMAX = MAX ( NSPMAX , NSP(IPLOT) )
!
         ENDIF
!
10    CONTINUE
       TES = RESHAPE(DBLE(NSP),(/NPOIN2,NPLAN/))
       DO IPLAN=1,NPLAN
         CALL PARCOM2
     & ( TES(:,IPLAN) ,
     &   TES(:,IPLAN) ,
     &   TES(:,IPLAN) ,
     &   NPOIN2 , 1 , 1 , 1 , MESH )
      ENDDO
      DO IPOIN = 1, NPOIN2
         DO IPLAN= 1,NPLAN
         NSP(IPOIN + NPOIN2*(IPLAN-1))= NINT(TES(IPOIN,IPLAN))
         ENDDO
      ENDDO
!BD_INCKA MOFIFICATION FOR PARALLEL MODE
      NSPMAX = P_IMAX(NSPMAX)
!BD_INCKA END OF MODIFICATION
      IF (LNG.EQ.1) THEN
        WRITE(LU,*)
     &     '   FREQUENCE',IFF,', NOMBRE DE SOUS PAS RUNGE KUTTA :'
     &        ,NSPMAX
      ELSE
        WRITE(LU,*)
     &     '   FREQUENCY',IFF,', NUMBER OF RUNGE KUTTA SUB TIME-STEP
     &S :',NSPMAX
      ENDIF
!
!
!-----------------------------------------------------------------------
!  LOOP ON NUMBER OF SUB-ITERATIONS
!-----------------------------------------------------------------------
!
      DO 20 ISP = 1 , NSPMAX
!
!-----------------------------------------------------------------------
!  LOCATES THE END POINT OF ALL THE CHARACTERISTICS
!-----------------------------------------------------------------------
!
        DO 30 IPLOT = 1 , NPLOT
!
            ISO(IPLOT) = 0
            IF (ISP.LE.NSP(IPLOT)) THEN
!
               IEL = ELT(IPLOT)
               IET = ETA(IPLOT)
!
               I1 = IKLE2(IEL,1)
               I2 = IKLE2(IEL,2)
               I3 = IKLE2(IEL,3)
               PAS = SENS * DT / NSP(IPLOT)
!
!
               DX(IPLOT) =
     & ( U(I1,IET  )*SHP1(IPLOT)*(1.D0-SHZ(IPLOT))
     & + U(I2,IET  )*SHP2(IPLOT)*(1.D0-SHZ(IPLOT))
     & + U(I3,IET  )*SHP3(IPLOT)*(1.D0-SHZ(IPLOT))
     & + U(I1,ETAS(IET))*SHP1(IPLOT)*SHZ(IPLOT)
     & + U(I2,ETAS(IET))*SHP2(IPLOT)*SHZ(IPLOT)
     & + U(I3,ETAS(IET))*SHP3(IPLOT)*SHZ(IPLOT) ) * PAS
!
               DY(IPLOT) =
     & ( V(I1,IET  )*SHP1(IPLOT)*(1.D0-SHZ(IPLOT))
     & + V(I2,IET  )*SHP2(IPLOT)*(1.D0-SHZ(IPLOT))
     & + V(I3,IET  )*SHP3(IPLOT)*(1.D0-SHZ(IPLOT))
     & + V(I1,ETAS(IET))*SHP1(IPLOT)*SHZ(IPLOT)
     & + V(I2,ETAS(IET))*SHP2(IPLOT)*SHZ(IPLOT)
     & + V(I3,ETAS(IET))*SHP3(IPLOT)*SHZ(IPLOT) ) * PAS
!
               DZ(IPLOT) =
     & ( W(I1,IET  )*SHP1(IPLOT)*(1.D0-SHZ(IPLOT))
     & + W(I2,IET  )*SHP2(IPLOT)*(1.D0-SHZ(IPLOT))
     & + W(I3,IET  )*SHP3(IPLOT)*(1.D0-SHZ(IPLOT))
     & + W(I1,ETAS(IET))*SHP1(IPLOT)*SHZ(IPLOT)
     & + W(I2,ETAS(IET))*SHP2(IPLOT)*SHZ(IPLOT)
     & + W(I3,ETAS(IET))*SHP3(IPLOT)*SHZ(IPLOT) ) * PAS
!
               XP = XPLOT(IPLOT) + DX(IPLOT)
               YP = YPLOT(IPLOT) + DY(IPLOT)
               ZP = ZPLOT(IPLOT) + DZ(IPLOT)
!
               SHP1(IPLOT) = ((X(I3)-X(I2))*(YP-Y(I2))
     &                        -(Y(I3)-Y(I2))*(XP-X(I2))) * SURDET(IEL)
               SHP2(IPLOT) = ((X(I1)-X(I3))*(YP-Y(I3))
     &                        -(Y(I1)-Y(I3))*(XP-X(I3))) * SURDET(IEL)
               SHP3(IPLOT) = ((X(I2)-X(I1))*(YP-Y(I1))
     &                        -(Y(I2)-Y(I1))*(XP-X(I1))) * SURDET(IEL)
               SHZ(IPLOT) = (ZP-TETA(IET)) / (TETA(IET+1)-TETA(IET))
!
               IF (SHP1(IPLOT).LT.EPSILO)
     &              ISO(IPLOT)=IBSET(ISO(IPLOT),2)
               IF (SHP2(IPLOT).LT.EPSILO)
     &              ISO(IPLOT)=IBSET(ISO(IPLOT),3)
               IF (SHP3(IPLOT).LT.EPSILO)
     &              ISO(IPLOT)=IBSET(ISO(IPLOT),4)
!
               IF  (SHZ(IPLOT).LT.EPSILO)
     &              ISO(IPLOT)=IBSET(ISO(IPLOT),0)
               IF  (SHZ(IPLOT).GT.1.D0-EPSILO)
     &              ISO(IPLOT)=IBSET(ISO(IPLOT),1)
!               IF (ABS(SHZ(IPLOT)).GT.2.5D0 ) THEN
!                  WRITE(LU,*)'SHZ***',IPLOT,IET,SHZ(IPLOT)
!                  WRITE(LU,*)TETA(IET),TETA(IET+1),ZP
!                  WRITE(LU,*)DZ(IPLOT),ZPLOT(IPLOT)
!                  STOP
!              ENDIF
!
               XPLOT(IPLOT) = XP
               YPLOT(IPLOT) = YP
               ZPLOT(IPLOT) = ZP
!
            ENDIF
!
!
30       CONTINUE
!
!-----------------------------------------------------------------------
!  TREATS DIFFERENTLY THE CHARACTERISTICS ISSUED FROM
!  THE START ELEMENT
!-----------------------------------------------------------------------
!
        DO 40 IPLOT = 1 , NPLOT
!
50          CONTINUE
!
            IF ((ISO(IPLOT).NE.0).AND.(TEST3(IPLOT)>0.5D0)) THEN
!             IF ((ISO(IPLOT).NE.0)) THEN
!
!-----------------------------------------------------------------------
!  HERE: LEFT THE ELEMENT
!-----------------------------------------------------------------------
!
               ISOH = IAND(ISO(IPLOT),28)
               ISOV = IAND(ISO(IPLOT), 3)
               IEL = ELT(IPLOT)
               IET = ETA(IPLOT)
               XP = XPLOT(IPLOT)
               YP = YPLOT(IPLOT)
               ZP = ZPLOT(IPLOT)
!
               IF (ISOH.NE.0) THEN
!
                  IF (ISOH.EQ.4) THEN
                     IFA = 2
                  ELSEIF (ISOH.EQ.8) THEN
                     IFA = 3
                  ELSEIF (ISOH.EQ.16) THEN
                     IFA = 1
                  ELSEIF (ISOH.EQ.12) THEN
                     IFA = 2
                     IF (DX(IPLOT)*(Y(IKLE2(IEL,3))-YP).LT.
     &                   DY(IPLOT)*(X(IKLE2(IEL,3))-XP)) IFA = 3
                  ELSEIF (ISOH.EQ.24) THEN
                     IFA = 3
                     IF (DX(IPLOT)*(Y(IKLE2(IEL,1))-YP).LT.
     &                   DY(IPLOT)*(X(IKLE2(IEL,1))-XP)) IFA = 1
                  ELSE
                     IFA = 1
                     IF (DX(IPLOT)*(Y(IKLE2(IEL,2))-YP).LT.
     &                   DY(IPLOT)*(X(IKLE2(IEL,2))-XP)) IFA = 2
                  ENDIF
!
                  IF (ISOV.GT.0) THEN
                     A1 = (ZP-TETA(IET+ISOV-1)) / DZ(IPLOT)
                     I1 = IKLE2(IEL,IFA)
                     I2 = IKLE2(IEL,ISUI(IFA))
                     IF ((X(I2)-X(I1))*(YP-A1*DY(IPLOT)-Y(I1)).GT.
     &               (Y(I2)-Y(I1))*(XP-A1*DX(IPLOT)-X(I1))) IFA=ISOV+3
                  ENDIF
!
               ELSE
!
                  IFA = ISOV + 3
!
               ENDIF
               IF ((GOODELT(IPLOT) == 1100).AND.(ISP==1)) THEN
                  DO I10=1,3
                    IF (IFABOR(IEL,I10)==-2) IFA = I10
                  ENDDO
               ENDIF
             IF ((GOODELT(IPLOT)==2001).AND.(IFABOR(IEL,IFA)==-2)
     &                .AND.(ISP==1)) THEN
                    IF (ISOH.EQ.12) THEN
                         IF (IFA==3) THEN
                            IFA = 2
                         ELSE
                            IFA = 3
                         ENDIF
                    ELSEIF (ISOH.EQ.24) THEN
                         IF (IFA==1) THEN
                            IFA = 3
                         ELSE
                            IFA = 1
                         ENDIF
                    ENDIF
             ENDIF
!
               IEL = IFABOR(IEL,IFA)
!
               IF (IFA.LE.3) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE OF THE PRISM IS A RECTANGULAR FACE
!  =================================================================
!-----------------------------------------------------------------------
!
                  IF (IEL.GT.0) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS AN INTERIOR FACE
!  MOVES TO THE ADJACENT ELEMENT
!-----------------------------------------------------------------------
!
                     I1 = IKLE2(IEL,1)
                     I2 = IKLE2(IEL,2)
                     I3 = IKLE2(IEL,3)
!
                     ELT(IPLOT) = IEL
                     SHP1(IPLOT) = ((X(I3)-X(I2))*(YP-Y(I2))
     &                           -(Y(I3)-Y(I2))*(XP-X(I2)))*SURDET(IEL)
                     SHP2(IPLOT) = ((X(I1)-X(I3))*(YP-Y(I3))
     &                           -(Y(I1)-Y(I3))*(XP-X(I3)))*SURDET(IEL)
                     SHP3(IPLOT) = ((X(I2)-X(I1))*(YP-Y(I1))
     &                           -(Y(I2)-Y(I1))*(XP-X(I1)))*SURDET(IEL)
!
                     ISO(IPLOT) = ISOV
!
         IF (SHP1(IPLOT).LT.EPSILO) ISO(IPLOT)=IBSET(ISO(IPLOT),2)
         IF (SHP2(IPLOT).LT.EPSILO) ISO(IPLOT)=IBSET(ISO(IPLOT),3)
         IF (SHP3(IPLOT).LT.EPSILO) ISO(IPLOT)=IBSET(ISO(IPLOT),4)
!
                     GOTO 50
!
                  ENDIF
!BD_INCKA MODIFICATION FOR PARALLEL MODE
!
!-----------------------------------------------------------------------
! HERE: TESTS PASSING TO THE NEIGHBOUR SUBDOMAIN AND COLLECTS DATA
!-----------------------------------------------------------------------
!
!           THIS CAN ONLY HAPPEN IN PARALLEL MODE
            IF(IEL==-2) THEN ! INTERFACE CROSSING
              CALL COLLECT_CHAR
     &            (IPID, IPLOT, ELT(IPLOT), IFA, IET, ISP,
     &             NSP(IPLOT), XP,YP,ZP,
     &         DX(IPLOT),DY(IPLOT),DZ(IPLOT),IFAPAR,NCHDIM,NCHARA,IFF)
!             CAN ONLY HAPPEN IN PARALLEL MODE
              TEST3(IPLOT) = 0.D0
                   GOTO 40
!
! ALTHOUGH A LOST TRACEBACK DETECTED AND SAVED HERE, ALLOWS THE
! FURTHER TREATMENT AS IF NOTHING HAPPENED IN ORDER TO APPLY
! THE JMH ALGORITHM WITH "TEST" FIELD OF MARKERS
!
            ENDIF
!BD_INCKA END OF MODIFICATION FOR PARALLEL MODE
!
                  DXP = DX(IPLOT)
                  DYP = DY(IPLOT)
                  I1  = IKLE2(ELT(IPLOT),IFA)
                  I2  = IKLE2(ELT(IPLOT),ISUI(IFA))
                  DX1 = X(I2) - X(I1)
                  DY1 = Y(I2) - Y(I1)
!
                  IF (IEL.EQ.-1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS A SOLID BOUNDARY
!  SETS SHP TO 0, END OF TRACING BACK
!-----------------------------------------------------------------------
!
                     SHP1(IPLOT) = 0.0D0
                     SHP2(IPLOT) = 0.0D0
                     SHP3(IPLOT) = 0.0D0
                     SHZ(IPLOT)  = 0.D0
                     NSP(IPLOT) = ISP
                     ETA(IPLOT) = IET
!                     EXIT
                     GOTO 40
!                      DOSTOP = .TRUE.
!                      GOTO 50
!
                  ENDIF
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS A LIQUID BOUNDARY
!  ENDS TRACING BACK (SIGN OF ELT)
!-----------------------------------------------------------------------
!
                  A1 = (DXP*(YP-Y(I1))-DYP*(XP-X(I1)))/(DXP*DY1-DYP*DX1)
                  IF (A1.GT.EPM1) A1 = 1.D0
                  IF (A1.LT.EPSI) A1 = 0.D0
!FGB
                  IF (IFA.EQ.1) THEN
                    SHP1(IPLOT) = 1.D0 - A1
                    SHP2(IPLOT) = A1
                    SHP3(IPLOT) = 0.D0
                  ELSEIF (IFA.EQ.2) THEN
                    SHP2(IPLOT) = 1.D0 - A1
                    SHP3(IPLOT) = A1
                    SHP1(IPLOT) = 0.D0
                  ELSE
                    SHP3(IPLOT) = 1.D0 - A1
                    SHP1(IPLOT) = A1
                    SHP2(IPLOT) = 0.D0
                  ENDIF
                   XPLOT(IPLOT) = X(I1) + A1 * DX1
                   YPLOT(IPLOT) = Y(I1) + A1 * DY1
                   IF (ABS(DXP).GT.ABS(DYP)) THEN
                      A1 = (XP-XPLOT(IPLOT))/DXP
                   ELSE
                      A1 = (YP-YPLOT(IPLOT))/DYP
                   ENDIF
                   IF (A1.GT.EPM1) A1 = 1.D0
                   IF (A1.LT.EPSI) A1 = 0.D0
                   ETA(IPLOT)=IET
                   ZPLOT(IPLOT) = ZP - A1*DZ(IPLOT)
                   SHZ(IPLOT) = (ZPLOT(IPLOT)-TETA(IET))
     &                       / (TETA(IET+1)-TETA(IET))
                   NSP(IPLOT) = ISP
!
               ELSE
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE OF THE PRISM IS A TRIANGULAR FACE
!  ===============================================================
!-----------------------------------------------------------------------
!
                  IFA = IFA - 4
!
                  IF (IEL.EQ.1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS AN INTERIOR FACE
!  MOVES TO THE ADJACENT ELEMENT
!-----------------------------------------------------------------------
!
                     ETA(IPLOT) = IET + IFA + IFA - 1
                     IF (ETA(IPLOT).EQ.NPLAN+1) THEN
                         ETA(IPLOT)=1
                         ZP=ZP-2*3.14159265D0
                         ZPLOT(IPLOT)=ZP
                     ENDIF
                     IF (ETA(IPLOT).EQ.0) THEN
                         ETA(IPLOT) = NPLAN
                         ZP=ZP+2*3.14159265D0
                         ZPLOT(IPLOT)=ZP
                     ENDIF
                     SHZ(IPLOT) = (ZP-TETA(ETA(IPLOT)))
     &                   / (TETA(ETA(IPLOT)+1)-TETA(ETA(IPLOT)))
!
                     ISO(IPLOT) = ISOH
!
               IF (SHZ(IPLOT).LT.EPSILO)
     &             ISO(IPLOT)=IBSET(ISO(IPLOT),0)
               IF (SHZ(IPLOT).GT.1.D0-EPSILO)
     &             ISO(IPLOT)=IBSET(ISO(IPLOT),1)
!
                     GOTO 50
!
                  ELSE
!
!         WRITE(LU,*)'YA UN PROBLEME',IEL,IPLOT
!         WRITE(LU,*)'SHP',SHP1(IPLOT),SHP2(IPLOT),SHP3(IPLOT)
!         WRITE(LU,*)'SHZ',SHZ(IPLOT)
!         WRITE(LU,*)'DXYZ',DX(IPLOT),DY(IPLOT),DZ(IPLOT)
!         WRITE(LU,*)'XYZ',XPLOT(IPLOT),YPLOT(IPLOT),ZPLOT(IPLOT)
!
                  STOP
                  ENDIF
               ENDIF
!
            ENDIF
!
40       CONTINUE
!         ENDDO
!
20    CONTINUE
!
!-----------------------------------------------------------------------
!
      RETURN
      END SUBROUTINE PIEDS_TOMAWAC
!
  !---------------------------------------------------------------------
  ! PREPARES THE INITIAL SEND OF THE LOST CHARACTERISTICS.
  ! THE FIELDS ARE PREPARED ACCORDING THE MPI_ALLTOALL(V) REQUIREMENTS.
  !---------------------------------------------------------------------
!
        SUBROUTINE PREP_INITIAL_SEND(NSEND,NLOSTCHAR,NCHARA)
!
          USE BIEF_DEF, ONLY : NCSIZE
          IMPLICIT NONE
          INTEGER LNG,LU
          COMMON/INFO/LNG,LU
          INTEGER, INTENT(IN)    :: NSEND(*)
          INTEGER, INTENT(OUT)   :: NLOSTCHAR(*)
          INTEGER, INTENT(INOUT) :: NCHARA(*)
          INTEGER I,N
          IF (NCHARA(IFREQ)==0) RETURN
          SENDCOUNTS(:,IFREQ)=HEAPCOUNTS(:,IFREQ)
          SDISPLS(1,IFREQ) = 0 ! CONTIGUOUS DATA
          DO I=2,NCSIZE
            SDISPLS(I,IFREQ) = SDISPLS(I-1,IFREQ)+SENDCOUNTS(I-1,IFREQ)
          END DO
          ICHA(:,IFREQ)=SENDCOUNTS(:,IFREQ) ! A RUNNING COUNTER PARTITION-WISE
          DO I=1,NCHARA(IFREQ)
            ! HEAPCHAR(I)%NEPID+1 - THE PARTITION SENT TO / OR -1
            IF(HEAPCHAR(I,IFREQ)%NEPID>=0) THEN
              N=HEAPCHAR(I,IFREQ)%NEPID+1
              SENDCHAR(SDISPLS(N,IFREQ)+ICHA(N,IFREQ),IFREQ)=
     &                                               HEAPCHAR(I,IFREQ)
              ICHA(N,IFREQ)=ICHA(N,IFREQ)-1
            ENDIF
          ENDDO
          NLOSTCHAR(IFREQ) = NSEND(IFREQ)
          HEAPCOUNTS(:,IFREQ)=0
          NCHARA(IFREQ)=0
          RETURN
        END SUBROUTINE PREP_INITIAL_SEND
!
        SUBROUTINE PREP_INITIAL_SEND_4D(NSEND,NLOSTCHAR,NCHARA)
!
          USE BIEF_DEF, ONLY : NCSIZE
          IMPLICIT NONE
          INTEGER LNG,LU
          COMMON/INFO/LNG,LU
          INTEGER, INTENT(IN)    :: NSEND(*)
          INTEGER, INTENT(OUT)   :: NLOSTCHAR(*)
          INTEGER, INTENT(INOUT) :: NCHARA(*)
          INTEGER I,N
          IF (NCHARA(IFREQ)==0) RETURN
          SENDCOUNTS(:,IFREQ)=HEAPCOUNTS(:,IFREQ)
          SDISPLS(1,IFREQ) = 0 ! CONTIGUOUS DATA
          DO I=2,NCSIZE
            SDISPLS(I,IFREQ) = SDISPLS(I-1,IFREQ)+SENDCOUNTS(I-1,IFREQ)
          END DO
          ICHA(:,IFREQ)=SENDCOUNTS(:,IFREQ) ! A RUNNING COUNTER PARTITION-WISE
          DO I=1,NCHARA(IFREQ)
            ! HEAPCHAR(I)%NEPID+1 - THE PARTITION SENT TO / OR -1
            IF(HEAPCHAR_4D(I,IFREQ)%NEPID>=0) THEN
              N=HEAPCHAR_4D(I,IFREQ)%NEPID+1
              SENDCHAR_4D(SDISPLS(N,IFREQ)+ICHA(N,IFREQ),IFREQ)=
     &                                             HEAPCHAR_4D(I,IFREQ)
              ICHA(N,IFREQ)=ICHA(N,IFREQ)-1
            ENDIF
          ENDDO
          NLOSTCHAR(IFREQ) = NSEND(IFREQ)
          HEAPCOUNTS(:,IFREQ)=0
          NCHARA(IFREQ)=0
          RETURN
        END SUBROUTINE PREP_INITIAL_SEND_4D
  !---------------------------------------------------------------------
  ! THE GLOBAL COMMUNICATION OF LOST CHARACTERISTICS - ALL-TO-ALL
  ! (THIS IS THE HEART OF ALL THINGS / THE GLOBAL COMMUNICATION).
  ! THE DATA IS SENT AND (NOTE!) RECEIVED -SORTED- ACCORDING TO THE
  ! MPI_ALLTOALL(V) SPECIFICATION IN A CONTIGUOUS FIELDS.
  ! DATA FOR A GIVEN PROCESSOR/PARTITION IN FIELD SECTIONS DESCRIBED BY
  ! DISPLACEMENTS SDISPLS AND RDISPLS.
  !---------------------------------------------------------------------
        SUBROUTINE GLOB_CHAR_COMM ()
          USE BIEF_DEF, ONLY : NCSIZE
          IMPLICIT NONE
          INTEGER LNG,LU
          COMMON/INFO/LNG,LU
          INTEGER :: I,IER
!
          CALL P_MPI_ALLTOALL(SENDCOUNTS(:,IFREQ),1,MPI_INTEGER,
     &                        RECVCOUNTS(:,IFREQ),1,MPI_INTEGER,
     &                        MPI_COMM_WORLD,IER)
          IF (IER/=MPI_SUCCESS) THEN
            WRITE(LU,*)
     &       ' @STREAMLINE::GLOB_CHAR_COMM::MPI_ALLTOALL ERROR: ',IER
            CALL PLANTE(1)
          ENDIF
          RDISPLS(1,IFREQ) = 0 ! SAVES THE RECEIVED DATA CONTIGUOUSLY
          DO I=2,NCSIZE
            RDISPLS(I,IFREQ) = RDISPLS(I-1,IFREQ)+RECVCOUNTS(I-1,IFREQ)
          END DO
          CALL P_MPI_ALLTOALLV
     &      (SENDCHAR(:,IFREQ),SENDCOUNTS(:,IFREQ),SDISPLS(:,IFREQ),
     &       CHARACTERISTIC,
     &       RECVCHAR(:,IFREQ),RECVCOUNTS(:,IFREQ),RDISPLS(:,IFREQ),
     &       CHARACTERISTIC,
     &       MPI_COMM_WORLD,IER)
          IF (IER/=MPI_SUCCESS) THEN
            WRITE(LU,*)
     &       ' @STREAMLINE::GLOB_CHAR_COMM::MPI_ALLTOALLV ERROR: ',IER
            CALL PLANTE(1)
            STOP
          ENDIF
          RETURN
        END SUBROUTINE GLOB_CHAR_COMM
!
        SUBROUTINE GLOB_CHAR_COMM_4D ()
          USE BIEF_DEF, ONLY : NCSIZE
          IMPLICIT NONE
          INTEGER LNG,LU
          COMMON/INFO/LNG,LU
          INTEGER :: I,IER
!
          CALL P_MPI_ALLTOALL(SENDCOUNTS(:,IFREQ),1,MPI_INTEGER,
     &          RECVCOUNTS(:,IFREQ),1,MPI_INTEGER,
     &          MPI_COMM_WORLD,IER)
          IF (IER/=MPI_SUCCESS) THEN
            WRITE(LU,*)
     &       ' @STREAMLINE::GLOB_CHAR_COMM::MPI_ALLTOALL ERROR: ',IER
            CALL PLANTE(1)
          ENDIF
          RDISPLS(1,IFREQ) = 0 ! SAVES THE RECEIVED DATA CONTIGUOUSLY
          DO I=2,NCSIZE
            RDISPLS(I,IFREQ) = RDISPLS(I-1,IFREQ)+RECVCOUNTS(I-1,IFREQ)
          END DO
          CALL P_MPI_ALLTOALLV_TOMA2
     &      (SENDCHAR_4D(:,IFREQ),SENDCOUNTS(:,IFREQ),SDISPLS(:,IFREQ),
     &       CHARACTER_4D,
     &       RECVCHAR_4D(:,IFREQ),RECVCOUNTS(:,IFREQ),RDISPLS(:,IFREQ),
     &       CHARACTER_4D,
     &       MPI_COMM_WORLD,IER)
          IF (IER/=MPI_SUCCESS) THEN
            WRITE(LU,*)
     &       ' @STREAMLINE::GLOB_CHAR_COMM::MPI_ALLTOALLV ERROR: ',IER
            CALL PLANTE(1)
            STOP
          ENDIF
!
          RETURN
        END SUBROUTINE GLOB_CHAR_COMM_4D
!
!
        SUBROUTINE GLOB_FONCTION_COMM ()
          USE BIEF_DEF, ONLY : NCSIZE
          IMPLICIT NONE
          INTEGER LNG,LU
          COMMON/INFO/LNG,LU
          INTEGER :: I,IER
          CALL P_MPI_ALLTOALLV_TOMA3
     &      (F_SEND,RECVCOUNTS(:,IFREQ),RDISPLS(:,IFREQ),
     &       FONCTION,
     &       F_RECV,SENDCOUNTS(:,IFREQ),SDISPLS(:,IFREQ),
     &       FONCTION,
     &       MPI_COMM_WORLD,IER)
          IF (IER/=MPI_SUCCESS) THEN
            WRITE(LU,*)
     &       ' @STREAMLINE::GLOB_CHAR_COMM::MPI_ALLTOALLV ERROR: ',IER
            CALL PLANTE(1)
            STOP
          ENDIF
          RETURN
        END SUBROUTINE GLOB_FONCTION_COMM
!
        SUBROUTINE GLOB_FONCTION_COMM_4D ()
          USE BIEF_DEF, ONLY : NCSIZE
          IMPLICIT NONE
          INTEGER LNG,LU
          COMMON/INFO/LNG,LU
          INTEGER :: I,IER
          CALL P_MPI_ALLTOALLV_TOMA4
     &      (F_SEND_4D,RECVCOUNTS(:,IFREQ),RDISPLS(:,IFREQ),
     &       FONCTION_4D,
     &       F_RECV_4D,SENDCOUNTS(:,IFREQ),SDISPLS(:,IFREQ),
     &       FONCTION_4D,
     &       MPI_COMM_WORLD,IER)
          IF (IER/=MPI_SUCCESS) THEN
            WRITE(LU,*)
     &       ' @STREAMLINE::GLOB_CHAR_COMM::MPI_ALLTOALLV ERROR: ',IER
            CALL PLANTE(1)
            STOP
          ENDIF
          RETURN
        END SUBROUTINE GLOB_FONCTION_COMM_4D
!
!-----------------------------------------------------------------------
! 3D STREAMLINE TRACKING FOR ADDITIONAL CHARACTERISTICS ARRIVED FROM
! NEIGHBOUR PARTITIONS - THERE'S NPLOT=NARRV OF THEM
! NOTE CHANGES IN THE INTERFACE COMPARED TO SCHAR11
! ISPDONE :: NUMBER OF ALREADY DONE R-K STEPS BY A TRACEBACK
! IFAPAR  :: DELIVERS LOCAL ELEMENT NUMBER AND THE PARTITION NR THERE
!            WHEN CROSSING THE INTERFACE VIA A HALO ELEMENT FACE
!-----------------------------------------------------------------------
! JAJ PINXIT BASED ON CHAR11 FRI JUL 18 14:30:18 CEST 2008
!
!                       ****************************
                        SUBROUTINE PIEDS_TOMAWAC_MPI
!                       ****************************
!
     & ( U , V , W , DT , NRK , X ,Y,TETA,IKLE2,IFABOR ,ETAS,
     &   XPLOT , YPLOT , ZPLOT , DX , DY , DZ , SHP1,SHP2,SHP3
     &    , SHZ , ELT , ETA,
     &   NPLOT , NPOIN2 , NELEM2 , NPLAN , IFF,
     &   SURDET , SENS , IFAPAR, NOMB,NARRV,CHARAC2)
!
      USE BIEF
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER           :: SENS,NPLAN,NOMB,NARRV
      INTEGER           :: NPOIN2,NELEM2,NPLOT,NRK
      INTEGER           :: IKLE2(NELEM2,3)
      INTEGER           :: ELT(NPLOT),NSP(NPLOT)
      INTEGER           :: ISPDONE(NPLOT)
      DOUBLE PRECISION  :: U(NPOIN2,NPLAN),V(NPOIN2,NPLAN)
      DOUBLE PRECISION  :: W(NPOIN2,NPLAN),SURDET(NELEM2)
      DOUBLE PRECISION  :: XPLOT(NPLOT),YPLOT(NPLOT)
      DOUBLE PRECISION  :: ZPLOT(NPLOT)
      DOUBLE PRECISION  :: SHP1(NPLOT),SHZ(NPLOT)
      DOUBLE PRECISION  :: SHP2(NPLOT),SHP3(NPLOT)
      DOUBLE PRECISION  :: X(NPOIN2),Y(NPOIN2),DT
      DOUBLE PRECISION  :: TETA(NPLAN+1)
      DOUBLE PRECISION  :: DX(NPLOT),DY(NPLOT)
      DOUBLE PRECISION  :: DZ(NPLOT),TEST3(NPLOT)
      INTEGER           :: IFABOR(NELEM2,5)
      INTEGER           :: ETA(NPLOT),ETAS(NPLAN)
      INTEGER           :: IFAPAR(6,*)
      INTEGER           :: IFF
      TYPE (CHARAC_TYPE):: CHARAC2(NPLOT)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELE,ISO
      INTEGER IPLOT,ISP,I1,I2,I3,IEL,IET,IET2,ISOH,ISOV,IFA,ISUI(3)
      INTEGER IPROC,ILOC,NEPID,ITE,MYPID,IORI
!
      DOUBLE PRECISION PAS,EPSILO,A1,DX1,DY1,DXP,DYP,XP,YP,ZP,DENOM
      DOUBLE PRECISION DELTAZ,EPSDZ,PAS2,EPM1,EPSI,EPSILO2
!
      INTRINSIC ABS
!
      INTEGER P_IMAX
      EXTERNAL P_IMAX
!
      DATA ISUI   / 2 , 3 , 1 /
      DATA EPSILO / -1.D-6 /
      DATA EPSILO2 / -1.D-16 /
      DATA EPSDZ /1.D-4/
      DATA EPSI /1.D-12/
!
!***********************************************************************
!  DEBUG PRINTOUTS
!
      IF (NCSIZE<=1) THEN
        WRITE(LU,*) 'CALLING PIEDS_TOMAWAC_MPI IN A SERIAL RUN.'
        CALL PLANTE(1)
        STOP
      ENDIF
!
!-----------------------------------------------------------------------
! FILLS ELT,NSP,XPLOT,YPLOT, COMPUTES VALID SHP FUNCTIONS, RANGE 1..NPLOT
! IMPORTANT: THE COMPUTED SHP(IPLOT) APPLIED LATER ON
! IN THE INTERPOLATION!...
!
      TEST3 = 1.D0
      EPM1 = 1.D0-EPSI
      DO IPLOT = 1,NPLOT
        XPLOT(IPLOT)   = CHARAC2(IPLOT)%XP
        YPLOT(IPLOT)   = CHARAC2(IPLOT)%YP
        ZPLOT(IPLOT)   = CHARAC2(IPLOT)%ZP
        DX(IPLOT)      = CHARAC2(IPLOT)%DX
        DY(IPLOT)      = CHARAC2(IPLOT)%DY
        DZ(IPLOT)      = CHARAC2(IPLOT)%DZ
        ELT(IPLOT)     = CHARAC2(IPLOT)%INE
        ETA(IPLOT)     = CHARAC2(IPLOT)%KNE
        NSP(IPLOT)     = CHARAC2(IPLOT)%NSP ! R-K STEPS TO BE FULFILLED
        ISPDONE(IPLOT) = CHARAC2(IPLOT)%ISP ! R-K STEPS ALREADY DONE
        MYPID          = CHARAC2(IPLOT)%MYPID
        IORI           = CHARAC2(IPLOT)%IOR
        PAS = SENS * DT / NSP(IPLOT)
        IEL = ELT(IPLOT)
        IET = ETA(IPLOT)
        XP  = XPLOT(IPLOT)
        YP  = YPLOT(IPLOT)
        ZP  = ZPLOT(IPLOT)
        I1 = IKLE2(IEL,1)
        I2 = IKLE2(IEL,2)
        I3 = IKLE2(IEL,3)
        SHP1(IPLOT) = ((X(I3)-X(I2))*(YP-Y(I2))
     &                 -(Y(I3)-Y(I2))*(XP-X(I2)))*SURDET(IEL)
        SHP2(IPLOT) = ((X(I1)-X(I3))*(YP-Y(I3))
     &                 -(Y(I1)-Y(I3))*(XP-X(I3)))*SURDET(IEL)
        SHP3(IPLOT) = ((X(I2)-X(I1))*(YP-Y(I1))
     &                 -(Y(I2)-Y(I1))*(XP-X(I1)))*SURDET(IEL)
        SHZ(IPLOT) = (ZP-TETA(IET)) / (TETA(IET+1)-TETA(IET))
!       ASSUMES ALL ARE LOCALISED, IT WILL BE SET OTHERWISE IF LOST-AGAIN
          CHARAC2(IPLOT)%NEPID=-1
!
!
! IF SOME OF THE SHP FUNCTIONS ARE NEGATIVE, WE ARE IN A WRONG ELEMENT
! (XP,YP) PROBABLY DEEPER IN THE SUBDOMAIN THAN THE HALO CELL GIVEN IN "INE"
!
        DO  WHILE((SHP1(IPLOT)<EPSILO).OR.(SHP2(IPLOT)<EPSILO)
     &         .OR.(SHP3(IPLOT)<EPSILO).OR.SHZ(IPLOT).LT.EPSILO.OR.
     &          SHZ(IPLOT).GT.1.D0-EPSILO)
          ISO=0
          IF(SHP1(IPLOT).LT.   EPSILO) ISO=IBSET(ISO,2)
          IF(SHP2(IPLOT).LT.   EPSILO) ISO=IBSET(ISO,3)
          IF(SHP3(IPLOT).LT.   EPSILO) ISO=IBSET(ISO,4)
          IF(SHZ(IPLOT).LT.     EPSILO) ISO=IBSET(ISO,0)
          IF(SHZ(IPLOT).GT.1.D0-EPSILO) ISO=IBSET(ISO,1)
               ISOH = IAND(ISO,28)
               ISOV = IAND(ISO, 3)
               IEL = ELT(IPLOT)
               IET = ETA(IPLOT)
               XP = XPLOT(IPLOT)
               YP = YPLOT(IPLOT)
               ZP = ZPLOT(IPLOT)
!
               IF (ISOH.NE.0) THEN
!
                  IF (ISOH.EQ.4) THEN
                     IFA = 2
                  ELSEIF (ISOH.EQ.8) THEN
                     IFA = 3
                  ELSEIF (ISOH.EQ.16) THEN
                     IFA = 1
                  ELSEIF (ISOH.EQ.12) THEN
                     IFA = 2
                     IF (DX(IPLOT)*(Y(IKLE2(IEL,3))-YP).GT.
     &                   DY(IPLOT)*(X(IKLE2(IEL,3))-XP)) IFA = 3
                  ELSEIF (ISOH.EQ.24) THEN
                     IFA = 3
                     IF (DX(IPLOT)*(Y(IKLE2(IEL,1))-YP).GT.
     &                   DY(IPLOT)*(X(IKLE2(IEL,1))-XP)) IFA = 1
                  ELSE
                     IFA = 1
                     IF (DX(IPLOT)*(Y(IKLE2(IEL,2))-YP).GT.
     &                   DY(IPLOT)*(X(IKLE2(IEL,2))-XP)) IFA = 2
                  ENDIF
!
                   IF (ISOV.GT.0) THEN
                     A1 = (ZP-TETA(IET+ISOV-1)) / DZ(IPLOT)
                     I1 = IKLE2(IEL,IFA)
                     I2 = IKLE2(IEL,ISUI(IFA))
                     IF ((X(I2)-X(I1))*(YP-A1*DY(IPLOT)-Y(I1)).GT.
     &                (Y(I2)-Y(I1))*(XP-A1*DX(IPLOT)-X(I1))) IFA=ISOV+3
                   ENDIF
!
               ELSE
!
                  IFA = ISOV + 3
!
               ENDIF
!
!
               IEL = IFABOR(IEL,IFA)
!
               IF (IFA.LE.3) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE OF THE PRISM IS A RECTANGULAR FACE
!  =================================================================
!-----------------------------------------------------------------------
!
                  IF (IEL.GT.0) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS AN INTERIOR FACE
!  MOVES TO THE ADJACENT ELEMENT
!-----------------------------------------------------------------------
!
                     I1 = IKLE2(IEL,1)
                     I2 = IKLE2(IEL,2)
                     I3 = IKLE2(IEL,3)
!
                     ELT(IPLOT) = IEL
                     SHP1(IPLOT) = ((X(I3)-X(I2))*(YP-Y(I2))
     &                           -(Y(I3)-Y(I2))*(XP-X(I2)))*SURDET(IEL)
                     SHP2(IPLOT) = ((X(I1)-X(I3))*(YP-Y(I3))
     &                           -(Y(I1)-Y(I3))*(XP-X(I3)))*SURDET(IEL)
                     SHP3(IPLOT) = ((X(I2)-X(I1))*(YP-Y(I1))
     &                           -(Y(I2)-Y(I1))*(XP-X(I1)))*SURDET(IEL)
!
                     ISO = ISOV
!
                      IF(SHP1(IPLOT).LT.EPSILO) ISO=IBSET(ISO,2)
                      IF(SHP2(IPLOT).LT.EPSILO) ISO=IBSET(ISO,3)
                      IF(SHP3(IPLOT).LT.EPSILO) ISO=IBSET(ISO,4)
!
                   CHARAC2(IPLOT)%INE=IEL
                    CYCLE
!
                  ENDIF
!
!-----------------------------------------------------------------------
! HERE: TESTS PASSING TO THE NEIGHBOUR SUBDOMAIN AND COLLECTS DATA
!-----------------------------------------------------------------------
!
               IF(IEL==-2) THEN  ! A LOST-AGAIN TRACEBACK DETECTED
!
                 IPROC=IFAPAR(IFA,ELT(IPLOT))
                 ILOC=IFAPAR(IFA+3,ELT(IPLOT))
                 CHARAC2(IPLOT)%XP=XPLOT(IPLOT) ! NEW POSITION
                 CHARAC2(IPLOT)%YP=YPLOT(IPLOT) ! IN THE OLD ELEMENT
                 CHARAC2(IPLOT)%ZP=ZPLOT(IPLOT) ! IN THE OLD ELEMENT
                 CHARAC2(IPLOT)%DX=DX(IPLOT) ! NEW POSITION
                 CHARAC2(IPLOT)%DY=DY(IPLOT) ! IN THE OLD ELEMENT
                 CHARAC2(IPLOT)%DZ=DZ(IPLOT) ! IN THE OLD ELEMENT
                 CHARAC2(IPLOT)%NEPID=IPROC
                 CHARAC2(IPLOT)%INE=ILOC
                 CHARAC2(IPLOT)%KNE=ETA(IPLOT)
!
                   TEST3(IPLOT)=0.D0
                 EXIT
!
               ENDIF
!
!-----------------------------------------------------------------------
! TREATS SOLID OR LIQUID BOUNDARIES DIFFERENTLY
!-----------------------------------------------------------------------
!
                  DXP = DX(IPLOT)
                  DYP = DY(IPLOT)
                  I1  = IKLE2(ELT(IPLOT),IFA)
                  I2  = IKLE2(ELT(IPLOT),ISUI(IFA))
                  DX1 = X(I2) - X(I1)
                  DY1 = Y(I2) - Y(I1)
!
                  IF(IEL.EQ.-1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS A SOLID BOUNDARY
!  PROJECTS THE RELICAT ON THE BOUNDARY AND MOVES
!-----------------------------------------------------------------------
!
                   ETA(IPLOT) = IET
                    SHP1(IPLOT) = 0.D0
                    SHP2(IPLOT) = 0.D0
                    SHP3(IPLOT) = 0.D0
                   SHZ(IPLOT) = 0.0D0
                   ISPDONE(IPLOT) = NSP(IPLOT)+1
                   CHARAC2(IPLOT)%INE = ELT(IPLOT)
                   CHARAC2(IPLOT)%KNE = ETA(IPLOT)
                   CHARAC2(IPLOT)%ISP = NSP(IPLOT) +1
                      EXIT
!                      A1 = (DXP*DX1+DYP*DY1) / (DX1**2+DY1**2)
!                      DX(IPLOT) = A1 * DX1
!                      DY(IPLOT) = A1 * DY1
! !
!                      A1=((XP-X(I1))*DX1+(YP-Y(I1))*DY1)/(DX1**2+DY1**2)
!                   IF (IFA.EQ.1) THEN
!                     SHP1(IPLOT) = 1.D0 - A1
!                     SHP2(IPLOT) = A1
!                     SHP3(IPLOT) = 0.D0
!                   ELSEIF (IFA.EQ.2) THEN
!                     SHP2(IPLOT) = 1.D0 - A1
!                     SHP3(IPLOT) = A1
!                     SHP1(IPLOT) = 0.D0
!                   ELSE
!                     SHP3(IPLOT) = 1.D0 - A1
!                     SHP1(IPLOT) = A1
!                     SHP2(IPLOT) = 0.D0
!                   ENDIF
!                      XPLOT(IPLOT) = X(I1) + A1 * DX1
!                      YPLOT(IPLOT) = Y(I1) + A1 * DY1
! !
!                      ISO = ISOV
! !
!                      IF(SHP1(IPLOT).LT.EPSILO) ISO=IBSET(ISO,2)
!                      IF(SHP2(IPLOT).LT.EPSILO) ISO=IBSET(ISO,3)
!                      IF(SHP3(IPLOT).LT.EPSILO) ISO=IBSET(ISO,4)
!                    CHARAC2(IPLOT)%INE = ELT(IPLOT)
!                    CHARAC2(IPLOT)%KNE = ETA(IPLOT)
!                    CYCLE
                  ENDIF
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS A LIQUID BOUNDARY
!  ENDS TRACING BACK (SIGN OF ELT)
!
!     OR
!
!  HERE: THE EXIT FACE IS A SUB-DOMAIN INTERFACE
!  INTERFACE POINT WILL BE TREATED IN THE NEXT SUB-DOMAIN
!  ONLY SETS TEST TO ZERO HERE
!-----------------------------------------------------------------------
!
!>>>>
                 A1 = (DXP*(YP-Y(I1))-DYP*(XP-X(I1)))/(DXP*DY1-DYP*DX1)
                  IF (A1.GT.EPM1) A1 = 1.D0
                  IF (A1.LT.EPSI) A1 = 0.D0
                  IF (IFA.EQ.1) THEN
                    SHP1(IPLOT) = 1.D0 - A1
                    SHP2(IPLOT) = A1
                    SHP3(IPLOT) = 0.D0
                  ELSEIF (IFA.EQ.2) THEN
                    SHP2(IPLOT) = 1.D0 - A1
                    SHP3(IPLOT) = A1
                    SHP1(IPLOT) = 0.D0
                  ELSE
                    SHP3(IPLOT) = 1.D0 - A1
                    SHP1(IPLOT) = A1
                    SHP2(IPLOT) = 0.D0
                  ENDIF
                  XPLOT(IPLOT) = X(I1) + A1 * DX1
                  YPLOT(IPLOT) = Y(I1) + A1 * DY1
                  IF(ABS(DXP).GT.ABS(DYP)) THEN
                     A1 = (XP-XPLOT(IPLOT))/DXP
                  ELSE
                     A1 = (YP-YPLOT(IPLOT))/DYP
                  ENDIF
                  IF (A1.GT.EPM1) A1 = 1.D0
                  IF (A1.LT.EPSI) A1 = 0.D0
                  ZPLOT(IPLOT) = ZP - A1*DZ(IPLOT)
                  SHZ(IPLOT) = (ZPLOT(IPLOT)-TETA(IET))
     &                       / (TETA(IET+1)-TETA(IET))
                  ISPDONE(IPLOT) = NSP(IPLOT)+1   ! THIS WILL FORBID ENTERING FURTHER LOOPS
                   CHARAC2(IPLOT)%INE = ELT(IPLOT)
                   CHARAC2(IPLOT)%KNE = ETA(IPLOT)
                   CHARAC2(IPLOT)%ISP = NSP(IPLOT) +1
!                 CAN ONLY HAPPEN IN PARALLEL.  ACTUALLY, NOT REQUIRED
                  IF(IEL.EQ.-2) TEST3(IPLOT) = 0.D0
                  ! A FUSE
                  IF(IEL==-2) WRITE(LU,*) ' *** SHIT IPLOT: ',IPLOT
 !                 EXIT
!
               ELSE
!
!-----------------------------------------------------------------------
!  IFA = 4 OR 5
!  HERE: THE EXIT FACE OF THE PRISM IS A TRIANGULAR FACE
!  =====================================================================
!-----------------------------------------------------------------------
!
                  IFA = IFA - 4
!                 HENCE IFA NOW EQUALS 0 OR 1
!
                  IF (IEL.EQ.1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS AN INTERIOR FACE
!  AND THERE IS NO NEED TO RE-COMPUTE THE VELOCITIES
!  MOVES TO THE ADJACENT ELEMENT
!-----------------------------------------------------------------------
!
                     ETA(IPLOT) = IET + IFA + IFA - 1
                     IF (ETA(IPLOT).EQ.NPLAN+1) THEN
                         ETA(IPLOT)=1
                         ZP=ZP-2*3.14159265D0
                         ZPLOT(IPLOT)=ZP
                     ENDIF
                     IF (ETA(IPLOT).EQ.0) THEN
                         ETA(IPLOT) = NPLAN
                         ZP=ZP+2*3.14159265D0
                         ZPLOT(IPLOT)=ZP
                     ENDIF
                     SHZ(IPLOT) = (ZP-TETA(ETA(IPLOT)))
     &                   / (TETA(ETA(IPLOT)+1)-TETA(ETA(IPLOT)))
!
                     ISO = ISOH
!
                      IF(SHZ(IPLOT).LT.     EPSILO) ISO=IBSET(ISO,0)
                      IF(SHZ(IPLOT).GT.1.D0-EPSILO) ISO=IBSET(ISO,1)
!
                   CHARAC2(IPLOT)%KNE=ETA(IPLOT)
                     CYCLE
!
                  ELSE
                    WRITE(LU,*) 'IEL',IEL
                  ENDIF
!
               ENDIF
!        ENDDO
       ENDDO
!
      ENDDO
!
!-----------------------------------------------------------------------
!  LOOP
!-----------------------------------------------------------------------
!
      DO  40 IPLOT=1,NPLOT
        MYPID          = CHARAC2(IPLOT)%MYPID
        IORI           = CHARAC2(IPLOT)%IOR
!
      PAS = SENS * DT / NSP(IPLOT)
!
!       IF (TEST3(IPLOT)>0.5D0) THEN
      DO ISP =1,NSP(IPLOT)
!       DO ISP = ISPDONE(IPLOT)+1,NSP(IPLOT)
!
!-----------------------------------------------------------------------
!  LOCATES THE END POINT OF ALL THE CHARACTERISTICS
!-----------------------------------------------------------------------
!
             ISO = 0
             PAS2=PAS
!
!                NEPID = CHARAC2(IPLOT)%NEPID
!             IF ( RECVCHAR(IPLOT,IFF)%NEPID==-1 .AND.
!     &              ISP>ISPDONE(IPLOT) ) THEN
             IF (CHARAC2(IPLOT)%NEPID==-1.AND.ISP>ISPDONE(IPLOT)
     &                                .AND.TEST3(IPLOT)>0.5D0 ) THEN
!               IF (NEPID==-1) THEN
!
!
!
               IEL = ELT(IPLOT)
               IET = ETA(IPLOT)
               I1 = IKLE2(IEL,1)
               I2 = IKLE2(IEL,2)
               I3 = IKLE2(IEL,3)
!
!
               DX(IPLOT) = ( U(I1,IET  )*SHP1(IPLOT)*(1.D0-SHZ(IPLOT))
     &                     + U(I2,IET  )*SHP2(IPLOT)*(1.D0-SHZ(IPLOT))
     &                     + U(I3,IET  )*SHP3(IPLOT)*(1.D0-SHZ(IPLOT))
     &                     + U(I1,ETAS(IET))*SHP1(IPLOT)*SHZ(IPLOT)
     &                     + U(I2,ETAS(IET))*SHP2(IPLOT)*SHZ(IPLOT)
     &                     + U(I3,ETAS(IET))*SHP3(IPLOT)*SHZ(IPLOT))*PAS
!
               DY(IPLOT) = ( V(I1,IET  )*SHP1(IPLOT)*(1.D0-SHZ(IPLOT))
     &                     + V(I2,IET  )*SHP2(IPLOT)*(1.D0-SHZ(IPLOT))
     &                     + V(I3,IET  )*SHP3(IPLOT)*(1.D0-SHZ(IPLOT))
     &                     + V(I1,ETAS(IET))*SHP1(IPLOT)*SHZ(IPLOT)
     &                     + V(I2,ETAS(IET))*SHP2(IPLOT)*SHZ(IPLOT)
     &                     + V(I3,ETAS(IET))*SHP3(IPLOT)*SHZ(IPLOT))*PAS
!
               DZ(IPLOT) = ( W(I1,IET  )*SHP1(IPLOT)*(1.D0-SHZ(IPLOT))
     &                     + W(I2,IET  )*SHP2(IPLOT)*(1.D0-SHZ(IPLOT))
     &                     + W(I3,IET  )*SHP3(IPLOT)*(1.D0-SHZ(IPLOT))
     &                     + W(I1,ETAS(IET))*SHP1(IPLOT)*SHZ(IPLOT)
     &                     + W(I2,ETAS(IET))*SHP2(IPLOT)*SHZ(IPLOT)
     &                     + W(I3,ETAS(IET))*SHP3(IPLOT)*SHZ(IPLOT))*PAS
!
!
               XP = XPLOT(IPLOT) + DX(IPLOT)
               YP = YPLOT(IPLOT) + DY(IPLOT)
               ZP = ZPLOT(IPLOT) + DZ(IPLOT)
!
               SHP1(IPLOT) = ((X(I3)-X(I2))*(YP-Y(I2))
     &                        -(Y(I3)-Y(I2))*(XP-X(I2))) * SURDET(IEL)
               SHP2(IPLOT) = ((X(I1)-X(I3))*(YP-Y(I3))
     &                        -(Y(I1)-Y(I3))*(XP-X(I3))) * SURDET(IEL)
               SHP3(IPLOT) = ((X(I2)-X(I1))*(YP-Y(I1))
     &                        -(Y(I2)-Y(I1))*(XP-X(I1))) * SURDET(IEL)
               SHZ(IPLOT) = (ZP-TETA(IET)) / (TETA(IET+1)-TETA(IET))
!
               XPLOT(IPLOT) = XP
               YPLOT(IPLOT) = YP
               ZPLOT(IPLOT) = ZP
!
!                ISO = 0
               IF(SHP1(IPLOT).LT.EPSILO) ISO=IBSET(ISO,2)
               IF(SHP2(IPLOT).LT.EPSILO) ISO=IBSET(ISO,3)
               IF(SHP3(IPLOT).LT.EPSILO) ISO=IBSET(ISO,4)
! !
               IF(SHZ(IPLOT).LT.     EPSILO) ISO=IBSET(ISO,0)
               IF(SHZ(IPLOT).GT.1.D0-EPSILO) ISO=IBSET(ISO,1)
!
!
           ! CONTINUOUS SETTING OF THE REACHED POSITION FOR IPLOT
           ! AND THE NUMBER OF STEPS DONE ALREADY
               CHARAC2(IPLOT)%XP=XPLOT(IPLOT)
               CHARAC2(IPLOT)%YP=YPLOT(IPLOT)
               CHARAC2(IPLOT)%ZP=ZPLOT(IPLOT)
               CHARAC2(IPLOT)%DX=DX(IPLOT)
               CHARAC2(IPLOT)%DY=DY(IPLOT)
               CHARAC2(IPLOT)%DZ=DZ(IPLOT)
               CHARAC2(IPLOT)%ISP=ISP
               CHARAC2(IPLOT)%KNE=ETA(IPLOT)
               CHARAC2(IPLOT)%NSP=NSP(IPLOT)
               CHARAC2(IPLOT)%INE=ELT(IPLOT)
!
            ENDIF
!
!-----------------------------------------------------------------------
!  TREATS DIFFERENTLY THE CHARACTERISTICS ISSUED FROM
!  THE START ELEMENT
!-----------------------------------------------------------------------
!
50          CONTINUE
!
!
!            IF (RECVCHAR(IPLOT,IFF)%NEPID==-1.AND.ISO.NE.0) THEN
!            IF (NEPID==-1.AND.ISO.NE.0) THEN
             IF ((ISO.NE.0).AND.(TEST3(IPLOT)>0.5D0)) THEN
!             IF (ISO.NE.0) THEN
!
!-----------------------------------------------------------------------
!  HERE: LEFT THE ELEMENT
!-----------------------------------------------------------------------
!
               ISOH = IAND(ISO,28)
               ISOV = IAND(ISO, 3)
               IEL = ELT(IPLOT)
               IET = ETA(IPLOT)
               XP = XPLOT(IPLOT)
               YP = YPLOT(IPLOT)
               ZP = ZPLOT(IPLOT)
!
!
!
!
               IF (ISOH.NE.0) THEN
!
                  IF (ISOH.EQ.4) THEN
                     IFA = 2
                  ELSEIF (ISOH.EQ.8) THEN
                     IFA = 3
                  ELSEIF (ISOH.EQ.16) THEN
                     IFA = 1
                  ELSEIF (ISOH.EQ.12) THEN
                     IFA = 2
                     IF (DX(IPLOT)*(Y(IKLE2(IEL,3))-YP).LT.
     &                   DY(IPLOT)*(X(IKLE2(IEL,3))-XP)) IFA = 3
                  ELSEIF (ISOH.EQ.24) THEN
                     IFA = 3
                     IF (DX(IPLOT)*(Y(IKLE2(IEL,1))-YP).LT.
     &                   DY(IPLOT)*(X(IKLE2(IEL,1))-XP)) IFA = 1
                  ELSE
                     IFA = 1
                     IF (DX(IPLOT)*(Y(IKLE2(IEL,2))-YP).LT.
     &                   DY(IPLOT)*(X(IKLE2(IEL,2))-XP)) IFA = 2
                  ENDIF
!
                  IF (ISOV.GT.0) THEN
                     A1 = (ZP-TETA(IET+ISOV-1)) / DZ(IPLOT)
                     I1 = IKLE2(IEL,IFA)
                     I2 = IKLE2(IEL,ISUI(IFA))
                     IF ((X(I2)-X(I1))*(YP-A1*DY(IPLOT)-Y(I1)).GT.
     &                (Y(I2)-Y(I1))*(XP-A1*DX(IPLOT)-X(I1))) IFA=ISOV+3
                  ENDIF
!
               ELSE
!
                  IFA = ISOV + 3
!
               ENDIF
!
               IEL = IFABOR(IEL,IFA)
!
               IF (IFA.LE.3) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE OF THE PRISM IS A RECTANGULAR FACE
!  =================================================================
!-----------------------------------------------------------------------
!
                  IF (IEL.GT.0) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS AN INTERIOR FACE
!  MOVES TO THE ADJACENT ELEMENT
!-----------------------------------------------------------------------
!
                     I1 = IKLE2(IEL,1)
                     I2 = IKLE2(IEL,2)
                     I3 = IKLE2(IEL,3)
!
                     ETA(IPLOT) = IET
                     ELT(IPLOT) = IEL
                     SHP1(IPLOT) = ((X(I3)-X(I2))*(YP-Y(I2))
     &                           -(Y(I3)-Y(I2))*(XP-X(I2)))*SURDET(IEL)
                     SHP2(IPLOT) = ((X(I1)-X(I3))*(YP-Y(I3))
     &                           -(Y(I1)-Y(I3))*(XP-X(I3)))*SURDET(IEL)
                     SHP3(IPLOT) = ((X(I2)-X(I1))*(YP-Y(I1))
     &                           -(Y(I2)-Y(I1))*(XP-X(I1)))*SURDET(IEL)
!
                     ISO = ISOV
!
                      IF(SHP1(IPLOT).LT.EPSILO) ISO=IBSET(ISO,2)
                      IF(SHP2(IPLOT).LT.EPSILO) ISO=IBSET(ISO,3)
                      IF(SHP3(IPLOT).LT.EPSILO) ISO=IBSET(ISO,4)
!
                     ISPDONE(IPLOT) = ISP
                    CHARAC2(IPLOT)%INE=ELT(IPLOT)
                    CHARAC2(IPLOT)%KNE=ETA(IPLOT)
!                     CYCLE
                     GOTO 50
!
                  ENDIF
!
!-----------------------------------------------------------------------
! HERE: TESTS PASSING TO THE NEIGHBOUR SUBDOMAIN AND COLLECTS DATA
!-----------------------------------------------------------------------
!
               IF(IEL==-2) THEN  ! A LOST-AGAIN TRACEBACK DETECTED
!
                 IPROC=IFAPAR(IFA,ELT(IPLOT))
                 ILOC=IFAPAR(IFA+3,ELT(IPLOT))
!
                   CHARAC2(IPLOT)%XP=XPLOT(IPLOT)
                   CHARAC2(IPLOT)%YP=YPLOT(IPLOT)
                   CHARAC2(IPLOT)%ZP=ZPLOT(IPLOT)
                   CHARAC2(IPLOT)%DX=DX(IPLOT)
                   CHARAC2(IPLOT)%DY=DY(IPLOT)
                   CHARAC2(IPLOT)%DZ=DZ(IPLOT)
                   CHARAC2(IPLOT)%ISP=ISP
                   CHARAC2(IPLOT)%NEPID=IPROC
                   CHARAC2(IPLOT)%INE=ILOC
                   CHARAC2(IPLOT)%KNE=ETA(IPLOT)
                   ISPDONE(IPLOT) = ISP
!
                  TEST3(IPLOT) = 0.D0
!
                 EXIT ! LOOP ON NSP
!
               ENDIF
!
!-----------------------------------------------------------------------
! TREATS SOLID OR LIQUID BOUNDARIES DIFFERENTLY
!-----------------------------------------------------------------------
!
                  DXP = DX(IPLOT)
                  DYP = DY(IPLOT)
                  I1  = IKLE2(ELT(IPLOT),IFA)
                  I2  = IKLE2(ELT(IPLOT),ISUI(IFA))
                  DX1 = X(I2) - X(I1)
                  DY1 = Y(I2) - Y(I1)
!
                  IF(IEL.EQ.-1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS A SOLID BOUNDARY
!  PROJECTS THE RELICAT ON THE BOUNDARY AND MOVES
!-----------------------------------------------------------------------
!
                        SHP1(IPLOT) = 0.0D0
                        SHP2(IPLOT) = 0.0D0
                        SHP3(IPLOT) = 0.0D0
                        ISPDONE(IPLOT) = NSP(IPLOT)+1
                        SHZ(IPLOT) = 0.D0
                        ETA(IPLOT) = IET
                   CHARAC2(IPLOT)%INE=ELT(IPLOT)
                   CHARAC2(IPLOT)%KNE=ETA(IPLOT)
                   CHARAC2(IPLOT)%ISP=NSP(IPLOT)+1
!
!                     GOTO 40
                      EXIT
!                       CYCLE
!
                  ENDIF
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS A LIQUID BOUNDARY
!  ENDS TRACING BACK (SIGN OF ELT)
!
!     OR
!
!  HERE: THE EXIT FACE IS A SUB-DOMAIN INTERFACE
!  INTERFACE POINT WILL BE TREATED IN THE NEXT SUB-DOMAIN
!  ONLY SETS TEST TO ZERO HERE
!-----------------------------------------------------------------------
!
!>>>>
                 A1 = (DXP*(YP-Y(I1))-DYP*(XP-X(I1)))/(DXP*DY1-DYP*DX1)
!
                  IF (A1.GT.EPM1) A1 = 1.D0
                  IF (A1.LT.EPSI) A1 = 0.D0
                  IF (IFA.EQ.1) THEN
                    SHP1(IPLOT) = 1.D0 - A1
                    SHP2(IPLOT) = A1
                    SHP3(IPLOT) = 0.D0
                  ELSEIF (IFA.EQ.2) THEN
                    SHP2(IPLOT) = 1.D0 - A1
                    SHP3(IPLOT) = A1
                    SHP1(IPLOT) = 0.D0
                  ELSE
                    SHP3(IPLOT) = 1.D0 - A1
                    SHP1(IPLOT) = A1
                    SHP2(IPLOT) = 0.D0
                  ENDIF
                  XPLOT(IPLOT) = X(I1) + A1 * DX1
                  YPLOT(IPLOT) = Y(I1) + A1 * DY1
                  IF(ABS(DXP).GT.ABS(DYP)) THEN
                    A1 = (XP-XPLOT(IPLOT))/DXP
                  ELSE
                    A1 = (YP-YPLOT(IPLOT))/DYP
                  ENDIF
                  IF (A1.GT.EPM1) A1 = 1.D0
                  IF (A1.LT.EPSI) A1 = 0.D0
!                  IF (A1.GT.1.D0) A1 = 1.D0
!                  IF (A1.LT.0.D0) A1 = 0.D0
!                  ISO = ISOV
                  ZPLOT(IPLOT) = ZP - A1*DZ(IPLOT)
                  SHZ(IPLOT) = (ZPLOT(IPLOT)-TETA(IET))
     &                       / (TETA(IET+1)-TETA(IET))
!                  ELT(IPLOT) = - SENS * ELT(IPLOT)
!                  NSP(IPLOT) = ISP
                  ISPDONE(IPLOT) = NSP(IPLOT)+1
                   CHARAC2(IPLOT)%INE=ELT(IPLOT)
                   CHARAC2(IPLOT)%KNE=ETA(IPLOT)
                   CHARAC2(IPLOT)%ISP=NSP(IPLOT)+1
!
!                 CAN ONLY HAPPEN IN PARALLEL.  ACTUALLY, NOT REQUIRED
!                  GOTO 50
!                   GOTO 40
                  IF(IEL.EQ.-2) TEST3(IPLOT) = 0.D0
                  ! A FUSE
                  IF(IEL==-2) WRITE(LU,*) ' *** SHIT IPLOT: ',IPLOT
!
               ELSE
!
!-----------------------------------------------------------------------
!  IFA = 4 OR 5
!  HERE: THE EXIT FACE OF THE PRISM IS A TRIANGULAR FACE
!  =====================================================================
!-----------------------------------------------------------------------
!
                  IFA = IFA - 4
!                 HENCE IFA NOW EQUALS 0 OR 1
!
                  IF (IEL.EQ.1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS AN INTERIOR FACE
!  AND THERE IS NO NEED TO RE-COMPUTE THE VELOCITIES
!  MOVES TO THE ADJACENT ELEMENT
!-----------------------------------------------------------------------
!
                     ETA(IPLOT) = IET + IFA + IFA - 1
                     IF (ETA(IPLOT).EQ.NPLAN+1) THEN
                         ETA(IPLOT)=1
                         ZP=ZP-2*3.14159265D0
                         ZPLOT(IPLOT)=ZP
                     ENDIF
                     IF (ETA(IPLOT).EQ.0) THEN
                         ETA(IPLOT) = NPLAN
                         ZP=ZP+2*3.14159265D0
                         ZPLOT(IPLOT)=ZP
                     ENDIF
                     SHZ(IPLOT) = (ZP-TETA(ETA(IPLOT)))
     &                   / (TETA(ETA(IPLOT)+1)-TETA(ETA(IPLOT)))
!
                     ISO = ISOH
                     ISPDONE(IPLOT) = ISP
!
                      IF(SHZ(IPLOT).LT.     EPSILO) ISO=IBSET(ISO,0)
                      IF(SHZ(IPLOT).GT.1.D0-EPSILO) ISO=IBSET(ISO,1)
                     CHARAC2(IPLOT)%KNE=ETA(IPLOT)
!
                     GOTO 50
!
                  ELSEIF(IEL.EQ.-1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS A SOLID BOUNDARY
!  PROJECTS THE RELICAT ON THE BOUNDARY AND MOVES
!-----------------------------------------------------------------------
!
                     STOP 'PROBLEME'
!
!
                  ELSE
                    STOP 'PROBLEME'
                  ENDIF
!
               ENDIF
           ! CONTINUOUS SETTING OF THE REACHED POSITION FOR IPLOT
           ! AND THE NUMBER OF STEPS DONE ALREADY
!
            ENDIF
!
!
        ENDDO
!       ENDIF
40     CONTINUE
!
!-----------------------------------------------------------------------
!
      RETURN
      END SUBROUTINE PIEDS_TOMAWAC_MPI
!
        SUBROUTINE WIPE_HEAPED_CHAR(RTEST,NPOIN,DOIT,NSEND,NLOSTCHAR,
     &                              NCHDIM,NCHARA)
          IMPLICIT NONE
          INTEGER LNG,LU
          COMMON/INFO/LNG,LU
          INTEGER, INTENT(IN)     :: NPOIN,NCHDIM
          INTEGER, INTENT(OUT)    :: NSEND,NLOSTCHAR
          INTEGER, INTENT(INOUT)  :: NCHARA
          DOUBLE PRECISION, INTENT(IN) :: RTEST(NPOIN)
          LOGICAL, INTENT(IN) :: DOIT
          INTEGER :: I
          IF(NCHARA>NCHDIM) THEN
            WRITE (*,*) ' @STREAMLINE::WIPE_HEAPED_CHAR::NPOIN>NCHDIM'
            CALL PLANTE(1)
            STOP
          ENDIF
          NSEND=NCHARA
          IF(DOIT) THEN
            IF (TRACE) WRITE (LU,*) ' -> APPLYING JMH-ALGORITHM '
            DO I=1,NCHARA
              IF(RTEST(HEAPCHAR(I,IFREQ)%IOR).GT.0.5D0) THEN
                NSEND=NSEND-1
                HEAPCOUNTS ( HEAPCHAR(I,IFREQ)%NEPID+1 ,IFREQ) =
     &                 HEAPCOUNTS( HEAPCHAR(I,IFREQ)%NEPID+1 ,IFREQ) - 1
                HEAPCHAR(I,IFREQ)%NEPID=-1 ! THIS IS THE MARKER FOR WIPING
              ENDIF
            END DO
          ELSE
            IF (TRACE) WRITE (LU,*) ' -> JMH-ALGORITHM -NOT- APPLIED'
          ENDIF
          NLOSTCHAR=NSEND ! SAVES THE NUMBER OF MY REALLY LOST CHARS
          IF (TRACE) WRITE (LU,'(A,A,4(1X,I6))')
     &           ' @STREAMLINE::WIPE_HEAPED_CHAR:: ',
     &           'NSEND, NLOSTCHAR, NCHARA, SUM(HEAPCOUNTS): ',
     &            NSEND, NLOSTCHAR, NCHARA, SUM(HEAPCOUNTS(:,IFREQ))
          RETURN
        END SUBROUTINE WIPE_HEAPED_CHAR
!
        SUBROUTINE WIPE_HEAPED_CHAR_4D(RTEST,NPOIN,DOIT,NSEND,
     &                              NLOSTCHAR,NCHDIM,NCHARA)
          IMPLICIT NONE
          INTEGER LNG,LU
          COMMON/INFO/LNG,LU
          INTEGER, INTENT(IN)     :: NPOIN,NCHDIM
          INTEGER, INTENT(OUT)    :: NSEND,NLOSTCHAR
          INTEGER, INTENT(INOUT)  :: NCHARA
          DOUBLE PRECISION, INTENT(IN) :: RTEST(NPOIN)
          LOGICAL, INTENT(IN) :: DOIT
          INTEGER :: I
          IF(NCHARA>NCHDIM) THEN
            WRITE (*,*) ' @STREAMLINE::WIPE_HEAPED_CHAR::NPOIN>NCHDIM'
            CALL PLANTE(1)
            STOP
          ENDIF
          NSEND=NCHARA
          IF(DOIT) THEN
            IF (TRACE) WRITE (LU,*) ' -> APPLYING JMH-ALGORITHM '
            DO I=1,NCHARA
              IF(RTEST(HEAPCHAR_4D(I,IFREQ)%IOR).GT.0.5D0) THEN
                NSEND=NSEND-1
                HEAPCOUNTS ( HEAPCHAR_4D(I,IFREQ)%NEPID+1 ,IFREQ) =
     &              HEAPCOUNTS( HEAPCHAR_4D(I,IFREQ)%NEPID+1 ,IFREQ) - 1
                HEAPCHAR_4D(I,IFREQ)%NEPID=-1 ! THIS IS THE MARKER FOR WIPING
              ENDIF
            END DO
          ELSE
            IF (TRACE) WRITE (LU,*) ' -> JMH-ALGORITHM -NOT- APPLIED'
          ENDIF
          NLOSTCHAR=NSEND ! SAVES THE NUMBER OF MY REALLY LOST CHARS
          IF (TRACE) WRITE (LU,'(A,A,4(1X,I6))')
     &           ' @STREAMLINE::WIPE_HEAPED_CHAR:: ',
     &           'NSEND, NLOSTCHAR, NCHARA, SUM(HEAPCOUNTS): ',
     &            NSEND, NLOSTCHAR, NCHARA, SUM(HEAPCOUNTS(:,IFREQ))
          RETURN
        END SUBROUTINE WIPE_HEAPED_CHAR_4D
!
      SUBROUTINE HEAP_FOUND(NLOSTAGAIN,NARRV,NCHARA)
          IMPLICIT NONE
          INTEGER LNG,LU
          COMMON/INFO/LNG,LU
          INTEGER, INTENT(OUT)    :: NLOSTAGAIN
          INTEGER, INTENT(IN)     :: NARRV
          INTEGER, INTENT(INOUT)  :: NCHARA
          INTEGER I
          SENDCOUNTS=0
          ! DO NOT ZEROIZE NCHARA, HEAPCOUNTS / ADDING FROM GENERATIONS!
          ! COUNTER PARTITION-WISE, ALSO MY-OWN
          DO I=1,NARRV
            IF(RECVCHAR(I,IFREQ)%NEPID==-1) THEN ! A LOCALISED TRACEBACK
              NCHARA=NCHARA+1
              HEAPCHAR(NCHARA,IFREQ) = RECVCHAR(I,IFREQ) ! ALREADY INTERPOLATED?
              HEAPCOUNTS(HEAPCHAR(NCHARA,IFREQ)%MYPID+1,IFREQ) =
     &             HEAPCOUNTS(HEAPCHAR(NCHARA,IFREQ)%MYPID+1,IFREQ)+1
            ELSE ! A LOST-AGAIN CHARACTERISTIC / TO BE SORTED LATER
              SENDCOUNTS(RECVCHAR(I,IFREQ)%NEPID+1,IFREQ) =
     &           SENDCOUNTS(RECVCHAR(I,IFREQ)%NEPID+1,IFREQ)+1
            ENDIF
          END DO
          NLOSTAGAIN=SUM(SENDCOUNTS(:,IFREQ))
          IF (TRACE) WRITE(LU,'(2(A,I7))')
     &       ' @STREAMLINE::HEAP_FOUND:: HEAPED: ',NCHARA,
     &                 ' LOST-AGAIN: ',NLOSTAGAIN
          RETURN
        END SUBROUTINE HEAP_FOUND
!
      SUBROUTINE HEAP_FOUND_4D(NLOSTAGAIN,NARRV,NCHARA)
          IMPLICIT NONE
          INTEGER LNG,LU
          COMMON/INFO/LNG,LU
          INTEGER, INTENT(OUT)    :: NLOSTAGAIN
          INTEGER, INTENT(IN)     :: NARRV
          INTEGER, INTENT(INOUT)  :: NCHARA
          INTEGER I
          SENDCOUNTS=0
          ! DO NOT ZEROIZE NCHARA, HEAPCOUNTS / ADDING FROM GENERATIONS!
          ! COUNTER PARTITION-WISE, ALSO MY-OWN
          DO I=1,NARRV
            IF(RECVCHAR_4D(I,IFREQ)%NEPID==-1) THEN ! A LOCALISED TRACEBACK
              NCHARA=NCHARA+1
              HEAPCHAR_4D(NCHARA,IFREQ) = RECVCHAR_4D(I,IFREQ) ! ALREADY INTERPOLATED?
              HEAPCOUNTS(HEAPCHAR_4D(NCHARA,IFREQ)%MYPID+1,IFREQ) =
     &           HEAPCOUNTS(HEAPCHAR_4D(NCHARA,IFREQ)%MYPID+1,IFREQ)+1
            ELSE ! A LOST-AGAIN CHARACTERISTIC / TO BE SORTED LATER
              SENDCOUNTS(RECVCHAR_4D(I,IFREQ)%NEPID+1,IFREQ) =
     &           SENDCOUNTS(RECVCHAR_4D(I,IFREQ)%NEPID+1,IFREQ)+1
            ENDIF
          END DO
          NLOSTAGAIN=SUM(SENDCOUNTS(:,IFREQ))
          IF (TRACE) WRITE(LU,'(2(A,I7))')
     &       ' @STREAMLINE::HEAP_FOUND:: HEAPED: ',NCHARA,
     &                 ' LOST-AGAIN: ',NLOSTAGAIN
          RETURN
        END SUBROUTINE HEAP_FOUND_4D
!
!                       *****************
                        SUBROUTINE PIED4D_TOMAWAC
!                       *****************
!
     &  (U , V , T , W , DT , NRK , X , Y , TETA , FREQ , IKLE2 ,
     &   IFABOR , ETAS , XPLOT , YPLOT , TPLOT , FPLOT , DX , DY , DW ,
     &   DF , SHP1 , SHP2 , SHP3 , SHT , SHF , ELT , ETA , FRE , NSP ,
     &   NPLOT , NPOIN2 , NELEM2 , NPLAN , NF , SURDET , SENS ,
     &   ISO ,IFAPAR, TEST3, NCHDIM,NCHARA,
     &   MESH,GOODELT,IFF)
!
!***********************************************************************
!  TOMAWAC  RELEASE 1.0              01/02/95 F MARCOS (LNH) 30 87 72 66
!  ADAPTED FOR PARALLEL RELEASE 6.0  16/07/09 B DELHOM (INCKA)
!***********************************************************************
!
!  FUNCTION :
!
!     TRACES IN TIME
!     THE CHARACTERISTICS CURVES
!     FOR TOMAWAC "HYPER PRISMS"
!     WITHIN THE TIME INTERVAL DT
!     USING AN HYBRID DISCRETISATION FINITE ELEMENTS+FINITE DIFF (2D)
!
!
!  DISCRETISATION :
!
!     THE DOMAIN IS APPROXIMATED USING A FINITE ELEMENT DISCRETISATION.
!     A LOCAL APPROXIMATION IS USED FOR THE VELOCITY :
!     THE VALUE IN ONE POINT OF AN ELEMENT ONLY DEPENDS THE VALUES AT THE
!     NODES OF THIS ELEMENT.
!
!
!  RESTRICTIONS AND ASSUMPTIONS:
!
!     THE ADVECTION FIELD U IS ASSUMED NOT TO VARY WITH TIME
!
!-----------------------------------------------------------------------
!                             ARGUMENTS
! .________________.____.______________________________________________.
! !      NOM       !MODE!                   ROLE                       !
! !________________!____!______________________________________________!
! !    U,V,T,W     ! -->! COMPOSANTE DE LA VITESSE DU CONVECTEUR       !
! !    DT          ! -->! PAS DE TEMPS.                                !
! !    NRK         ! -->! NOMBRE DE SOUS-PAS DE RUNGE-KUTTA.           !
! !  X,Y,TETA,FREQ ! -->! COORDONNEES DES POINTS DU MAILLAGE.          !
! !    IKLE2       ! -->! TRANSITION ENTRE LES NUMEROTATIONS LOCALE    !
! !                !    ! ET GLOBALE DU MAILLAGE 2D.                   !
! !    IFABOR      ! -->! NUMEROS 2D DES ELEMENTS AYANT UNE FACE COMMUNE
! !                !    ! AVEC L'ELEMENT .  SI IFABOR
! !                !    ! ON A UNE FACE LIQUIDE,SOLIDE,OU PERIODIQUE   !
! !    ETAS        !! TABLEAU DE TRAVAIL DONNANT LE NUMERO DE      !
! !                !    ! L'ETAGE SUPERIEUR                            !
! ! X.,Y.,T.,FPLOT !! POSITIONS SUCCESSIVES DES DERIVANTS.         !
! !  DX,DY,DW,DF   ! -- ! STOCKAGE DES SOUS-PAS .                      !
! !    SHP1-2-3    !! COORDONNEES BARYCENTRIQUES 2D AU PIED DES    !
! !                !    ! COURBES CARACTERISTIQUES.                    !
! !    SHT         !! COORDONNEES BARYCENTRIQUES SUIVANT TETA DES  !
! !                !    ! NOEUDS DANS LEURS ETAGES "ETA" ASSOCIES.     !
! !    SHF         !! COORDONNEES BARYCENTRIQUES SUIVANT F DES     !
! !                !    ! NOEUDS DANS LEURS FREQUENCES "FRE" ASSOCIEES.!
! !    ELT         !! NUMEROS DES ELEMENTS 2D CHOISIS POUR CHAQUE  !
! !                !    ! NOEUD.                                       !
! !    ETA         !! NUMEROS DES ETAGES CHOISIS POUR CHAQUE NOEUD.!
! !    FRE         !! NUMEROS DES FREQ. CHOISIES POUR CHAQUE NOEUD.!
! !    NSP         ! -- ! NOMBRE DE SOUS-PAS DE RUNGE KUTTA.           !
! !    NPLOT       ! -->! NOMBRE DE DERIVANTS.                         !
! !    NPOIN2      ! -->! NOMBRE DE POINTS DU MAILLAGE 2D.             !
! !    NELEM2      ! -->! NOMBRE D'ELEMENTS DU MAILLAGE 2D.            !
! !    NPLAN       ! -->! NOMBRE DE DIRECTIONS                         !
! !    NF          ! -->! NOMBRE DE FREQUENCES                         !
! !    SURDET      ! -->! VARIABLE UTILISEE PAR LA TRANSFORMEE ISOPARAM.
! !    SENS        ! -->! DESCENTE OU REMONTEE DES CARACTERISTIQUES.   !
! !    ISO         !! INDIQUE PAR BIT LA FACE DE SORTIE DE L'ELEMEN!
! !________________!____!______________________________________________!
!  MODE: -->(DONNEE NON MODIFIEE),(DONNEE MODIFIEE)
!-----------------------------------------------------------------------
! CALLED BY : WAC
! CALLS : --
!
!***********************************************************************
!
      USE BIEF
      IMPLICIT NONE
!
      INTEGER LNG,LU
      COMMON/INFO/ LNG,LU
!
      INTEGER NPOIN2,NELEM2,NPLAN,NPLOT,NSPMAX,NRK,SENS,NF
!
      DOUBLE PRECISION U(NPOIN2,NPLAN,NF),V(NPOIN2,NPLAN,NF)
      DOUBLE PRECISION T(NPOIN2,NPLAN,NF),W(NPOIN2,NPLAN,NF)
      DOUBLE PRECISION XPLOT(NPLOT),YPLOT(NPLOT)
      DOUBLE PRECISION TPLOT(NPLOT),FPLOT(NPLOT)
      DOUBLE PRECISION SURDET(NELEM2),SHT(NPLOT),SHF(NPLOT)
      DOUBLE PRECISION SHP1(NPLOT),SHP2(NPLOT),SHP3(NPLOT)
      DOUBLE PRECISION X(NPOIN2),Y(NPOIN2),TETA(NPLAN+1),FREQ(NF)
      DOUBLE PRECISION DX(NPLOT),DY(NPLOT),DW(NPLOT),DF(NPLOT)
      DOUBLE PRECISION PAS,DT,EPSILO,A1,A2
      DOUBLE PRECISION DX1,DY1,DXP,DYP,DTP,DFP,XP,YP,TP,FP
!
      INTEGER IKLE2(NELEM2,3),IFABOR(NELEM2,7),ETAS(NPLAN)
      INTEGER ELT(NPLOT),ETA(NPLOT),FRE(NPLOT),NSP(NPLOT),ISO(NPLOT)
      INTEGER IPLOT,ISP,I1,I2,I3,IEL,IET,IFR,IFA,ISUI(3)
      INTEGER ISOH,ISOT,ISOF,ISOV
!BD_INCKA MODIFICATION FOR PARALLEL MODE
      INTEGER         , INTENT(IN)    :: IFAPAR(6,*)
      DOUBLE PRECISION, INTENT(INOUT) :: TEST3(NPLOT)
      INTEGER         , INTENT(INOUT) :: GOODELT(NPLOT)
      INTEGER                         :: NCHDIM,NCHARA,IPLAN,IPOIN,
     &                                   I10,IFF
      INTEGER  P_IMAX, P_ISUM
      EXTERNAL P_IMAX, P_ISUM
      DOUBLE PRECISION :: TES(NPOIN2,NPLAN),DENOM,DET1,DET2
      TYPE(BIEF_MESH)  MESH
!BD_INCKA END OF MODIFICATION FOR PARALLEL MODE
!
      INTRINSIC ABS , INT , MAX , SQRT
!
      DATA ISUI   / 2 , 3 , 1 /
      DATA EPSILO / -1.D-6 /
!
!-----------------------------------------------------------------------
!  COMPUTES THE MAXIMUM NUMBER OF SUB-ITERATIONS
!-----------------------------------------------------------------------
!
      NSPMAX = 1
!
      DO 10 IPLOT = 1 , NPLOT
!
         TEST3(IPLOT) = 1.D0
         NSP(IPLOT) = 0
         IEL = ELT(IPLOT)
!
         IF (IEL.GT.0) THEN
!
            IET = ETA(IPLOT)
            IFR = FRE(IPLOT)
!
            I1 = IKLE2(IEL,1)
            I2 = IKLE2(IEL,2)
            I3 = IKLE2(IEL,3)
!
         DXP =(1.D0-SHF(IPLOT))*
     &              ( U(I1,IET  ,IFR)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &          + U(I2,IET  ,IFR)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &          + U(I3,IET  ,IFR)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &          + U(I1,ETAS(IET),IFR)*SHP1(IPLOT)*SHT(IPLOT)
     &          + U(I2,ETAS(IET),IFR)*SHP2(IPLOT)*SHT(IPLOT)
     &          + U(I3,ETAS(IET),IFR)*SHP3(IPLOT)*SHT(IPLOT))
     &        + SHF(IPLOT)*
     &              ( U(I1,IET  ,IFR+1)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &          + U(I2,IET  ,IFR+1)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &          + U(I3,IET  ,IFR+1)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &          + U(I1,ETAS(IET),IFR+1)*SHP1(IPLOT)*SHT(IPLOT)
     &          + U(I2,ETAS(IET),IFR+1)*SHP2(IPLOT)*SHT(IPLOT)
     &          + U(I3,ETAS(IET),IFR+1)*SHP3(IPLOT)*SHT(IPLOT))
!
         DYP =(1.D0-SHF(IPLOT))*
     &              ( V(I1,IET  ,IFR)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &          + V(I2,IET  ,IFR)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &          + V(I3,IET  ,IFR)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &          + V(I1,ETAS(IET),IFR)*SHP1(IPLOT)*SHT(IPLOT)
     &          + V(I2,ETAS(IET),IFR)*SHP2(IPLOT)*SHT(IPLOT)
     &          + V(I3,ETAS(IET),IFR)*SHP3(IPLOT)*SHT(IPLOT))
     &        + SHF(IPLOT)*
     &              ( V(I1,IET  ,IFR+1)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &          + V(I2,IET  ,IFR+1)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &          + V(I3,IET  ,IFR+1)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &          + V(I1,ETAS(IET),IFR+1)*SHP1(IPLOT)*SHT(IPLOT)
     &          + V(I2,ETAS(IET),IFR+1)*SHP2(IPLOT)*SHT(IPLOT)
     &          + V(I3,ETAS(IET),IFR+1)*SHP3(IPLOT)*SHT(IPLOT))
!
         DTP =(1.D0-SHF(IPLOT))*
     &              ( T(I1,IET  ,IFR)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &          + T(I2,IET  ,IFR)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &          + T(I3,IET  ,IFR)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &          + T(I1,ETAS(IET),IFR)*SHP1(IPLOT)*SHT(IPLOT)
     &          + T(I2,ETAS(IET),IFR)*SHP2(IPLOT)*SHT(IPLOT)
     &          + T(I3,ETAS(IET),IFR)*SHP3(IPLOT)*SHT(IPLOT))
     &        + SHF(IPLOT)*
     &              ( T(I1,IET  ,IFR+1)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &          + T(I2,IET  ,IFR+1)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &          + T(I3,IET  ,IFR+1)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &          + T(I1,ETAS(IET),IFR+1)*SHP1(IPLOT)*SHT(IPLOT)
     &          + T(I2,ETAS(IET),IFR+1)*SHP2(IPLOT)*SHT(IPLOT)
     &          + T(I3,ETAS(IET),IFR+1)*SHP3(IPLOT)*SHT(IPLOT))
!
         DFP =(1.D0-SHF(IPLOT))*
     &              ( W(I1,IET  ,IFR)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &          + W(I2,IET  ,IFR)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &          + W(I3,IET  ,IFR)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &          + W(I1,ETAS(IET),IFR)*SHP1(IPLOT)*SHT(IPLOT)
     &          + W(I2,ETAS(IET),IFR)*SHP2(IPLOT)*SHT(IPLOT)
     &          + W(I3,ETAS(IET),IFR)*SHP3(IPLOT)*SHT(IPLOT))
     &        + SHF(IPLOT)*
     &              ( W(I1,IET  ,IFR+1)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &          + W(I2,IET  ,IFR+1)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &          + W(I3,IET  ,IFR+1)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &          + W(I1,ETAS(IET),IFR+1)*SHP1(IPLOT)*SHT(IPLOT)
     &          + W(I2,ETAS(IET),IFR+1)*SHP2(IPLOT)*SHT(IPLOT)
     &          + W(I3,ETAS(IET),IFR+1)*SHP3(IPLOT)*SHT(IPLOT))
!
         NSP(IPLOT)= MAX( INT(NRK*DT*ABS(DTP/(TETA(IET)-TETA(IET+1)))),
     &                   INT(NRK*DT*ABS(DFP/(FREQ(IFR)-FREQ(IFR+1)))) )
         NSP(IPLOT)= MAX( NSP(IPLOT),
     &               INT(NRK*DT*SQRT((DXP*DXP+DYP*DYP)*SURDET(IEL))) )
! CHECKS WHETHER THE CORRECT ELEMENT HAS BEEN FOUND (NOT A BOUNDARY ELEMENT
! WHICH WILL BE IGNORED AT A LATER DATE; SEE SUBROUTINE 'INIPIE'
         IF ((GOODELT(IPLOT).EQ.2000).OR.(GOODELT(IPLOT).EQ.1100)
     &  .OR.(GOODELT(IPLOT).EQ.1010).OR.(GOODELT(IPLOT).EQ.1000))
     &                                NSP(IPLOT) = 1
!          IF ((GOODELT(IPLOT).EQ.3000).OR.(GOODELT(IPLOT).EQ.4000))
!      *       NSP(IPLOT)=1
         IF ((1000*(GOODELT(IPLOT)/1000)-GOODELT(IPLOT)).EQ.0)
     &       NSP(IPLOT) = 1
            NSP(IPLOT) = MAX (1,NSP(IPLOT))
!
            NSPMAX = MAX ( NSPMAX , NSP(IPLOT) )
!
         ENDIF
!
10    CONTINUE
       TES = RESHAPE(DBLE(NSP),(/NPOIN2,NPLAN/))
       DO IPLAN=1,NPLAN
         CALL PARCOM2
     & ( TES(:,IPLAN) ,
     &   TES(:,IPLAN) ,
     &   TES(:,IPLAN) ,
     &   NPOIN2 , 1 , 1 , 1 , MESH )
      ENDDO
      DO IPOIN = 1, NPOIN2
         DO IPLAN= 1,NPLAN
         NSP(IPOIN + NPOIN2*(IPLAN-1))= NINT(TES(IPOIN,IPLAN))
         ENDDO
      ENDDO
!BD_INCKA MODIFICATION FOR PARALLEL MODE
      NSPMAX = P_IMAX(NSPMAX)
      IF(LNG.EQ.1) THEN
         WRITE(LU,*) 'NOMBRE MAX DE SOUS PAS :',NSPMAX
      ELSE
         WRITE(LU,*) 'NUMBER OF SUB-ITERATIONS :',NSPMAX
      ENDIF
!
!-----------------------------------------------------------------------
!  LOOP ON NUMBER OF SUB-ITERATIONS
!-----------------------------------------------------------------------
!
      DO 20 ISP = 1 , NSPMAX
!
!-----------------------------------------------------------------------
!  LOCATES THE END POINT OF ALL THE CHARACTERISTICS
!-----------------------------------------------------------------------
!
         DO 30 IPLOT = 1 , NPLOT
!
            ISO(IPLOT) = 0
            IF (ISP.LE.NSP(IPLOT)) THEN
!
!
               IEL = ELT(IPLOT)
               IET = ETA(IPLOT)
               IFR = FRE(IPLOT)
!
               I1 = IKLE2(IEL,1)
               I2 = IKLE2(IEL,2)
               I3 = IKLE2(IEL,3)
               PAS = SENS * DT / NSP(IPLOT)
!
         DX(IPLOT) = ( (1.D0-SHF(IPLOT))*
     &          ( U(I1,IET  ,IFR)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + U(I2,IET  ,IFR)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + U(I3,IET  ,IFR)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + U(I1,ETAS(IET),IFR)*SHP1(IPLOT)*SHT(IPLOT)
     &      + U(I2,ETAS(IET),IFR)*SHP2(IPLOT)*SHT(IPLOT)
     &      + U(I3,ETAS(IET),IFR)*SHP3(IPLOT)*SHT(IPLOT))
     &        + SHF(IPLOT)*
     &          ( U(I1,IET  ,IFR+1)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + U(I2,IET  ,IFR+1)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + U(I3,IET  ,IFR+1)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + U(I1,ETAS(IET),IFR+1)*SHP1(IPLOT)*SHT(IPLOT)
     &      + U(I2,ETAS(IET),IFR+1)*SHP2(IPLOT)*SHT(IPLOT)
     &      + U(I3,ETAS(IET),IFR+1)*SHP3(IPLOT)*SHT(IPLOT)) )*PAS
!
         DY(IPLOT) = ( (1.D0-SHF(IPLOT))*
     &          ( V(I1,IET  ,IFR)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + V(I2,IET  ,IFR)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + V(I3,IET  ,IFR)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + V(I1,ETAS(IET),IFR)*SHP1(IPLOT)*SHT(IPLOT)
     &      + V(I2,ETAS(IET),IFR)*SHP2(IPLOT)*SHT(IPLOT)
     &      + V(I3,ETAS(IET),IFR)*SHP3(IPLOT)*SHT(IPLOT))
     &        + SHF(IPLOT)*
     &          ( V(I1,IET  ,IFR+1)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + V(I2,IET  ,IFR+1)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + V(I3,IET  ,IFR+1)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + V(I1,ETAS(IET),IFR+1)*SHP1(IPLOT)*SHT(IPLOT)
     &      + V(I2,ETAS(IET),IFR+1)*SHP2(IPLOT)*SHT(IPLOT)
     &      + V(I3,ETAS(IET),IFR+1)*SHP3(IPLOT)*SHT(IPLOT)) )*PAS
!
         DW(IPLOT) = ( (1.D0-SHF(IPLOT))*
     &          ( T(I1,IET  ,IFR)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + T(I2,IET  ,IFR)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + T(I3,IET  ,IFR)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + T(I1,ETAS(IET),IFR)*SHP1(IPLOT)*SHT(IPLOT)
     &      + T(I2,ETAS(IET),IFR)*SHP2(IPLOT)*SHT(IPLOT)
     &      + T(I3,ETAS(IET),IFR)*SHP3(IPLOT)*SHT(IPLOT))
     &        + SHF(IPLOT)*
     &          ( T(I1,IET  ,IFR+1)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + T(I2,IET  ,IFR+1)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + T(I3,IET  ,IFR+1)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + T(I1,ETAS(IET),IFR+1)*SHP1(IPLOT)*SHT(IPLOT)
     &      + T(I2,ETAS(IET),IFR+1)*SHP2(IPLOT)*SHT(IPLOT)
     &      + T(I3,ETAS(IET),IFR+1)*SHP3(IPLOT)*SHT(IPLOT)) )*PAS
!
         DF(IPLOT) = ( (1.D0-SHF(IPLOT))*
     &          ( W(I1,IET  ,IFR)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + W(I2,IET  ,IFR)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + W(I3,IET  ,IFR)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + W(I1,ETAS(IET),IFR)*SHP1(IPLOT)*SHT(IPLOT)
     &      + W(I2,ETAS(IET),IFR)*SHP2(IPLOT)*SHT(IPLOT)
     &      + W(I3,ETAS(IET),IFR)*SHP3(IPLOT)*SHT(IPLOT))
     &        + SHF(IPLOT)*
     &          ( W(I1,IET  ,IFR+1)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + W(I2,IET  ,IFR+1)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + W(I3,IET  ,IFR+1)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + W(I1,ETAS(IET),IFR+1)*SHP1(IPLOT)*SHT(IPLOT)
     &      + W(I2,ETAS(IET),IFR+1)*SHP2(IPLOT)*SHT(IPLOT)
     &      + W(I3,ETAS(IET),IFR+1)*SHP3(IPLOT)*SHT(IPLOT)) )*PAS
!
               XP = XPLOT(IPLOT) + DX(IPLOT)
               YP = YPLOT(IPLOT) + DY(IPLOT)
               TP = TPLOT(IPLOT) + DW(IPLOT)
               FP = FPLOT(IPLOT) + DF(IPLOT)
!
               SHP1(IPLOT) = ((X(I3)-X(I2))*(YP-Y(I2))
     &                        -(Y(I3)-Y(I2))*(XP-X(I2))) * SURDET(IEL)
               SHP2(IPLOT) = ((X(I1)-X(I3))*(YP-Y(I3))
     &                        -(Y(I1)-Y(I3))*(XP-X(I3))) * SURDET(IEL)
               SHP3(IPLOT) = ((X(I2)-X(I1))*(YP-Y(I1))
     &                        -(Y(I2)-Y(I1))*(XP-X(I1))) * SURDET(IEL)
               SHT(IPLOT) = (TP-TETA(IET)) / (TETA(IET+1)-TETA(IET))
               SHF(IPLOT) = (FP-FREQ(IFR)) / (FREQ(IFR+1)-FREQ(IFR))
!             IF (ABS(SHT(IPLOT)).GT.2.5D0 ) THEN
!         WRITE(LU,*) 'SHT***',IPLOT,IET,SHT(IPLOT)
!         WRITE(LU,*) TETA(IET),TETA(IET+1),ZP
!         WRITE(LU,*) DZ(IPLOT),ZPLOT(IPLOT)
!         STOP
!              ENDIF
!
               XPLOT(IPLOT) = XP
               YPLOT(IPLOT) = YP
               TPLOT(IPLOT) = TP
               FPLOT(IPLOT) = FP
!
               IF (SHP1(IPLOT).LT.EPSILO)
     &              ISO(IPLOT)=IBSET(ISO(IPLOT),4)
               IF (SHP2(IPLOT).LT.EPSILO)
     &              ISO(IPLOT)=IBSET(ISO(IPLOT),5)
               IF (SHP3(IPLOT).LT.EPSILO)
     &              ISO(IPLOT)=IBSET(ISO(IPLOT),6)
!
               IF  (SHT(IPLOT).LT.EPSILO)
     &              ISO(IPLOT)=IBSET(ISO(IPLOT),0)
               IF  (SHT(IPLOT).GT.1.D0-EPSILO)
     &              ISO(IPLOT)=IBSET(ISO(IPLOT),1)
!
               IF  (SHF(IPLOT).LT.EPSILO)
     &              ISO(IPLOT)=IBSET(ISO(IPLOT),2)
               IF  (SHF(IPLOT).GT.1.D0-EPSILO)
     &              ISO(IPLOT)=IBSET(ISO(IPLOT),3)
!
            ENDIF
!
30       CONTINUE
!
!-----------------------------------------------------------------------
!  TREATS DIFFERENTLY THE CHARACTERISTICS ISSUED FROM
!  THE START ELEMENT
!-----------------------------------------------------------------------
!
         DO 40 IPLOT = 1 , NPLOT
!
50          CONTINUE
!
            IF ((ISO(IPLOT).NE.0).AND.(TEST3(IPLOT)>0.5D0)) THEN
!
!-----------------------------------------------------------------------
!  HERE: LEFT THE ELEMENT
!-----------------------------------------------------------------------
!
              ISOT = IAND(ISO(IPLOT), 3)
              ISOF = IAND(ISO(IPLOT),12)/4
              ISOV = IAND(ISO(IPLOT),15)
              ISOH = IAND(ISO(IPLOT),112)
              IEL = ELT(IPLOT)
              IET = ETA(IPLOT)
              IFR = FRE(IPLOT)
              XP = XPLOT(IPLOT)
              YP = YPLOT(IPLOT)
              TP = TPLOT(IPLOT)
              FP = FPLOT(IPLOT)
!
              IF (ISOH.NE.0) THEN
!
                IF (ISOH.EQ.16) THEN
                   IFA = 2
                ELSEIF (ISOH.EQ.32) THEN
                   IFA = 3
                ELSEIF (ISOH.EQ.64) THEN
                   IFA = 1
                ELSEIF (ISOH.EQ.48) THEN
                   IFA = 2
                   IF (DX(IPLOT)*(Y(IKLE2(IEL,3))-YP).LT.
     &                 DY(IPLOT)*(X(IKLE2(IEL,3))-XP)) IFA = 3
                ELSEIF (ISOH.EQ.96) THEN
                   IFA = 3
                   IF (DX(IPLOT)*(Y(IKLE2(IEL,1))-YP).LT.
     &                 DY(IPLOT)*(X(IKLE2(IEL,1))-XP)) IFA = 1
                ELSE
                   IFA = 1
                   IF (DX(IPLOT)*(Y(IKLE2(IEL,2))-YP).LT.
     &                 DY(IPLOT)*(X(IKLE2(IEL,2))-XP)) IFA = 2
                ENDIF
!
                IF (ISOV.GT.0) THEN
                  I1 = IKLE2(IEL,IFA)
                  I2 = IKLE2(IEL,ISUI(IFA))
                  IF (ISOF.GT.0) THEN
                 IF (ISOT.GT.0) THEN
                  A1=(FP-FREQ(IFR+ISOF-1))/DF(IPLOT)
                  A2=(TP-TETA(IET+ISOT-1))/DW(IPLOT)
                  IF (A1.LT.A2) THEN
                          IF ((X(I2)-X(I1))*(YP-A1*DY(IPLOT)-Y(I1)).GT.
     &             (Y(I2)-Y(I1))*(XP-A1*DX(IPLOT)-X(I1))) IFA=ISOF+5
                       ELSE
                          IF ((X(I2)-X(I1))*(YP-A2*DY(IPLOT)-Y(I1)).GT.
     &             (Y(I2)-Y(I1))*(XP-A2*DX(IPLOT)-X(I1))) IFA=ISOT+3
                       ENDIF
                    ELSE
                        A1 = (FP-FREQ(IFR+ISOF-1)) / DF(IPLOT)
                        IF ((X(I2)-X(I1))*(YP-A1*DY(IPLOT)-Y(I1)).GT.
     &             (Y(I2)-Y(I1))*(XP-A1*DX(IPLOT)-X(I1))) IFA=ISOF+5
                     ENDIF
                  ELSE
                      A1 = (TP-TETA(IET+ISOT-1)) / DW(IPLOT)
                      IF ((X(I2)-X(I1))*(YP-A1*DY(IPLOT)-Y(I1)).GT.
     &             (Y(I2)-Y(I1))*(XP-A1*DX(IPLOT)-X(I1))) IFA=ISOT+3
                   ENDIF
                ENDIF
!
             ELSEIF (ISOT.GT.0) THEN
!
                IFA = ISOT + 3
!
                IF (ISOF.GT.0) THEN
                   A1=(FP-FREQ(IFR+ISOF-1))/DF(IPLOT)
                   A2=(TP-TETA(IET+ISOT-1))/DW(IPLOT)
                   IF (A1.LT.A2) IFA = ISOF + 5
                ENDIF
             ELSE
                IFA = ISOF + 5
             ENDIF
!
!     IF ((GOODELT(IPLOT) == 1100).OR.
!     *                        (GOODELT(IPLOT) == 1102)) THEN
!     IF ((GOODELT(IPLOT) == 1100).OR.
!     *           (GOODELT(IPLOT)==2000).OR.(GOODELT(IPLOT)==1010)) THEN
!     IF ((GOODELT(IPLOT)==1100).AND.(IFABOR(IEL,IFA)==-1)) THEN
!     DO I10=1,3
!     IF (IFABOR(IEL,I10)==-2) IFA = I10
!     ENDDO
!     ENDIF
             IF ((GOODELT(IPLOT)==1100).AND.(ISP==1)) THEN
                DO I10=1,3
                   IF (IFABOR(IEL,I10)==-2) IFA = I10
                ENDDO
             ENDIF
             IF ((GOODELT(IPLOT)==2001).AND.(IFABOR(IEL,IFA)==-2)
     &            .AND.(ISP==1)) THEN
                IF (ISOH.EQ.48) THEN
                   IF (IFA==3) THEN
                      IFA = 2
                   ELSE
                      IFA = 3
                   ENDIF
                ELSEIF (ISOH.EQ.96) THEN
                   IF (IFA==1) THEN
                      IFA = 3
                         ELSE
                            IFA = 1
                         ENDIF
                      ENDIF
                   ENDIF
                   IEL = IFABOR(IEL,IFA)
!
                   IF (IFA.LE.3) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE OF THE PRISM IS A RECTANGULAR FACE
!     =================================================================
!-----------------------------------------------------------------------
!
                      IF (IEL.GT.0) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS AN INTERIOR FACE
!  MOVES TO THE ADJACENT ELEMENT
!-----------------------------------------------------------------------
!
                         I1 = IKLE2(IEL,1)
                         I2 = IKLE2(IEL,2)
                         I3 = IKLE2(IEL,3)
!
                         ELT(IPLOT) = IEL
                         SHP1(IPLOT) = ((X(I3)-X(I2))*(YP-Y(I2))
     &                        -(Y(I3)-Y(I2))*(XP-X(I2)))*SURDET(IEL)
                         SHP2(IPLOT) = ((X(I1)-X(I3))*(YP-Y(I3))
     &                        -(Y(I1)-Y(I3))*(XP-X(I3)))*SURDET(IEL)
                         SHP3(IPLOT) = ((X(I2)-X(I1))*(YP-Y(I1))
     &                        -(Y(I2)-Y(I1))*(XP-X(I1)))*SURDET(IEL)
!
                     ISO(IPLOT) = ISOV
!
               IF (SHP1(IPLOT).LT.EPSILO) ISO(IPLOT)=IBSET(ISO(IPLOT),4)
               IF (SHP2(IPLOT).LT.EPSILO) ISO(IPLOT)=IBSET(ISO(IPLOT),5)
               IF (SHP3(IPLOT).LT.EPSILO) ISO(IPLOT)=IBSET(ISO(IPLOT),6)
!
               GOTO 50
!
            ENDIF
!     BD_INCKA MODIFICATION FOR PARALLEL MODE
!
!-----------------------------------------------------------------------
! HERE: TESTS PASSING TO THE NEIGHBOUR SUBDOMAIN AND COLLECTS DATA
!-----------------------------------------------------------------------
!
!     THIS CAN ONLY HAPPEN IN PARALLEL
            IF(IEL==-2) THEN    ! INTERFACE CROSSING
               CALL COLLECT_CHAR_4D
     &              (IPID, IPLOT, ELT(IPLOT), IFA, IET ,IFR, ISP,
     &              NSP(IPLOT), XP,YP,TP,FP,
     &              DX(IPLOT),DY(IPLOT),DW(IPLOT),DF(IPLOT),IFAPAR,
     &              NCHDIM,NCHARA,IFF)
!     CAN ONLY HAPPEN IN PARALLEL
               TEST3(IPLOT) = 0.D0
               GOTO 40
!
!     ALTHOUGH A LOST TRACEBACK DETECTED AND SAVED HERE, ALLOWS THE
!     FURTHER TREATMENT AS IF NOTHING HAPPENED IN ORDER TO APPLY
!     THE JMH ALGORITHM WITH "TEST" FIELD OF MARKERS
!
            ENDIF
!     BD_INCKA END OF MODIFICATION FOR PARALLEL MODE
!
            DXP = DX(IPLOT)
            DYP = DY(IPLOT)
            I1  = IKLE2(ELT(IPLOT),IFA)
            I2  = IKLE2(ELT(IPLOT),ISUI(IFA))
            DX1 = X(I2) - X(I1)
            DY1 = Y(I2) - Y(I1)
!
            IF (IEL.EQ.-1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS A SOLID BOUNDARY
!  SETS SHP TO 0, END OF TRACING BACK
!-----------------------------------------------------------------------
!
               SHP1(IPLOT) = 0.D0
               SHP2(IPLOT) = 0.D0
               SHP3(IPLOT) = 0.D0
               ELT(IPLOT) = - SENS * ELT(IPLOT)
               NSP(IPLOT) = ISP
               GOTO 40
!
            ENDIF
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS A LIQUID BOUNDARY
!  ENDS TRACING BACK (SIGN OF ELT)
!-----------------------------------------------------------------------
!
            A1 = (DXP*(YP-Y(I1))-DYP*(XP-X(I1)))/(DXP*DY1-DYP*DX1)
            IF (A1.GT.1.D0) A1 = 1.D0
            IF (A1.LT.0.D0) A1 = 0.D0
            IF (IFA.EQ.1) THEN
               SHP1(IPLOT) = 1.D0 - A1
               SHP2(IPLOT) = A1
               SHP3(IPLOT) = 0.D0
            ELSEIF (IFA.EQ.2) THEN
               SHP2(IPLOT) = 1.D0 - A1
               SHP3(IPLOT) = A1
               SHP1(IPLOT) = 0.D0
            ELSE
               SHP3(IPLOT) = 1.D0 - A1
               SHP1(IPLOT) = A1
               SHP2(IPLOT) = 0.D0
            ENDIF
            XPLOT(IPLOT) = X(I1) + A1 * DX1
            YPLOT(IPLOT) = Y(I1) + A1 * DY1
            IF (ABS(DXP).GT.ABS(DYP)) THEN
               A1 = (XP-XPLOT(IPLOT))/DXP
            ELSE
               A1 = (YP-YPLOT(IPLOT))/DYP
            ENDIF
            TPLOT(IPLOT) = TP - A1*DW(IPLOT)
            SHT(IPLOT) = (TPLOT(IPLOT)-TETA(IET))
     &           / (TETA(IET+1)-TETA(IET))
            FPLOT(IPLOT) = FP - A1*DF(IPLOT)
                  SHF(IPLOT) = (FPLOT(IPLOT)-FREQ(IFR))
     &           / (FREQ(IFR+1)-FREQ(IFR))
                  ELT(IPLOT) = - SENS * ELT(IPLOT)
                  NSP(IPLOT) = ISP
!
               ELSEIF (IFA.LE.5) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE OF THE PRISM IS A TRIANGULAR FACE TETA
!  =====================================================================
!-----------------------------------------------------------------------
!
                  IFA = IFA - 4
!
                  IF (IEL.EQ.1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS AN INTERIOR FACE
!  MOVES TO THE ADJACENT ELEMENT
!-----------------------------------------------------------------------
!
                     ETA(IPLOT) = IET + IFA + IFA - 1
                     IF (ETA(IPLOT).EQ.NPLAN+1) THEN
                        ETA(IPLOT)=1
                        TP=TP-2*3.14159265D0
                        TPLOT(IPLOT)=TP
                     ENDIF
                     IF (ETA(IPLOT).EQ.0) THEN
                        ETA(IPLOT) = NPLAN
                        TP=TP+2*3.14159265D0
                        TPLOT(IPLOT)=TP
                     ENDIF
                     SHT(IPLOT) = (TP-TETA(ETA(IPLOT)))
     &                    / (TETA(ETA(IPLOT)+1)-TETA(ETA(IPLOT)))
!
                     ISO(IPLOT) = ISOH+ISOF*4
!
                     IF (SHT(IPLOT).LT.EPSILO)
     &                    ISO(IPLOT)=IBSET(ISO(IPLOT),0)
                     IF (SHT(IPLOT).GT.1.D0-EPSILO)
     &                    ISO(IPLOT)=IBSET(ISO(IPLOT),1)
!
                     GOTO 50
!
                  ELSE
!
        IF(LNG.EQ.1) THEN
           WRITE(LU,*) 'PROBLEME DANS PIED4D',IEL,IPLOT
        ELSE
           WRITE(LU,*) 'PROBLEM IN PIED4D',IEL,IPLOT
        ENDIF
        WRITE(LU,*) 'SHP',SHP1(IPLOT),SHP2(IPLOT),SHP3(IPLOT)
        WRITE(LU,*) 'SHT',SHT(IPLOT)
        WRITE(LU,*) 'DXYZ',DX(IPLOT),DY(IPLOT),DW(IPLOT)
        WRITE(LU,*) 'XYZ',XPLOT(IPLOT),YPLOT(IPLOT),TPLOT(IPLOT)
!
        STOP
      ENDIF
!
      ELSE
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE OF THE PRISM IS A TRIANGULAR FACE FREQ
!  =====================================================================
!-----------------------------------------------------------------------
!
                  IFA = IFA - 6
!
                  IF ((IFA.EQ.1).AND.(IFR.EQ.NF-1)) IEL=-1
                  IF ((IFA.EQ.0).AND.(IFR.EQ.1)) IEL=-1
                  IF (IEL.EQ.1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS AN INTERIOR FACE
!  MOVES TO THE ADJACENT ELEMENT
!-----------------------------------------------------------------------
!
                     FRE(IPLOT) = IFR + IFA + IFA - 1
                     SHF(IPLOT) = (FP-FREQ(FRE(IPLOT)))
     &                   / (FREQ(FRE(IPLOT)+1)-FREQ(FRE(IPLOT)))
!
                     ISO(IPLOT) = ISOH+ISOT
!
               IF (SHF(IPLOT).LT.EPSILO)
     &             ISO(IPLOT)=IBSET(ISO(IPLOT),2)
               IF (SHF(IPLOT).GT.1.D0-EPSILO)
     &             ISO(IPLOT)=IBSET(ISO(IPLOT),3)
!
                     GOTO 50
!
                  ELSE
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS THE MIN OR MAX FREQUENCY
!  PROJECTS THE RELICAT ON THE BOUNDARY AND CONTINUES
!-----------------------------------------------------------------------
!
                     FPLOT(IPLOT)=FREQ(IFR+IFA)
                     DF(IPLOT)=0.D0
                     SHF(IPLOT)=IFA
                     ISO(IPLOT) = ISOH +ISOT
                     IF(ISO(IPLOT).NE.0) GOTO 50
!
                  ENDIF
!
               ENDIF
!
            ENDIF
!
 40      CONTINUE
!
 20   CONTINUE
!
!-----------------------------------------------------------------------
!
      RETURN
      END SUBROUTINE PIED4D_TOMAWAC
!
!                       *********************
                        SUBROUTINE PIEDS4D_TOMAWAC_MPI
!                       *********************
!
     & ( U , V ,T,  W , DT , NRK , X ,Y,TETA,FREQ,IKLE2,IFABOR ,ETAS,
     &   XPLOT , YPLOT , TPLOT ,FPLOT, DX , DY , DW, DF , SHP1,SHP2,
     &   SHP3 , SHT, SHF , ELT , ETA, FRE,
     &   NPLOT , NPOIN2 , NELEM2 , NPLAN , NF, IFF,
     &   SURDET , SENS , IFAPAR, NOMB,NARRV,CHARAC2)
!
      USE BIEF
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER           :: SENS,NPLAN,NOMB,NARRV
      INTEGER           :: NPOIN2,NELEM2,NPLOT,NRK,NF
      INTEGER           :: IKLE2(NELEM2,3)
      INTEGER           :: ELT(NPLOT),NSP(NPLOT)
      INTEGER           :: ISPDONE(NPLOT)
      DOUBLE PRECISION  :: U(NPOIN2,NPLAN,NF),V(NPOIN2,NPLAN,NF)
      DOUBLE PRECISION  :: T(NPOIN2,NPLAN,NF),W(NPOIN2,NPLAN,NF)
      DOUBLE PRECISION  :: XPLOT(NPLOT),YPLOT(NPLOT)
      DOUBLE PRECISION  :: TPLOT(NPLOT),FPLOT(NPLOT)
      DOUBLE PRECISION  :: SURDET(NELEM2),SHT(NPLOT),SHF(NPLOT)
      DOUBLE PRECISION  :: SHP1(NPLOT),SHP2(NPLOT),SHP3(NPLOT)
      DOUBLE PRECISION  :: X(NPOIN2),Y(NPOIN2),TETA(NPLAN+1),FREQ(NF)
      DOUBLE PRECISION  :: DX(NPLOT),DY(NPLOT),DW(NPLOT),DF(NPLOT)
      DOUBLE PRECISION  :: PAS,EPSILO,A1,DX1,DY1,XP,YP,TP,FP
      DOUBLE PRECISION  :: DXP,DYP,DTP,DFP
      DOUBLE PRECISION  :: DELTAZ,EPSDZ,PAS2,EPM1,EPSI,EPSILO2,A2,DENOM
      DOUBLE PRECISION  :: DT
      DOUBLE PRECISION  :: TEST3(NPLOT)
      INTEGER           :: IFABOR(NELEM2,7)
      INTEGER           :: ETA(NPLOT),ETAS(NPLAN),FRE(NPLOT)
      INTEGER           :: IFAPAR(6,*)
      INTEGER           :: IFF
      TYPE (CHARAC_TYPE_4D):: CHARAC2(NPLOT)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELE,ISO
      INTEGER IPLOT,ISP,I1,I2,I3,IEL,IET,IET2,ISOH,ISOV,IFA,ISUI(3)
      INTEGER IPROC,ILOC,NEPID,ITE,MYPID,IORI,ISOT,ISOF,IFR
!
!
!
      INTRINSIC ABS
!
      INTEGER P_IMAX
      EXTERNAL P_IMAX
!
      DATA ISUI   / 2 , 3 , 1 /
      DATA EPSILO / -1.D-6 /
      DATA EPSILO2 / -1.D-16 /
      DATA EPSDZ /1.D-4/
      DATA EPSI /1.D-12/
!
!***********************************************************************
!  DEBUG PRINTOUTS
!
      IF (NCSIZE<=1) THEN
        WRITE(LU,*) 'CALLING PIEDS_TOMAWAC_MPI IN A SERIAL RUN.'
        CALL PLANTE(1)
        STOP
      ENDIF
!
!-----------------------------------------------------------------------
! FILLS ELT,NSP,XPLOT,YPLOT, COMPUTES VALID SHP FUNCTIONS, RANGE 1..NPLOT
! IMPORTANT: THE COMPUTED SHP(IPLOT) APPLIED LATER ON
! IN THE INTERPOLATION!...
!
      TEST3 = 1.D0
      EPM1 = 1.D0-EPSI
      DO IPLOT = 1,NPLOT
        XPLOT(IPLOT)   = CHARAC2(IPLOT)%XP
        YPLOT(IPLOT)   = CHARAC2(IPLOT)%YP
        TPLOT(IPLOT)   = CHARAC2(IPLOT)%ZP
        FPLOT(IPLOT)   = CHARAC2(IPLOT)%FP
        DX(IPLOT)      = CHARAC2(IPLOT)%DX
        DY(IPLOT)      = CHARAC2(IPLOT)%DY
        DW(IPLOT)      = CHARAC2(IPLOT)%DZ
        DF(IPLOT)      = CHARAC2(IPLOT)%DF
        ELT(IPLOT)     = CHARAC2(IPLOT)%INE
        ETA(IPLOT)     = CHARAC2(IPLOT)%KNE
        FRE(IPLOT)     = CHARAC2(IPLOT)%FNE
        NSP(IPLOT)     = CHARAC2(IPLOT)%NSP ! R-K STEPS TO BE FULFILLED
        ISPDONE(IPLOT) = CHARAC2(IPLOT)%ISP ! R-K STEPS ALREADY DONE
        MYPID          = CHARAC2(IPLOT)%MYPID
        IORI           = CHARAC2(IPLOT)%IOR
        PAS = SENS * DT / NSP(IPLOT)
        IEL = ELT(IPLOT)
        IET = ETA(IPLOT)
        IFR = FRE(IPLOT)
        XP  = XPLOT(IPLOT)
        YP  = YPLOT(IPLOT)
        TP  = TPLOT(IPLOT)
        FP  = FPLOT(IPLOT)
        I1 = IKLE2(IEL,1)
        I2 = IKLE2(IEL,2)
        I3 = IKLE2(IEL,3)
               SHP1(IPLOT) = ((X(I3)-X(I2))*(YP-Y(I2))
     &                        -(Y(I3)-Y(I2))*(XP-X(I2))) * SURDET(IEL)
               SHP2(IPLOT) = ((X(I1)-X(I3))*(YP-Y(I3))
     &                        -(Y(I1)-Y(I3))*(XP-X(I3))) * SURDET(IEL)
               SHP3(IPLOT) = ((X(I2)-X(I1))*(YP-Y(I1))
     &                        -(Y(I2)-Y(I1))*(XP-X(I1))) * SURDET(IEL)
               SHT(IPLOT) = (TP-TETA(IET)) / (TETA(IET+1)-TETA(IET))
               SHF(IPLOT) = (FP-FREQ(IFR)) / (FREQ(IFR+1)-FREQ(IFR))
!       ASSUMES ALL ARE LOCALISED, IT WILL BE SET OTHERWISE IF LOST-AGAIN
!
          CHARAC2(IPLOT)%NEPID=-1
!
!
!
!
! IF SOME OF THE SHP FUNCTIONS ARE NEGATIVE, WE ARE IN A WRONG ELEMENT
! (XP,YP) PROBABLY DEEPER IN THE SUBDOMAIN THAN THE HALO CELL GIVEN IN "INE"
!
        DO  WHILE((SHP1(IPLOT)<EPSILO).OR.(SHP2(IPLOT)<EPSILO)
     &         .OR.(SHP3(IPLOT)<EPSILO).OR.SHT(IPLOT).LT.EPSILO.OR.
     &          SHT(IPLOT).GT.1.D0-EPSILO.OR.SHF(IPLOT).LT.EPSILO
     &          .OR.SHF(IPLOT).GT.1.D0-EPSILO)
          ISO=0
               IF (SHP1(IPLOT).LT.EPSILO) ISO=IBSET(ISO,4)
               IF (SHP2(IPLOT).LT.EPSILO) ISO=IBSET(ISO,5)
               IF (SHP3(IPLOT).LT.EPSILO) ISO=IBSET(ISO,6)
               IF (SHT(IPLOT).LT.EPSILO)  ISO=IBSET(ISO,0)
               IF (SHT(IPLOT).GT.1.D0-EPSILO)  ISO=IBSET(ISO,1)
               IF (SHF(IPLOT).LT.EPSILO)  ISO=IBSET(ISO,2)
               IF  (SHF(IPLOT).GT.1.D0-EPSILO) ISO=IBSET(ISO,3)
!
              ISOT = IAND(ISO, 3)
              ISOF = IAND(ISO,12)/4
              ISOV = IAND(ISO,15)
              ISOH = IAND(ISO,112)
!
               IEL = ELT(IPLOT)
               IET = ETA(IPLOT)
               IFR = FRE(IPLOT)
               XP = XPLOT(IPLOT)
               YP = YPLOT(IPLOT)
               TP = TPLOT(IPLOT)
               FP = FPLOT(IPLOT)
!
              IF (ISOH.NE.0) THEN
!
                IF (ISOH.EQ.16) THEN
                   IFA = 2
                ELSEIF (ISOH.EQ.32) THEN
                   IFA = 3
                ELSEIF (ISOH.EQ.64) THEN
                   IFA = 1
                ELSEIF (ISOH.EQ.48) THEN
                   IFA = 2
                   IF (DX(IPLOT)*(Y(IKLE2(IEL,3))-YP).LT.
     &                 DY(IPLOT)*(X(IKLE2(IEL,3))-XP)) IFA = 3
                ELSEIF (ISOH.EQ.96) THEN
                   IFA = 3
                   IF (DX(IPLOT)*(Y(IKLE2(IEL,1))-YP).LT.
     &                 DY(IPLOT)*(X(IKLE2(IEL,1))-XP)) IFA = 1
                ELSE
                   IFA = 1
                   IF (DX(IPLOT)*(Y(IKLE2(IEL,2))-YP).LT.
     &                 DY(IPLOT)*(X(IKLE2(IEL,2))-XP)) IFA = 2
                ENDIF
!
                IF (ISOV.GT.0) THEN
                   I1 = IKLE2(IEL,IFA)
                   I2 = IKLE2(IEL,ISUI(IFA))
                   IF (ISOF.GT.0) THEN
                      IF (ISOT.GT.0) THEN
                         A1=(FP-FREQ(IFR+ISOF-1))/DF(IPLOT)
                         A2=(TP-TETA(IET+ISOT-1))/DW(IPLOT)
                         IF (A1.LT.A2) THEN
                           IF ((X(I2)-X(I1))*(YP-A1*DY(IPLOT)-Y(I1)).GT.
     &               (Y(I2)-Y(I1))*(XP-A1*DX(IPLOT)-X(I1))) IFA=ISOF+5
                         ELSE
                          IF ((X(I2)-X(I1))*(YP-A2*DY(IPLOT)-Y(I1)).GT.
     &             (Y(I2)-Y(I1))*(XP-A2*DX(IPLOT)-X(I1))) IFA=ISOT+3
                       ENDIF
                    ELSE
                       A1 = (FP-FREQ(IFR+ISOF-1)) / DF(IPLOT)
                       IF ((X(I2)-X(I1))*(YP-A1*DY(IPLOT)-Y(I1)).GT.
     &                (Y(I2)-Y(I1))*(XP-A1*DX(IPLOT)-X(I1))) IFA=ISOF+5
                    ENDIF
                 ELSE
                    A1 = (TP-TETA(IET+ISOT-1)) / DW(IPLOT)
!CD CORRECTION V6P1
                    IF ((X(I2)-X(I1))*(YP-A1*DY(IPLOT)-Y(I1)).GT.
     &                 (Y(I2)-Y(I1))*(XP-A1*DX(IPLOT)-X(I1))) IFA=ISOT+3
                 ENDIF
              ENDIF
!
           ELSEIF (ISOT.GT.0) THEN
!
              IFA = ISOT + 3
!
              IF (ISOF.GT.0) THEN
                 A1=(FP-FREQ(IFR+ISOF-1))/DF(IPLOT)
                 A2=(TP-TETA(IET+ISOT-1))/DW(IPLOT)
                 IF (A1.LT.A2) IFA = ISOF + 5
              ENDIF
           ELSE
              IFA = ISOF + 5
           ENDIF
!
!     IF (IFABOR(IEL,IFA)==-2) THEN
!
!                     IF (ISOH.EQ.48) THEN
!                          IF (IFA==3) THEN
!                             IFA = 2
!                          ELSE
!                             IFA = 3
!                          ENDIF
!                     ELSEIF (ISOH.EQ.96) THEN
!                          IF (IFA==1) THEN
!     IFA = 3
!     ELSE
!     IFA = 1
!     ENDIF
!     ENDIF
!
!     ENDIF
           IEL = IFABOR(IEL,IFA)
!
!
           IF (IFA.LE.3) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE OF THE PRISM IS A RECTANGULAR FACE
!     =================================================================
!-----------------------------------------------------------------------
!
              IF (IEL.GT.0) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS AN INTERIOR FACE
!  MOVES TO THE ADJACENT ELEMENT
!-----------------------------------------------------------------------
!
                 I1 = IKLE2(IEL,1)
                     I2 = IKLE2(IEL,2)
                     I3 = IKLE2(IEL,3)
!
                     ELT(IPLOT) = IEL
                     SHP1(IPLOT) = ((X(I3)-X(I2))*(YP-Y(I2))
     &                    -(Y(I3)-Y(I2))*(XP-X(I2)))*SURDET(IEL)
                     SHP2(IPLOT) = ((X(I1)-X(I3))*(YP-Y(I3))
     &                    -(Y(I1)-Y(I3))*(XP-X(I3)))*SURDET(IEL)
                     SHP3(IPLOT) = ((X(I2)-X(I1))*(YP-Y(I1))
     &                    -(Y(I2)-Y(I1))*(XP-X(I1)))*SURDET(IEL)
!
                     ISO = ISOV
!
                     IF (SHP1(IPLOT).LT.EPSILO) ISO=IBSET(ISO,4)
                     IF (SHP2(IPLOT).LT.EPSILO) ISO=IBSET(ISO,5)
                     IF (SHP3(IPLOT).LT.EPSILO) ISO=IBSET(ISO,6)
!
!
                   CHARAC2(IPLOT)%INE=IEL
                   CYCLE
!
                ENDIF
!
!-----------------------------------------------------------------------
! HERE: TESTS PASSING TO THE NEIGHBOUR SUBDOMAIN AND COLLECTS DATA
!-----------------------------------------------------------------------
!
                IF(IEL==-2) THEN ! A LOST-AGAIN TRACEBACK DETECTED
!
                 IPROC=IFAPAR(IFA,ELT(IPLOT))
                 ILOC=IFAPAR(IFA+3,ELT(IPLOT))
                 CHARAC2(IPLOT)%XP=XPLOT(IPLOT) ! NEW POSITION
                 CHARAC2(IPLOT)%YP=YPLOT(IPLOT) ! IN THE OLD ELEMENT
                 CHARAC2(IPLOT)%ZP=TPLOT(IPLOT) ! IN THE OLD ELEMENT
                 CHARAC2(IPLOT)%FP=FPLOT(IPLOT) ! IN THE OLD ELEMENT
                 CHARAC2(IPLOT)%DX=DX(IPLOT) ! NEW POSITION
                 CHARAC2(IPLOT)%DY=DY(IPLOT) ! IN THE OLD ELEMENT
                 CHARAC2(IPLOT)%DZ=DW(IPLOT) ! IN THE OLD ELEMENT
                 CHARAC2(IPLOT)%DF=DF(IPLOT) ! IN THE OLD ELEMENT
                 CHARAC2(IPLOT)%NEPID=IPROC
                 CHARAC2(IPLOT)%INE=ILOC
                 CHARAC2(IPLOT)%KNE=ETA(IPLOT)
                 CHARAC2(IPLOT)%FNE=FRE(IPLOT)
!
                   TEST3(IPLOT)=0.D0
                 EXIT
!
               ENDIF
!
!-----------------------------------------------------------------------
! TREATS SOLID OR LIQUID BOUNDARIES DIFFERENTLY
!-----------------------------------------------------------------------
!
                  DXP = DX(IPLOT)
                  DYP = DY(IPLOT)
                  I1  = IKLE2(ELT(IPLOT),IFA)
                  I2  = IKLE2(ELT(IPLOT),ISUI(IFA))
                  DX1 = X(I2) - X(I1)
                  DY1 = Y(I2) - Y(I1)
!
                  IF(IEL.EQ.-1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS A SOLID BOUNDARY
!  PROJECTS THE RELICAT ON THE BOUNDARY AND MOVES
!-----------------------------------------------------------------------
!
                   ETA(IPLOT) = IET
                    SHP1(IPLOT) = 0.D0
                    SHP2(IPLOT) = 0.D0
                    SHP3(IPLOT) = 0.D0
                   SHT(IPLOT) = 0.0D0
                   SHF(IPLOT) = 0.0D0
                   ISPDONE(IPLOT) = NSP(IPLOT)+1
                   CHARAC2(IPLOT)%INE = ELT(IPLOT)
                   CHARAC2(IPLOT)%KNE = ETA(IPLOT)
                   CHARAC2(IPLOT)%FNE = FRE(IPLOT)
                   CHARAC2(IPLOT)%ISP = NSP(IPLOT) +1
                      EXIT
!                      A1 = (DXP*DX1+DYP*DY1) / (DX1**2+DY1**2)
!                      DX(IPLOT) = A1 * DX1
!                      DY(IPLOT) = A1 * DY1
! !
!                      A1=((XP-X(I1))*DX1+(YP-Y(I1))*DY1)/(DX1**2+DY1**2)
!                   IF (IFA.EQ.1) THEN
!                     SHP1(IPLOT) = 1.D0 - A1
!                     SHP2(IPLOT) = A1
!                     SHP3(IPLOT) = 0.D0
!                   ELSEIF (IFA.EQ.2) THEN
!                     SHP2(IPLOT) = 1.D0 - A1
!                     SHP3(IPLOT) = A1
!                     SHP1(IPLOT) = 0.D0
!                   ELSE
!                     SHP3(IPLOT) = 1.D0 - A1
!                     SHP1(IPLOT) = A1
!                     SHP2(IPLOT) = 0.D0
!                   ENDIF
!                      XPLOT(IPLOT) = X(I1) + A1 * DX1
!                      YPLOT(IPLOT) = Y(I1) + A1 * DY1
! !
!                      ISO = ISOV
! !
!                      IF(SHP1(IPLOT).LT.EPSILO) ISO=IBSET(ISO,2)
!                      IF(SHP2(IPLOT).LT.EPSILO) ISO=IBSET(ISO,3)
!                      IF(SHP3(IPLOT).LT.EPSILO) ISO=IBSET(ISO,4)
!                    CHARAC2(IPLOT)%INE = ELT(IPLOT)
!                    CHARAC2(IPLOT)%KNE = ETA(IPLOT)
!                    CYCLE
                  ENDIF
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS A LIQUID BOUNDARY
!  ENDS TRACING BACK (SIGN OF ELT)
!
!     OR
!
!  HERE: THE EXIT FACE IS A SUB-DOMAIN INTERFACE
!  INTERFACE POINT WILL BE TREATED IN THE NEXT SUB-DOMAIN
!  ONLY SETS TEST TO ZERO HERE
!-----------------------------------------------------------------------
!
!>>>>
                 A1 = (DXP*(YP-Y(I1))-DYP*(XP-X(I1)))/(DXP*DY1-DYP*DX1)
                  IF (A1.GT.EPM1) A1 = 1.D0
                  IF (A1.LT.EPSI) A1 = 0.D0
                  IF (IFA.EQ.1) THEN
                    SHP1(IPLOT) = 1.D0 - A1
                    SHP2(IPLOT) = A1
                    SHP3(IPLOT) = 0.D0
                  ELSEIF (IFA.EQ.2) THEN
                    SHP2(IPLOT) = 1.D0 - A1
                    SHP3(IPLOT) = A1
                    SHP1(IPLOT) = 0.D0
                  ELSE
                    SHP3(IPLOT) = 1.D0 - A1
                    SHP1(IPLOT) = A1
                    SHP2(IPLOT) = 0.D0
                  ENDIF
                  XPLOT(IPLOT) = X(I1) + A1 * DX1
                  YPLOT(IPLOT) = Y(I1) + A1 * DY1
                  IF(ABS(DXP).GT.ABS(DYP)) THEN
                     A1 = (XP-XPLOT(IPLOT))/DXP
                  ELSE
                     A1 = (YP-YPLOT(IPLOT))/DYP
                  ENDIF
                  IF (A1.GT.EPM1) A1 = 1.D0
                  IF (A1.LT.EPSI) A1 = 0.D0
                  TPLOT(IPLOT) = TP - A1*DW(IPLOT)
                  SHT(IPLOT) = (TPLOT(IPLOT)-TETA(IET))
     &                       / (TETA(IET+1)-TETA(IET))
                  FPLOT(IPLOT) = FP - A1*DF(IPLOT)
                  SHF(IPLOT) = (FPLOT(IPLOT)-FREQ(IFR))
     &                       / (FREQ(IFR+1)-FREQ(IFR))
!
                  ISPDONE(IPLOT) = NSP(IPLOT)+1   ! THIS WILL FORBID ENTERING FURTHER LOOPS
                   CHARAC2(IPLOT)%INE = ELT(IPLOT)
                   CHARAC2(IPLOT)%KNE = ETA(IPLOT)
                   CHARAC2(IPLOT)%FNE = FRE(IPLOT)
                   CHARAC2(IPLOT)%ISP = NSP(IPLOT) +1
!                 CAN ONLY HAPPEN IN PARALLEL.  ACTUALLY, NOT REQUIRED
                  IF(IEL.EQ.-2) TEST3(IPLOT) = 0.D0
                  ! A FUSE
                  IF(IEL==-2) WRITE(LU,*) ' *** SHIT IPLOT: ',IPLOT
!                 EXIT
!
               ELSEIF (IFA.LE.5) THEN
!
!-----------------------------------------------------------------------
!  IFA = 4 OR 5
!  HERE: THE EXIT FACE OF THE PRISM IS A TRIANGULAR FACE TETA
!  =====================================================================
!-----------------------------------------------------------------------
!
                  IFA = IFA - 4
!
                  IF (IEL.EQ.1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS AN INTERIOR FACE
!  MOVES TO THE ADJACENT ELEMENT
!-----------------------------------------------------------------------
!
                     ETA(IPLOT) = IET + IFA + IFA - 1
                     IF (ETA(IPLOT).EQ.NPLAN+1) THEN
                        ETA(IPLOT)=1
                        TP=TP-2*3.14159265D0
                        TPLOT(IPLOT)=TP
                     ENDIF
                     IF (ETA(IPLOT).EQ.0) THEN
                        ETA(IPLOT) = NPLAN
                        TP=TP+2*3.14159265D0
                        TPLOT(IPLOT)=TP
                     ENDIF
                     SHT(IPLOT) = (TP-TETA(ETA(IPLOT)))
     &                    / (TETA(ETA(IPLOT)+1)-TETA(ETA(IPLOT)))
!
                     ISO = ISOH+ISOF*4
!
                     IF (SHT(IPLOT).LT.EPSILO) ISO=IBSET(ISO,0)
                     IF (SHT(IPLOT).GT.1.D0-EPSILO) ISO=IBSET(ISO,1)
!
!     GOTO 50
                     CYCLE
!
                  ELSE
!
                     IF(LNG.EQ.1) THEN
                        WRITE(LU,*) 'PROBLEME DANS PIED4D',IEL,IPLOT
                     ELSE
                        WRITE(LU,*) 'PROBLEM IN PIED4D',IEL,IPLOT
                     ENDIF
                   WRITE(LU,*) 'SHP',SHP1(IPLOT),SHP2(IPLOT),SHP3(IPLOT)
                     WRITE(LU,*) 'SHT',SHT(IPLOT)
                     WRITE(LU,*) 'DXYZ',DX(IPLOT),DY(IPLOT),DW(IPLOT)
                WRITE(LU,*) 'XYZ',XPLOT(IPLOT),YPLOT(IPLOT),TPLOT(IPLOT)
                     STOP
                  ENDIF
!
               ELSE
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE OF THE PRISM IS A TRIANGULAR FACE FREQ
!  =====================================================================
!-----------------------------------------------------------------------
!
                  IFA = IFA - 6
!
                  IF ((IFA.EQ.1).AND.(IFR.EQ.NF-1)) IEL=-1
                  IF ((IFA.EQ.0).AND.(IFR.EQ.1)) IEL=-1
                  IF (IEL.EQ.1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS AN INTERIOR FACE
!  MOVES TO THE ADJACENT ELEMENT
!-----------------------------------------------------------------------
!
                     FRE(IPLOT) = IFR + IFA + IFA - 1
                     SHF(IPLOT) = (FP-FREQ(FRE(IPLOT)))
     &                    / (FREQ(FRE(IPLOT)+1)-FREQ(FRE(IPLOT)))
!
                     ISO = ISOH+ISOT
!
                     IF (SHF(IPLOT).LT.EPSILO)  ISO=IBSET(ISO,2)
                     IF (SHF(IPLOT).GT.1.D0-EPSILO)  ISO=IBSET(ISO,3)
!
!     GOTO 50
                     CYCLE
!
                  ELSE
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS THE MIN OR MAX FREQUENCY
!  PROJECTS THE RELICAT ON THE BOUNDARY AND CONTINUES
!-----------------------------------------------------------------------
!
                     FPLOT(IPLOT)=FREQ(IFR+IFA)
                     DF(IPLOT)=0.D0
                     SHF(IPLOT)=IFA
                     ISO = ISOH +ISOT
                     IF(ISO.NE.0) CYCLE ! GOTO 50
!
                  ENDIF
         ENDIF
!     ENDDO
      ENDDO
!        IF (TEST3(IPLOT).LE.0.5) THEN
!           SHP1(IPLOT) = 0.D0
!           SHP2(IPLOT) = 0.D0
!           SHP3(IPLOT) = 0.D0
!        ENDIF
!
      ENDDO
!
!-----------------------------------------------------------------------
!  LOOP
!-----------------------------------------------------------------------
!
      DO  40 IPLOT=1,NPLOT
         MYPID          = CHARAC2(IPLOT)%MYPID
         IORI           = CHARAC2(IPLOT)%IOR
!
         PAS = SENS * DT / NSP(IPLOT)
!
         DO ISP =1,NSP(IPLOT)
!
!-----------------------------------------------------------------------
!     LOCATES THE END POINT OF ALL THE CHARACTERISTICS
!-----------------------------------------------------------------------
!
             ISO = 0
             PAS2=PAS
!
             IF (CHARAC2(IPLOT)%NEPID==-1.AND.ISP>ISPDONE(IPLOT)
     &            .AND.TEST3(IPLOT)>0.5D0 ) THEN
!
!
               IEL = ELT(IPLOT)
               IET = ETA(IPLOT)
               IFR = FRE(IPLOT)
               I1 = IKLE2(IEL,1)
               I2 = IKLE2(IEL,2)
               I3 = IKLE2(IEL,3)
!
         DX(IPLOT) = ( (1.D0-SHF(IPLOT))*
     &          ( U(I1,IET  ,IFR)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + U(I2,IET  ,IFR)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + U(I3,IET  ,IFR)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + U(I1,ETAS(IET),IFR)*SHP1(IPLOT)*SHT(IPLOT)
     &      + U(I2,ETAS(IET),IFR)*SHP2(IPLOT)*SHT(IPLOT)
     &      + U(I3,ETAS(IET),IFR)*SHP3(IPLOT)*SHT(IPLOT))
     &        + SHF(IPLOT)*
     &          ( U(I1,IET  ,IFR+1)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + U(I2,IET  ,IFR+1)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + U(I3,IET  ,IFR+1)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + U(I1,ETAS(IET),IFR+1)*SHP1(IPLOT)*SHT(IPLOT)
     &      + U(I2,ETAS(IET),IFR+1)*SHP2(IPLOT)*SHT(IPLOT)
     &      + U(I3,ETAS(IET),IFR+1)*SHP3(IPLOT)*SHT(IPLOT)) )*PAS
!
         DY(IPLOT) = ( (1.D0-SHF(IPLOT))*
     &          ( V(I1,IET  ,IFR)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + V(I2,IET  ,IFR)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + V(I3,IET  ,IFR)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + V(I1,ETAS(IET),IFR)*SHP1(IPLOT)*SHT(IPLOT)
     &      + V(I2,ETAS(IET),IFR)*SHP2(IPLOT)*SHT(IPLOT)
     &      + V(I3,ETAS(IET),IFR)*SHP3(IPLOT)*SHT(IPLOT))
     &        + SHF(IPLOT)*
     &          ( V(I1,IET  ,IFR+1)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + V(I2,IET  ,IFR+1)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + V(I3,IET  ,IFR+1)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + V(I1,ETAS(IET),IFR+1)*SHP1(IPLOT)*SHT(IPLOT)
     &      + V(I2,ETAS(IET),IFR+1)*SHP2(IPLOT)*SHT(IPLOT)
     &      + V(I3,ETAS(IET),IFR+1)*SHP3(IPLOT)*SHT(IPLOT)) )*PAS
!
         DW(IPLOT) = ( (1.D0-SHF(IPLOT))*
     &          ( T(I1,IET  ,IFR)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + T(I2,IET  ,IFR)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + T(I3,IET  ,IFR)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + T(I1,ETAS(IET),IFR)*SHP1(IPLOT)*SHT(IPLOT)
     &      + T(I2,ETAS(IET),IFR)*SHP2(IPLOT)*SHT(IPLOT)
     &      + T(I3,ETAS(IET),IFR)*SHP3(IPLOT)*SHT(IPLOT))
     &        + SHF(IPLOT)*
     &          ( T(I1,IET  ,IFR+1)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + T(I2,IET  ,IFR+1)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + T(I3,IET  ,IFR+1)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + T(I1,ETAS(IET),IFR+1)*SHP1(IPLOT)*SHT(IPLOT)
     &      + T(I2,ETAS(IET),IFR+1)*SHP2(IPLOT)*SHT(IPLOT)
     &      + T(I3,ETAS(IET),IFR+1)*SHP3(IPLOT)*SHT(IPLOT)) )*PAS
!
         DF(IPLOT) = ( (1.D0-SHF(IPLOT))*
     &          ( W(I1,IET  ,IFR)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + W(I2,IET  ,IFR)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + W(I3,IET  ,IFR)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + W(I1,ETAS(IET),IFR)*SHP1(IPLOT)*SHT(IPLOT)
     &      + W(I2,ETAS(IET),IFR)*SHP2(IPLOT)*SHT(IPLOT)
     &      + W(I3,ETAS(IET),IFR)*SHP3(IPLOT)*SHT(IPLOT))
     &        + SHF(IPLOT)*
     &          ( W(I1,IET  ,IFR+1)*SHP1(IPLOT)*(1.D0-SHT(IPLOT))
     &      + W(I2,IET  ,IFR+1)*SHP2(IPLOT)*(1.D0-SHT(IPLOT))
     &      + W(I3,IET  ,IFR+1)*SHP3(IPLOT)*(1.D0-SHT(IPLOT))
     &      + W(I1,ETAS(IET),IFR+1)*SHP1(IPLOT)*SHT(IPLOT)
     &      + W(I2,ETAS(IET),IFR+1)*SHP2(IPLOT)*SHT(IPLOT)
     &      + W(I3,ETAS(IET),IFR+1)*SHP3(IPLOT)*SHT(IPLOT)) )*PAS
!
!
               XP = XPLOT(IPLOT) + DX(IPLOT)
               YP = YPLOT(IPLOT) + DY(IPLOT)
               TP = TPLOT(IPLOT) + DW(IPLOT)
               FP = FPLOT(IPLOT) + DF(IPLOT)
!
               SHP1(IPLOT) = ((X(I3)-X(I2))*(YP-Y(I2))
     &                        -(Y(I3)-Y(I2))*(XP-X(I2))) * SURDET(IEL)
               SHP2(IPLOT) = ((X(I1)-X(I3))*(YP-Y(I3))
     &                        -(Y(I1)-Y(I3))*(XP-X(I3))) * SURDET(IEL)
               SHP3(IPLOT) = ((X(I2)-X(I1))*(YP-Y(I1))
     &                        -(Y(I2)-Y(I1))*(XP-X(I1))) * SURDET(IEL)
               SHT(IPLOT) = (TP-TETA(IET)) / (TETA(IET+1)-TETA(IET))
               SHF(IPLOT) = (FP-FREQ(IFR)) / (FREQ(IFR+1)-FREQ(IFR))
!
               XPLOT(IPLOT) = XP
               YPLOT(IPLOT) = YP
               TPLOT(IPLOT) = TP
               FPLOT(IPLOT) = FP
!
               IF (SHP1(IPLOT).LT.EPSILO) ISO=IBSET(ISO,4)
               IF (SHP2(IPLOT).LT.EPSILO) ISO=IBSET(ISO,5)
               IF (SHP3(IPLOT).LT.EPSILO) ISO=IBSET(ISO,6)
!
               IF  (SHT(IPLOT).LT.EPSILO) ISO=IBSET(ISO,0)
               IF  (SHT(IPLOT).GT.1.D0-EPSILO) ISO=IBSET(ISO,1)
!
               IF  (SHF(IPLOT).LT.EPSILO) ISO=IBSET(ISO,2)
               IF  (SHF(IPLOT).GT.1.D0-EPSILO) ISO=IBSET(ISO,3)
!
!
           ! CONTINUOUS SETTING OF THE REACHED POSITION FOR IPLOT
           ! AND THE NUMBER OF STEPS DONE ALREADY
               CHARAC2(IPLOT)%XP=XPLOT(IPLOT)
               CHARAC2(IPLOT)%YP=YPLOT(IPLOT)
               CHARAC2(IPLOT)%ZP=TPLOT(IPLOT)
               CHARAC2(IPLOT)%FP=FPLOT(IPLOT)
               CHARAC2(IPLOT)%DX=DX(IPLOT)
               CHARAC2(IPLOT)%DY=DY(IPLOT)
               CHARAC2(IPLOT)%DZ=DW(IPLOT)
               CHARAC2(IPLOT)%DF=DF(IPLOT)
               CHARAC2(IPLOT)%ISP=ISP
               CHARAC2(IPLOT)%KNE=ETA(IPLOT)
               CHARAC2(IPLOT)%NSP=NSP(IPLOT)
               CHARAC2(IPLOT)%INE=ELT(IPLOT)
               CHARAC2(IPLOT)%FNE=FRE(IPLOT)
!
            ENDIF
!
!-----------------------------------------------------------------------
!  TREATS DIFFERENTLY THE CHARACTERISTICS ISSUED FROM
!  THE START ELEMENT
!-----------------------------------------------------------------------
!
50          CONTINUE
!
!
!
             IF ((ISO.NE.0).AND.(TEST3(IPLOT)>0.5D0)) THEN
!
!-----------------------------------------------------------------------
!  HERE: LEFT THE ELEMENT
!-----------------------------------------------------------------------
!
              ISOT = IAND(ISO, 3)
              ISOF = IAND(ISO,12)/4
              ISOV = IAND(ISO,15)
              ISOH = IAND(ISO,112)
              IEL = ELT(IPLOT)
              IET = ETA(IPLOT)
              IFR = FRE(IPLOT)
              XP = XPLOT(IPLOT)
              YP = YPLOT(IPLOT)
              TP = TPLOT(IPLOT)
              FP = FPLOT(IPLOT)
!
              IF (ISOH.NE.0) THEN
!
                IF (ISOH.EQ.16) THEN
                   IFA = 2
                ELSEIF (ISOH.EQ.32) THEN
                   IFA = 3
                ELSEIF (ISOH.EQ.64) THEN
                   IFA = 1
                ELSEIF (ISOH.EQ.48) THEN
                   IFA = 2
                   IF (DX(IPLOT)*(Y(IKLE2(IEL,3))-YP).LT.
     &                 DY(IPLOT)*(X(IKLE2(IEL,3))-XP)) IFA = 3
                ELSEIF (ISOH.EQ.96) THEN
                   IFA = 3
                   IF (DX(IPLOT)*(Y(IKLE2(IEL,1))-YP).LT.
     &                 DY(IPLOT)*(X(IKLE2(IEL,1))-XP)) IFA = 1
                ELSE
                   IFA = 1
                   IF (DX(IPLOT)*(Y(IKLE2(IEL,2))-YP).LT.
     &                 DY(IPLOT)*(X(IKLE2(IEL,2))-XP)) IFA = 2
                ENDIF
!
                IF (ISOV.GT.0) THEN
                  I1 = IKLE2(IEL,IFA)
                  I2 = IKLE2(IEL,ISUI(IFA))
                  IF (ISOF.GT.0) THEN
                     IF (ISOT.GT.0) THEN
                        A1=(FP-FREQ(IFR+ISOF-1))/DF(IPLOT)
                        A2=(TP-TETA(IET+ISOT-1))/DW(IPLOT)
                        IF (A1.LT.A2) THEN
                           IF ((X(I2)-X(I1))*(YP-A1*DY(IPLOT)-Y(I1)).GT.
     &                (Y(I2)-Y(I1))*(XP-A1*DX(IPLOT)-X(I1))) IFA=ISOF+5
                        ELSE
                           IF ((X(I2)-X(I1))*(YP-A2*DY(IPLOT)-Y(I1)).GT.
     &                 (Y(I2)-Y(I1))*(XP-A2*DX(IPLOT)-X(I1))) IFA=ISOT+3
                        ENDIF
                     ELSE
                A1 = (FP-FREQ(IFR+ISOF-1)) / DF(IPLOT)
                IF ((X(I2)-X(I1))*(YP-A1*DY(IPLOT)-Y(I1)).GT.
     &               (Y(I2)-Y(I1))*(XP-A1*DX(IPLOT)-X(I1))) IFA=ISOF+5
             ENDIF
          ELSE
             A1 = (TP-TETA(IET+ISOT-1)) / DW(IPLOT)
             IF ((X(I2)-X(I1))*(YP-A1*DY(IPLOT)-Y(I1)).GT.
     &             (Y(I2)-Y(I1))*(XP-A1*DX(IPLOT)-X(I1))) IFA=ISOT+3
          ENDIF
       ENDIF
!
      ELSEIF (ISOT.GT.0) THEN
!
         IFA = ISOT + 3
!
         IF (ISOF.GT.0) THEN
            A1=(FP-FREQ(IFR+ISOF-1))/DF(IPLOT)
            A2=(TP-TETA(IET+ISOT-1))/DW(IPLOT)
            IF (A1.LT.A2) IFA = ISOF + 5
         ENDIF
      ELSE
         IFA = ISOF + 5
      ENDIF
!
!
       IEL = IFABOR(IEL,IFA)
!
       IF (IFA.LE.3) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE OF THE PRISM IS A RECTANGULAR FACE
!     =================================================================
!-----------------------------------------------------------------------
!
          IF (IEL.GT.0) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS AN INTERIOR FACE
!  MOVES TO THE ADJACENT ELEMENT
!-----------------------------------------------------------------------
!
                     I1 = IKLE2(IEL,1)
                     I2 = IKLE2(IEL,2)
                     I3 = IKLE2(IEL,3)
!
                     ETA(IPLOT) = IET
                     ELT(IPLOT) = IEL
                     FRE(IPLOT) = IFR
                     SHP1(IPLOT) = ((X(I3)-X(I2))*(YP-Y(I2))
     &                           -(Y(I3)-Y(I2))*(XP-X(I2)))*SURDET(IEL)
                     SHP2(IPLOT) = ((X(I1)-X(I3))*(YP-Y(I3))
     &                           -(Y(I1)-Y(I3))*(XP-X(I3)))*SURDET(IEL)
                     SHP3(IPLOT) = ((X(I2)-X(I1))*(YP-Y(I1))
     &                           -(Y(I2)-Y(I1))*(XP-X(I1)))*SURDET(IEL)
!
                     ISO = ISOV
!
                     IF (SHP1(IPLOT).LT.EPSILO) ISO=IBSET(ISO,4)
                     IF (SHP2(IPLOT).LT.EPSILO) ISO=IBSET(ISO,5)
                     IF (SHP3(IPLOT).LT.EPSILO) ISO=IBSET(ISO,6)
!
                     ISPDONE(IPLOT) = ISP
                     CHARAC2(IPLOT)%INE=ELT(IPLOT)
                     CHARAC2(IPLOT)%KNE=ETA(IPLOT)
                     CHARAC2(IPLOT)%FNE=FRE(IPLOT)
!                     CYCLE
                     GOTO 50
!
                  ENDIF
!
!-----------------------------------------------------------------------
! HERE: TESTS PASSING TO THE NEIGHBOUR SUBDOMAIN AND COLLECTS DATA
!-----------------------------------------------------------------------
!
               IF(IEL==-2) THEN  ! A LOST-AGAIN TRACEBACK DETECTED
!
                 IPROC=IFAPAR(IFA,ELT(IPLOT))
                 ILOC=IFAPAR(IFA+3,ELT(IPLOT))
!
                   CHARAC2(IPLOT)%XP=XPLOT(IPLOT)
                   CHARAC2(IPLOT)%YP=YPLOT(IPLOT)
                   CHARAC2(IPLOT)%ZP=TPLOT(IPLOT)
                   CHARAC2(IPLOT)%FP=FPLOT(IPLOT)
                   CHARAC2(IPLOT)%DX=DX(IPLOT)
                   CHARAC2(IPLOT)%DY=DY(IPLOT)
                   CHARAC2(IPLOT)%DZ=DW(IPLOT)
                   CHARAC2(IPLOT)%DF=DF(IPLOT)
                   CHARAC2(IPLOT)%ISP=ISP
                   CHARAC2(IPLOT)%NEPID=IPROC
                   CHARAC2(IPLOT)%INE=ILOC
                   CHARAC2(IPLOT)%KNE=ETA(IPLOT)
                   CHARAC2(IPLOT)%FNE=FRE(IPLOT)
                   ISPDONE(IPLOT) = ISP
!
                  TEST3(IPLOT) = 0.D0
!
                 EXIT ! LOOP ON NSP
!
               ENDIF
!
!-----------------------------------------------------------------------
! TREATS SOLID OR LIQUID BOUNDARIES DIFFERENTLY
!-----------------------------------------------------------------------
!
                  DXP = DX(IPLOT)
                  DYP = DY(IPLOT)
                  I1  = IKLE2(ELT(IPLOT),IFA)
                  I2  = IKLE2(ELT(IPLOT),ISUI(IFA))
                  DX1 = X(I2) - X(I1)
                  DY1 = Y(I2) - Y(I1)
!
                  IF(IEL.EQ.-1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS A SOLID BOUNDARY
!  PROJECTS THE RELICAT ON THE BOUNDARY AND MOVES
!-----------------------------------------------------------------------
!
                        SHP1(IPLOT) = 0.0D0
                        SHP2(IPLOT) = 0.0D0
                        SHP3(IPLOT) = 0.0D0
                        ISPDONE(IPLOT) = NSP(IPLOT)+1
                        SHT(IPLOT) = 0.D0
                        SHF(IPLOT) = 0.D0
                        ETA(IPLOT) = IET
                        FRE(IPLOT) = IFR
                   CHARAC2(IPLOT)%INE=ELT(IPLOT)
                   CHARAC2(IPLOT)%KNE=ETA(IPLOT)
                   CHARAC2(IPLOT)%FNE=FRE(IPLOT)
                   CHARAC2(IPLOT)%ISP=NSP(IPLOT)+1
!
!                     GOTO 40
                      EXIT
!                       CYCLE
!
                  ENDIF
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS A LIQUID BOUNDARY
!  ENDS TRACING BACK (SIGN OF ELT)
!
!     OR
!
!  HERE: THE EXIT FACE IS A SUB-DOMAIN INTERFACE
!  INTERFACE POINT WILL BE TREATED IN THE NEXT SUB-DOMAIN
!  ONLY SETS TEST TO ZERO HERE
!-----------------------------------------------------------------------
!
!>>>>
                 A1 = (DXP*(YP-Y(I1))-DYP*(XP-X(I1)))/(DXP*DY1-DYP*DX1)
                  IF (A1.GT.EPM1) A1 = 1.D0
                  IF (A1.LT.EPSI) A1 = 0.D0
                  IF (IFA.EQ.1) THEN
                    SHP1(IPLOT) = 1.D0 - A1
                    SHP2(IPLOT) = A1
                    SHP3(IPLOT) = 0.D0
                  ELSEIF (IFA.EQ.2) THEN
                    SHP2(IPLOT) = 1.D0 - A1
                    SHP3(IPLOT) = A1
                    SHP1(IPLOT) = 0.D0
                  ELSE
                    SHP3(IPLOT) = 1.D0 - A1
                    SHP1(IPLOT) = A1
                    SHP2(IPLOT) = 0.D0
                  ENDIF
                  XPLOT(IPLOT) = X(I1) + A1 * DX1
                  YPLOT(IPLOT) = Y(I1) + A1 * DY1
                  IF(ABS(DXP).GT.ABS(DYP)) THEN
                    A1 = (XP-XPLOT(IPLOT))/DXP
                  ELSE
                    A1 = (YP-YPLOT(IPLOT))/DYP
                  ENDIF
                  IF (A1.GT.EPM1) A1 = 1.D0
                  IF (A1.LT.EPSI) A1 = 0.D0
                  TPLOT(IPLOT) = TP - A1*DW(IPLOT)
                  SHT(IPLOT) = (TPLOT(IPLOT)-TETA(IET))
     &                       / (TETA(IET+1)-TETA(IET))
                  FPLOT(IPLOT) = FP - A1*DF(IPLOT)
                  SHF(IPLOT) = (FPLOT(IPLOT)-FREQ(IFR))
     &                       / (FREQ(IFR+1)-FREQ(IFR))
!                  ELT(IPLOT) = - SENS * ELT(IPLOT)
!                  NSP(IPLOT) = ISP
                  ISPDONE(IPLOT) = NSP(IPLOT)+1
                   CHARAC2(IPLOT)%INE=ELT(IPLOT)
                   CHARAC2(IPLOT)%KNE=ETA(IPLOT)
                   CHARAC2(IPLOT)%FNE=FRE(IPLOT)
                   CHARAC2(IPLOT)%ISP=NSP(IPLOT)+1
!
!                 CAN ONLY HAPPEN IN PARALLEL.  ACTUALLY, NOT REQUIRED
!                  GOTO 50
!                   GOTO 40
                  IF(IEL.EQ.-2) TEST3(IPLOT) = 0.D0
                  ! A FUSE
                  IF(IEL==-2) WRITE(LU,*) ' *** SHIT IPLOT: ',IPLOT
!
               ELSEIF (IFA.LE.5) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE OF THE PRISM IS A TRIANGULAR FACE TETA
!  =====================================================================
!-----------------------------------------------------------------------
!
                  IFA = IFA - 4
!
                  IF (IEL.EQ.1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS AN INTERIOR FACE
!  MOVES TO THE ADJACENT ELEMENT
!-----------------------------------------------------------------------
!
                     ETA(IPLOT) = IET + IFA + IFA - 1
                     IF (ETA(IPLOT).EQ.NPLAN+1) THEN
                        ETA(IPLOT)=1
                        TP=TP-2*3.14159265D0
                        TPLOT(IPLOT)=TP
                     ENDIF
                     IF (ETA(IPLOT).EQ.0) THEN
                        ETA(IPLOT) = NPLAN
                        TP=TP+2*3.14159265D0
                        TPLOT(IPLOT)=TP
                     ENDIF
                     SHT(IPLOT) = (TP-TETA(ETA(IPLOT)))
     &                    / (TETA(ETA(IPLOT)+1)-TETA(ETA(IPLOT)))
!
                     ISO = ISOH+ISOF*4
!
                     IF (SHT(IPLOT).LT.EPSILO) ISO=IBSET(ISO,0)
                     IF (SHT(IPLOT).GT.1.D0-EPSILO) ISO=IBSET(ISO,1)
                     CHARAC2(IPLOT)%KNE=ETA(IPLOT)
!
                     GOTO 50
!
                  ELSE
!
                     IF(LNG.EQ.1) THEN
                        WRITE(LU,*) 'PROBLEME DANS PIED4D',IEL,IPLOT
                     ELSE
                        WRITE(LU,*) 'PROBLEM IN PIED4D',IEL,IPLOT
                     ENDIF
                 WRITE(LU,*) 'SHP',SHP1(IPLOT),SHP2(IPLOT),SHP3(IPLOT)
                     WRITE(LU,*) 'SHT',SHT(IPLOT)
                     WRITE(LU,*) 'DXYZ',DX(IPLOT),DY(IPLOT),DW(IPLOT)
        WRITE(LU,*) 'XYZ',XPLOT(IPLOT),YPLOT(IPLOT),TPLOT(IPLOT)
        STOP
                  ENDIF
!
               ELSE
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE OF THE PRISM IS A TRIANGULAR FACE FREQ
!  =====================================================================
!-----------------------------------------------------------------------
!
                  IFA = IFA - 6
!
                  IF ((IFA.EQ.1).AND.(IFR.EQ.NF-1)) IEL=-1
                  IF ((IFA.EQ.0).AND.(IFR.EQ.1)) IEL=-1
                  IF (IEL.EQ.1) THEN
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS AN INTERIOR FACE
!  MOVES TO THE ADJACENT ELEMENT
!-----------------------------------------------------------------------
!
                     FRE(IPLOT) = IFR + IFA + IFA - 1
                     SHF(IPLOT) = (FP-FREQ(FRE(IPLOT)))
     &                   / (FREQ(FRE(IPLOT)+1)-FREQ(FRE(IPLOT)))
!
                     ISO = ISOH+ISOT
!
               IF (SHF(IPLOT).LT.EPSILO) ISO=IBSET(ISO,2)
               IF (SHF(IPLOT).GT.1.D0-EPSILO) ISO=IBSET(ISO,3)
                     CHARAC2(IPLOT)%FNE=FRE(IPLOT)
!
                     GOTO 50
!
                  ELSE
!
!-----------------------------------------------------------------------
!  HERE: THE EXIT FACE IS THE MIN OR MAX FREQUENCY
!-----------------------------------------------------------------------
!
                    FPLOT(IPLOT)=FREQ(IFR+IFA)
                    DF(IPLOT)=0.D0
                    SHF(IPLOT)=IFA
                    ISO = ISOH +ISOT
                    IF(ISO.NE.0) GOTO 50
!
                 ENDIF
!
               ENDIF
                                ! CONTINUOUS SETTING OF THE REACHED POSITION FOR IPLOT
           ! AND THE NUMBER OF STEPS DONE ALREADY
!
            ENDIF
!
!
       ENDDO
!       ENDIF
40     CONTINUE
!
!-----------------------------------------------------------------------
!
      RETURN
      END SUBROUTINE PIEDS4D_TOMAWAC_MPI
      END MODULE TOMAWAC_MPI
