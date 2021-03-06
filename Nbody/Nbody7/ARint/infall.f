      SUBROUTINE INFALL(IBH,IESC,NBH2,ISUB)
*
*
*       Removal of colliding body.
*       --------------------------
*
      INCLUDE 'common6.h'
      PARAMETER  (NMX=10,NMX3=3*NMX,NMX4=4*NMX,NMXm=NMX*(NMX-1)/2)
      REAL*8  M,MASS,MC,MMIJ,XCM(3),VCM(3),CG(6)
      COMMON/ARCHAIN/XCH(NMX3),VCH(NMX3),WTTL,M(NMX),
     &           XCDUM(NMX3),WCDUM(NMX3),MC(NMX),
     &           XI(NMX3),VI(NMX3),MASS,RINV(NMXm),RSUM,INAME(NMX),NN
      COMMON/ARCHAIN2/ MMIJ,CMX(3),CMV(3),ENERGY,EnerGR,CHTIME
      common/TIMECOMMON/Taika,timecomparison
      COMMON/CHAINC/  XC(3,NCMAX),UC(3,NCMAX),BODYC(NCMAX),ICH,
     &                LISTC(LMAX)
      COMMON/CHREG/  TIMEC,TMAX,RMAXC,CM(10),NAMEC(NMX),NSTEP1,KZ27,KZ30
      COMMON/CLUMP/   BODYS(NCMAX,5),T0S(5),TS(5),STEPS(5),RMAXS(5),
     &                NAMES(NCMAX,5),ISYS(5)
      COMMON/CCOLL2/  QK(NMX4),PK(NMX4),RIK(NMX,NMX),SIZE(NMX),VSTAR1,
     &                ECOLL1,RCOLL,QPERI,ISTAR(NMX),ICOLL,ISYNC,NDISS1
      COMMON/ECHAIN/  ECH
      COMMON/INCOND/  X4(3,NMX),XDOT4(3,NMX)
*
*
*       Increase collision counter and set current time from chain.
      NCOLL = NCOLL + 1
      TIME0 = TIME
      TIME = T0S(ISUB) + Taika + CHTIME
*
*       Copy chain variables to standard form.
      LK = 0
      DO 10 L = 1,NCH
          DO 5 K = 1,3
              LK = LK + 1
              X4(K,L) = XCH(LK)
              XDOT4(K,L) = VCH(LK)
    5     CONTINUE
   10 CONTINUE
*
*       Switch if NAMEC(IESC) = NAME0 to obtain ICM in CHTERM2 (NN > 2 only).
      IF (NN.GT.2.AND.NAMEC(IESC).EQ.NAME0) THEN
          KK = IBH
          IBH = IESC
          IESC = KK
      END IF
      KST = MAX(ISTAR(IBH),ISTAR(IESC))
*
*       Define new local c.m. for two-body system.
      LX = IBH
      LK = 3*(IESC - 1)
      LN = 3*(LX - 1)
      DO 20 K = 1,3
          LK = LK + 1
          LN = LN + 1
          XCM(K) = (M(IESC)*XCH(LK) +
     &              M(LX)*XCH(LN))/(M(IESC) + M(LX))
          VCM(K) = (M(IESC)*VCH(LK) +
     &              M(LX)*VCH(LN))/(M(IESC) + M(LX))
   20 CONTINUE
*
*       Copy new chain data from remaining members (over-write IESC).
      LK = 3*(IESC - 1)
      DO 40 L = IESC,NCH-1
          DO 35 K = 1,3
              LK = LK + 1
              XCH(LK) = X4(K,L+1)
              VCH(LK) = XDOT4(K,L+1)
   35     CONTINUE
   40 CONTINUE
