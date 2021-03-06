#include "OBSFIT_OPTIONS.h"

C--  File active_file_control_obsfit_rl.F:
C--   Contents
C--   o active_read_obsfit_rl
C--   o active_write_obsfit_rl

CBOP 0
C     !ROUTINE: ACTIVE_READ_OBSFIT_RL
C     !INTERFACE:
      SUBROUTINE ACTIVE_READ_OBSFIT_RL(
     I                                  fid,
     I                                  active_num_file,
     O                                  active_var,
     I                                  active_varnum,
     I                                  lAdInit,
     I                                  irec,
     I                                  irecglob,
     I                                  theSimulationMode,
     I                                  myOptimIter,
     I                                  bi,
     I                                  bj,
     I                                  myThid )

C     !DESCRIPTION: 
C     ==================================================================
C     | SUBROUTINE ACTIVE_READ_OBSFIT_RL
C     | Read an active record from an obsfit .equi. tiled file
C     | (can be netcdf or binary)  
C     ==================================================================

C !USES:
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#ifdef ALLOW_OBSFIT
# include "netcdf.inc"
# include "OBSFIT_SIZE.h"
# include "obsfit.h"
#endif

C !INPUT PARAMETERS:
      integer  fid
      integer  active_num_file, active_varnum
      integer  irec, irecglob
      integer  theSimulationMode
      integer  myOptimIter
      integer  bi, bj, myThid
      _RL      active_var
      logical  lAdInit

CEOP

#ifdef ALLOW_OBSFIT
C !LOCAL VARIABLES:
      integer  err, varid1
      integer  vec_start, vec_count
      integer  ivar, i
      _RL      active_data_t
      real*8   vec_tmp(2)

c     >>>>>>>>>>>>>>>>>>>             <<<<<<<<<<<<<<<<<<<
c     >>>>>>>>>>>>>>>>>>> FORWARD RUN <<<<<<<<<<<<<<<<<<<
c     >>>>>>>>>>>>>>>>>>>             <<<<<<<<<<<<<<<<<<<

      if (theSimulationMode .eq. FORWARD_SIMULATION) then

        _BEGIN_MASTER( myThid )

      if (obsfitDoNcOutput) then
      
      vec_start=irec
      vec_count=1

      err = NF_INQ_VARID(fid, obsfit_names(active_num_file,
     &  active_varnum), varid1 )
      err = NF_GET_VARA_DOUBLE(fid, varid1, vec_start, vec_count,
     & active_var)

      err = NF_INQ_VARID(fid, obsfit_namesmask(active_num_file,
     & active_varnum), varid1)
      err = NF_GET_VARA_DOUBLE(fid, varid1, vec_start, vec_count,
     & sample_modmask(bi,bj))

      else

      read(fid,rec=( (irec-1)*obs_num_var_tot(active_num_file)
     & +obs_num_var_cur(active_num_file,active_varnum)-1)*2+1 )
     & vec_tmp
#ifdef _BYTESWAPIO
            call MDS_BYTESWAPR8(2,vec_tmp)
#endif
      active_var=vec_tmp(1)
      read(fid,rec=( (irec-1)*obs_num_var_tot(active_num_file)
     & +obs_num_var_cur(active_num_file,active_varnum)-1)*2+2 )
     & vec_tmp
#ifdef _BYTESWAPIO
            call MDS_BYTESWAPR8(2,vec_tmp)
#endif
      sample_modmask(bi,bj)=vec_tmp(1)

      endif

        _END_MASTER( myThid )

      endif

c     >>>>>>>>>>>>>>>>>>>             <<<<<<<<<<<<<<<<<<<
c     >>>>>>>>>>>>>>>>>>> ADJOINT RUN <<<<<<<<<<<<<<<<<<<
c     >>>>>>>>>>>>>>>>>>>             <<<<<<<<<<<<<<<<<<<

      if (theSimulationMode .eq. REVERSE_SIMULATION) then

        _BEGIN_MASTER( myThid )

      if (obsfitDoNcOutput) then

      vec_start=irec
      vec_count=1

      err = NF_INQ_VARID(fid, obsfit_names(active_num_file, 
     & active_varnum), varid1 )
      err = NF_GET_VARA_DOUBLE(fid, varid1, vec_start, vec_count,
     & active_data_t)

c     Add active_var from appropriate location to data.
      active_data_t = active_data_t + active_var
c     Store the result on disk.
      vec_start=irec
      vec_count=1

      err = NF_INQ_VARID(fid, obsfit_names(active_num_file,
     & active_varnum), varid1 )
      err = NF_PUT_VARA_DOUBLE(fid, varid1, vec_start, vec_count,
     & active_data_t)

