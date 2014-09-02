      SUBROUTINE KSCORR(IPAIR,UI,UIDOT,FP,FD,TD2,TDOT4,TDOT5,TDOT6)
*
*
*       Corrector for KS motion.
*       -----------------------
*
      INCLUDE 'common2.h'
      COMMON/SLOW/  RANGE,ISLOW(10)
      REAL*8  UI(4),UIDOT(4),FP(6),FD(6),FREG(4),FRD(4),A1(3,4),A(8),
     &        U2(4),U3(4),U4(4),U5(4)
*
*
*       Convert from physical to regularized derivative using T' = R.
      RI = R(IPAIR)
      DO 1 K = 1,3
          FD(K) = RI*FD(K)
    1 CONTINUE
*
*       Include KS slow-down factor in the perturbation if ZMOD > 1.
      IF (KZ(26).GT.0) THEN
          IMOD = KSLOW(IPAIR)
          IF (IMOD.GT.1) THEN
              ZMOD = FLOAT(ISLOW(IMOD))
              DO 5 K = 1,3
                  FP(K) = ZMOD*FP(K)
                  FD(K) = ZMOD*FD(K)
    5         CONTINUE
          END IF
      END IF
*
*       Predict H to order HDOT3.
      DTU = DTAU(IPAIR)
      HPRED = ((ONE6*HDOT3(IPAIR)*DTU + 0.5*HDOT2(IPAIR))*DTU +
     &                                  HDOT(IPAIR))*DTU + H(IPAIR)
      DT12 = 12.0/DTU**2
*
*       Perform iteration without re-evaluating perturbations.
      DO 30 ITER = 1,4
*
*       Form new transformation matrix.
          CALL MATRIX(UI,A1)
*
*       Form twice regularized force and half first derivative of H.
          HD = 0.0D0
          TD2 = 0.0D0
          DO 10 K = 1,4
              A(K) = A1(1,K)*FP(1) + A1(2,K)*FP(2) + A1(3,K)*FP(3)
              A(K+4) = A1(1,K)*FD(1) + A1(2,K)*FD(2) + A1(3,K)*FD(3)
              FREG(K) = HPRED*UI(K) + RI*A(K)
              HD = HD + UIDOT(K)*A(K)
              TD2 = TD2 + UI(K)*UIDOT(K)
   10     CONTINUE
*
*       Set regularized velocity matrix (Levi-Civita matrix not required).
          CALL MATRIX(UIDOT,A1)
*
*       Include the whole (L*F)' term in explicit derivatives of FU & H.
          HD2 = 0.0D0
          DO 20 K = 1,4
              AK4 = A(K+4) +A1(1,K)*FP(1) +A1(2,K)*FP(2) +A1(3,K)*FP(3)
              HD2 = HD2 + FREG(K)*A(K) + 2.0D0*UIDOT(K)*AK4
              FRD(K) = HD*UI(K) + 0.5*(HPRED*UIDOT(K) +RI*AK4) +TD2*A(K)
*       Set half the regularized force.
              FREG(K) = 0.25D0*FREG(K)
   20     CONTINUE
*
*       Save corrected U and UDOT in local variables.
          DO 25 K = 1,4
              UIDOT(K) = UDOT(K,IPAIR) +
     &                   ((FREG(K) + FU(K,IPAIR)) +
     &                   0.5*(FUDOT(K,IPAIR) - ONE6*FRD(K))*DTU)*DTU
              UI(K) = U0(K,IPAIR) +
     &                (0.5*(UIDOT(K) + UDOT(K,IPAIR)) +
     &                ONE6*(FU(K,IPAIR) - FREG(K))*DTU)*DTU
   25     CONTINUE
*
*       Improve the energy.
          HD = 2.0D0*HD
          HD3 = (HD2 - HDOT2(IPAIR))/DTU
          HD4 = (0.5*(HD2 + HDOT2(IPAIR)) + (HDOT(IPAIR) -HD)/DTU)*DT12
          HPRED = H(IPAIR) + (0.5*(HD + HDOT(IPAIR)) +
     &                       ONE12*(HDOT2(IPAIR) - HD2)*DTU)*DTU
   30 CONTINUE
*
*       Form U4 & U5 and copy corrected values to common.
      DO 35 K = 1,4
          U4(K) = (FRD(K) - 6.0*FUDOT(K,IPAIR))/DTU
          U5(K) = (0.5*(FRD(K) + 6.0*FUDOT(K,IPAIR)) -
     &            2.0*(FREG(K) - FU(K,IPAIR))/DTU)*DT12
          U(K,IPAIR) = UI(K)
          U0(K,IPAIR) = UI(K)
          UDOT(K,IPAIR) = UIDOT(K)
          FU(K,IPAIR) = FREG(K)
          FUDOT(K,IPAIR) = ONE6*FRD(K)
          FUDOT2(K,IPAIR) = U4(K) + 0.5*U5(K)*DTU
          FUDOT3(K,IPAIR) = U5(K)
   35 CONTINUE
*
*       Save new energy and four derivatives.
      H(IPAIR) = HPRED
      HDOT(IPAIR) = HD
      HDOT2(IPAIR) = HD2
      HDOT3(IPAIR) = HD3
      HDOT4(IPAIR) = HD4
*
*       Form scalar terms for time derivatives (1/2 of TDOT4 & 1/4 of TDOT5).
      TD3 = 0.0D0
      TDOT4 = 0.0D0
      TDOT5 = 0.0D0
      TDOT6 = 0.0D0
      DO 40 K = 1,4
          TD3 = TD3 + UIDOT(K)**2 + 2.0D0*UI(K)*FREG(K)
          TDOT4 = TDOT4 + UI(K)*FRD(K) + 6.0D0*UIDOT(K)*FREG(K)
          TDOT5 = TDOT5 + 0.5D0*FUDOT2(K,IPAIR)*UI(K) +
     &                          2.0D0*FRD(K)*UIDOT(K) + 6.0D0*FREG(K)**2
          TDOT6 = TDOT6 + 2.0*U5(K)*UI(K) + 10.0*U4(K)*UIDOT(K) +
     &                                      10.0*FRD(K)*FREG(K)    
   40 CONTINUE
*
*       Save R and second & third time derivatives.
      R(IPAIR) = UI(1)**2 + UI(2)**2 + UI(3)**2 + UI(4)**2
      TDOT2(IPAIR) = 2.0D0*TD2
      TDOT3(IPAIR) = 2.0D0*TD3
*
      RETURN
*
      END