*
*       Augment the heavy mass and reduce membership.
      M(LX) = M(LX) + M(IESC)
      BODYC(LX) = BODYC(LX) + M(IESC)
      ISTAR(LX) = KST
      NCH = NCH - 1
      NN = NCH
      NCOLL = NCOLL + 1
      WRITE (6,45)  NAMEC(LX), BODYC(LX)*SMU, KST
   45 FORMAT (' NEW STAR/BH    NAM M K* ',I5,F7.2,I4)
*
*       Check possible reduction of dominant body index.
      IF (LX.GT.IESC) LX = LX - 1
*
*       Place X & V of new c.m. body in location for IBH.
      LK = 3*(LX - 1)
      DO 50 K = 1,3
          LK = LK + 1
          XCH(LK) = XCM(K)
          VCH(LK) = VCM(K)
   50 CONTINUE
*
*       Identify global index of coalescence body.
      DO 55 J = IFIRST,NTOT
          IF (NAME(J).EQ.NAMEC(IESC)) THEN
              I = J
          END IF
   55 CONTINUE
*
*       Define collider as ghost.
      CALL GHOST(I)
*
*       Remove chain (and clump) mass & reference name of absorbed member.
      DO 65 L = IESC,NCH
          M(L) = M(L+1)
          BODYC(L) = BODYC(L+1)
          NAMEC(L) = NAMEC(L+1)
          SIZE(L) = SIZE(L+1)
          ISTAR(L) = ISTAR(L+1)
          BODYS(L,ISUB) = BODYS(L+1,ISUB)
          NAMES(L,ISUB) = NAMES(L+1,ISUB)
   65 CONTINUE
*
*       Copy new chain coordinates & velocities to standard variables.
      LK = 0
      DO 80 L = 1,NCH
          DO 75 K = 1,3
              LK = LK + 1
              X4(K,L) = XCH(LK)
              XDOT4(K,L) = VCH(LK)
   75     CONTINUE
   80 CONTINUE
*
*       Prepare c.m. check (should be perfect).
      DO 85 K = 1,6
          CG(K) = 0.0
   85 CONTINUE
*
      LK = 0
      DO 95 L = 1,NCH
          DO 90 K = 1,3
              LK = LK + 1
              CG(K) = CG(K) + BODYC(L)*XCH(LK)
              CG(K+3) = CG(K+3) + BODYC(L)*VCH(LK)
   90     CONTINUE
   95 CONTINUE
*
      DO 96 K = 1,6
          CG(K) = CG(K)/BODY(ICH)
   96 CONTINUE
*
      IF (KZ(30).GT.2) THEN
          WRITE (6,98)  TIME+TOFF, (CG(K),K=1,6)
   98     FORMAT (' INFALL CHECK:   T CG ',F10.5,1P,6E9.1)
          CALL FLUSH(3)
      END IF
*
*       Check optional velocity kick (only VX component for simplicity).
      IF (KZ(43).EQ.0.AND.NBH2.EQ.0) GO TO 120
*
      VKICK = 3.0*VRMS/VSTAR
      VI2 = XDOT(1,ICH)**2
      XDOT(1,ICH) = XDOT(1,ICH) + VKICK
      X0DOT(1,ICH) = XDOT(1,ICH)
*       Correct for energy gain & ECH and re-initialize chain c.m.
      ECDOT = ECDOT - 0.5*BODY(ICH)*(XDOT(1,ICH)**2 - VI2)
      TIME = TBLOCK
      CALL FPOLY1(ICH,ICH,0)
      CALL FPOLY2(ICH,ICH,0)
      WRITE (6,100)  LIST(1,ICH), IESC, ISUB, VKICK*VSTAR, STEP(ICH)
  100 FORMAT (' SINGLE BH    NNB IESC ISUB VK SI ',
     &                       I5,2I4,F6.1,1P,E10.2)
*       Ensure current coordinates & velocities for chain components.
      CALL XCPRED(1)
      TIME = TIME0
*       Initialize the memberships (ECH already added to ECOLL in DECORR).
      NCH = 0
      NSUB = MAX(NSUB - 1,0)
*
  120 RETURN
*
      END
