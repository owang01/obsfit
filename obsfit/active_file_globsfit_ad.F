#include "OBSFIT_OPTIONS.h"

C--  File active_file_globsfit_ad.F:
C--   Contents
C--   o adactive_read_globsfit
C--   o adactive_write_globsfit

CBOP 0
C     !ROUTINE: ADACTIVE_READ_GLOBSFIT
C     !INTERFACE:
      SUBROUTINE ADACTIVE_READ_GLOBSFIT(
     I                              active_num_file,
     I                              adactive_var,
     I                              active_varnum,
     I                              irec,
     I                              lAdInit,
     I                              myIter,
     I                              myThid )

C     !DESCRIPTION:
C     ==================================================================
C     | SUBROUTINE ADACTIVE_READ_GLOBSFIT
C     | Adjoint of ACTIVE_READ_GLOBSFIT.F
C     ==================================================================

C !USES:
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "SIZE.h"
#ifdef ALLOW_OBSFIT
# include "OBSFIT_SIZE.h"
# include "obsfit.h"
#endif

C !INPUT PARAMETERS:
C     active_num_file: file number
C     adactive_var:    array
C     irec:            record number
C     myIter:          number of optimization iteration (default: 0)
C     myThid:          thread number for this instance
C     lAdInit:         initialisation of corresponding adjoint
C                      variable and write to active file
      integer active_num_file
      _RL     adactive_var
      integer irec, active_varnum
      integer myIter
      integer myThid
      logical lAdInit
CEOP

#ifdef ALLOW_OBSFIT

      call active_read_globsfit_rl( fidadglobal(active_num_file),
     &     active_num_file,
     &     adactive_var, active_varnum, lAdInit,
     &     irec, obs_ind_glob(active_num_file,irec),
     &     REVERSE_SIMULATION, myIter, myThid)

#endif

      END

C     ==================================================================

CBOP 0
C     !ROUTINE: ADACTIVE_WRITE_GLOBSFIT
C     !INTERFACE:
      SUBROUTINE ADACTIVE_WRITE_GLOBSFIT(
     I                                  active_num_file,
     I                                  adactive_var,
     I                                  active_varnum,
     I                                  irec,
     I                                  myIter,
     I                                  myThid,
     I                                  dummy )

C     !DESCRIPTION:
C     ==================================================================
C     | SUBROUTINE ADACTIVE_WRITE_GLOBSFIT
C     | Adjoint of ACTIVE_WRITE_GLOBSFIT.F
C     ==================================================================

C !USES:
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "SIZE.h"
#ifdef ALLOW_OBSFIT
# include "OBSFIT_SIZE.h"
# include "obsfit.h"
#endif

C !INPUT PARAMETERS:
C     active_num_file: file number
C     adactive_var:    array
C     irec:            record number
C     myIter:          number of optimization iteration (default: 0)
C     myThid:          thread number for this instance
C     lAdInit:         initialisation of corresponding adjoint
C                      variable and write to active file
      integer active_num_file
      _RL     adactive_var
      integer irec, active_varnum
      integer myIter
      integer myThid
      _RL     dummy
CEOP

#ifdef ALLOW_OBSFIT

      call active_write_globsfit_rl( fidadglobal(active_num_file),
     &     active_num_file,
     &     adactive_var, active_varnum,
     &     irec, obs_ind_glob(active_num_file,irec),
     &     REVERSE_SIMULATION, myIter,myThid)

#endif

      END

C     ==================================================================