c     Set active_var to zero.
      active_var = 0. _d 0

      else

      read(fid,rec=( (irec-1)*obs_num_var_tot(active_num_file)
     & +obs_num_var_cur(active_num_file,active_varnum)-1)*2+1 )
     & vec_tmp
#ifdef _BYTESWAPIO
            call MDS_BYTESWAPR8(2,vec_tmp)
#endif
      active_data_t=vec_tmp(1)

c     Add active_var from appropriate location to data.
      active_data_t = active_data_t + active_var

c     Store the result on disk.
      vec_tmp(1)=active_data_t
#ifdef _BYTESWAPIO
            call MDS_BYTESWAPR8(2,vec_tmp)
#endif
      write(fid,rec=( (irec-1)*obs_num_var_tot(active_num_file)
     & +obs_num_var_cur(active_num_file,active_varnum)-1)*2+1 )
     & vec_tmp

c     Set active_var to zero.
      active_var = 0. _d 0

      endif

        _END_MASTER( myThid )

      endif

c     >>>>>>>>>>>>>>>>>>>             <<<<<<<<<<<<<<<<<<<
c     >>>>>>>>>>>>>>>>>>> TANGENT RUN <<<<<<<<<<<<<<<<<<<
c     >>>>>>>>>>>>>>>>>>>             <<<<<<<<<<<<<<<<<<<

      if (theSimulationMode .eq. TANGENT_SIMULATION) then

        _BEGIN_MASTER( myThid )

      if (obsfitDoNcOutput) then

      vec_start=irec
      vec_count=1

      err = NF_INQ_VARID(fid,obsfit_names(active_num_file,
     & active_varnum), varid1 )
      err = NF_GET_VARA_DOUBLE(fid, varid1, vec_start, vec_count,
     & active_var)

      else

      read(fid,rec=( (irec-1)*obs_num_var_tot(active_num_file)
     & +obs_num_var_cur(active_num_file,active_varnum)-1)*2+1 )
     & vec_tmp
#ifdef _BYTESWAPIO
            call MDS_BYTESWAPR8(2,vec_tmp)
#endif
      active_var=vec_tmp(1)

      endif

        _END_MASTER( myThid )

      endif

#endif /* ALLOW_OBSFIT */

      RETURN
      END

C     =================================================================

CBOP 0
C     !ROUTINE: ACTIVE_WRITE_OBSFIT_RL
C     !INTERFACE:
      SUBROUTINE ACTIVE_WRITE_OBSFIT_RL(
     I                                 fid,
     I                                 active_num_file,
     I                                 active_var,
     I                                 active_varnum,
     I                                 irec,
     I                                 irecglob,
     I                                 theSimulationMode,
     I                                 myOptimIter,
     I                                 bi,
     I                                 bj,
     I                                 myThid )

C     !DESCRIPTION: 
C     ==========================================================
C     | SUBROUTINE ACTIVE_WRITE_OBSFIT_RL
C     | Write an active record to an obsfit .equi. tiled file
C     | (can be netcdf or binary)  
C     ==========================================================

C !USES:
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#ifdef ALLOW_OBSFIT
# include "netcdf.inc"
# include "OBSFIT_SIZE.h"
# include "obsfit.h"
#endif

C !INPUT PARAMETERS:
      integer  fid
      integer  active_num_file, active_varnum
      integer  irec, irecglob
      integer  theSimulationMode
      integer  myOptimIter
      integer  bi, bj, myThid
      _RL      active_var
CEOP

#ifdef ALLOW_OBSFIT
C !LOCAL VARIABLES:
      integer  err, varid1
      integer  vec_start, vec_count
      integer  ivar, i
      _RL      active_data_t
      real*8   vec_tmp(2)

c     >>>>>>>>>>>>>>>>>>>             <<<<<<<<<<<<<<<<<<<
c     >>>>>>>>>>>>>>>>>>> FORWARD RUN <<<<<<<<<<<<<<<<<<<
c     >>>>>>>>>>>>>>>>>>>             <<<<<<<<<<<<<<<<<<<

      if (theSimulationMode .eq. FORWARD_SIMULATION) then

        _BEGIN_MASTER( myThid )

      if (obsfitDoNcOutput) then

      vec_start=irec
      vec_count=1

      err = NF_INQ_VARID(fid,obsfit_names(active_num_file,
     & active_varnum),varid1 )
      err = NF_PUT_VARA_DOUBLE(fid, varid1, vec_start, vec_count,
     & active_var)

      err = NF_INQ_VARID(fid,obsfit_namesmask(active_num_file,
     & active_varnum), varid1 )
      err = NF_PUT_VARA_DOUBLE(fid, varid1, vec_start, vec_count,
     & sample_modmask(bi,bj))

      err = NF_INQ_VARID(fid,'sample_ind_glob', varid1 )
      err = NF_PUT_VAR1_INT(fid, varid1, vec_start,
     & irecglob)

      else

      vec_tmp(1)=active_var
      vec_tmp(2)=irecglob
