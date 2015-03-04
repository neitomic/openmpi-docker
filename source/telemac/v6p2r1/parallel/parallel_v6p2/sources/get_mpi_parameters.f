!                    *****************************
                     SUBROUTINE GET_MPI_PARAMETERS
!                    *****************************
!
     &(P_INTEGER,P_REAL8,P_UB,P_COMM_WORLD,P_SUCCESS)
!
!***********************************************************************
! PARALLEL   V6P1                                   21/08/2010
!***********************************************************************
!
!brief
!
!history  J-M HERVOUET (LNHE)
!+        02/02/2009
!+        V6P0
!+
!
!history  N.DURAND (HRW), S.E.BOURBAN (HRW)
!+        13/07/2010
!+        V6P0
!+   Translation of French comments within the FORTRAN sources into
!+   English comments
!
!history  N.DURAND (HRW), S.E.BOURBAN (HRW)
!+        21/08/2010
!+        V6P0
!+   Creation of DOXYGEN tags for automated documentation and
!+   cross-referencing of the FORTRAN sources
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| P_COMM_WORLD   |<--|  MPI_COMM_WORLD VALUE
!| P_INTEGER      |<--|  MPI_INTEGER VALUE 
!| P_REAL8        |<--|  MPI_REAL8 VALUE 
!| P_SUCCESS      |<--|  MPI_SUCCESS VALUE
!| P_UB           |<--|  MPI_UB VALUE
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
!
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(OUT) :: P_INTEGER,P_REAL8,P_UB
      INTEGER, INTENT(OUT) :: P_COMM_WORLD,P_SUCCESS
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INCLUDE 'mpif.h'
!
      P_INTEGER   =MPI_INTEGER
!     P_REAL8     =MPI_REAL8
!     CHRISTOPHE DENIS + JMH ON 04/12/2009 (FOR BLUE GENE)
      P_REAL8     =MPI_DOUBLE_PRECISION
      P_UB        =MPI_UB
      P_COMM_WORLD=MPI_COMM_WORLD
      P_SUCCESS   =MPI_SUCCESS
!
!-----------------------------------------------------------------------
!
      RETURN
      END
