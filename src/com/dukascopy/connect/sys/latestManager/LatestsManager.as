package com.dukascopy.connect.sys.latestManager {
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.sqlite.SQLRespond;
	import com.dukascopy.connect.sys.sqlite.SQLite;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.vo.ChatVO;
	import com.telefision.sys.signals.Signal;
	/**
	 * @author IgorBloom
	 */
	public class LatestsManager {
		
		static private var needLoadFromSql:Boolean = true;
		static private var needLoadFromServer:Boolean = true;
		static private var inited:Boolean = false;
		static private var S_LIST_CHANGED:Signal = new Signal("LatestsManager.S_LIST_CHANGED");
		
		static private var latest:Array/*ChatVO*/= [];
		static private var serverHash:String = "";
		static private var busy:Boolean = false;
		
		//static private var _dukascopySecurityKey:String=".ap.iO.Oe.eT.tP.vHIqv.mI.xd.5WIJP.7J.in.ZI.YR.Mv.84.k7.lT.Ii.iT.B1.pU.G7.G0.HG.GLIgz.jlIz0.oiINP.lj.B2.C1.9m.3i.8V.sC.xhIp7.hSIC9IqoI8r.lu.Lo.9Y.kd.2nINQIAU.Ul.uFICI.U4.Um..yIWcI9lIDC.sD.V5IguIg5.2qIQsIpg.0M.moIQj.tX.Fp.32IpH.XP.sgIAP.a5.W4.86.Xm.WTIgc.Zh.W1IXq.wD.Q9.Bx.Tx.yB.xm.TH.Vp.3wI8D.by.FN.JC.Qy.kt.y6.SK.rh.aa.04.rW.Wp.m6.lM.98.bL.a4.hT.Ds.P5I98ICk.dY.Y1.Km.YO.b7.3G.C4.pg.78ID5.Lj.ae.hO.bG.wM.ja.eiINU.Pl.81IqWI8uIq1IIJIAW.iNIAq.Ue.ClIgW.lh.au.uqIUp.VC.wsIQz.ge.27.az.gB.xX.Ti.Gm.ZvIg6.wv.9E.v2.eRIFN.2Y.7x.LgIWS.DH.7U.aR.VT.Wd.Tz.w0.gxIUU.p5.JjIgx.R4IU2.Vu.ld.1K.jM.VjIDm.LiIFzIIz.XB.hE.6eIJrIUM.4f.dAIqdIAgIQ1.Cd.k6.FQ.wSIF7.PMIAK.9h.Ug.KB.ME.Y8IHxIgB.7p.mXIHd.dWIq7.Td.bf.HbIFT.Xh.RM.FeINq.15.tl.BZ.ED.1L.YcIFi.5i.Rs.fs.2e.31ICi.E6..m.aD.U1.BH.gi.Uu.rU.5AIq9.UbIAHIgGIA1.uB.aO.wrI8R.jv.ln.0z.y1.DAIDa.ioIqt.8M.x4.bQ.xv.tE.8KIz5.Ie.uI.At.0k.YW.P1.Oj.L3ICc.WG.1D.7A.gW.kb.rM.FzIFh.CIIzB.fG.Wf.hk.pS.GS.Dl.C6.H1.Bv.lr.sl.fn.Wu.ZD.g2.zm.GU.Ck.0s.sH.XS.28.uxI9b.5g.aU.0xIC5IHR.6i.bnIAwIIP.HJ.68I99IUJ.08.wq.Gs.eg.7E.bcI9jIWT..4.BO.sXIq3.xG.DS.rC.yc.LGIN9ICZ.o2.EiIFl.eF.zB.w2.C2.bE.wh.QtI9qICjIJw.6C.EE.H7.Ym.0gINt.Ag.iWIQw.JV.05.eM.Cg.3M.50.7nIJt.0FIFc.X7IJx.uL.Ls.EK.Uz.cFII5.r8.DV.RF.ii.6j.Xo.NI.LzIUP.jX.eIIWx.CM.Kb.LuIpMIJa.HY.Fq.WK.dI.xJ.xj.tM.kD.CO.US.7d.me.NHIQg.Fg.tQIqq.pM.HS.76.PX.LK..I.zO.o7.zv.loIgwIDL.vxIQ2.XR.Ai.am.sp.25.x2.JH.iu.th.pu.ZGIg9.HN.0yI9sIFb.afIJ8.Ea.iQ.Bz.UB.hM.zK.yf.V9.Ki.Wk.XG.b4IWsIUR.hv.HlIF3.o5Iz7IQt.WX..h.1f.x1.cp.9r.nz.tFIJI.c7IALINm.nSIqU.U9.bD.Zx.YK.e2.8k.Il.wb.eB.ig.ke.jt.bZIJ0I9WIJF.1U.1XIA8.oe.RlI8o.6tIU8.Ct.CX.Ju.Ik.RO.4N.go.ot.X9.Co.ds.GgI9NIpXIQv.61.mr.xT.nk.flIUj.DF.Rv.8A.t5.vK.fe.Jr.T5INx.2m.ct.c3.9LIzlIFD.j2.9jIzR.dF.iY.3d.ms.fW.6v.QD.ZM.ou.lRI8mIphIgo.AK.fdIU3.FI.EH.hh.Af.gH.vR.vmIzN.l9IgA.Jq.p3.UQ.O1.9z.VS.FrIUY.rt.Jf.LdIF4.Wm.as.XVIQq.a6.4X.SqIUd.FXIAG.4bICfIN2.Lx.sQ.gCID6.7t.6R.ci.WN.RXIgC.d6Iqj.jR.ai.1S.1YIDt.cC.Oc.ff.1i.Sw.19.fJ.p1.RSI8g.K6.QaIJj.bF.1W.E4.rOIg4.0h.dG.tcI89.Pi.hRIIS.OZ.94.55.hjIWX.p2IHt.YB.Wt.6Q.L0.Sb.zX.ew.cKIgbIF0.eP.nC.BTI9E.kvIAQ.Cx.hm.4AIgq.lz.P2.A5IHNIzM.1E.MDIIy.eGI9U.2z..v.dD.sK.IY.bBINW.IH.cy.dn.5Q.wyIz8IFn.VZ.Id.02.s4.vVIUn.Ly.JZ.Eq.FKIHF.sv.v5I9I.i6..NIDS..iIQm.1AIq0.6Y.an.9o.8xI9A.kT.UW.tjIIfI8K.yD.c5.zLIJc.eY.np.Cm.mOIDn.8C.4q.oH.2o.jPICG.wm.2N.KIIUy.2w.Xf.uoIQe.C9IpN.2Z.HL.PAIgs.SR.ox.7S.Rd.FO.Ay.eh.eJINM.XI.cL.6x.2tIU6IAr.b1IQJIIB.H0.gg.aBIDs.So.Ro.xC.Rr.oOIAv.3F.07IzJ.my.IQIzd.79.ud.9K.gz.d1.92.xE.RT.Cs.d9.gZIpl.KC.at.3J.bN.wP.ICICO.18.PJ.mJ.Ed.S4.kyI88.aA.EB.xR.pxICs.LX.W9.hX.5VIHUICFIDx.4n.60IIW.YQIAz.I8.oc.UY.Jo.vS.bM.MK.WUI9p.yF.oR.mi.9a.l5IAS.3W.OD.1t.X2.kH.U5.rmIWG.xw.s5.vG.c6III.3u.fo.3qIIs.IR.LWIzC.r9.0R.2F.BL..8.lw.L4.6r.uj.Ke.E0ING.nT.9qIpc.yR.Qx.NB.u8.9f..WIWK.V3.0Y.SL.S8Iqe.s8.cDIQC.l7.kMIF9.aH.wl.oy.RK.wO.bzIIU.rT.Qz.gt.ye.na.a3.G6.NS.Sl.yE.Np.fy.rvIQi.Re.jEIDO.T0.kc.Pq.3t.xu.hb.Yg.Tr.Wi.kA.iG.9e.tw.PQIFSIQU.Sj.S3.tp.4w.7D.Cw.Uv.Mq.uS.Vi.xZ.ma.Ev..VICD.3v.1uIDj.ag.AZIDK..x..5.AV.J9.oB.9Z.Ou.EmINT.mG.1p.Sv.U0IWnIDN..Q.Ox.A4.ry.MsIqp.0u.SU.PL.Z7.W0.cB.jsIFM.guIATI9a.jSIQh.ed.AS.wk.88.Jk.aG.WSIFo.ks.Rg.4p.Ny.Qw.aP.2WIDJ.6M.Kf.Pv.Rk.MG.iM.ziIza.ur.rG.IbIqm.8F.VI.vD.8h.QM.8v.eV.Xc.aJ.8T.uVIC4.lF.ulIqa.iV.2f.e8.PC.mSIp4.lbIU5.rg.WoIIC.1CIJu.0i.fO.kj.CfIpp.J6IAD.80.9v.D1.NO.ik.IO.H9.hc.ISIFaIqk.gp.3V.WFIpA.9A.0o.m4.FZ.y5.ydIJK.tI..R.m0.bK.A9.L9.Pg.5E.IZ.Jp.DL.O3.4JI9dI9YIWA.us.yy.TD.RV.I0.ak.9PIIT.is.NZIHl.ac.II.8a.UP.gI.b8.3T.E9.TY.Uo.Cv.1F.O9.R2.sO.Gh.h8.4l.Uk.cd.wi.5TIpe.My.oU.eWIN8.DvIqH.bv.F1.Pe.8s.V4.Be.6F.mF.XE.ly.tKII7.xaI9K.6z.9u.hP.TK.UK.Lp.z2.F5.cx.tO.cN.ZF.Mn.po.fiIF8.FD.gr.F7.l8.aZ.j3.v3.9R.Y5.Lh.9SICu.UO.zQ.OT.Zf.xr.w5.yT.MN.XT.FP.LeIW3.21.iU.uu.nb.1N.ij.V6.jp.PU.7I.uw.7i.mY.j8.sm.5z.6X.hIIJsIFg.POIIMIC1.rP.N2.nNIJm.ZW.L7.ZK.49.lZ.Kj.jx.Hf.l3.6n.Gl.F8I8SIJf.hsIAh.N5.iL.h5.Vv.ng.S2.HWIHoIqCICL.2P.D2IWk.aY.rq.bP.NRIWM.75.wI.rF.xH.ku.xo.3n.3p.kU.nf.GpIJp.a0.7b.Tf.Kn.PB.QG.tA.UiIN1.sw.U7.J4.dh.w3IC2.Wc.G2.bHIpZ.FhI9oI8l.XLI8J.MZ.ZnIpi.GGIDpIzQ.R5.IJ.sq.VnIWF.EI.ty.9V.KG.ro.Dk.wAIpd.JX.Gq.mU.wUIHK.ca.SV.9I.gVIpL.OU.2yIC3.9bIIG.ZP.eu.IfIFr.9W.ep.lQ.Nm.Ih.uRIzkIFp.xgIqh.TkIFI.f5.GH.kJ.AP.wXI9T.Fw.pc.YC.B0.sr.wJIHW.QO.3EIAX.aFI9LIqTIqb.BA.m3.Ej..b.e6.0j.3N.XQ.Ca.nY.gT.Og.lgIHBIH6IQNIHZ.0p.xQ.VG.f2.H2.St.1o.DW.eoIDyIJW.UAIJk.5nIDo.tT.nD.IB.Ez.42.GP.k2IgV.oA.Mw.4M.VQINX.Ac.ps.3a.8b.5x.Z5.VD.gcINf.D4.vj.10.HO.vg.Bq.on.7oI8t.nG.fK.du.KK.MSIJ4.0v.lY.jn.uK.eaI8Y.r2.Dw.u0.cS.JJ.2cID3.TO.pj.ce.SNIIx.Sh.ZJ.vZ.hfIFWI87.N8.yP.tU.YF.Fy.zoIAbIgRIDl.tV.ya.TLIq5ICK.B8IJd.DZI9u.c8I8h.Pj.lO.lk.Y9I9PIgE.3l.ir.Nf.26.rfI8k.8G.Mk.rc.5e.u5.8S.PZ.VyI9X.RNIpv.QYIAOIIN.Ss.ch.lXIzp.fD.5G.0f.Uw.Z0.mz.O6.mPI9e.gM.IL.Ys.ZQ.8H.R9IJ9.mQ.dlIHG.2h..EIzZIFxIzYIqs.Qd..3.5Z.DT.YG.UH.TB.iF.WO.oq.kN.X8.uM.fN.FR.mbIz3.Ae.oT.cn.cU.JD.5MICaIJRICr.EQ.ITIggIJL.a8.ec.ckICn.vX.Kg.E2.lKIUa.YJIpj.P7.7a.rV.il.HKIp1.EOIId.Mj.4d.0cIgj.eD.aS.kQIFk.QE.Ni.MC.zh.Xl..J.fX.UUI84.SD.dO.5L.5j.QP.MB.mW.i1.46.Xv.6l.GI.gQIAo.fAID1.J5.LVI8W.Vs.ru.zl.y3.nt.Si.VA.mg.DXIFd..d.Gf.OM.DRIWO.IA.wCIFY.JeIFLIA5.dt.Y4IIjIFt.H5IgnIUH.OP.tr.5r.CH.Sf.pE.yQIFe.txIWJ.Pc.5f.dT.vl.mB.sL.wN.7cIzs.TnIqZ.Cu.TF.ST.we.Zl.1OIgrIzO.of.Kd.UR.0a.aI.O8.gl.jF.Ao.DyIUs.w6.h0.UJ.vo.iHI8I.i8.kS.8pINz.v6Iqy.Bs.Ip.BQ.HI.nq.wW.1ZIpW.1c.sk.Nq.pY.mH.OEINr.eA.d4.dC.e9.wp.Pk.aT.FF.mCIDu.KY.zu.Lw.BD.3Z..YIgM.Bj.lfIIK.MJ.Tg..B..1IHX.MV.3y.rs.pH.Iz.3c.Cq.70.Pw.SI.LD.QC.J0IQFIpb.WR.Ut.umIJb.Zp.kC.HAIHQ.fa.MO.9i.BI.t0.m7.Z8IHC.A7.8Z.g9.F6IDd.LL.yn.vi.Mm.UMII4.tZ.5N.Yz.PaII3.dx.tW.8BIUb.nI.czIpmIH0.ts.BCIHL.Pb.Aw.LH.cl.WEIWU.Ho.Ln.11.vk.jY.iz.FJ.Zk.1R.kY.AGI9RIWg.90..G.UD.kw.bT.I9.3HIHV.M0.c0.yo.lW.1P.ZO..gICJIQH.jU.iwIq8.3e.Up.CB.0S.93.xk.htIqi.bb.MW.z3.8Q.NW.AU.6s.cq.MxICU.OyIJn.Lb.sT.WDI8q.3Q.ND.7j.F9.N7.Yh.IF.7L.RI..D.Bu.aN.mj.KN.z6.AL.Ns.6a.1k.j6.kq.6f.W5IHp.zF.k8I82.UhID0.t1.OY.MR.xp.Jc.K9.bj.KJ.xN.Ar.nu.he.S0IUx.f3INv.5X.6G.d2.NJ.ML.fq.SQ.cQ.Yw.0A.LQ.2X..K.eeIFK.n0.py.I3.IyIWD.o4.N9IQn.Wy.dM.FW.okI9G.vc.Q7.JW.TJ.5l.NY.dy.DK.QQ.0O.wF.oM.59.cf.JQ.yVIDY.8c.Fv.GEIIQ.6W.jd.Cp.ri.8u.U6.g3IWQIJB.Q1.QiI91.Uj.Q3.kk.5R.fP.Es.sh.1G.BE.W8IC6.gnI90.TT.BKI8O.tG.eS.Pz.nF.LE.4OIqK.Vb.RA.ow.WH.Rp.zkIJ3.jLINy.uW.x9.Lm.EF.IUIgp.LYI8L.EkIIX.t8.UL.bx.xO.Ak.Ht.nQIgI.JNIFP.Wl.2p.GB.5H.wK.Qp.CE.3gIHwIIY.Fb.bdIIe.P9.eO.jW.RE.Ky.Gy.D9.lE.Ef.ESIqlIFH.nj.zt.LP.bU.UV.Z1.0CINN.0LIglI8BI9r.fT.bo.kG.cY.4F.SF.KXIzm.i4.BS.xi.UI.Hv.Mt.BY.lH.AN.Vm.Pr.x0.n6.HZ.ay.Gc.KL.Fd.Wv.Nr.Gj..e.JwINB.Xp.M8.VHIHhIDD.Kq.6H.Zo.MP.62.Rh.c9IpF.Hy.kL.pR.ui.SG.JvIN6.hV.rD.iq.hZ.TC.oh.Pn.6g.PW.iEINC.0GIpEIWj.Xt.KE.rJ.xl.yg.rwICq.XiIzu.Zg.JB.UG.Xd.Ta.3P.NtIAj.MA.zw.tNIzX.RL.MMIF1..M.xIIz1.kW.8g.Uy.yA.8nINwIgtIQZIAa.69IIa.AC.Y2.AA.QKIqV.jC.JS.Qv.ZmI9t.MQ.WW.ZwIzy.j9.jh.Dn.gLIND.pf.INIUu.P8.id.em.Sm.4Z.ip.QZ.aK.An.SY.KQ.Dh.d5IQb.pb.aw.PmIgO.9Q.jZ..9.SZ..cI9yIWu.dB.Ap.g5.BV.vyIqc.T2.Od.Xe.YL.sB.vLIz6IqN.4h.5qIq4.pI.Qr.2H.Bw.VkIg1IFR.re.av.kaIgyIIA.ey.b9IDf.FBIQTI8H.El.pP.zdIDA.RQIAm.jr.8D.8t.NU.gb.Zi.23.Cj.RzIJVII8.2O.FjIzr.LF.jm.Gr.g4.8N.AQ.u1.Ew.OL.QN.sPIWt.s2.zC..f.DQ.o6IpV.mE.R0IAf.j0.zqIQY.odICT.Dx.bl.v8.ZL.HC.aV.aE.Uc.OR.MrI8n.uC.Yy.Fm.kg.DqIWR.lV.9l.XZ.kiID4.fSIzz.Hh.2KIW7I9h.mf.rA.hy.2G.Kw.n7.3b.tY.NG.Eb.B9.pp.rx.NcINS.mL.YkIDrINF.6T.Au.EVIzF.iZII2.aC.67IDk.wf.Cc.CDIIR.3L.jD.3U.wV.GkIFj.gS.pO.pJ.Eg.GaINA..Z.2Q.Aa.pq.fZ.7hIW9.Kx.ssIzL.s3.nO.aW.V8.Av.S7IpU..o.nR.v0.YeIAk.iaI9O.k1.Xq.xA.NQIH8.Sn.3I.YM.4k.D7IWz.uE.4e.Vc.zP..L.1z.uDIH4.Os.8R.DUIDz.Us.0N.yNIFZ.0Q.96IJ1.53.z1.U3.Oi.pkIpw.Qu.djICXIU0.Y6.YD.Tj.Io.6o.1T.Su.L1.He.3z.SW.M4.j7.fx.u2.RU.z8IHM.gk.5B.6IIzo.c4IzD.nh.n3.E7.Hj.XMICw.5C.r7IDX.LC.UN.i7.mR.jT.0mIqz.cM.li.MfIQX.2s.OX.KR.yzIQ6.oa.Do.g8.GtIpT.5JI8j..j.7O.mA.cv.pv.Hd.X0Igd.GNIp8.t3I8z.5h.no.4GIFu.Eu.VtICb.t4Ip0IFs.TcIIhIC0.raIpC.YTIAlIgY.h3.X4IUQ.BG.NeIUBIzE.Sr.kE.Xj.Ir.dzIq6.tq.IX.fL.IK.7B.xY.fk.IjIAu.Aq.mZIH9.7Z.9H.dKIAV.zV.xK.ovICQ.mw.jQ.PTIFC.cr.2v.gR.89.6U.l2ICC.UF.o1IJi.n2..w.b3.48I8y.7g.nwIqf.rd.nmIFB.LS.8r.X5.OC.BdIW0.cT.Me.WJ.CYIWL.mc.3RIp3IJE.IPIqX.7y.HM.GY.LB.Ol.cmIWaIIDIFvIpY.wwIUr.xtI9S.Zd.G1.Mb.82.GXIQL.Sc.zD.XyIA9.hd.cj.Qm.GbIDb.kxI9C.Kl.We.Ch.IsIDcIAd.ZH.7C.XYI8f.gw.1s.vUIFEI8Q.Yt.u6.ek.Fx.rR.Xw.ZaI8GIUq.1V.ByIpt.2LIJy.hoIpJ.iD.M9ID7.nP.AFIgU.pB.sV.vQ.di.3A.Na.TG.6q.Zz.CT.Az.RB.As.n9.da.uc.Jz.gf.nZ.BP.Xg.lt.M5.G9.G5.Op.GZ.QS.6bIJY.jG.Iv.s0.DD.df.vn.mqIHg.st.Bh.yC.73.DP.8IIH1Ize.2d.OrIQa.Zj.GuICY.EC.DE.g0.Ic.cAIAx.7e.9MIIn.kBIN7.6m.WLINRIAyIWYIgS.44.hp.s6.zg.bp.HnIzt.JA.fU.GzIJG.Mo.d7Igi.GD.39.nKIpO.Q5IHEIDE.Ad.Wh.Dd.Wr.Nu.oWIqF.mmINp.Nx.rz.KZ.u9.1d.ut.jk.uy.i0.rEIQPIUK.bhI8N.s7.gO.s1IDH.m8.FA.5S.Hi.AR.2C.9t.f7.Q6.2I.wt.Ig.Kk.VJ.al.HpIDQ.DN.KH.B7.lqICS.vzIqg.rIIQ7.3XIXI.7X.vv.NVIqM.8q.Rb.fh.WB.2xIH5.1j.4IIzv.cG.01IUGIQ3.Xs.7mIFJ.Yb.sz.dg.lcIQ8Ipo.3j.jz.0H.rY.Rj.NN.nU.PIIIr.BR.Z4.Y3.LN.65IFU.Mp.fY.8L.8EICo.lU.PH.JR.fEIWm.9p.R7.do.2g.KzIW1.AD.Di.jA.z9INc.za.r4IUZ.8oIHHICd.TS.QI.j4.u4IJJ.CK.mp.On..U.WwIHeI8p.Q2.fv.z5IWp.oK.TyIDV.n8.OkIpQ.KU.VV.ze.Bf.YHIgh.zU.Bt.iA.bR.hr.3f.Kc.rB.pV.H4.Yd.Zc.tBIQrIUm.Tl.8mI9k.VL.ix.Ps.ne.WQ.KV.Pf.eqIItI8d.jJ.yi.UE.k3.sI.5p.lA.wz.uO.37.Fi.1b.oP.UT.1B.ivIHjIWI.De.E1.C5.C0.I1.LU.ic.eN.K4IJe.Br.8y.57.1m.ZtIgJ.GT.1wID9.A6.8X.EJ.WA.C7.WMIWW.kr.hw.N1IC8.m2.zy.Q8.Z6.MI.hq.Hw.ELIWe.1HIqO.lJ.BM.OI.TbINY.5y.yk.fm.nA.zE.Yf.7zIp6.9G.cJ.AE.7fIHD.xz.VE.8z.bS.Lr.Qc.0n.ie.QH.RYIFVIzWI9F.pz.yt.ko.24.jq.oGIHi.km.vf.w8.wdIWr.8O.vMIzV.o9ICM.L2.3K.lL.pd.v4.TN.5mIAAIUg.pXIzx.lI.0b.xS.ZS.se.lx.4U.wE.CU.Mc.2VI9x.Tp.Hk.dPI8EIHA.ZX.vI.HE.f9.uvIIF.up.Px.B3.c2.YA.0XIUc.Sa.sN.XU.LJ.wg.uX.TVIIwIFF.ez.y4.be.2T.Rw.Ep.Gv.co.06IHI..A.ji..n.Xn.tvIWE.sG.vd.fI.VK.n1.Rm.No.2j.1J.Jg.CF.SCIqQ.QWIC7.JE.e3.JY.NK.Ka.NPIHr.oN.g7.zr.bwINL.TX.BkIWH.4H.oV.oIIJN.1a.xbIQS.Tq.OH.Ll.47.wL.mx.3m.vA.bC.8W.CV.IV.gm.Xu.Oh.f4.Vg.6y.3O.cI.Vh.R6Iz2.Hz.iC.ad.Nk.uf.EZ.ax.Nj.vb.hW.X6I95.dZ.xq.oC.OF.F0.lpIzq.41.JM.SP.XD.bt.G4.2k.XAIHOI83.GoIW2.hC.cWINi.r0.cu.Vo.6p.SB.CNIDq.7Y.ug.rK.s9.BB.etIgv.EcIDB.yh.1g.T3.wT.hY.J2.zA.e4.8iIA3.IMIU9.vq.4RINbI8V.DI.er.Ci.fM.QL.kK.iP.Cb.LRI85.zY.S5.K7IDZ.TAIUL.Cz.R1INo.x6.Lf.EA.dH.yX.ebIARIHSIIv.fCIN3.8l.SJ.fHI8b.H3.43II1Ipq.FaINk.Om.3r.Xz.9FINs.HD.4W.CPIp5.C3.9T.TuI81IWC.8d.M6.1n..rIJT.tt.ZE.NdICz.lm.N4.PtIpk.a2.dv..q.T6IIp.ej.xP.OV.pF.zWIDw.HaIUO.5b.FTIIL.U8IprIWq.ab.RyIFA.ywIzII9n.Ua.hB.hQ.hK.KTIUDIQGIAYI8v.6P.ex.8f.dpIIb.63.EP.m5.Jh.DJ.mM.fp.0J.17.JUIzH.7v.kZ.Wj.Z2IDP.xn.RW.GR.gA.AH.NT.zZ.yY.Dp.7V.yv.ObIQMIge.7HIWw.0B.l1.sn.E5.xW.hG.pC.HU.gPIFX.OzIDI.CC.yu.Cy.AM.wGIHy.Da.ToIUv.VUI8s.DbIUVIHbIzA.KO.3B.34.sAINdIJ5.dd.NlIJv.nJ.Sy.Hr.zGIJA.Hu.VP.hL.jy.IW.G3.X3.sY.uJ.p0.fQ.VR.e7.OG.YS.AW.35IgFICN.Y7II9INH.A2.K1.EN.jc.fw.DG.GnIqY.dN.Rf.FEIzn.yS.Vw.Du.6A.Qg.4K.ER.CZ.fu.Rt.Bl.eQ.0d.rX.9X.x5.r5.XC.Ur.yG.NM.2l.vJI9c.2a.pLIA4.RnINj.jN.85.zJ.suINl.Uq.Iu.EG.KMICE.TE.HT.Rc.Ru.i5IJq.p7.tD.KP.Z9.HPI9v.OA..FIAI.NA.ni.64IIHIWfI8TIqEIqn.f0.tH.hFIQK.pe.VX.AO.4YI9D.zp.QlIFy.uZIz4..O.5D.md.09.9J.gDIUT.ua.6u.I4IIq.A1.xM.gFIpa.wu.WgIJQ.si.4a.HV.FfIAc.m9.36.XJIIc.58.PS.vh.Ow.6D.6S.uh.52IU4.BcIHk.yMIWb.bs.oD.HH.NFI8e.8J.f6.3x.T7IQp.tz.nn.AlIgk.bX.Ba.1v.VOIAt.z7.D8IUf.sj.Tt.yK.kP.Gw.XX..zIAC.lv.YpIAN.GC.T4IQBIWlIzTIDg.mh.mT.cV.Nv.fV.r6.NLICh.V2IzS.Fn.XH.tRICv.GO.h6.nsINO.pw.Df.yL.Dr.hz.o0.A8.QT.hi.t6.BX.plIHa..a.VYIIO.YaIJSI9m.iy.WY..l.d8.6w.Ft..2Izi.Dj.6h.iX.EU.Qo.Zu.e5IQc.ZB.Gd.AY.4i.zx.td.3h.4D.fg.pr.Nz.Wq.Gi.aQ.Va.00.ybIqP.CG.aqI9B.4vIUC.Nh.2RIWN.xB.mu.ZT.5P.CW.Ab.PEIIi.yZINII9M..SI8F.2B.BgI9V.VWIIl.wn.a1.9sIUtIJo.dkIgL.Ey.yWIAnIqL.6c.PuIQo.Am.vpIHn.Jx.Er.Iw.0UIHP.p9.fr.kX.Zr.rSIWd.nx.bq.Y0.gE.Bi.dX.vw.FU.TW.TI.N0IQE.0l.ABIWi.LO.FkIgZ.Qs.gh.ID.db.RP.LAIpP.Yr.Py.VFIIm.4jI97.QA.uG.xy.W7.4s.jB.FH.2U.L6INa.6KIIo.Sz.E3.V7.40.gqICH..H.2M.BW.Jm.L5IpIIN5.TeIHJ.Mi.hN.Sx.DO.6J.KW.pK.L8.KhI93IU7.wx.k0.dJ.Q4.Yn.5o.Xr.oS.QR.j5IWv.vT.7WI8cIUFICR.ymIDR.PY.vs.nr.WP.Hm.RC.2S.RD.Qb.XO.Tm.hD.kh.ypIWZ.0t.cO.i9.GW.hgIHuI9z.9y.LaI80.wc.gUIQVIQ9IQ5.WC.Ex.oZ.66.mn.Ux.9B.kO.DY.Wn.OW.cgIAs.UC.XbIJz.wB.jo.4cIFG.sRIqS.brIJg.UZ..C.jV.eZIDh.ZZ.7M.72.bYI86.Vq.sd.Qn.1qIIZ.fj.Qk.A3I9J.Lq.fb.1hIpf.dc.Ce.95.hU.Bo.ta.dr.O7.P0.ET.SH.VBIIV.dV.Jl.nM.TRIQ4..0IgQ.1M.CJ.CQ.7r.XN.X1ICl.uT.mt.S1.9g.p4.I5.biIAE.ve.BpIgH.7u.45.EY.F2IHs.Dt.kf.jK.OJ.zM.4L.n5.K2.Of.iB.uA.Fl.yI.OqIUo.IxIUN.kn.im.0r.pT.O5.gj.2JIQd.h4.4tIDGI8x.Zy.WZ.sxICy.87.TQ.NCINu.9O.oY.PR.4r.g1.QJ.nV.AjINJ.iKIqI.og.iI.NX.vP.if.W6.6kIHY.Pd.HFIJH.3YICW.PK.HX.Vr.bW.54ID8.WV.gs.dRI8P.gX.BmI8X.vC.vaIQf.x7.Qq.JyIIE.Ud.BNIq2.KS.GAIJC.hn.ft.Kp.N6.4xIQk.wR.xcIDMI9i.hA.DMIHm.wj.ny.h1.yqINhIJD.YUIIg.7R.9N.7s.LMI9QIHfI8Z.Qj.aM.dS.W2.6B.tu.kpIqR.0W.w4.lC.fF.rk.4TIzj.En.n4.RaIIu.8U.Qf..P.p6.zS.sM.ml.0DI8i.It.wZIpz.gY.Zs.cs.b5.4y.3S.pmI8M.de.MYIQA.77.YY.bJ.Qe.OK.M2IQyIDT..k.BF.ZRIUE.8e.9d.MHIUl.c1IpKIgN.zsIQOINg.SOIUh.llI96.SX.1r.ATI92.ev.la.pi.CL.aj.yl.J3.UfIW6..7IAM.vt.3oIWVIHv.QB.7GIzU.d3Ig0.mN.Zq.ZC.pG.Po.G8.vu.mVIzfINVIqJINE.RZ.nE.iJ.a7.jb.5Y.nX.tL.M7.5sIp2.M3Ipn.pa.5U.RJ.b2.cH.vY.xf.JO.Mz.Nn.tkICV.hx.wH.0q.h7.gv.teIpS.Kr.R8.InIIk.Ku.7Q.sf.NE.O4.eK.JG.Rq.4V.leIU1IAJ.Jd.7NI8C.5I.6Z.vE.1QIJ7.Ng.un.I2.EM.Vd.sJ.33.y8.rL.ubIgfIUw.LT.ThIgK.eU.je.5d.zI.GK.CS.Md.A0.sW.E8.Ja.iS.dqIg3.Yx.eL.vB.D5.it.KD.bm..6.Zb.h9IWo.os.jO.rrIJ6.y0.y7.2r.EXIQx.Sd.bA.mv.H6.zb.k4.lGIFQ.Z3IDWIH2II0IA0.l6.pnINe.PG.ys.Fc.aL.uk.e1.6O.gy.JFIHq.e0.eCIWy.Dz.Gx.d0IA6.saIFm.fR.4gIF5IW4.cP.Un.dw.J7.2E.YPIDi.oL.7k.i3IQ0.m1.w7.w9.O2.7q.so.lBIQuIpD.zcIW8.p8.k5.j1.Yi.nL.MXICP.tC.wY.k9.3C.sb.omIp9.IG.5O.pN.2u.g6IQl.znI9Z.1xINKIWh.zR.FL.jg.P3.vF.KA.r3.kz.yrIqr.y9.yj.5c.V1.bO.29.Lt.b0Iqw.JI.DC.sSIzKIQW.bV.Sp.tn.B6.OQ.HQ.tb.D6IUe.TvIA7.oF.FV.12.pQ.Yu.b6.Ji.Pp.RH.t2.4Q.14.4m.DB.ih.mK.GF.jw.QF.Kv.D3.wo.5t.u7.jH.cR.Ee.ZY.HxIN4IUA.7KIzc.SM..X.Ze.oj.a9.hu.cwIpu.6dIQI.SA.Vx.mkIgD.1y.oX.Ia.TM.es.QV.Ma.hHIHz.ib.RG.30.OO..s.nW.tm.Wz.WxIA2.QU.dE.OtI8A.PP.7l.xs.8Y.rp.YX.HR.zT.pWIzh.Eo.eEI8U.gJ.91.9x.W3IJX.FGIzb.8w.N3.wQIUS.PNIJ2.C8IWB.5k.MF.Sk.hlIDUINn.AI.LkIJhIAe.LZ.3k.vWIF2.eH.jf.51.pDIg7I8a.xe.to.dQ.w1IDv.4B.vr.xx.yO.tS.baI9w.Cn.rH.5u.uN.yU.zf..tIUI.yJIJl.XaIpR.3D.Vf.9U.0P.Yo.nd.mD.B5.Ts.YV.S6.ZUIqG.VN.ZN.T8.rl.xV.0V.K3.t9.Hs.Ri.83.sF.TPICm.Ks.uH.AX.6L.sU.oQ.JTIAB.Nb.z4..pID2.zj.pA.5F.EW.GV.K0.dU.lsIqu.tJIUi.ueICtIAZ.ju.ccIgX.FY.GM.cX.J8.Xk.uP.Yv.Ov.5K.ZAIUk.5a.Dg.vN.Ws.JP.9D.TZIQD.XW.7w.nvI9f..u.H8.scIUW.2iIpx.YI.Se.OB.20IW5.4o.gd.u3IDF.ZV.97.8P.2A.T1.oo.6NIJO.zzIgm.03.K8.uQ.P4.bu.XFI8wIpy.56IN0.YN.22IqD.TU.Yj.cE.z0I9g.nl.I6.UXIgT.CRIWP.71.lD.v9INZ.Oo.ao.Bn.Vl.el.SS.R3I94.rZIHT.kI.Iq.Hq..TIHc.tf.FM.Ph.ar.HB.Nw.K5.O0IqB.oz.Lv.0IICeIH7.zN.Yq.h2.4E.Rx.ob.PF.bk.cZ.AJ.cbIpG.9C.0w.xF.Ml.or.lN.BUIga.Jb.vO.l4IUz.uU.gN.1I.ON.SEIF6.fz.M1.Xx.kRIJMICg.Im.KtIps.rQ.oE.9kIpB.7T.rn.ef.5w.5v.dm.I7.oJ.ga.Et.WI.pt.0K.KF.x8.Ge.dL.6E.FS.l0.MU.o3.OS.4z.0e.haIFw.FsIAi.ti.o8.y2IJU.fBIFf.PV.B4.jj.f8IFq.Dm.D0.2DIUX.yx.U2Iqx.x3.9cICA.YE.P6.Cr.ol.uY.LI.eX.JL.9n.Oa.uz.Wb.rN.7P.iR.r1IDe.6V.BbIz9.Ko.zH.kl.16.nc.V0.hJIFO.YZ.i2.xDI9H.8j.fcIg8ICx.Js.kFIzP.0T.jI.Eh.Fo.QXIJZ.Jt.74.v7.t7IQQ.yHIzg.Yl.9w.13.Mh.tg.1eIg2IAp.xU.gG.J1.VM.Vz.2b.Fu.f1.Q0.ah.CA.MT.Hc.xL.Sg.FC.BJ.rj.enIQR.bIIqA.T9.aX.38.lP.Wa.4P.pZ.Dc.JK.F3.S9.Lc.sE.sZ.sy.nB.4u.op.F4.Mu.Ah.rbII6.ph.XK.kV.0Z.4C.Ax.Jn.Mg.Ve.4S.bg.IEIgPICp.v1.lS.PD.waICB.0E.GQ.GJ.7FIAF.Hg.3s.TwIzG.gK.99Izw.1lIH3.Qh.RR.nH";
		static private var _dukascopySecurityKey:String=".ap.iO.Oe.eT.tP.vHIqv.mI.xd.5WIJ";
		
		public function LatestsManager() { }
		
		
		static public function init():void {
			if (inited)
				return;
			inited = true;
			WS.S_CONNECTED.add(onWSConnected);
			WS.S_DISCONNECTED.add(onWSDisconnected);
			Auth.S_NEED_AUTHORIZATION.add(onNeedAuthorization);
			WSClient.S_CHAT_MSG.add(onChatMsg);
			WSClient.S_CHAT_MSG_REMOVED.add(onChatMsg);
			WSClient.S_CHAT_MSG_UPDATED.add(onChatMsg);
			load();
		}
		
		static private function onNeedAuthorization():void{
			needLoadFromSql = true;
			needLoadFromServer = true;
			echo("LatestManager", "onNeedAuthorization", "TODO - CLEAR ALL DATA");
		}
		
		static private function onChatMsg(data:Object):void {
			echo("LatestManager", "onChatMsg", "new message");
		}
		
		static private function onWSConnected():void {
			load();
			echo("LatestManager", "onWSConnected", "websocket connected");
		}
		
		static private function onWSDisconnected():void {
			needLoadFromServer = true;
		}
		
		static private function load():void {
			busy = true;
			// load local chats
			if (needLoadFromSql == true){
				echo("LatestManager", "load", "Load chats from sql lite");
				SQLite.call_getLatest(function(sqlr:SQLRespond):void{
					// PARSE ITEMS!
					needLoadFromSql = sqlr.error;
					
					if (sqlr.data != null && sqlr.data.length >0){
						echo("LatestManager", "load.SQLite.call_getLatest", "Chats from sql loaded! creating");
						// sync data
						var n:int = 0;
						var l:int = sqlr.data.length;
						var sqlErrData:int = 0;
						for (n; n < l; n++) {
							var rowdata:String = sqlr.data[n]['data'];
							var chatUID:String = sqlr.data[n]['chat_uid'];
							if (rowdata.length == 0){
								sqlErrData++;
								continue;
							}
						}
						
						if (sqlErrData > 0)
							echo("LatestManager", "load.SQLite.call_getLatest", "Error in sql rows: "+sqlErrData+"/"+sqlr.data.length,true);
						
						
						S_LIST_CHANGED.invoke(); // loaded from sqlite
					}
					
					loadFromPHPServer();
					
				});
				
				return;
			}
			
			// loading from php server
			loadFromPHPServer();
			
		}
		
		static private function loadFromPHPServer():void {
			
			if (needLoadFromServer == false) {
				busy = false;	
				return;
			}
			
			if (WS.connected == false) {
				busy = false;		
				return;
			}
				
			echo("LatestsManager","loadFromPHPServer","loading chats from php server");
				
			PHP.chat_getLatest(function(r:PHPRespond):void {
				
				busy = false;	
				
				echo("LatestManager", "loadFromPHPServer.PHP.chat_getLatest", "Chats from php loaded");
				
				// sync data!
							
				if (r.error==false)
					needLoadFromServer = false;
					
				if (r.data == null || r.data.latest==null)
					return;
					
				echo("LatestManager", "loadFromPHPServer.PHP.chat_getLatest", "Creating");
					
				if(r.data.hash!=null)
					serverHash = r.data.hash;
				if (latest == null)
					latest = [];
				var n:int = 0
				var len:int = r.data.latest.length;	
				var tmp:Array = [];
				var cvo:ChatVO = latest[m];
				// over data
				for (n; n < len; n++){
					var itm:Object = r.data.latest[n];
					var m:int = 0;
					var l2:int = latest.length;
					var wasFound:Boolean = false;
					// over store
					for (m; m < l2;m++){
						cvo = latest[m];
						if (cvo.uid == itm.uid) {
							// DATA
							wasFound = true;
							//if (cvo.update(itm))
								SQLite.call_saveChatItem(cvo.uid,cvo.toString());
						}
					}
					if (wasFound == false) {
						//echo("LatestManager", "loadFromPHPServer", "NEW CHAT ITEM! NEED TO SAVE");
						tmp.push(itm);
					}
				}
				
				// add new items
				n = 0;
				len = tmp.length;
				for (n; n < len; n++) {
					cvo= new ChatVO(tmp[n]);
					latest.unshift(cvo);
					SQLite.call_saveChatItem(cvo.uid,cvo.toString());
				}
				
				
				S_LIST_CHANGED.invoke();
				
			}, serverHash);
		}
		
		static public function get dukascopySecurityKey():String {
			return _dukascopySecurityKey;
		}
		
	}

}