#ifdef _BYTESWAPIO
            call MDS_BYTESWAPR8(2,vec_tmp)
#endif
      write(fid,rec=( (irec-1)*obs_num_var_tot(active_num_file)
     & +obs_num_var_cur(active_num_file,active_varnum)-1)*2+1 )
     & vec_tmp
      vec_tmp(1)=sample_modmask(bi,bj)
      vec_tmp(2)=irecglob
#ifdef _BYTESWAPIO
            call MDS_BYTESWAPR8(2,vec_tmp)
#endif
      write(fid,rec=( (irec-1)*obs_num_var_tot(active_num_file)
     & +obs_num_var_cur(active_num_file,active_varnum)-1)*2+2 )
     & vec_tmp

      endif

        _END_MASTER( myThid )

      endif

c     >>>>>>>>>>>>>>>>>>>             <<<<<<<<<<<<<<<<<<<
c     >>>>>>>>>>>>>>>>>>> ADJOINT RUN <<<<<<<<<<<<<<<<<<<
c     >>>>>>>>>>>>>>>>>>>             <<<<<<<<<<<<<<<<<<<

      if (theSimulationMode .eq. REVERSE_SIMULATION) then

        _BEGIN_MASTER( myThid )

      if (obsfitDoNcOutput) then

      vec_start=irec
      vec_count=1
      err = NF_INQ_VARID(fid,obsfit_names(active_num_file,
     & active_varnum),varid1 )
      err = NF_GET_VARA_DOUBLE(fid, varid1, vec_start, vec_count,
     & active_data_t)

c     Add active_var to data.
      active_var = active_var + active_data_t
      active_data_t = 0. _d 0

      vec_start=irec
      vec_count=1

      err = NF_INQ_VARID(fid,obsfit_names(active_num_file,
     & active_varnum),varid1 )
      err = NF_PUT_VARA_DOUBLE(fid, varid1, vec_start, vec_count,
     & active_data_t)

      else

      read(fid,rec=( (irec-1)*obs_num_var_tot(active_num_file)
     & +obs_num_var_cur(active_num_file,active_varnum)-1)*2+1 )
     & vec_tmp
#ifdef _BYTESWAPIO
            call MDS_BYTESWAPR8(2,vec_tmp)
#endif
      active_data_t=vec_tmp(1)

c     Add active_var from appropriate location to data.
      active_var = active_var + active_data_t
      active_data_t = 0. _d 0

c     Store the result on disk.
      vec_tmp(1)=active_data_t
#ifdef _BYTESWAPIO
            call MDS_BYTESWAPR8(2,vec_tmp)
#endif
      write(fid,rec=( (irec-1)*obs_num_var_tot(active_num_file)
     & +obs_num_var_cur(active_num_file,active_varnum)-1)*2+1 )
     & vec_tmp

      endif

        _END_MASTER( myThid )

      endif

c     >>>>>>>>>>>>>>>>>>>             <<<<<<<<<<<<<<<<<<<
c     >>>>>>>>>>>>>>>>>>> TANGENT RUN <<<<<<<<<<<<<<<<<<<
c     >>>>>>>>>>>>>>>>>>>             <<<<<<<<<<<<<<<<<<<

      if (theSimulationMode .eq. TANGENT_SIMULATION) then

        _BEGIN_MASTER( myThid )

      if (obsfitDoNcOutput) then

      vec_start=irec
      vec_count=1

      err = NF_INQ_VARID(fid, obsfit_names(active_num_file,
     & active_varnum),varid1 )
      err = NF_PUT_VARA_DOUBLE(fid, varid1, vec_start, vec_count,
     & active_var)

      else

      vec_tmp(1)=active_var
      vec_tmp(2)=irecglob
#ifdef _BYTESWAPIO
            call MDS_BYTESWAPR8(2,vec_tmp)
#endif
      write(fid,rec=( (irec-1)*obs_num_var_tot(active_num_file)
     & +obs_num_var_cur(active_num_file,active_varnum)-1)*2+1 )
     & vec_tmp

      endif

        _END_MASTER( myThid )

      endif

#endif /* ALLOW_OBSFIT */

      RETURN
      END

C     ==================================================================
