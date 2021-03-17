package com.dukascopy.connect.sys.richTextField {
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.store.Store;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;

	public class RichTextSmilesCodes {
 
		[Embed(source = "smiles/1f004.png")] public var SM_1F004:Class;
		[Embed(source = "smiles/1f0cf.png")] public var SM_1F0CF:Class;
		[Embed(source = "smiles/1f170.png")] public var SM_1F170:Class;
		[Embed(source = "smiles/1f171.png")] public var SM_1F171:Class;
		[Embed(source = "smiles/1f17e.png")] public var SM_1F17E:Class;
		[Embed(source = "smiles/1f17f.png")] public var SM_1F17F:Class;
		[Embed(source = "smiles/1f18e.png")] public var SM_1F18E:Class;
		[Embed(source = "smiles/1f191.png")] public var SM_1F191:Class;
		[Embed(source = "smiles/1f192.png")] public var SM_1F192:Class;
		[Embed(source = "smiles/1f193.png")] public var SM_1F193:Class;
		[Embed(source = "smiles/1f194.png")] public var SM_1F194:Class;
		[Embed(source = "smiles/1f195.png")] public var SM_1F195:Class;
		[Embed(source = "smiles/1f196.png")] public var SM_1F196:Class;
		[Embed(source = "smiles/1f197.png")] public var SM_1F197:Class;
		[Embed(source = "smiles/1f198.png")] public var SM_1F198:Class;
		[Embed(source = "smiles/1f199.png")] public var SM_1F199:Class;
		[Embed(source = "smiles/1f19a.png")] public var SM_1F19A:Class;
		[Embed(source = "smiles/1f201.png")] public var SM_1F201:Class;
		[Embed(source = "smiles/1f202.png")] public var SM_1F202:Class;
		[Embed(source = "smiles/1f21a.png")] public var SM_1F21A:Class;
		[Embed(source = "smiles/1f22f.png")] public var SM_1F22F:Class;
		[Embed(source = "smiles/1f232.png")] public var SM_1F232:Class;
		[Embed(source = "smiles/1f233.png")] public var SM_1F233:Class;
		[Embed(source = "smiles/1f234.png")] public var SM_1F234:Class;
		[Embed(source = "smiles/1f235.png")] public var SM_1F235:Class;
		[Embed(source = "smiles/1f236.png")] public var SM_1F236:Class;
		[Embed(source = "smiles/1f237.png")] public var SM_1F237:Class;
		[Embed(source = "smiles/1f238.png")] public var SM_1F238:Class;
		[Embed(source = "smiles/1f239.png")] public var SM_1F239:Class;
		[Embed(source = "smiles/1f23a.png")] public var SM_1F23A:Class;
		[Embed(source = "smiles/1f250.png")] public var SM_1F250:Class;
		[Embed(source = "smiles/1f251.png")] public var SM_1F251:Class;
		[Embed(source = "smiles/1f300.png")] public var SM_1F300:Class;
		[Embed(source = "smiles/1f301.png")] public var SM_1F301:Class;
		[Embed(source = "smiles/1f302.png")] public var SM_1F302:Class;
		[Embed(source = "smiles/1f303.png")] public var SM_1F303:Class;
		[Embed(source = "smiles/1f304.png")] public var SM_1F304:Class;
		[Embed(source = "smiles/1f305.png")] public var SM_1F305:Class;
		[Embed(source = "smiles/1f306.png")] public var SM_1F306:Class;
		[Embed(source = "smiles/1f307.png")] public var SM_1F307:Class;
		[Embed(source = "smiles/1f308.png")] public var SM_1F308:Class;
		[Embed(source = "smiles/1f309.png")] public var SM_1F309:Class;
		[Embed(source = "smiles/1f30a.png")] public var SM_1F30A:Class;
		[Embed(source = "smiles/1f30b.png")] public var SM_1F30B:Class;
		[Embed(source = "smiles/1f30c.png")] public var SM_1F30C:Class;
		[Embed(source = "smiles/1f30d.png")] public var SM_1F30D:Class;
		[Embed(source = "smiles/1f30e.png")] public var SM_1F30E:Class;
		[Embed(source = "smiles/1f30f.png")] public var SM_1F30F:Class;
		[Embed(source = "smiles/1f310.png")] public var SM_1F310:Class;
		[Embed(source = "smiles/1f311.png")] public var SM_1F311:Class;
		[Embed(source = "smiles/1f312.png")] public var SM_1F312:Class;
		[Embed(source = "smiles/1f313.png")] public var SM_1F313:Class;
		[Embed(source = "smiles/1f314.png")] public var SM_1F314:Class;
		[Embed(source = "smiles/1f315.png")] public var SM_1F315:Class;
		[Embed(source = "smiles/1f316.png")] public var SM_1F316:Class;
		[Embed(source = "smiles/1f317.png")] public var SM_1F317:Class;
		[Embed(source = "smiles/1f318.png")] public var SM_1F318:Class;
		[Embed(source = "smiles/1f319.png")] public var SM_1F319:Class;
		[Embed(source = "smiles/1f31a.png")] public var SM_1F31A:Class;
		[Embed(source = "smiles/1f31b.png")] public var SM_1F31B:Class;
		[Embed(source = "smiles/1f31c.png")] public var SM_1F31C:Class;
		[Embed(source = "smiles/1f31d.png")] public var SM_1F31D:Class;
		[Embed(source = "smiles/1f31e.png")] public var SM_1F31E:Class;
		[Embed(source = "smiles/1f31f.png")] public var SM_1F31F:Class;
		[Embed(source = "smiles/1f320.png")] public var SM_1F320:Class;
		[Embed(source = "smiles/1f321.png")] public var SM_1F321:Class;
		[Embed(source = "smiles/1f324.png")] public var SM_1F324:Class;
		[Embed(source = "smiles/1f325.png")] public var SM_1F325:Class;
		[Embed(source = "smiles/1f326.png")] public var SM_1F326:Class;
		[Embed(source = "smiles/1f327.png")] public var SM_1F327:Class;
		[Embed(source = "smiles/1f328.png")] public var SM_1F328:Class;
		[Embed(source = "smiles/1f329.png")] public var SM_1F329:Class;
		[Embed(source = "smiles/1f32a.png")] public var SM_1F32A:Class;
		[Embed(source = "smiles/1f32b.png")] public var SM_1F32B:Class;
		[Embed(source = "smiles/1f32c.png")] public var SM_1F32C:Class;
		[Embed(source = "smiles/1f32d.png")] public var SM_1F32D:Class;
		[Embed(source = "smiles/1f32e.png")] public var SM_1F32E:Class;
		[Embed(source = "smiles/1f32f.png")] public var SM_1F32F:Class;
		[Embed(source = "smiles/1f330.png")] public var SM_1F330:Class;
		[Embed(source = "smiles/1f331.png")] public var SM_1F331:Class;
		[Embed(source = "smiles/1f332.png")] public var SM_1F332:Class;
		[Embed(source = "smiles/1f333.png")] public var SM_1F333:Class;
		[Embed(source = "smiles/1f334.png")] public var SM_1F334:Class;
		[Embed(source = "smiles/1f335.png")] public var SM_1F335:Class;
		[Embed(source = "smiles/1f336.png")] public var SM_1F336:Class;
		[Embed(source = "smiles/1f337.png")] public var SM_1F337:Class;
		[Embed(source = "smiles/1f338.png")] public var SM_1F338:Class;
		[Embed(source = "smiles/1f339.png")] public var SM_1F339:Class;
		[Embed(source = "smiles/1f33a.png")] public var SM_1F33A:Class;
		[Embed(source = "smiles/1f33b.png")] public var SM_1F33B:Class;
		[Embed(source = "smiles/1f33c.png")] public var SM_1F33C:Class;
		[Embed(source = "smiles/1f33d.png")] public var SM_1F33D:Class;
		[Embed(source = "smiles/1f33e.png")] public var SM_1F33E:Class;
		[Embed(source = "smiles/1f33f.png")] public var SM_1F33F:Class;
		[Embed(source = "smiles/1f340.png")] public var SM_1F340:Class;
		[Embed(source = "smiles/1f341.png")] public var SM_1F341:Class;
		[Embed(source = "smiles/1f342.png")] public var SM_1F342:Class;
		[Embed(source = "smiles/1f343.png")] public var SM_1F343:Class;
		[Embed(source = "smiles/1f344.png")] public var SM_1F344:Class;
		[Embed(source = "smiles/1f345.png")] public var SM_1F345:Class;
		[Embed(source = "smiles/1f346.png")] public var SM_1F346:Class;
		[Embed(source = "smiles/1f347.png")] public var SM_1F347:Class;
		[Embed(source = "smiles/1f348.png")] public var SM_1F348:Class;
		[Embed(source = "smiles/1f349.png")] public var SM_1F349:Class;
		[Embed(source = "smiles/1f34a.png")] public var SM_1F34A:Class;
		[Embed(source = "smiles/1f34b.png")] public var SM_1F34B:Class;
		[Embed(source = "smiles/1f34c.png")] public var SM_1F34C:Class;
		[Embed(source = "smiles/1f34d.png")] public var SM_1F34D:Class;
		[Embed(source = "smiles/1f34e.png")] public var SM_1F34E:Class;
		[Embed(source = "smiles/1f34f.png")] public var SM_1F34F:Class;
		[Embed(source = "smiles/1f350.png")] public var SM_1F350:Class;
		[Embed(source = "smiles/1f351.png")] public var SM_1F351:Class;
		[Embed(source = "smiles/1f352.png")] public var SM_1F352:Class;
		[Embed(source = "smiles/1f353.png")] public var SM_1F353:Class;
		[Embed(source = "smiles/1f354.png")] public var SM_1F354:Class;
		[Embed(source = "smiles/1f355.png")] public var SM_1F355:Class;
		[Embed(source = "smiles/1f356.png")] public var SM_1F356:Class;
		[Embed(source = "smiles/1f357.png")] public var SM_1F357:Class;
		[Embed(source = "smiles/1f358.png")] public var SM_1F358:Class;
		[Embed(source = "smiles/1f359.png")] public var SM_1F359:Class;
		[Embed(source = "smiles/1f35a.png")] public var SM_1F35A:Class;
		[Embed(source = "smiles/1f35b.png")] public var SM_1F35B:Class;
		[Embed(source = "smiles/1f35c.png")] public var SM_1F35C:Class;
		[Embed(source = "smiles/1f35d.png")] public var SM_1F35D:Class;
		[Embed(source = "smiles/1f35e.png")] public var SM_1F35E:Class;
		[Embed(source = "smiles/1f35f.png")] public var SM_1F35F:Class;
		[Embed(source = "smiles/1f360.png")] public var SM_1F360:Class;
		[Embed(source = "smiles/1f361.png")] public var SM_1F361:Class;
		[Embed(source = "smiles/1f362.png")] public var SM_1F362:Class;
		[Embed(source = "smiles/1f363.png")] public var SM_1F363:Class;
		[Embed(source = "smiles/1f364.png")] public var SM_1F364:Class;
		[Embed(source = "smiles/1f365.png")] public var SM_1F365:Class;
		[Embed(source = "smiles/1f366.png")] public var SM_1F366:Class;
		[Embed(source = "smiles/1f367.png")] public var SM_1F367:Class;
		[Embed(source = "smiles/1f368.png")] public var SM_1F368:Class;
		[Embed(source = "smiles/1f369.png")] public var SM_1F369:Class;
		[Embed(source = "smiles/1f36a.png")] public var SM_1F36A:Class;
		[Embed(source = "smiles/1f36b.png")] public var SM_1F36B:Class;
		[Embed(source = "smiles/1f36c.png")] public var SM_1F36C:Class;
		[Embed(source = "smiles/1f36d.png")] public var SM_1F36D:Class;
		[Embed(source = "smiles/1f36e.png")] public var SM_1F36E:Class;
		[Embed(source = "smiles/1f36f.png")] public var SM_1F36F:Class;
		[Embed(source = "smiles/1f370.png")] public var SM_1F370:Class;
		[Embed(source = "smiles/1f371.png")] public var SM_1F371:Class;
		[Embed(source = "smiles/1f372.png")] public var SM_1F372:Class;
		[Embed(source = "smiles/1f373.png")] public var SM_1F373:Class;
		[Embed(source = "smiles/1f374.png")] public var SM_1F374:Class;
		[Embed(source = "smiles/1f375.png")] public var SM_1F375:Class;
		[Embed(source = "smiles/1f376.png")] public var SM_1F376:Class;
		[Embed(source = "smiles/1f377.png")] public var SM_1F377:Class;
		[Embed(source = "smiles/1f378.png")] public var SM_1F378:Class;
		[Embed(source = "smiles/1f379.png")] public var SM_1F379:Class;
		[Embed(source = "smiles/1f37a.png")] public var SM_1F37A:Class;
		[Embed(source = "smiles/1f37b.png")] public var SM_1F37B:Class;
		[Embed(source = "smiles/1f37c.png")] public var SM_1F37C:Class;
		[Embed(source = "smiles/1f37d.png")] public var SM_1F37D:Class;
		[Embed(source = "smiles/1f37e.png")] public var SM_1F37E:Class;
		[Embed(source = "smiles/1f37f.png")] public var SM_1F37F:Class;
		[Embed(source = "smiles/1f380.png")] public var SM_1F380:Class;
		[Embed(source = "smiles/1f381.png")] public var SM_1F381:Class;
		[Embed(source = "smiles/1f382.png")] public var SM_1F382:Class;
		[Embed(source = "smiles/1f383.png")] public var SM_1F383:Class;
		[Embed(source = "smiles/1f384.png")] public var SM_1F384:Class;
		[Embed(source = "smiles/1f385.png")] public var SM_1F385:Class;
		[Embed(source = "smiles/1f386.png")] public var SM_1F386:Class;
		[Embed(source = "smiles/1f387.png")] public var SM_1F387:Class;
		[Embed(source = "smiles/1f388.png")] public var SM_1F388:Class;
		[Embed(source = "smiles/1f389.png")] public var SM_1F389:Class;
		[Embed(source = "smiles/1f38a.png")] public var SM_1F38A:Class;
		[Embed(source = "smiles/1f38b.png")] public var SM_1F38B:Class;
		[Embed(source = "smiles/1f38c.png")] public var SM_1F38C:Class;
		[Embed(source = "smiles/1f38d.png")] public var SM_1F38D:Class;
		[Embed(source = "smiles/1f38e.png")] public var SM_1F38E:Class;
		[Embed(source = "smiles/1f38f.png")] public var SM_1F38F:Class;
		[Embed(source = "smiles/1f390.png")] public var SM_1F390:Class;
		[Embed(source = "smiles/1f391.png")] public var SM_1F391:Class;
		[Embed(source = "smiles/1f392.png")] public var SM_1F392:Class;
		[Embed(source = "smiles/1f393.png")] public var SM_1F393:Class;
		[Embed(source = "smiles/1f396.png")] public var SM_1F396:Class;
		[Embed(source = "smiles/1f397.png")] public var SM_1F397:Class;
		[Embed(source = "smiles/1f399.png")] public var SM_1F399:Class;
		[Embed(source = "smiles/1f39a.png")] public var SM_1F39A:Class;
		[Embed(source = "smiles/1f39b.png")] public var SM_1F39B:Class;
		[Embed(source = "smiles/1f39e.png")] public var SM_1F39E:Class;
		[Embed(source = "smiles/1f39f.png")] public var SM_1F39F:Class;
		[Embed(source = "smiles/1f3a0.png")] public var SM_1F3A0:Class;
		[Embed(source = "smiles/1f3a1.png")] public var SM_1F3A1:Class;
		[Embed(source = "smiles/1f3a2.png")] public var SM_1F3A2:Class;
		[Embed(source = "smiles/1f3a3.png")] public var SM_1F3A3:Class;
		[Embed(source = "smiles/1f3a4.png")] public var SM_1F3A4:Class;
		[Embed(source = "smiles/1f3a5.png")] public var SM_1F3A5:Class;
		[Embed(source = "smiles/1f3a6.png")] public var SM_1F3A6:Class;
		[Embed(source = "smiles/1f3a7.png")] public var SM_1F3A7:Class;
		[Embed(source = "smiles/1f3a8.png")] public var SM_1F3A8:Class;
		[Embed(source = "smiles/1f3a9.png")] public var SM_1F3A9:Class;
		[Embed(source = "smiles/1f3aa.png")] public var SM_1F3AA:Class;
		[Embed(source = "smiles/1f3ab.png")] public var SM_1F3AB:Class;
		[Embed(source = "smiles/1f3ac.png")] public var SM_1F3AC:Class;
		[Embed(source = "smiles/1f3ad.png")] public var SM_1F3AD:Class;
		[Embed(source = "smiles/1f3ae.png")] public var SM_1F3AE:Class;
		[Embed(source = "smiles/1f3af.png")] public var SM_1F3AF:Class;
		[Embed(source = "smiles/1f3b0.png")] public var SM_1F3B0:Class;
		[Embed(source = "smiles/1f3b1.png")] public var SM_1F3B1:Class;
		[Embed(source = "smiles/1f3b2.png")] public var SM_1F3B2:Class;
		[Embed(source = "smiles/1f3b3.png")] public var SM_1F3B3:Class;
		[Embed(source = "smiles/1f3b4.png")] public var SM_1F3B4:Class;
		[Embed(source = "smiles/1f3b5.png")] public var SM_1F3B5:Class;
		[Embed(source = "smiles/1f3b6.png")] public var SM_1F3B6:Class;
		[Embed(source = "smiles/1f3b7.png")] public var SM_1F3B7:Class;
		[Embed(source = "smiles/1f3b8.png")] public var SM_1F3B8:Class;
		[Embed(source = "smiles/1f3b9.png")] public var SM_1F3B9:Class;
		[Embed(source = "smiles/1f3ba.png")] public var SM_1F3BA:Class;
		[Embed(source = "smiles/1f3bb.png")] public var SM_1F3BB:Class;
		[Embed(source = "smiles/1f3bc.png")] public var SM_1F3BC:Class;
		[Embed(source = "smiles/1f3bd.png")] public var SM_1F3BD:Class;
		[Embed(source = "smiles/1f3be.png")] public var SM_1F3BE:Class;
		[Embed(source = "smiles/1f3bf.png")] public var SM_1F3BF:Class;
		[Embed(source = "smiles/1f3c0.png")] public var SM_1F3C0:Class;
		[Embed(source = "smiles/1f3c1.png")] public var SM_1F3C1:Class;
		[Embed(source = "smiles/1f3c2.png")] public var SM_1F3C2:Class;
		[Embed(source = "smiles/1f3c3.png")] public var SM_1F3C3:Class;
		[Embed(source = "smiles/1f3c4.png")] public var SM_1F3C4:Class;
		[Embed(source = "smiles/1f3c5.png")] public var SM_1F3C5:Class;
		[Embed(source = "smiles/1f3c6.png")] public var SM_1F3C6:Class;
		[Embed(source = "smiles/1f3c7.png")] public var SM_1F3C7:Class;
		[Embed(source = "smiles/1f3c8.png")] public var SM_1F3C8:Class;
		[Embed(source = "smiles/1f3c9.png")] public var SM_1F3C9:Class;
		[Embed(source = "smiles/1f3ca.png")] public var SM_1F3CA:Class;
		[Embed(source = "smiles/1f3cb.png")] public var SM_1F3CB:Class;
		[Embed(source = "smiles/1f3cc.png")] public var SM_1F3CC:Class;
		[Embed(source = "smiles/1f3cd.png")] public var SM_1F3CD:Class;
		[Embed(source = "smiles/1f3ce.png")] public var SM_1F3CE:Class;
		[Embed(source = "smiles/1f3cf.png")] public var SM_1F3CF:Class;
		[Embed(source = "smiles/1f3d0.png")] public var SM_1F3D0:Class;
		[Embed(source = "smiles/1f3d1.png")] public var SM_1F3D1:Class;
		[Embed(source = "smiles/1f3d2.png")] public var SM_1F3D2:Class;
		[Embed(source = "smiles/1f3d3.png")] public var SM_1F3D3:Class;
		[Embed(source = "smiles/1f3d4.png")] public var SM_1F3D4:Class;
		[Embed(source = "smiles/1f3d5.png")] public var SM_1F3D5:Class;
		[Embed(source = "smiles/1f3d6.png")] public var SM_1F3D6:Class;
		[Embed(source = "smiles/1f3d7.png")] public var SM_1F3D7:Class;
		[Embed(source = "smiles/1f3d8.png")] public var SM_1F3D8:Class;
		[Embed(source = "smiles/1f3d9.png")] public var SM_1F3D9:Class;
		[Embed(source = "smiles/1f3da.png")] public var SM_1F3DA:Class;
		[Embed(source = "smiles/1f3db.png")] public var SM_1F3DB:Class;
		[Embed(source = "smiles/1f3dc.png")] public var SM_1F3DC:Class;
		[Embed(source = "smiles/1f3dd.png")] public var SM_1F3DD:Class;
		[Embed(source = "smiles/1f3de.png")] public var SM_1F3DE:Class;
		[Embed(source = "smiles/1f3df.png")] public var SM_1F3DF:Class;
		[Embed(source = "smiles/1f3e0.png")] public var SM_1F3E0:Class;
		[Embed(source = "smiles/1f3e1.png")] public var SM_1F3E1:Class;
		[Embed(source = "smiles/1f3e2.png")] public var SM_1F3E2:Class;
		[Embed(source = "smiles/1f3e3.png")] public var SM_1F3E3:Class;
		[Embed(source = "smiles/1f3e4.png")] public var SM_1F3E4:Class;
		[Embed(source = "smiles/1f3e5.png")] public var SM_1F3E5:Class;
		[Embed(source = "smiles/1f3e6.png")] public var SM_1F3E6:Class;
		[Embed(source = "smiles/1f3e7.png")] public var SM_1F3E7:Class;
		[Embed(source = "smiles/1f3e8.png")] public var SM_1F3E8:Class;
		[Embed(source = "smiles/1f3e9.png")] public var SM_1F3E9:Class;
		[Embed(source = "smiles/1f3ea.png")] public var SM_1F3EA:Class;
		[Embed(source = "smiles/1f3eb.png")] public var SM_1F3EB:Class;
		[Embed(source = "smiles/1f3ec.png")] public var SM_1F3EC:Class;
		[Embed(source = "smiles/1f3ed.png")] public var SM_1F3ED:Class;
		[Embed(source = "smiles/1f3ee.png")] public var SM_1F3EE:Class;
		[Embed(source = "smiles/1f3ef.png")] public var SM_1F3EF:Class;
		[Embed(source = "smiles/1f3f0.png")] public var SM_1F3F0:Class;
		[Embed(source = "smiles/1f3f3.png")] public var SM_1F3F3:Class;
		[Embed(source = "smiles/1f3f4.png")] public var SM_1F3F4:Class;
		[Embed(source = "smiles/1f3f5.png")] public var SM_1F3F5:Class;
		[Embed(source = "smiles/1f3f7.png")] public var SM_1F3F7:Class;
		[Embed(source = "smiles/1f3f8.png")] public var SM_1F3F8:Class;
		[Embed(source = "smiles/1f3f9.png")] public var SM_1F3F9:Class;
		[Embed(source = "smiles/1f3fa.png")] public var SM_1F3FA:Class;
		[Embed(source = "smiles/1f3fb.png")] public var SM_1F3FB:Class;
		[Embed(source = "smiles/1f3fc.png")] public var SM_1F3FC:Class;
		[Embed(source = "smiles/1f3fd.png")] public var SM_1F3FD:Class;
		[Embed(source = "smiles/1f3fe.png")] public var SM_1F3FE:Class;
		[Embed(source = "smiles/1f3ff.png")] public var SM_1F3FF:Class;
		[Embed(source = "smiles/1f400.png")] public var SM_1F400:Class;
		[Embed(source = "smiles/1f401.png")] public var SM_1F401:Class;
		[Embed(source = "smiles/1f402.png")] public var SM_1F402:Class;
		[Embed(source = "smiles/1f403.png")] public var SM_1F403:Class;
		[Embed(source = "smiles/1f404.png")] public var SM_1F404:Class;
		[Embed(source = "smiles/1f405.png")] public var SM_1F405:Class;
		[Embed(source = "smiles/1f406.png")] public var SM_1F406:Class;
		[Embed(source = "smiles/1f407.png")] public var SM_1F407:Class;
		[Embed(source = "smiles/1f408.png")] public var SM_1F408:Class;
		[Embed(source = "smiles/1f409.png")] public var SM_1F409:Class;
		[Embed(source = "smiles/1f40a.png")] public var SM_1F40A:Class;
		[Embed(source = "smiles/1f40b.png")] public var SM_1F40B:Class;
		[Embed(source = "smiles/1f40c.png")] public var SM_1F40C:Class;
		[Embed(source = "smiles/1f40d.png")] public var SM_1F40D:Class;
		[Embed(source = "smiles/1f40e.png")] public var SM_1F40E:Class;
		[Embed(source = "smiles/1f40f.png")] public var SM_1F40F:Class;
		[Embed(source = "smiles/1f410.png")] public var SM_1F410:Class;
		[Embed(source = "smiles/1f411.png")] public var SM_1F411:Class;
		[Embed(source = "smiles/1f412.png")] public var SM_1F412:Class;
		[Embed(source = "smiles/1f413.png")] public var SM_1F413:Class;
		[Embed(source = "smiles/1f414.png")] public var SM_1F414:Class;
		[Embed(source = "smiles/1f415.png")] public var SM_1F415:Class;
		[Embed(source = "smiles/1f416.png")] public var SM_1F416:Class;
		[Embed(source = "smiles/1f417.png")] public var SM_1F417:Class;
		[Embed(source = "smiles/1f418.png")] public var SM_1F418:Class;
		[Embed(source = "smiles/1f419.png")] public var SM_1F419:Class;
		[Embed(source = "smiles/1f41a.png")] public var SM_1F41A:Class;
		[Embed(source = "smiles/1f41b.png")] public var SM_1F41B:Class;
		[Embed(source = "smiles/1f41c.png")] public var SM_1F41C:Class;
		[Embed(source = "smiles/1f41d.png")] public var SM_1F41D:Class;
		[Embed(source = "smiles/1f41e.png")] public var SM_1F41E:Class;
		[Embed(source = "smiles/1f41f.png")] public var SM_1F41F:Class;
		[Embed(source = "smiles/1f420.png")] public var SM_1F420:Class;
		[Embed(source = "smiles/1f421.png")] public var SM_1F421:Class;
		[Embed(source = "smiles/1f422.png")] public var SM_1F422:Class;
		[Embed(source = "smiles/1f423.png")] public var SM_1F423:Class;
		[Embed(source = "smiles/1f424.png")] public var SM_1F424:Class;
		[Embed(source = "smiles/1f425.png")] public var SM_1F425:Class;
		[Embed(source = "smiles/1f426.png")] public var SM_1F426:Class;
		[Embed(source = "smiles/1f427.png")] public var SM_1F427:Class;
		[Embed(source = "smiles/1f428.png")] public var SM_1F428:Class;
		[Embed(source = "smiles/1f429.png")] public var SM_1F429:Class;
		[Embed(source = "smiles/1f42a.png")] public var SM_1F42A:Class;
		[Embed(source = "smiles/1f42b.png")] public var SM_1F42B:Class;
		[Embed(source = "smiles/1f42c.png")] public var SM_1F42C:Class;
		[Embed(source = "smiles/1f42d.png")] public var SM_1F42D:Class;
		[Embed(source = "smiles/1f42e.png")] public var SM_1F42E:Class;
		[Embed(source = "smiles/1f42f.png")] public var SM_1F42F:Class;
		[Embed(source = "smiles/1f430.png")] public var SM_1F430:Class;
		[Embed(source = "smiles/1f431.png")] public var SM_1F431:Class;
		[Embed(source = "smiles/1f432.png")] public var SM_1F432:Class;
		[Embed(source = "smiles/1f433.png")] public var SM_1F433:Class;
		[Embed(source = "smiles/1f434.png")] public var SM_1F434:Class;
		[Embed(source = "smiles/1f435.png")] public var SM_1F435:Class;
		[Embed(source = "smiles/1f436.png")] public var SM_1F436:Class;
		[Embed(source = "smiles/1f437.png")] public var SM_1F437:Class;
		[Embed(source = "smiles/1f438.png")] public var SM_1F438:Class;
		[Embed(source = "smiles/1f439.png")] public var SM_1F439:Class;
		[Embed(source = "smiles/1f43a.png")] public var SM_1F43A:Class;
		[Embed(source = "smiles/1f43b.png")] public var SM_1F43B:Class;
		[Embed(source = "smiles/1f43c.png")] public var SM_1F43C:Class;
		[Embed(source = "smiles/1f43d.png")] public var SM_1F43D:Class;
		[Embed(source = "smiles/1f43e.png")] public var SM_1F43E:Class;
		[Embed(source = "smiles/1f43f.png")] public var SM_1F43F:Class;
		[Embed(source = "smiles/1f440.png")] public var SM_1F440:Class;
		[Embed(source = "smiles/1f441.png")] public var SM_1F441:Class;
		[Embed(source = "smiles/1f442.png")] public var SM_1F442:Class;
		[Embed(source = "smiles/1f443.png")] public var SM_1F443:Class;
		[Embed(source = "smiles/1f444.png")] public var SM_1F444:Class;
		[Embed(source = "smiles/1f445.png")] public var SM_1F445:Class;
		[Embed(source = "smiles/1f446.png")] public var SM_1F446:Class;
		[Embed(source = "smiles/1f447.png")] public var SM_1F447:Class;
		[Embed(source = "smiles/1f448.png")] public var SM_1F448:Class;
		[Embed(source = "smiles/1f449.png")] public var SM_1F449:Class;
		[Embed(source = "smiles/1f44a.png")] public var SM_1F44A:Class;
		[Embed(source = "smiles/1f44b.png")] public var SM_1F44B:Class;
		[Embed(source = "smiles/1f44c.png")] public var SM_1F44C:Class;
		[Embed(source = "smiles/1f44d.png")] public var SM_1F44D:Class;
		[Embed(source = "smiles/1f44e.png")] public var SM_1F44E:Class;
		[Embed(source = "smiles/1f44f.png")] public var SM_1F44F:Class;
		[Embed(source = "smiles/1f450.png")] public var SM_1F450:Class;
		[Embed(source = "smiles/1f451.png")] public var SM_1F451:Class;
		[Embed(source = "smiles/1f452.png")] public var SM_1F452:Class;
		[Embed(source = "smiles/1f453.png")] public var SM_1F453:Class;
		[Embed(source = "smiles/1f454.png")] public var SM_1F454:Class;
		[Embed(source = "smiles/1f455.png")] public var SM_1F455:Class;
		[Embed(source = "smiles/1f456.png")] public var SM_1F456:Class;
		[Embed(source = "smiles/1f457.png")] public var SM_1F457:Class;
		[Embed(source = "smiles/1f458.png")] public var SM_1F458:Class;
		[Embed(source = "smiles/1f459.png")] public var SM_1F459:Class;
		[Embed(source = "smiles/1f45a.png")] public var SM_1F45A:Class;
		[Embed(source = "smiles/1f45b.png")] public var SM_1F45B:Class;
		[Embed(source = "smiles/1f45c.png")] public var SM_1F45C:Class;
		[Embed(source = "smiles/1f45d.png")] public var SM_1F45D:Class;
		[Embed(source = "smiles/1f45e.png")] public var SM_1F45E:Class;
		[Embed(source = "smiles/1f45f.png")] public var SM_1F45F:Class;
		[Embed(source = "smiles/1f460.png")] public var SM_1F460:Class;
		[Embed(source = "smiles/1f461.png")] public var SM_1F461:Class;
		[Embed(source = "smiles/1f462.png")] public var SM_1F462:Class;
		[Embed(source = "smiles/1f463.png")] public var SM_1F463:Class;
		[Embed(source = "smiles/1f464.png")] public var SM_1F464:Class;
		[Embed(source = "smiles/1f465.png")] public var SM_1F465:Class;
		[Embed(source = "smiles/1f466.png")] public var SM_1F466:Class;
		[Embed(source = "smiles/1f467.png")] public var SM_1F467:Class;
		[Embed(source = "smiles/1f468.png")] public var SM_1F468:Class;
		[Embed(source = "smiles/1f469.png")] public var SM_1F469:Class;
		[Embed(source = "smiles/1f46a.png")] public var SM_1F46A:Class;
		[Embed(source = "smiles/1f46b.png")] public var SM_1F46B:Class;
		[Embed(source = "smiles/1f46c.png")] public var SM_1F46C:Class;
		[Embed(source = "smiles/1f46d.png")] public var SM_1F46D:Class;
		[Embed(source = "smiles/1f46e.png")] public var SM_1F46E:Class;
		[Embed(source = "smiles/1f46f.png")] public var SM_1F46F:Class;
		[Embed(source = "smiles/1f470.png")] public var SM_1F470:Class;
		[Embed(source = "smiles/1f471.png")] public var SM_1F471:Class;
		[Embed(source = "smiles/1f472.png")] public var SM_1F472:Class;
		[Embed(source = "smiles/1f473.png")] public var SM_1F473:Class;
		[Embed(source = "smiles/1f474.png")] public var SM_1F474:Class;
		[Embed(source = "smiles/1f475.png")] public var SM_1F475:Class;
		[Embed(source = "smiles/1f476.png")] public var SM_1F476:Class;
		[Embed(source = "smiles/1f477.png")] public var SM_1F477:Class;
		[Embed(source = "smiles/1f478.png")] public var SM_1F478:Class;
		[Embed(source = "smiles/1f479.png")] public var SM_1F479:Class;
		[Embed(source = "smiles/1f47a.png")] public var SM_1F47A:Class;
		[Embed(source = "smiles/1f47b.png")] public var SM_1F47B:Class;
		[Embed(source = "smiles/1f47c.png")] public var SM_1F47C:Class;
		[Embed(source = "smiles/1f47d.png")] public var SM_1F47D:Class;
		[Embed(source = "smiles/1f47e.png")] public var SM_1F47E:Class;
		[Embed(source = "smiles/1f47f.png")] public var SM_1F47F:Class;
		[Embed(source = "smiles/1f480.png")] public var SM_1F480:Class;
		[Embed(source = "smiles/1f481.png")] public var SM_1F481:Class;
		[Embed(source = "smiles/1f482.png")] public var SM_1F482:Class;
		[Embed(source = "smiles/1f483.png")] public var SM_1F483:Class;
		[Embed(source = "smiles/1f484.png")] public var SM_1F484:Class;
		[Embed(source = "smiles/1f485.png")] public var SM_1F485:Class;
		[Embed(source = "smiles/1f486.png")] public var SM_1F486:Class;
		[Embed(source = "smiles/1f487.png")] public var SM_1F487:Class;
		[Embed(source = "smiles/1f488.png")] public var SM_1F488:Class;
		[Embed(source = "smiles/1f489.png")] public var SM_1F489:Class;
		[Embed(source = "smiles/1f48a.png")] public var SM_1F48A:Class;
		[Embed(source = "smiles/1f48b.png")] public var SM_1F48B:Class;
		[Embed(source = "smiles/1f48c.png")] public var SM_1F48C:Class;
		[Embed(source = "smiles/1f48d.png")] public var SM_1F48D:Class;
		[Embed(source = "smiles/1f48e.png")] public var SM_1F48E:Class;
		[Embed(source = "smiles/1f48f.png")] public var SM_1F48F:Class;
		[Embed(source = "smiles/1f490.png")] public var SM_1F490:Class;
		[Embed(source = "smiles/1f491.png")] public var SM_1F491:Class;
		[Embed(source = "smiles/1f492.png")] public var SM_1F492:Class;
		[Embed(source = "smiles/1f493.png")] public var SM_1F493:Class;
		[Embed(source = "smiles/1f494.png")] public var SM_1F494:Class;
		[Embed(source = "smiles/1f495.png")] public var SM_1F495:Class;
		[Embed(source = "smiles/1f496.png")] public var SM_1F496:Class;
		[Embed(source = "smiles/1f497.png")] public var SM_1F497:Class;
		[Embed(source = "smiles/1f498.png")] public var SM_1F498:Class;
		[Embed(source = "smiles/1f499.png")] public var SM_1F499:Class;
		[Embed(source = "smiles/1f49a.png")] public var SM_1F49A:Class;
		[Embed(source = "smiles/1f49b.png")] public var SM_1F49B:Class;
		[Embed(source = "smiles/1f49c.png")] public var SM_1F49C:Class;
		[Embed(source = "smiles/1f49d.png")] public var SM_1F49D:Class;
		[Embed(source = "smiles/1f49e.png")] public var SM_1F49E:Class;
		[Embed(source = "smiles/1f49f.png")] public var SM_1F49F:Class;
		[Embed(source = "smiles/1f4a0.png")] public var SM_1F4A0:Class;
		[Embed(source = "smiles/1f4a1.png")] public var SM_1F4A1:Class;
		[Embed(source = "smiles/1f4a2.png")] public var SM_1F4A2:Class;
		[Embed(source = "smiles/1f4a3.png")] public var SM_1F4A3:Class;
		[Embed(source = "smiles/1f4a4.png")] public var SM_1F4A4:Class;
		[Embed(source = "smiles/1f4a5.png")] public var SM_1F4A5:Class;
		[Embed(source = "smiles/1f4a6.png")] public var SM_1F4A6:Class;
		[Embed(source = "smiles/1f4a7.png")] public var SM_1F4A7:Class;
		[Embed(source = "smiles/1f4a8.png")] public var SM_1F4A8:Class;
		[Embed(source = "smiles/1f4a9.png")] public var SM_1F4A9:Class;
		[Embed(source = "smiles/1f4aa.png")] public var SM_1F4AA:Class;
		[Embed(source = "smiles/1f4ab.png")] public var SM_1F4AB:Class;
		[Embed(source = "smiles/1f4ac.png")] public var SM_1F4AC:Class;
		[Embed(source = "smiles/1f4ad.png")] public var SM_1F4AD:Class;
		[Embed(source = "smiles/1f4ae.png")] public var SM_1F4AE:Class;
		[Embed(source = "smiles/1f4af.png")] public var SM_1F4AF:Class;
		[Embed(source = "smiles/1f4b0.png")] public var SM_1F4B0:Class;
		[Embed(source = "smiles/1f4b1.png")] public var SM_1F4B1:Class;
		[Embed(source = "smiles/1f4b2.png")] public var SM_1F4B2:Class;
		[Embed(source = "smiles/1f4b3.png")] public var SM_1F4B3:Class;
		[Embed(source = "smiles/1f4b4.png")] public var SM_1F4B4:Class;
		[Embed(source = "smiles/1f4b5.png")] public var SM_1F4B5:Class;
		[Embed(source = "smiles/1f4b6.png")] public var SM_1F4B6:Class;
		[Embed(source = "smiles/1f4b7.png")] public var SM_1F4B7:Class;
		[Embed(source = "smiles/1f4b8.png")] public var SM_1F4B8:Class;
		[Embed(source = "smiles/1f4b9.png")] public var SM_1F4B9:Class;
		[Embed(source = "smiles/1f4ba.png")] public var SM_1F4BA:Class;
		[Embed(source = "smiles/1f4bb.png")] public var SM_1F4BB:Class;
		[Embed(source = "smiles/1f4bc.png")] public var SM_1F4BC:Class;
		[Embed(source = "smiles/1f4bd.png")] public var SM_1F4BD:Class;
		[Embed(source = "smiles/1f4be.png")] public var SM_1F4BE:Class;
		[Embed(source = "smiles/1f4bf.png")] public var SM_1F4BF:Class;
		[Embed(source = "smiles/1f4c0.png")] public var SM_1F4C0:Class;
		[Embed(source = "smiles/1f4c1.png")] public var SM_1F4C1:Class;
		[Embed(source = "smiles/1f4c2.png")] public var SM_1F4C2:Class;
		[Embed(source = "smiles/1f4c3.png")] public var SM_1F4C3:Class;
		[Embed(source = "smiles/1f4c4.png")] public var SM_1F4C4:Class;
		[Embed(source = "smiles/1f4c5.png")] public var SM_1F4C5:Class;
		[Embed(source = "smiles/1f4c6.png")] public var SM_1F4C6:Class;
		[Embed(source = "smiles/1f4c7.png")] public var SM_1F4C7:Class;
		[Embed(source = "smiles/1f4c8.png")] public var SM_1F4C8:Class;
		[Embed(source = "smiles/1f4c9.png")] public var SM_1F4C9:Class;
		[Embed(source = "smiles/1f4ca.png")] public var SM_1F4CA:Class;
		[Embed(source = "smiles/1f4cb.png")] public var SM_1F4CB:Class;
		[Embed(source = "smiles/1f4cc.png")] public var SM_1F4CC:Class;
		[Embed(source = "smiles/1f4cd.png")] public var SM_1F4CD:Class;
		[Embed(source = "smiles/1f4ce.png")] public var SM_1F4CE:Class;
		[Embed(source = "smiles/1f4cf.png")] public var SM_1F4CF:Class;
		[Embed(source = "smiles/1f4d0.png")] public var SM_1F4D0:Class;
		[Embed(source = "smiles/1f4d1.png")] public var SM_1F4D1:Class;
		[Embed(source = "smiles/1f4d2.png")] public var SM_1F4D2:Class;
		[Embed(source = "smiles/1f4d3.png")] public var SM_1F4D3:Class;
		[Embed(source = "smiles/1f4d4.png")] public var SM_1F4D4:Class;
		[Embed(source = "smiles/1f4d5.png")] public var SM_1F4D5:Class;
		[Embed(source = "smiles/1f4d6.png")] public var SM_1F4D6:Class;
		[Embed(source = "smiles/1f4d7.png")] public var SM_1F4D7:Class;
		[Embed(source = "smiles/1f4d8.png")] public var SM_1F4D8:Class;
		[Embed(source = "smiles/1f4d9.png")] public var SM_1F4D9:Class;
		[Embed(source = "smiles/1f4da.png")] public var SM_1F4DA:Class;
		[Embed(source = "smiles/1f4db.png")] public var SM_1F4DB:Class;
		[Embed(source = "smiles/1f4dc.png")] public var SM_1F4DC:Class;
		[Embed(source = "smiles/1f4dd.png")] public var SM_1F4DD:Class;
		[Embed(source = "smiles/1f4de.png")] public var SM_1F4DE:Class;
		[Embed(source = "smiles/1f4df.png")] public var SM_1F4DF:Class;
		[Embed(source = "smiles/1f4e0.png")] public var SM_1F4E0:Class;
		[Embed(source = "smiles/1f4e1.png")] public var SM_1F4E1:Class;
		[Embed(source = "smiles/1f4e2.png")] public var SM_1F4E2:Class;
		[Embed(source = "smiles/1f4e3.png")] public var SM_1F4E3:Class;
		[Embed(source = "smiles/1f4e4.png")] public var SM_1F4E4:Class;
		[Embed(source = "smiles/1f4e5.png")] public var SM_1F4E5:Class;
		[Embed(source = "smiles/1f4e6.png")] public var SM_1F4E6:Class;
		[Embed(source = "smiles/1f4e7.png")] public var SM_1F4E7:Class;
		[Embed(source = "smiles/1f4e8.png")] public var SM_1F4E8:Class;
		[Embed(source = "smiles/1f4e9.png")] public var SM_1F4E9:Class;
		[Embed(source = "smiles/1f4ea.png")] public var SM_1F4EA:Class;
		[Embed(source = "smiles/1f4eb.png")] public var SM_1F4EB:Class;
		[Embed(source = "smiles/1f4ec.png")] public var SM_1F4EC:Class;
		[Embed(source = "smiles/1f4ed.png")] public var SM_1F4ED:Class;
		[Embed(source = "smiles/1f4ee.png")] public var SM_1F4EE:Class;
		[Embed(source = "smiles/1f4ef.png")] public var SM_1F4EF:Class;
		[Embed(source = "smiles/1f4f0.png")] public var SM_1F4F0:Class;
		[Embed(source = "smiles/1f4f1.png")] public var SM_1F4F1:Class;
		[Embed(source = "smiles/1f4f2.png")] public var SM_1F4F2:Class;
		[Embed(source = "smiles/1f4f3.png")] public var SM_1F4F3:Class;
		[Embed(source = "smiles/1f4f4.png")] public var SM_1F4F4:Class;
		[Embed(source = "smiles/1f4f5.png")] public var SM_1F4F5:Class;
		[Embed(source = "smiles/1f4f6.png")] public var SM_1F4F6:Class;
		[Embed(source = "smiles/1f4f7.png")] public var SM_1F4F7:Class;
		[Embed(source = "smiles/1f4f8.png")] public var SM_1F4F8:Class;
		[Embed(source = "smiles/1f4f9.png")] public var SM_1F4F9:Class;
		[Embed(source = "smiles/1f4fa.png")] public var SM_1F4FA:Class;
		[Embed(source = "smiles/1f4fb.png")] public var SM_1F4FB:Class;
		[Embed(source = "smiles/1f4fc.png")] public var SM_1F4FC:Class;
		[Embed(source = "smiles/1f4fd.png")] public var SM_1F4FD:Class;
		[Embed(source = "smiles/1f4ff.png")] public var SM_1F4FF:Class;
		[Embed(source = "smiles/1f500.png")] public var SM_1F500:Class;
		[Embed(source = "smiles/1f501.png")] public var SM_1F501:Class;
		[Embed(source = "smiles/1f502.png")] public var SM_1F502:Class;
		[Embed(source = "smiles/1f503.png")] public var SM_1F503:Class;
		[Embed(source = "smiles/1f504.png")] public var SM_1F504:Class;
		[Embed(source = "smiles/1f505.png")] public var SM_1F505:Class;
		[Embed(source = "smiles/1f506.png")] public var SM_1F506:Class;
		[Embed(source = "smiles/1f507.png")] public var SM_1F507:Class;
		[Embed(source = "smiles/1f508.png")] public var SM_1F508:Class;
		[Embed(source = "smiles/1f509.png")] public var SM_1F509:Class;
		[Embed(source = "smiles/1f50a.png")] public var SM_1F50A:Class;
		[Embed(source = "smiles/1f50b.png")] public var SM_1F50B:Class;
		[Embed(source = "smiles/1f50c.png")] public var SM_1F50C:Class;
		[Embed(source = "smiles/1f50d.png")] public var SM_1F50D:Class;
		[Embed(source = "smiles/1f50e.png")] public var SM_1F50E:Class;
		[Embed(source = "smiles/1f50f.png")] public var SM_1F50F:Class;
		[Embed(source = "smiles/1f510.png")] public var SM_1F510:Class;
		[Embed(source = "smiles/1f511.png")] public var SM_1F511:Class;
		[Embed(source = "smiles/1f512.png")] public var SM_1F512:Class;
		[Embed(source = "smiles/1f513.png")] public var SM_1F513:Class;
		[Embed(source = "smiles/1f514.png")] public var SM_1F514:Class;
		[Embed(source = "smiles/1f515.png")] public var SM_1F515:Class;
		[Embed(source = "smiles/1f516.png")] public var SM_1F516:Class;
		[Embed(source = "smiles/1f517.png")] public var SM_1F517:Class;
		[Embed(source = "smiles/1f518.png")] public var SM_1F518:Class;
		[Embed(source = "smiles/1f519.png")] public var SM_1F519:Class;
		[Embed(source = "smiles/1f51a.png")] public var SM_1F51A:Class;
		[Embed(source = "smiles/1f51b.png")] public var SM_1F51B:Class;
		[Embed(source = "smiles/1f51c.png")] public var SM_1F51C:Class;
		[Embed(source = "smiles/1f51d.png")] public var SM_1F51D:Class;
		[Embed(source = "smiles/1f51e.png")] public var SM_1F51E:Class;
		[Embed(source = "smiles/1f51f.png")] public var SM_1F51F:Class;
		[Embed(source = "smiles/1f520.png")] public var SM_1F520:Class;
		[Embed(source = "smiles/1f521.png")] public var SM_1F521:Class;
		[Embed(source = "smiles/1f522.png")] public var SM_1F522:Class;
		[Embed(source = "smiles/1f523.png")] public var SM_1F523:Class;
		[Embed(source = "smiles/1f524.png")] public var SM_1F524:Class;
		[Embed(source = "smiles/1f525.png")] public var SM_1F525:Class;
		[Embed(source = "smiles/1f526.png")] public var SM_1F526:Class;
		[Embed(source = "smiles/1f527.png")] public var SM_1F527:Class;
		[Embed(source = "smiles/1f528.png")] public var SM_1F528:Class;
		[Embed(source = "smiles/1f529.png")] public var SM_1F529:Class;
		[Embed(source = "smiles/1f52a.png")] public var SM_1F52A:Class;
		[Embed(source = "smiles/1f52b.png")] public var SM_1F52B:Class;
		[Embed(source = "smiles/1f52c.png")] public var SM_1F52C:Class;
		[Embed(source = "smiles/1f52d.png")] public var SM_1F52D:Class;
		[Embed(source = "smiles/1f52e.png")] public var SM_1F52E:Class;
		[Embed(source = "smiles/1f52f.png")] public var SM_1F52F:Class;
		[Embed(source = "smiles/1f530.png")] public var SM_1F530:Class;
		[Embed(source = "smiles/1f531.png")] public var SM_1F531:Class;
		[Embed(source = "smiles/1f532.png")] public var SM_1F532:Class;
		[Embed(source = "smiles/1f533.png")] public var SM_1F533:Class;
		[Embed(source = "smiles/1f534.png")] public var SM_1F534:Class;
		[Embed(source = "smiles/1f535.png")] public var SM_1F535:Class;
		[Embed(source = "smiles/1f536.png")] public var SM_1F536:Class;
		[Embed(source = "smiles/1f537.png")] public var SM_1F537:Class;
		[Embed(source = "smiles/1f538.png")] public var SM_1F538:Class;
		[Embed(source = "smiles/1f539.png")] public var SM_1F539:Class;
		[Embed(source = "smiles/1f53a.png")] public var SM_1F53A:Class;
		[Embed(source = "smiles/1f53b.png")] public var SM_1F53B:Class;
		[Embed(source = "smiles/1f53c.png")] public var SM_1F53C:Class;
		[Embed(source = "smiles/1f53d.png")] public var SM_1F53D:Class;
		[Embed(source = "smiles/1f549.png")] public var SM_1F549:Class;
		[Embed(source = "smiles/1f54a.png")] public var SM_1F54A:Class;
		[Embed(source = "smiles/1f54b.png")] public var SM_1F54B:Class;
		[Embed(source = "smiles/1f54c.png")] public var SM_1F54C:Class;
		[Embed(source = "smiles/1f54d.png")] public var SM_1F54D:Class;
		[Embed(source = "smiles/1f54e.png")] public var SM_1F54E:Class;
		[Embed(source = "smiles/1f550.png")] public var SM_1F550:Class;
		[Embed(source = "smiles/1f551.png")] public var SM_1F551:Class;
		[Embed(source = "smiles/1f552.png")] public var SM_1F552:Class;
		[Embed(source = "smiles/1f553.png")] public var SM_1F553:Class;
		[Embed(source = "smiles/1f554.png")] public var SM_1F554:Class;
		[Embed(source = "smiles/1f555.png")] public var SM_1F555:Class;
		[Embed(source = "smiles/1f556.png")] public var SM_1F556:Class;
		[Embed(source = "smiles/1f557.png")] public var SM_1F557:Class;
		[Embed(source = "smiles/1f558.png")] public var SM_1F558:Class;
		[Embed(source = "smiles/1f559.png")] public var SM_1F559:Class;
		[Embed(source = "smiles/1f55a.png")] public var SM_1F55A:Class;
		[Embed(source = "smiles/1f55b.png")] public var SM_1F55B:Class;
		[Embed(source = "smiles/1f55c.png")] public var SM_1F55C:Class;
		[Embed(source = "smiles/1f55d.png")] public var SM_1F55D:Class;
		[Embed(source = "smiles/1f55e.png")] public var SM_1F55E:Class;
		[Embed(source = "smiles/1f55f.png")] public var SM_1F55F:Class;
		[Embed(source = "smiles/1f560.png")] public var SM_1F560:Class;
		[Embed(source = "smiles/1f561.png")] public var SM_1F561:Class;
		[Embed(source = "smiles/1f562.png")] public var SM_1F562:Class;
		[Embed(source = "smiles/1f563.png")] public var SM_1F563:Class;
		[Embed(source = "smiles/1f564.png")] public var SM_1F564:Class;
		[Embed(source = "smiles/1f565.png")] public var SM_1F565:Class;
		[Embed(source = "smiles/1f566.png")] public var SM_1F566:Class;
		[Embed(source = "smiles/1f567.png")] public var SM_1F567:Class;
		[Embed(source = "smiles/1f56f.png")] public var SM_1F56F:Class;
		[Embed(source = "smiles/1f570.png")] public var SM_1F570:Class;
		[Embed(source = "smiles/1f573.png")] public var SM_1F573:Class;
		[Embed(source = "smiles/1f574.png")] public var SM_1F574:Class;
		[Embed(source = "smiles/1f575.png")] public var SM_1F575:Class;
		[Embed(source = "smiles/1f576.png")] public var SM_1F576:Class;
		[Embed(source = "smiles/1f577.png")] public var SM_1F577:Class;
		[Embed(source = "smiles/1f578.png")] public var SM_1F578:Class;
		[Embed(source = "smiles/1f579.png")] public var SM_1F579:Class;
		[Embed(source = "smiles/1f587.png")] public var SM_1F587:Class;
		[Embed(source = "smiles/1f58a.png")] public var SM_1F58A:Class;
		[Embed(source = "smiles/1f58b.png")] public var SM_1F58B:Class;
		[Embed(source = "smiles/1f58c.png")] public var SM_1F58C:Class;
		[Embed(source = "smiles/1f58d.png")] public var SM_1F58D:Class;
		[Embed(source = "smiles/1f590.png")] public var SM_1F590:Class;
		[Embed(source = "smiles/1f595.png")] public var SM_1F595:Class;
		[Embed(source = "smiles/1f596.png")] public var SM_1F596:Class;
		[Embed(source = "smiles/1f5a5.png")] public var SM_1F5A5:Class;
		[Embed(source = "smiles/1f5a8.png")] public var SM_1F5A8:Class;
		[Embed(source = "smiles/1f5b1.png")] public var SM_1F5B1:Class;
		[Embed(source = "smiles/1f5b2.png")] public var SM_1F5B2:Class;
		[Embed(source = "smiles/1f5bc.png")] public var SM_1F5BC:Class;
		[Embed(source = "smiles/1f5c2.png")] public var SM_1F5C2:Class;
		[Embed(source = "smiles/1f5c3.png")] public var SM_1F5C3:Class;
		[Embed(source = "smiles/1f5c4.png")] public var SM_1F5C4:Class;
		[Embed(source = "smiles/1f5d1.png")] public var SM_1F5D1:Class;
		[Embed(source = "smiles/1f5d2.png")] public var SM_1F5D2:Class;
		[Embed(source = "smiles/1f5d3.png")] public var SM_1F5D3:Class;
		[Embed(source = "smiles/1f5dc.png")] public var SM_1F5DC:Class;
		[Embed(source = "smiles/1f5dd.png")] public var SM_1F5DD:Class;
		[Embed(source = "smiles/1f5de.png")] public var SM_1F5DE:Class;
		[Embed(source = "smiles/1f5e1.png")] public var SM_1F5E1:Class;
		[Embed(source = "smiles/1f5e3.png")] public var SM_1F5E3:Class;
		[Embed(source = "smiles/1f5e8.png")] public var SM_1F5E8:Class;
		[Embed(source = "smiles/1f5ef.png")] public var SM_1F5EF:Class;
		[Embed(source = "smiles/1f5f3.png")] public var SM_1F5F3:Class;
		[Embed(source = "smiles/1f5fa.png")] public var SM_1F5FA:Class;
		[Embed(source = "smiles/1f5fb.png")] public var SM_1F5FB:Class;
		[Embed(source = "smiles/1f5fc.png")] public var SM_1F5FC:Class;
		[Embed(source = "smiles/1f5fd.png")] public var SM_1F5FD:Class;
		[Embed(source = "smiles/1f5fe.png")] public var SM_1F5FE:Class;
		[Embed(source = "smiles/1f5ff.png")] public var SM_1F5FF:Class;
		[Embed(source = "smiles/1f600.png")] public var SM_1F600:Class;
		[Embed(source = "smiles/1f601.png")] public var SM_1F601:Class;
		[Embed(source = "smiles/1f602.png")] public var SM_1F602:Class;
		[Embed(source = "smiles/1f603.png")] public var SM_1F603:Class;
		[Embed(source = "smiles/1f604.png")] public var SM_1F604:Class;
		[Embed(source = "smiles/1f605.png")] public var SM_1F605:Class;
		[Embed(source = "smiles/1f606.png")] public var SM_1F606:Class;
		[Embed(source = "smiles/1f607.png")] public var SM_1F607:Class;
		[Embed(source = "smiles/1f608.png")] public var SM_1F608:Class;
		[Embed(source = "smiles/1f609.png")] public var SM_1F609:Class;
		[Embed(source = "smiles/1f60a.png")] public var SM_1F60A:Class;
		[Embed(source = "smiles/1f60b.png")] public var SM_1F60B:Class;
		[Embed(source = "smiles/1f60c.png")] public var SM_1F60C:Class;
		[Embed(source = "smiles/1f60d.png")] public var SM_1F60D:Class;
		[Embed(source = "smiles/1f60e.png")] public var SM_1F60E:Class;
		[Embed(source = "smiles/1f60f.png")] public var SM_1F60F:Class;
		[Embed(source = "smiles/1f610.png")] public var SM_1F610:Class;
		[Embed(source = "smiles/1f611.png")] public var SM_1F611:Class;
		[Embed(source = "smiles/1f612.png")] public var SM_1F612:Class;
		[Embed(source = "smiles/1f613.png")] public var SM_1F613:Class;
		[Embed(source = "smiles/1f614.png")] public var SM_1F614:Class;
		[Embed(source = "smiles/1f615.png")] public var SM_1F615:Class;
		[Embed(source = "smiles/1f616.png")] public var SM_1F616:Class;
		[Embed(source = "smiles/1f617.png")] public var SM_1F617:Class;
		[Embed(source = "smiles/1f618.png")] public var SM_1F618:Class;
		[Embed(source = "smiles/1f619.png")] public var SM_1F619:Class;
		[Embed(source = "smiles/1f61a.png")] public var SM_1F61A:Class;
		[Embed(source = "smiles/1f61b.png")] public var SM_1F61B:Class;
		[Embed(source = "smiles/1f61c.png")] public var SM_1F61C:Class;
		[Embed(source = "smiles/1f61d.png")] public var SM_1F61D:Class;
		[Embed(source = "smiles/1f61e.png")] public var SM_1F61E:Class;
		[Embed(source = "smiles/1f61f.png")] public var SM_1F61F:Class;
		[Embed(source = "smiles/1f620.png")] public var SM_1F620:Class;
		[Embed(source = "smiles/1f621.png")] public var SM_1F621:Class;
		[Embed(source = "smiles/1f622.png")] public var SM_1F622:Class;
		[Embed(source = "smiles/1f623.png")] public var SM_1F623:Class;
		[Embed(source = "smiles/1f624.png")] public var SM_1F624:Class;
		[Embed(source = "smiles/1f625.png")] public var SM_1F625:Class;
		[Embed(source = "smiles/1f626.png")] public var SM_1F626:Class;
		[Embed(source = "smiles/1f627.png")] public var SM_1F627:Class;
		[Embed(source = "smiles/1f628.png")] public var SM_1F628:Class;
		[Embed(source = "smiles/1f629.png")] public var SM_1F629:Class;
		[Embed(source = "smiles/1f62a.png")] public var SM_1F62A:Class;
		[Embed(source = "smiles/1f62b.png")] public var SM_1F62B:Class;
		[Embed(source = "smiles/1f62c.png")] public var SM_1F62C:Class;
		[Embed(source = "smiles/1f62d.png")] public var SM_1F62D:Class;
		[Embed(source = "smiles/1f62e.png")] public var SM_1F62E:Class;
		[Embed(source = "smiles/1f62f.png")] public var SM_1F62F:Class;
		[Embed(source = "smiles/1f630.png")] public var SM_1F630:Class;
		[Embed(source = "smiles/1f631.png")] public var SM_1F631:Class;
		[Embed(source = "smiles/1f632.png")] public var SM_1F632:Class;
		[Embed(source = "smiles/1f633.png")] public var SM_1F633:Class;
		[Embed(source = "smiles/1f634.png")] public var SM_1F634:Class;
		[Embed(source = "smiles/1f635.png")] public var SM_1F635:Class;
		[Embed(source = "smiles/1f636.png")] public var SM_1F636:Class;
		[Embed(source = "smiles/1f637.png")] public var SM_1F637:Class;
		[Embed(source = "smiles/1f638.png")] public var SM_1F638:Class;
		[Embed(source = "smiles/1f639.png")] public var SM_1F639:Class;
		[Embed(source = "smiles/1f63a.png")] public var SM_1F63A:Class;
		[Embed(source = "smiles/1f63b.png")] public var SM_1F63B:Class;
		[Embed(source = "smiles/1f63c.png")] public var SM_1F63C:Class;
		[Embed(source = "smiles/1f63d.png")] public var SM_1F63D:Class;
		[Embed(source = "smiles/1f63e.png")] public var SM_1F63E:Class;
		[Embed(source = "smiles/1f63f.png")] public var SM_1F63F:Class;
		[Embed(source = "smiles/1f640.png")] public var SM_1F640:Class;
		[Embed(source = "smiles/1f641.png")] public var SM_1F641:Class;
		[Embed(source = "smiles/1f642.png")] public var SM_1F642:Class;
		[Embed(source = "smiles/1f643.png")] public var SM_1F643:Class;
		[Embed(source = "smiles/1f644.png")] public var SM_1F644:Class;
		[Embed(source = "smiles/1f645.png")] public var SM_1F645:Class;
		[Embed(source = "smiles/1f646.png")] public var SM_1F646:Class;
		[Embed(source = "smiles/1f647.png")] public var SM_1F647:Class;
		[Embed(source = "smiles/1f648.png")] public var SM_1F648:Class;
		[Embed(source = "smiles/1f649.png")] public var SM_1F649:Class;
		[Embed(source = "smiles/1f64a.png")] public var SM_1F64A:Class;
		[Embed(source = "smiles/1f64b.png")] public var SM_1F64B:Class;
		[Embed(source = "smiles/1f64c.png")] public var SM_1F64C:Class;
		[Embed(source = "smiles/1f64d.png")] public var SM_1F64D:Class;
		[Embed(source = "smiles/1f64e.png")] public var SM_1F64E:Class;
		[Embed(source = "smiles/1f64f.png")] public var SM_1F64F:Class;
		[Embed(source = "smiles/1f680.png")] public var SM_1F680:Class;
		[Embed(source = "smiles/1f681.png")] public var SM_1F681:Class;
		[Embed(source = "smiles/1f682.png")] public var SM_1F682:Class;
		[Embed(source = "smiles/1f683.png")] public var SM_1F683:Class;
		[Embed(source = "smiles/1f684.png")] public var SM_1F684:Class;
		[Embed(source = "smiles/1f685.png")] public var SM_1F685:Class;
		[Embed(source = "smiles/1f686.png")] public var SM_1F686:Class;
		[Embed(source = "smiles/1f687.png")] public var SM_1F687:Class;
		[Embed(source = "smiles/1f688.png")] public var SM_1F688:Class;
		[Embed(source = "smiles/1f689.png")] public var SM_1F689:Class;
		[Embed(source = "smiles/1f68a.png")] public var SM_1F68A:Class;
		[Embed(source = "smiles/1f68b.png")] public var SM_1F68B:Class;
		[Embed(source = "smiles/1f68c.png")] public var SM_1F68C:Class;
		[Embed(source = "smiles/1f68d.png")] public var SM_1F68D:Class;
		[Embed(source = "smiles/1f68e.png")] public var SM_1F68E:Class;
		[Embed(source = "smiles/1f68f.png")] public var SM_1F68F:Class;
		[Embed(source = "smiles/1f690.png")] public var SM_1F690:Class;
		[Embed(source = "smiles/1f691.png")] public var SM_1F691:Class;
		[Embed(source = "smiles/1f692.png")] public var SM_1F692:Class;
		[Embed(source = "smiles/1f693.png")] public var SM_1F693:Class;
		[Embed(source = "smiles/1f694.png")] public var SM_1F694:Class;
		[Embed(source = "smiles/1f695.png")] public var SM_1F695:Class;
		[Embed(source = "smiles/1f696.png")] public var SM_1F696:Class;
		[Embed(source = "smiles/1f697.png")] public var SM_1F697:Class;
		[Embed(source = "smiles/1f698.png")] public var SM_1F698:Class;
		[Embed(source = "smiles/1f699.png")] public var SM_1F699:Class;
		[Embed(source = "smiles/1f69a.png")] public var SM_1F69A:Class;
		[Embed(source = "smiles/1f69b.png")] public var SM_1F69B:Class;
		[Embed(source = "smiles/1f69c.png")] public var SM_1F69C:Class;
		[Embed(source = "smiles/1f69d.png")] public var SM_1F69D:Class;
		[Embed(source = "smiles/1f69e.png")] public var SM_1F69E:Class;
		[Embed(source = "smiles/1f69f.png")] public var SM_1F69F:Class;
		[Embed(source = "smiles/1f6a0.png")] public var SM_1F6A0:Class;
		[Embed(source = "smiles/1f6a1.png")] public var SM_1F6A1:Class;
		[Embed(source = "smiles/1f6a2.png")] public var SM_1F6A2:Class;
		[Embed(source = "smiles/1f6a3.png")] public var SM_1F6A3:Class;
		[Embed(source = "smiles/1f6a4.png")] public var SM_1F6A4:Class;
		[Embed(source = "smiles/1f6a5.png")] public var SM_1F6A5:Class;
		[Embed(source = "smiles/1f6a6.png")] public var SM_1F6A6:Class;
		[Embed(source = "smiles/1f6a7.png")] public var SM_1F6A7:Class;
		[Embed(source = "smiles/1f6a8.png")] public var SM_1F6A8:Class;
		[Embed(source = "smiles/1f6a9.png")] public var SM_1F6A9:Class;
		[Embed(source = "smiles/1f6aa.png")] public var SM_1F6AA:Class;
		[Embed(source = "smiles/1f6ab.png")] public var SM_1F6AB:Class;
		[Embed(source = "smiles/1f6ac.png")] public var SM_1F6AC:Class;
		[Embed(source = "smiles/1f6ad.png")] public var SM_1F6AD:Class;
		[Embed(source = "smiles/1f6ae.png")] public var SM_1F6AE:Class;
		[Embed(source = "smiles/1f6af.png")] public var SM_1F6AF:Class;
		[Embed(source = "smiles/1f6b0.png")] public var SM_1F6B0:Class;
		[Embed(source = "smiles/1f6b1.png")] public var SM_1F6B1:Class;
		[Embed(source = "smiles/1f6b2.png")] public var SM_1F6B2:Class;
		[Embed(source = "smiles/1f6b3.png")] public var SM_1F6B3:Class;
		[Embed(source = "smiles/1f6b4.png")] public var SM_1F6B4:Class;
		[Embed(source = "smiles/1f6b5.png")] public var SM_1F6B5:Class;
		[Embed(source = "smiles/1f6b6.png")] public var SM_1F6B6:Class;
		[Embed(source = "smiles/1f6b7.png")] public var SM_1F6B7:Class;
		[Embed(source = "smiles/1f6b8.png")] public var SM_1F6B8:Class;
		[Embed(source = "smiles/1f6b9.png")] public var SM_1F6B9:Class;
		[Embed(source = "smiles/1f6ba.png")] public var SM_1F6BA:Class;
		[Embed(source = "smiles/1f6bb.png")] public var SM_1F6BB:Class;
		[Embed(source = "smiles/1f6bc.png")] public var SM_1F6BC:Class;
		[Embed(source = "smiles/1f6bd.png")] public var SM_1F6BD:Class;
		[Embed(source = "smiles/1f6be.png")] public var SM_1F6BE:Class;
		[Embed(source = "smiles/1f6bf.png")] public var SM_1F6BF:Class;
		[Embed(source = "smiles/1f6c0.png")] public var SM_1F6C0:Class;
		[Embed(source = "smiles/1f6c1.png")] public var SM_1F6C1:Class;
		[Embed(source = "smiles/1f6c2.png")] public var SM_1F6C2:Class;
		[Embed(source = "smiles/1f6c3.png")] public var SM_1F6C3:Class;
		[Embed(source = "smiles/1f6c4.png")] public var SM_1F6C4:Class;
		[Embed(source = "smiles/1f6c5.png")] public var SM_1F6C5:Class;
		[Embed(source = "smiles/1f6cb.png")] public var SM_1F6CB:Class;
		[Embed(source = "smiles/1f6cc.png")] public var SM_1F6CC:Class;
		[Embed(source = "smiles/1f6cd.png")] public var SM_1F6CD:Class;
		[Embed(source = "smiles/1f6ce.png")] public var SM_1F6CE:Class;
		[Embed(source = "smiles/1f6cf.png")] public var SM_1F6CF:Class;
		[Embed(source = "smiles/1f6d0.png")] public var SM_1F6D0:Class;
		[Embed(source = "smiles/1f6e0.png")] public var SM_1F6E0:Class;
		[Embed(source = "smiles/1f6e1.png")] public var SM_1F6E1:Class;
		[Embed(source = "smiles/1f6e2.png")] public var SM_1F6E2:Class;
		[Embed(source = "smiles/1f6e3.png")] public var SM_1F6E3:Class;
		[Embed(source = "smiles/1f6e4.png")] public var SM_1F6E4:Class;
		[Embed(source = "smiles/1f6e5.png")] public var SM_1F6E5:Class;
		[Embed(source = "smiles/1f6e9.png")] public var SM_1F6E9:Class;
		[Embed(source = "smiles/1f6eb.png")] public var SM_1F6EB:Class;
		[Embed(source = "smiles/1f6ec.png")] public var SM_1F6EC:Class;
		[Embed(source = "smiles/1f6f0.png")] public var SM_1F6F0:Class;
		[Embed(source = "smiles/1f6f3.png")] public var SM_1F6F3:Class;
		[Embed(source = "smiles/1f910.png")] public var SM_1F910:Class;
		[Embed(source = "smiles/1f911.png")] public var SM_1F911:Class;
		[Embed(source = "smiles/1f912.png")] public var SM_1F912:Class;
		[Embed(source = "smiles/1f913.png")] public var SM_1F913:Class;
		[Embed(source = "smiles/1f914.png")] public var SM_1F914:Class;
		[Embed(source = "smiles/1f915.png")] public var SM_1F915:Class;
		[Embed(source = "smiles/1f916.png")] public var SM_1F916:Class;
		[Embed(source = "smiles/1f917.png")] public var SM_1F917:Class;
		[Embed(source = "smiles/1f918.png")] public var SM_1F918:Class;
		[Embed(source = "smiles/1f980.png")] public var SM_1F980:Class;
		[Embed(source = "smiles/1f981.png")] public var SM_1F981:Class;
		[Embed(source = "smiles/1f982.png")] public var SM_1F982:Class;
		[Embed(source = "smiles/1f983.png")] public var SM_1F983:Class;
		[Embed(source = "smiles/1f984.png")] public var SM_1F984:Class;
		[Embed(source = "smiles/1f9c0.png")] public var SM_1F9C0:Class;
		[Embed(source = "smiles/203c.png")] public var SM_203C:Class;
		[Embed(source = "smiles/2049.png")] public var SM_2049:Class;
		[Embed(source = "smiles/2122.png")] public var SM_2122:Class;
		[Embed(source = "smiles/2139.png")] public var SM_2139:Class;
		[Embed(source = "smiles/2194.png")] public var SM_2194:Class;
		[Embed(source = "smiles/2195.png")] public var SM_2195:Class;
		[Embed(source = "smiles/2196.png")] public var SM_2196:Class;
		[Embed(source = "smiles/2197.png")] public var SM_2197:Class;
		[Embed(source = "smiles/2198.png")] public var SM_2198:Class;
		[Embed(source = "smiles/2199.png")] public var SM_2199:Class;
		[Embed(source = "smiles/21a9.png")] public var SM_21A9:Class;
		[Embed(source = "smiles/21aa.png")] public var SM_21AA:Class;
		[Embed(source = "smiles/231a.png")] public var SM_231A:Class;
		[Embed(source = "smiles/231b.png")] public var SM_231B:Class;
		[Embed(source = "smiles/2328.png")] public var SM_2328:Class;
		[Embed(source = "smiles/23e9.png")] public var SM_23E9:Class;
		[Embed(source = "smiles/23ea.png")] public var SM_23EA:Class;
		[Embed(source = "smiles/23eb.png")] public var SM_23EB:Class;
		[Embed(source = "smiles/23ec.png")] public var SM_23EC:Class;
		[Embed(source = "smiles/23ed.png")] public var SM_23ED:Class;
		[Embed(source = "smiles/23ee.png")] public var SM_23EE:Class;
		[Embed(source = "smiles/23ef.png")] public var SM_23EF:Class;
		[Embed(source = "smiles/23f0.png")] public var SM_23F0:Class;
		[Embed(source = "smiles/23f1.png")] public var SM_23F1:Class;
		[Embed(source = "smiles/23f2.png")] public var SM_23F2:Class;
		[Embed(source = "smiles/23f3.png")] public var SM_23F3:Class;
		[Embed(source = "smiles/23f8.png")] public var SM_23F8:Class;
		[Embed(source = "smiles/23f9.png")] public var SM_23F9:Class;
		[Embed(source = "smiles/23fa.png")] public var SM_23FA:Class;
		[Embed(source = "smiles/24c2.png")] public var SM_24C2:Class;
		[Embed(source = "smiles/25aa.png")] public var SM_25AA:Class;
		[Embed(source = "smiles/25ab.png")] public var SM_25AB:Class;
		[Embed(source = "smiles/25b6.png")] public var SM_25B6:Class;
		[Embed(source = "smiles/25c0.png")] public var SM_25C0:Class;
		[Embed(source = "smiles/25fb.png")] public var SM_25FB:Class;
		[Embed(source = "smiles/25fc.png")] public var SM_25FC:Class;
		[Embed(source = "smiles/25fd.png")] public var SM_25FD:Class;
		[Embed(source = "smiles/25fe.png")] public var SM_25FE:Class;
		[Embed(source = "smiles/2600.png")] public var SM_2600:Class;
		[Embed(source = "smiles/2601.png")] public var SM_2601:Class;
		[Embed(source = "smiles/2602.png")] public var SM_2602:Class;
		[Embed(source = "smiles/2603.png")] public var SM_2603:Class;
		[Embed(source = "smiles/2604.png")] public var SM_2604:Class;
		[Embed(source = "smiles/260e.png")] public var SM_260E:Class;
		[Embed(source = "smiles/2611.png")] public var SM_2611:Class;
		[Embed(source = "smiles/2614.png")] public var SM_2614:Class;
		[Embed(source = "smiles/2615.png")] public var SM_2615:Class;
		[Embed(source = "smiles/2618.png")] public var SM_2618:Class;
		[Embed(source = "smiles/261d.png")] public var SM_261D:Class;
		[Embed(source = "smiles/2620.png")] public var SM_2620:Class;
		[Embed(source = "smiles/2622.png")] public var SM_2622:Class;
		[Embed(source = "smiles/2623.png")] public var SM_2623:Class;
		[Embed(source = "smiles/2626.png")] public var SM_2626:Class;
		[Embed(source = "smiles/262a.png")] public var SM_262A:Class;
		[Embed(source = "smiles/262e.png")] public var SM_262E:Class;
		[Embed(source = "smiles/262f.png")] public var SM_262F:Class;
		[Embed(source = "smiles/2638.png")] public var SM_2638:Class;
		[Embed(source = "smiles/2639.png")] public var SM_2639:Class;
		[Embed(source = "smiles/263a.png")] public var SM_263A:Class;
		[Embed(source = "smiles/2648.png")] public var SM_2648:Class;
		[Embed(source = "smiles/2649.png")] public var SM_2649:Class;
		[Embed(source = "smiles/264a.png")] public var SM_264A:Class;
		[Embed(source = "smiles/264b.png")] public var SM_264B:Class;
		[Embed(source = "smiles/264c.png")] public var SM_264C:Class;
		[Embed(source = "smiles/264d.png")] public var SM_264D:Class;
		[Embed(source = "smiles/264e.png")] public var SM_264E:Class;
		[Embed(source = "smiles/264f.png")] public var SM_264F:Class;
		[Embed(source = "smiles/2650.png")] public var SM_2650:Class;
		[Embed(source = "smiles/2651.png")] public var SM_2651:Class;
		[Embed(source = "smiles/2652.png")] public var SM_2652:Class;
		[Embed(source = "smiles/2653.png")] public var SM_2653:Class;
		[Embed(source = "smiles/2660.png")] public var SM_2660:Class;
		[Embed(source = "smiles/2663.png")] public var SM_2663:Class;
		[Embed(source = "smiles/2665.png")] public var SM_2665:Class;
		[Embed(source = "smiles/2666.png")] public var SM_2666:Class;
		[Embed(source = "smiles/2668.png")] public var SM_2668:Class;
		[Embed(source = "smiles/267b.png")] public var SM_267B:Class;
		[Embed(source = "smiles/267f.png")] public var SM_267F:Class;
		[Embed(source = "smiles/2692.png")] public var SM_2692:Class;
		[Embed(source = "smiles/2693.png")] public var SM_2693:Class;
		[Embed(source = "smiles/2694.png")] public var SM_2694:Class;
		[Embed(source = "smiles/2696.png")] public var SM_2696:Class;
		[Embed(source = "smiles/2697.png")] public var SM_2697:Class;
		[Embed(source = "smiles/2699.png")] public var SM_2699:Class;
		[Embed(source = "smiles/269b.png")] public var SM_269B:Class;
		[Embed(source = "smiles/269c.png")] public var SM_269C:Class;
		[Embed(source = "smiles/26a0.png")] public var SM_26A0:Class;
		[Embed(source = "smiles/26a1.png")] public var SM_26A1:Class;
		[Embed(source = "smiles/26aa.png")] public var SM_26AA:Class;
		[Embed(source = "smiles/26ab.png")] public var SM_26AB:Class;
		[Embed(source = "smiles/26b0.png")] public var SM_26B0:Class;
		[Embed(source = "smiles/26b1.png")] public var SM_26B1:Class;
		[Embed(source = "smiles/26bd.png")] public var SM_26BD:Class;
		[Embed(source = "smiles/26be.png")] public var SM_26BE:Class;
		[Embed(source = "smiles/26c4.png")] public var SM_26C4:Class;
		[Embed(source = "smiles/26c5.png")] public var SM_26C5:Class;
		[Embed(source = "smiles/26c8.png")] public var SM_26C8:Class;
		[Embed(source = "smiles/26ce.png")] public var SM_26CE:Class;
		[Embed(source = "smiles/26cf.png")] public var SM_26CF:Class;
		[Embed(source = "smiles/26d1.png")] public var SM_26D1:Class;
		[Embed(source = "smiles/26d3.png")] public var SM_26D3:Class;
		[Embed(source = "smiles/26d4.png")] public var SM_26D4:Class;
		[Embed(source = "smiles/26e9.png")] public var SM_26E9:Class;
		[Embed(source = "smiles/26ea.png")] public var SM_26EA:Class;
		[Embed(source = "smiles/26f0.png")] public var SM_26F0:Class;
		[Embed(source = "smiles/26f1.png")] public var SM_26F1:Class;
		[Embed(source = "smiles/26f2.png")] public var SM_26F2:Class;
		[Embed(source = "smiles/26f3.png")] public var SM_26F3:Class;
		[Embed(source = "smiles/26f4.png")] public var SM_26F4:Class;
		[Embed(source = "smiles/26f5.png")] public var SM_26F5:Class;
		[Embed(source = "smiles/26f7.png")] public var SM_26F7:Class;
		[Embed(source = "smiles/26f8.png")] public var SM_26F8:Class;
		[Embed(source = "smiles/26f9.png")] public var SM_26F9:Class;
		[Embed(source = "smiles/26fa.png")] public var SM_26FA:Class;
		[Embed(source = "smiles/26fd.png")] public var SM_26FD:Class;
		[Embed(source = "smiles/2702.png")] public var SM_2702:Class;
		[Embed(source = "smiles/2705.png")] public var SM_2705:Class;
		[Embed(source = "smiles/2708.png")] public var SM_2708:Class;
		[Embed(source = "smiles/2709.png")] public var SM_2709:Class;
		[Embed(source = "smiles/270a.png")] public var SM_270A:Class;
		[Embed(source = "smiles/270b.png")] public var SM_270B:Class;
		[Embed(source = "smiles/270c.png")] public var SM_270C:Class;
		[Embed(source = "smiles/270d.png")] public var SM_270D:Class;
		[Embed(source = "smiles/270f.png")] public var SM_270F:Class;
		[Embed(source = "smiles/2712.png")] public var SM_2712:Class;
		[Embed(source = "smiles/2714.png")] public var SM_2714:Class;
		[Embed(source = "smiles/2716.png")] public var SM_2716:Class;
		[Embed(source = "smiles/271d.png")] public var SM_271D:Class;
		[Embed(source = "smiles/2721.png")] public var SM_2721:Class;
		[Embed(source = "smiles/2728.png")] public var SM_2728:Class;
		[Embed(source = "smiles/2733.png")] public var SM_2733:Class;
		[Embed(source = "smiles/2734.png")] public var SM_2734:Class;
		[Embed(source = "smiles/2744.png")] public var SM_2744:Class;
		[Embed(source = "smiles/2747.png")] public var SM_2747:Class;
		[Embed(source = "smiles/274c.png")] public var SM_274C:Class;
		[Embed(source = "smiles/274e.png")] public var SM_274E:Class;
		[Embed(source = "smiles/2753.png")] public var SM_2753:Class;
		[Embed(source = "smiles/2754.png")] public var SM_2754:Class;
		[Embed(source = "smiles/2755.png")] public var SM_2755:Class;
		[Embed(source = "smiles/2757.png")] public var SM_2757:Class;
		[Embed(source = "smiles/2763.png")] public var SM_2763:Class;
		[Embed(source = "smiles/2764.png")] public var SM_2764:Class;
		[Embed(source = "smiles/2795.png")] public var SM_2795:Class;
		[Embed(source = "smiles/2796.png")] public var SM_2796:Class;
		[Embed(source = "smiles/2797.png")] public var SM_2797:Class;
		[Embed(source = "smiles/27a1.png")] public var SM_27A1:Class;
		[Embed(source = "smiles/27b0.png")] public var SM_27B0:Class;
		[Embed(source = "smiles/27bf.png")] public var SM_27BF:Class;
		[Embed(source = "smiles/2934.png")] public var SM_2934:Class;
		[Embed(source = "smiles/2935.png")] public var SM_2935:Class;
		[Embed(source = "smiles/2b05.png")] public var SM_2B05:Class;
		[Embed(source = "smiles/2b06.png")] public var SM_2B06:Class;
		[Embed(source = "smiles/2b07.png")] public var SM_2B07:Class;
		[Embed(source = "smiles/2b1b.png")] public var SM_2B1B:Class;
		[Embed(source = "smiles/2b1c.png")] public var SM_2B1C:Class;
		[Embed(source = "smiles/2b50.png")] public var SM_2B50:Class;
		[Embed(source = "smiles/2b55.png")] public var SM_2B55:Class;
		[Embed(source = "smiles/3030.png")] public var SM_3030:Class;
		[Embed(source = "smiles/303d.png")] public var SM_303D:Class;
		[Embed(source = "smiles/3297.png")] public var SM_3297:Class;
		[Embed(source = "smiles/3299.png")] public var SM_3299:Class;
		[Embed(source = "smiles/a9.png")] public var SM_A9:Class;
		[Embed(source = "smiles/ae.png")] public var SM_AE:Class;
		/*[Embed(source = "smiles/2a-20e3.png")] public var SM_2A-20E3:Class;
		[Embed(source = "smiles/30-20e3.png")] public var SM_30-20E3:Class;
		[Embed(source = "smiles/33-20e3.png")] public var SM_33-20E3:Class;
		[Embed(source = "smiles/34-20e3.png")] public var SM_34-20E3:Class;
		[Embed(source = "smiles/35-20e3.png")] public var SM_35-20E3:Class;
		[Embed(source = "smiles/36-20e3.png")] public var SM_36-20E3:Class;
		[Embed(source = "smiles/37-20e3.png")] public var SM_37-20E3:Class;
		[Embed(source = "smiles/38-20e3.png")] public var SM_38-20E3:Class;
		[Embed(source = "smiles/39-20e3.png")] public var SM_39-20E3:Class;
		[Embed(source = "smiles/31-20e3.png")] public var SM_31-20E3:Class;
		[Embed(source = "smiles/32-20e3.png")] public var SM_32-20E3:Class;
		[Embed(source = "smiles/26f9-1f3fb.png")] public var SM_26F9-1F3FB:Class;
		[Embed(source = "smiles/26f9-1f3fc.png")] public var SM_26F9-1F3FC:Class;
		[Embed(source = "smiles/26f9-1f3fd.png")] public var SM_26F9-1F3FD:Class;
		[Embed(source = "smiles/26f9-1f3fe.png")] public var SM_26F9-1F3FE:Class;
		[Embed(source = "smiles/26f9-1f3ff.png")] public var SM_26F9-1F3FF:Class;
		[Embed(source = "smiles/270a-1f3fb.png")] public var SM_270A-1F3FB:Class;
		[Embed(source = "smiles/270a-1f3fc.png")] public var SM_270A-1F3FC:Class;
		[Embed(source = "smiles/270a-1f3fd.png")] public var SM_270A-1F3FD:Class;
		[Embed(source = "smiles/270a-1f3fe.png")] public var SM_270A-1F3FE:Class;
		[Embed(source = "smiles/270a-1f3ff.png")] public var SM_270A-1F3FF:Class;
		[Embed(source = "smiles/270b-1f3fb.png")] public var SM_270B-1F3FB:Class;
		[Embed(source = "smiles/270b-1f3fc.png")] public var SM_270B-1F3FC:Class;
		[Embed(source = "smiles/270b-1f3fd.png")] public var SM_270B-1F3FD:Class;
		[Embed(source = "smiles/270b-1f3fe.png")] public var SM_270B-1F3FE:Class;
		[Embed(source = "smiles/270b-1f3ff.png")] public var SM_270B-1F3FF:Class;
		[Embed(source = "smiles/270c-1f3fb.png")] public var SM_270C-1F3FB:Class;
		[Embed(source = "smiles/270c-1f3fc.png")] public var SM_270C-1F3FC:Class;
		[Embed(source = "smiles/270c-1f3fd.png")] public var SM_270C-1F3FD:Class;
		[Embed(source = "smiles/270c-1f3fe.png")] public var SM_270C-1F3FE:Class;
		[Embed(source = "smiles/270c-1f3ff.png")] public var SM_270C-1F3FF:Class;
		[Embed(source = "smiles/270d-1f3fb.png")] public var SM_270D-1F3FB:Class;
		[Embed(source = "smiles/270d-1f3fc.png")] public var SM_270D-1F3FC:Class;
		[Embed(source = "smiles/270d-1f3fd.png")] public var SM_270D-1F3FD:Class;
		[Embed(source = "smiles/270d-1f3fe.png")] public var SM_270D-1F3FE:Class;
		[Embed(source = "smiles/270d-1f3ff.png")] public var SM_270D-1F3FF:Class;
		[Embed(source = "smiles/261d-1f3fb.png")] public var SM_261D-1F3FB:Class;
		[Embed(source = "smiles/261d-1f3fc.png")] public var SM_261D-1F3FC:Class;
		[Embed(source = "smiles/261d-1f3fd.png")] public var SM_261D-1F3FD:Class;
		[Embed(source = "smiles/261d-1f3fe.png")] public var SM_261D-1F3FE:Class;
		[Embed(source = "smiles/261d-1f3ff.png")] public var SM_261D-1F3FF:Class;
		[Embed(source = "smiles/1f6a3-1f3fb.png")] public var SM_1F6A3-1F3FB:Class;
		[Embed(source = "smiles/1f6a3-1f3fc.png")] public var SM_1F6A3-1F3FC:Class;
		[Embed(source = "smiles/1f6a3-1f3fd.png")] public var SM_1F6A3-1F3FD:Class;
		[Embed(source = "smiles/1f6a3-1f3fe.png")] public var SM_1F6A3-1F3FE:Class;
		[Embed(source = "smiles/1f6a3-1f3ff.png")] public var SM_1F6A3-1F3FF:Class;
		[Embed(source = "smiles/1f6b4-1f3fb.png")] public var SM_1F6B4-1F3FB:Class;
		[Embed(source = "smiles/1f6b4-1f3fc.png")] public var SM_1F6B4-1F3FC:Class;
		[Embed(source = "smiles/1f6b4-1f3fd.png")] public var SM_1F6B4-1F3FD:Class;
		[Embed(source = "smiles/1f6b4-1f3fe.png")] public var SM_1F6B4-1F3FE:Class;
		[Embed(source = "smiles/1f6b4-1f3ff.png")] public var SM_1F6B4-1F3FF:Class;
		[Embed(source = "smiles/1f6b5-1f3fb.png")] public var SM_1F6B5-1F3FB:Class;
		[Embed(source = "smiles/1f6b5-1f3fc.png")] public var SM_1F6B5-1F3FC:Class;
		[Embed(source = "smiles/1f6b5-1f3fd.png")] public var SM_1F6B5-1F3FD:Class;
		[Embed(source = "smiles/1f6b5-1f3fe.png")] public var SM_1F6B5-1F3FE:Class;
		[Embed(source = "smiles/1f6b5-1f3ff.png")] public var SM_1F6B5-1F3FF:Class;
		[Embed(source = "smiles/1f6b6-1f3fb.png")] public var SM_1F6B6-1F3FB:Class;
		[Embed(source = "smiles/1f6b6-1f3fc.png")] public var SM_1F6B6-1F3FC:Class;
		[Embed(source = "smiles/1f6b6-1f3fd.png")] public var SM_1F6B6-1F3FD:Class;
		[Embed(source = "smiles/1f6b6-1f3fe.png")] public var SM_1F6B6-1F3FE:Class;
		[Embed(source = "smiles/1f6b6-1f3ff.png")] public var SM_1F6B6-1F3FF:Class;
		[Embed(source = "smiles/1f6c0-1f3fb.png")] public var SM_1F6C0-1F3FB:Class;
		[Embed(source = "smiles/1f6c0-1f3fc.png")] public var SM_1F6C0-1F3FC:Class;
		[Embed(source = "smiles/1f6c0-1f3fd.png")] public var SM_1F6C0-1F3FD:Class;
		[Embed(source = "smiles/1f6c0-1f3fe.png")] public var SM_1F6C0-1F3FE:Class;
		[Embed(source = "smiles/1f6c0-1f3ff.png")] public var SM_1F6C0-1F3FF:Class;
		[Embed(source = "smiles/1f918-1f3fb.png")] public var SM_1F918-1F3FB:Class;
		[Embed(source = "smiles/1f918-1f3fc.png")] public var SM_1F918-1F3FC:Class;
		[Embed(source = "smiles/1f918-1f3fd.png")] public var SM_1F918-1F3FD:Class;
		[Embed(source = "smiles/1f918-1f3fe.png")] public var SM_1F918-1F3FE:Class;
		[Embed(source = "smiles/1f918-1f3ff.png")] public var SM_1F918-1F3FF:Class;
		[Embed(source = "smiles/23-20e3.png")] public var SM_23-20E3:Class;
		[Embed(source = "smiles/1f645-1f3fb.png")] public var SM_1F645-1F3FB:Class;
		[Embed(source = "smiles/1f645-1f3fc.png")] public var SM_1F645-1F3FC:Class;
		[Embed(source = "smiles/1f645-1f3fd.png")] public var SM_1F645-1F3FD:Class;
		[Embed(source = "smiles/1f645-1f3fe.png")] public var SM_1F645-1F3FE:Class;
		[Embed(source = "smiles/1f645-1f3ff.png")] public var SM_1F645-1F3FF:Class;
		[Embed(source = "smiles/1f646-1f3fb.png")] public var SM_1F646-1F3FB:Class;
		[Embed(source = "smiles/1f646-1f3fc.png")] public var SM_1F646-1F3FC:Class;
		[Embed(source = "smiles/1f646-1f3fd.png")] public var SM_1F646-1F3FD:Class;
		[Embed(source = "smiles/1f646-1f3fe.png")] public var SM_1F646-1F3FE:Class;
		[Embed(source = "smiles/1f646-1f3ff.png")] public var SM_1F646-1F3FF:Class;
		[Embed(source = "smiles/1f647-1f3fb.png")] public var SM_1F647-1F3FB:Class;
		[Embed(source = "smiles/1f647-1f3fc.png")] public var SM_1F647-1F3FC:Class;
		[Embed(source = "smiles/1f647-1f3fd.png")] public var SM_1F647-1F3FD:Class;
		[Embed(source = "smiles/1f647-1f3fe.png")] public var SM_1F647-1F3FE:Class;
		[Embed(source = "smiles/1f647-1f3ff.png")] public var SM_1F647-1F3FF:Class;
		[Embed(source = "smiles/1f64b-1f3fb.png")] public var SM_1F64B-1F3FB:Class;
		[Embed(source = "smiles/1f64b-1f3fc.png")] public var SM_1F64B-1F3FC:Class;
		[Embed(source = "smiles/1f64b-1f3fd.png")] public var SM_1F64B-1F3FD:Class;
		[Embed(source = "smiles/1f64b-1f3fe.png")] public var SM_1F64B-1F3FE:Class;
		[Embed(source = "smiles/1f64b-1f3ff.png")] public var SM_1F64B-1F3FF:Class;
		[Embed(source = "smiles/1f64c-1f3fb.png")] public var SM_1F64C-1F3FB:Class;
		[Embed(source = "smiles/1f64c-1f3fc.png")] public var SM_1F64C-1F3FC:Class;
		[Embed(source = "smiles/1f64c-1f3fd.png")] public var SM_1F64C-1F3FD:Class;
		[Embed(source = "smiles/1f64c-1f3fe.png")] public var SM_1F64C-1F3FE:Class;
		[Embed(source = "smiles/1f64c-1f3ff.png")] public var SM_1F64C-1F3FF:Class;
		[Embed(source = "smiles/1f64d-1f3fb.png")] public var SM_1F64D-1F3FB:Class;
		[Embed(source = "smiles/1f64d-1f3fc.png")] public var SM_1F64D-1F3FC:Class;
		[Embed(source = "smiles/1f64d-1f3fd.png")] public var SM_1F64D-1F3FD:Class;
		[Embed(source = "smiles/1f64d-1f3fe.png")] public var SM_1F64D-1F3FE:Class;
		[Embed(source = "smiles/1f64d-1f3ff.png")] public var SM_1F64D-1F3FF:Class;
		[Embed(source = "smiles/1f64e-1f3fb.png")] public var SM_1F64E-1F3FB:Class;
		[Embed(source = "smiles/1f64e-1f3fc.png")] public var SM_1F64E-1F3FC:Class;
		[Embed(source = "smiles/1f64e-1f3fd.png")] public var SM_1F64E-1F3FD:Class;
		[Embed(source = "smiles/1f64e-1f3fe.png")] public var SM_1F64E-1F3FE:Class;
		[Embed(source = "smiles/1f64e-1f3ff.png")] public var SM_1F64E-1F3FF:Class;
		[Embed(source = "smiles/1f64f-1f3fb.png")] public var SM_1F64F-1F3FB:Class;
		[Embed(source = "smiles/1f64f-1f3fc.png")] public var SM_1F64F-1F3FC:Class;
		[Embed(source = "smiles/1f64f-1f3fd.png")] public var SM_1F64F-1F3FD:Class;
		[Embed(source = "smiles/1f64f-1f3fe.png")] public var SM_1F64F-1F3FE:Class;
		[Embed(source = "smiles/1f64f-1f3ff.png")] public var SM_1F64F-1F3FF:Class;
		[Embed(source = "smiles/1f590-1f3fb.png")] public var SM_1F590-1F3FB:Class;
		[Embed(source = "smiles/1f590-1f3fc.png")] public var SM_1F590-1F3FC:Class;
		[Embed(source = "smiles/1f590-1f3fd.png")] public var SM_1F590-1F3FD:Class;
		[Embed(source = "smiles/1f590-1f3fe.png")] public var SM_1F590-1F3FE:Class;
		[Embed(source = "smiles/1f590-1f3ff.png")] public var SM_1F590-1F3FF:Class;
		[Embed(source = "smiles/1f595-1f3fb.png")] public var SM_1F595-1F3FB:Class;
		[Embed(source = "smiles/1f595-1f3fc.png")] public var SM_1F595-1F3FC:Class;
		[Embed(source = "smiles/1f595-1f3fd.png")] public var SM_1F595-1F3FD:Class;
		[Embed(source = "smiles/1f595-1f3fe.png")] public var SM_1F595-1F3FE:Class;
		[Embed(source = "smiles/1f595-1f3ff.png")] public var SM_1F595-1F3FF:Class;
		[Embed(source = "smiles/1f596-1f3fb.png")] public var SM_1F596-1F3FB:Class;
		[Embed(source = "smiles/1f596-1f3fc.png")] public var SM_1F596-1F3FC:Class;
		[Embed(source = "smiles/1f596-1f3fd.png")] public var SM_1F596-1F3FD:Class;
		[Embed(source = "smiles/1f596-1f3fe.png")] public var SM_1F596-1F3FE:Class;
		[Embed(source = "smiles/1f596-1f3ff.png")] public var SM_1F596-1F3FF:Class;
		[Embed(source = "smiles/1f476-1f3fb.png")] public var SM_1F476-1F3FB:Class;
		[Embed(source = "smiles/1f476-1f3fc.png")] public var SM_1F476-1F3FC:Class;
		[Embed(source = "smiles/1f476-1f3fd.png")] public var SM_1F476-1F3FD:Class;
		[Embed(source = "smiles/1f476-1f3fe.png")] public var SM_1F476-1F3FE:Class;
		[Embed(source = "smiles/1f476-1f3ff.png")] public var SM_1F476-1F3FF:Class;
		[Embed(source = "smiles/1f477-1f3fb.png")] public var SM_1F477-1F3FB:Class;
		[Embed(source = "smiles/1f477-1f3fc.png")] public var SM_1F477-1F3FC:Class;
		[Embed(source = "smiles/1f477-1f3fd.png")] public var SM_1F477-1F3FD:Class;
		[Embed(source = "smiles/1f477-1f3fe.png")] public var SM_1F477-1F3FE:Class;
		[Embed(source = "smiles/1f477-1f3ff.png")] public var SM_1F477-1F3FF:Class;
		[Embed(source = "smiles/1f478-1f3fb.png")] public var SM_1F478-1F3FB:Class;
		[Embed(source = "smiles/1f478-1f3fc.png")] public var SM_1F478-1F3FC:Class;
		[Embed(source = "smiles/1f478-1f3fd.png")] public var SM_1F478-1F3FD:Class;
		[Embed(source = "smiles/1f478-1f3fe.png")] public var SM_1F478-1F3FE:Class;
		[Embed(source = "smiles/1f478-1f3ff.png")] public var SM_1F478-1F3FF:Class;
		[Embed(source = "smiles/1f47c-1f3fb.png")] public var SM_1F47C-1F3FB:Class;
		[Embed(source = "smiles/1f47c-1f3fc.png")] public var SM_1F47C-1F3FC:Class;
		[Embed(source = "smiles/1f47c-1f3fd.png")] public var SM_1F47C-1F3FD:Class;
		[Embed(source = "smiles/1f47c-1f3fe.png")] public var SM_1F47C-1F3FE:Class;
		[Embed(source = "smiles/1f47c-1f3ff.png")] public var SM_1F47C-1F3FF:Class;
		[Embed(source = "smiles/1f481-1f3fb.png")] public var SM_1F481-1F3FB:Class;
		[Embed(source = "smiles/1f481-1f3fc.png")] public var SM_1F481-1F3FC:Class;
		[Embed(source = "smiles/1f481-1f3fd.png")] public var SM_1F481-1F3FD:Class;
		[Embed(source = "smiles/1f481-1f3fe.png")] public var SM_1F481-1F3FE:Class;
		[Embed(source = "smiles/1f481-1f3ff.png")] public var SM_1F481-1F3FF:Class;
		[Embed(source = "smiles/1f482-1f3fb.png")] public var SM_1F482-1F3FB:Class;
		[Embed(source = "smiles/1f482-1f3fc.png")] public var SM_1F482-1F3FC:Class;
		[Embed(source = "smiles/1f482-1f3fd.png")] public var SM_1F482-1F3FD:Class;
		[Embed(source = "smiles/1f482-1f3fe.png")] public var SM_1F482-1F3FE:Class;
		[Embed(source = "smiles/1f482-1f3ff.png")] public var SM_1F482-1F3FF:Class;
		[Embed(source = "smiles/1f483-1f3fb.png")] public var SM_1F483-1F3FB:Class;
		[Embed(source = "smiles/1f483-1f3fc.png")] public var SM_1F483-1F3FC:Class;
		[Embed(source = "smiles/1f483-1f3fd.png")] public var SM_1F483-1F3FD:Class;
		[Embed(source = "smiles/1f483-1f3fe.png")] public var SM_1F483-1F3FE:Class;
		[Embed(source = "smiles/1f483-1f3ff.png")] public var SM_1F483-1F3FF:Class;
		[Embed(source = "smiles/1f485-1f3fb.png")] public var SM_1F485-1F3FB:Class;
		[Embed(source = "smiles/1f485-1f3fc.png")] public var SM_1F485-1F3FC:Class;
		[Embed(source = "smiles/1f485-1f3fd.png")] public var SM_1F485-1F3FD:Class;
		[Embed(source = "smiles/1f485-1f3fe.png")] public var SM_1F485-1F3FE:Class;
		[Embed(source = "smiles/1f485-1f3ff.png")] public var SM_1F485-1F3FF:Class;
		[Embed(source = "smiles/1f486-1f3fb.png")] public var SM_1F486-1F3FB:Class;
		[Embed(source = "smiles/1f486-1f3fc.png")] public var SM_1F486-1F3FC:Class;
		[Embed(source = "smiles/1f486-1f3fd.png")] public var SM_1F486-1F3FD:Class;
		[Embed(source = "smiles/1f486-1f3fe.png")] public var SM_1F486-1F3FE:Class;
		[Embed(source = "smiles/1f486-1f3ff.png")] public var SM_1F486-1F3FF:Class;
		[Embed(source = "smiles/1f487-1f3fb.png")] public var SM_1F487-1F3FB:Class;
		[Embed(source = "smiles/1f487-1f3fc.png")] public var SM_1F487-1F3FC:Class;
		[Embed(source = "smiles/1f487-1f3fd.png")] public var SM_1F487-1F3FD:Class;
		[Embed(source = "smiles/1f487-1f3fe.png")] public var SM_1F487-1F3FE:Class;
		[Embed(source = "smiles/1f487-1f3ff.png")] public var SM_1F487-1F3FF:Class;
		[Embed(source = "smiles/1f4aa-1f3fb.png")] public var SM_1F4AA-1F3FB:Class;
		[Embed(source = "smiles/1f4aa-1f3fc.png")] public var SM_1F4AA-1F3FC:Class;
		[Embed(source = "smiles/1f4aa-1f3fd.png")] public var SM_1F4AA-1F3FD:Class;
		[Embed(source = "smiles/1f4aa-1f3fe.png")] public var SM_1F4AA-1F3FE:Class;
		[Embed(source = "smiles/1f4aa-1f3ff.png")] public var SM_1F4AA-1F3FF:Class;
		[Embed(source = "smiles/1f46e-1f3fb.png")] public var SM_1F46E-1F3FB:Class;
		[Embed(source = "smiles/1f46e-1f3fc.png")] public var SM_1F46E-1F3FC:Class;
		[Embed(source = "smiles/1f46e-1f3fd.png")] public var SM_1F46E-1F3FD:Class;
		[Embed(source = "smiles/1f46e-1f3fe.png")] public var SM_1F46E-1F3FE:Class;
		[Embed(source = "smiles/1f46e-1f3ff.png")] public var SM_1F46E-1F3FF:Class;
		[Embed(source = "smiles/1f470-1f3fb.png")] public var SM_1F470-1F3FB:Class;
		[Embed(source = "smiles/1f470-1f3fc.png")] public var SM_1F470-1F3FC:Class;
		[Embed(source = "smiles/1f470-1f3fd.png")] public var SM_1F470-1F3FD:Class;
		[Embed(source = "smiles/1f470-1f3fe.png")] public var SM_1F470-1F3FE:Class;
		[Embed(source = "smiles/1f470-1f3ff.png")] public var SM_1F470-1F3FF:Class;
		[Embed(source = "smiles/1f471-1f3fb.png")] public var SM_1F471-1F3FB:Class;
		[Embed(source = "smiles/1f471-1f3fc.png")] public var SM_1F471-1F3FC:Class;
		[Embed(source = "smiles/1f471-1f3fd.png")] public var SM_1F471-1F3FD:Class;
		[Embed(source = "smiles/1f471-1f3fe.png")] public var SM_1F471-1F3FE:Class;
		[Embed(source = "smiles/1f471-1f3ff.png")] public var SM_1F471-1F3FF:Class;
		[Embed(source = "smiles/1f472-1f3fb.png")] public var SM_1F472-1F3FB:Class;
		[Embed(source = "smiles/1f472-1f3fc.png")] public var SM_1F472-1F3FC:Class;
		[Embed(source = "smiles/1f472-1f3fd.png")] public var SM_1F472-1F3FD:Class;
		[Embed(source = "smiles/1f472-1f3fe.png")] public var SM_1F472-1F3FE:Class;
		[Embed(source = "smiles/1f472-1f3ff.png")] public var SM_1F472-1F3FF:Class;
		[Embed(source = "smiles/1f473-1f3fb.png")] public var SM_1F473-1F3FB:Class;
		[Embed(source = "smiles/1f473-1f3fc.png")] public var SM_1F473-1F3FC:Class;
		[Embed(source = "smiles/1f473-1f3fd.png")] public var SM_1F473-1F3FD:Class;
		[Embed(source = "smiles/1f473-1f3fe.png")] public var SM_1F473-1F3FE:Class;
		[Embed(source = "smiles/1f473-1f3ff.png")] public var SM_1F473-1F3FF:Class;
		[Embed(source = "smiles/1f474-1f3fb.png")] public var SM_1F474-1F3FB:Class;
		[Embed(source = "smiles/1f474-1f3fc.png")] public var SM_1F474-1F3FC:Class;
		[Embed(source = "smiles/1f474-1f3fd.png")] public var SM_1F474-1F3FD:Class;
		[Embed(source = "smiles/1f474-1f3fe.png")] public var SM_1F474-1F3FE:Class;
		[Embed(source = "smiles/1f474-1f3ff.png")] public var SM_1F474-1F3FF:Class;
		[Embed(source = "smiles/1f475-1f3fb.png")] public var SM_1F475-1F3FB:Class;
		[Embed(source = "smiles/1f475-1f3fc.png")] public var SM_1F475-1F3FC:Class;
		[Embed(source = "smiles/1f475-1f3fd.png")] public var SM_1F475-1F3FD:Class;
		[Embed(source = "smiles/1f475-1f3fe.png")] public var SM_1F475-1F3FE:Class;
		[Embed(source = "smiles/1f475-1f3ff.png")] public var SM_1F475-1F3FF:Class;
		[Embed(source = "smiles/1f466-1f3fb.png")] public var SM_1F466-1F3FB:Class;
		[Embed(source = "smiles/1f466-1f3fc.png")] public var SM_1F466-1F3FC:Class;
		[Embed(source = "smiles/1f466-1f3fd.png")] public var SM_1F466-1F3FD:Class;
		[Embed(source = "smiles/1f466-1f3fe.png")] public var SM_1F466-1F3FE:Class;
		[Embed(source = "smiles/1f466-1f3ff.png")] public var SM_1F466-1F3FF:Class;
		[Embed(source = "smiles/1f467-1f3fb.png")] public var SM_1F467-1F3FB:Class;
		[Embed(source = "smiles/1f467-1f3fc.png")] public var SM_1F467-1F3FC:Class;
		[Embed(source = "smiles/1f467-1f3fd.png")] public var SM_1F467-1F3FD:Class;
		[Embed(source = "smiles/1f467-1f3fe.png")] public var SM_1F467-1F3FE:Class;
		[Embed(source = "smiles/1f467-1f3ff.png")] public var SM_1F467-1F3FF:Class;
		[Embed(source = "smiles/1f468-1f3fb.png")] public var SM_1F468-1F3FB:Class;
		[Embed(source = "smiles/1f468-1f3fc.png")] public var SM_1F468-1F3FC:Class;
		[Embed(source = "smiles/1f468-1f3fd.png")] public var SM_1F468-1F3FD:Class;
		[Embed(source = "smiles/1f468-1f3fe.png")] public var SM_1F468-1F3FE:Class;
		[Embed(source = "smiles/1f468-1f3ff.png")] public var SM_1F468-1F3FF:Class;
		[Embed(source = "smiles/1f468-1f468-1f466-1f466.png")] public var SM_1F468-1F468-1F466-1F466:Class;
		[Embed(source = "smiles/1f468-1f468-1f466.png")] public var SM_1F468-1F468-1F466:Class;
		[Embed(source = "smiles/1f468-1f468-1f467-1f466.png")] public var SM_1F468-1F468-1F467-1F466:Class;
		[Embed(source = "smiles/1f468-1f468-1f467-1f467.png")] public var SM_1F468-1F468-1F467-1F467:Class;
		[Embed(source = "smiles/1f468-1f468-1f467.png")] public var SM_1F468-1F468-1F467:Class;
		[Embed(source = "smiles/1f468-1f469-1f466-1f466.png")] public var SM_1F468-1F469-1F466-1F466:Class;
		[Embed(source = "smiles/1f468-1f469-1f467-1f466.png")] public var SM_1F468-1F469-1F467-1F466:Class;
		[Embed(source = "smiles/1f468-1f469-1f467-1f467.png")] public var SM_1F468-1F469-1F467-1F467:Class;
		[Embed(source = "smiles/1f468-1f469-1f467.png")] public var SM_1F468-1F469-1F467:Class;
		[Embed(source = "smiles/1f468-2764-1f468.png")] public var SM_1F468-2764-1F468:Class;
		[Embed(source = "smiles/1f468-2764-1f48b-1f468.png")] public var SM_1F468-2764-1F48B-1F468:Class;
		[Embed(source = "smiles/1f469-1f3fb.png")] public var SM_1F469-1F3FB:Class;
		[Embed(source = "smiles/1f469-1f3fc.png")] public var SM_1F469-1F3FC:Class;
		[Embed(source = "smiles/1f469-1f3fd.png")] public var SM_1F469-1F3FD:Class;
		[Embed(source = "smiles/1f469-1f3fe.png")] public var SM_1F469-1F3FE:Class;
		[Embed(source = "smiles/1f469-1f3ff.png")] public var SM_1F469-1F3FF:Class;
		[Embed(source = "smiles/1f469-1f469-1f466-1f466.png")] public var SM_1F469-1F469-1F466-1F466:Class;
		[Embed(source = "smiles/1f469-1f469-1f466.png")] public var SM_1F469-1F469-1F466:Class;
		[Embed(source = "smiles/1f469-1f469-1f467-1f466.png")] public var SM_1F469-1F469-1F467-1F466:Class;
		[Embed(source = "smiles/1f469-1f469-1f467-1f467.png")] public var SM_1F469-1F469-1F467-1F467:Class;
		[Embed(source = "smiles/1f469-1f469-1f467.png")] public var SM_1F469-1F469-1F467:Class;
		[Embed(source = "smiles/1f469-2764-1f469.png")] public var SM_1F469-2764-1F469:Class;
		[Embed(source = "smiles/1f469-2764-1f48b-1f469.png")] public var SM_1F469-2764-1F48B-1F469:Class;
		[Embed(source = "smiles/1f441-1f5e8.png")] public var SM_1F441-1F5E8:Class;
		[Embed(source = "smiles/1f442-1f3fb.png")] public var SM_1F442-1F3FB:Class;
		[Embed(source = "smiles/1f442-1f3fc.png")] public var SM_1F442-1F3FC:Class;
		[Embed(source = "smiles/1f442-1f3fd.png")] public var SM_1F442-1F3FD:Class;
		[Embed(source = "smiles/1f442-1f3fe.png")] public var SM_1F442-1F3FE:Class;
		[Embed(source = "smiles/1f442-1f3ff.png")] public var SM_1F442-1F3FF:Class;
		[Embed(source = "smiles/1f443-1f3fb.png")] public var SM_1F443-1F3FB:Class;
		[Embed(source = "smiles/1f443-1f3fc.png")] public var SM_1F443-1F3FC:Class;
		[Embed(source = "smiles/1f443-1f3fd.png")] public var SM_1F443-1F3FD:Class;
		[Embed(source = "smiles/1f443-1f3fe.png")] public var SM_1F443-1F3FE:Class;
		[Embed(source = "smiles/1f443-1f3ff.png")] public var SM_1F443-1F3FF:Class;
		[Embed(source = "smiles/1f446-1f3fb.png")] public var SM_1F446-1F3FB:Class;
		[Embed(source = "smiles/1f446-1f3fc.png")] public var SM_1F446-1F3FC:Class;
		[Embed(source = "smiles/1f446-1f3fd.png")] public var SM_1F446-1F3FD:Class;
		[Embed(source = "smiles/1f446-1f3fe.png")] public var SM_1F446-1F3FE:Class;
		[Embed(source = "smiles/1f446-1f3ff.png")] public var SM_1F446-1F3FF:Class;
		[Embed(source = "smiles/1f447-1f3fb.png")] public var SM_1F447-1F3FB:Class;
		[Embed(source = "smiles/1f447-1f3fc.png")] public var SM_1F447-1F3FC:Class;
		[Embed(source = "smiles/1f447-1f3fd.png")] public var SM_1F447-1F3FD:Class;
		[Embed(source = "smiles/1f447-1f3fe.png")] public var SM_1F447-1F3FE:Class;
		[Embed(source = "smiles/1f447-1f3ff.png")] public var SM_1F447-1F3FF:Class;
		[Embed(source = "smiles/1f448-1f3fb.png")] public var SM_1F448-1F3FB:Class;
		[Embed(source = "smiles/1f448-1f3fc.png")] public var SM_1F448-1F3FC:Class;
		[Embed(source = "smiles/1f448-1f3fd.png")] public var SM_1F448-1F3FD:Class;
		[Embed(source = "smiles/1f448-1f3fe.png")] public var SM_1F448-1F3FE:Class;
		[Embed(source = "smiles/1f448-1f3ff.png")] public var SM_1F448-1F3FF:Class;
		[Embed(source = "smiles/1f449-1f3fb.png")] public var SM_1F449-1F3FB:Class;
		[Embed(source = "smiles/1f449-1f3fc.png")] public var SM_1F449-1F3FC:Class;
		[Embed(source = "smiles/1f449-1f3fd.png")] public var SM_1F449-1F3FD:Class;
		[Embed(source = "smiles/1f449-1f3fe.png")] public var SM_1F449-1F3FE:Class;
		[Embed(source = "smiles/1f449-1f3ff.png")] public var SM_1F449-1F3FF:Class;
		[Embed(source = "smiles/1f44a-1f3fb.png")] public var SM_1F44A-1F3FB:Class;
		[Embed(source = "smiles/1f44a-1f3fc.png")] public var SM_1F44A-1F3FC:Class;
		[Embed(source = "smiles/1f44a-1f3fd.png")] public var SM_1F44A-1F3FD:Class;
		[Embed(source = "smiles/1f44a-1f3fe.png")] public var SM_1F44A-1F3FE:Class;
		[Embed(source = "smiles/1f44a-1f3ff.png")] public var SM_1F44A-1F3FF:Class;
		[Embed(source = "smiles/1f44b-1f3fb.png")] public var SM_1F44B-1F3FB:Class;
		[Embed(source = "smiles/1f44b-1f3fc.png")] public var SM_1F44B-1F3FC:Class;
		[Embed(source = "smiles/1f44b-1f3fd.png")] public var SM_1F44B-1F3FD:Class;
		[Embed(source = "smiles/1f44b-1f3fe.png")] public var SM_1F44B-1F3FE:Class;
		[Embed(source = "smiles/1f44b-1f3ff.png")] public var SM_1F44B-1F3FF:Class;
		[Embed(source = "smiles/1f44c-1f3fb.png")] public var SM_1F44C-1F3FB:Class;
		[Embed(source = "smiles/1f44c-1f3fc.png")] public var SM_1F44C-1F3FC:Class;
		[Embed(source = "smiles/1f44c-1f3fd.png")] public var SM_1F44C-1F3FD:Class;
		[Embed(source = "smiles/1f44c-1f3fe.png")] public var SM_1F44C-1F3FE:Class;
		[Embed(source = "smiles/1f44c-1f3ff.png")] public var SM_1F44C-1F3FF:Class;
		[Embed(source = "smiles/1f44d-1f3fb.png")] public var SM_1F44D-1F3FB:Class;
		[Embed(source = "smiles/1f44d-1f3fc.png")] public var SM_1F44D-1F3FC:Class;
		[Embed(source = "smiles/1f44d-1f3fd.png")] public var SM_1F44D-1F3FD:Class;
		[Embed(source = "smiles/1f44d-1f3fe.png")] public var SM_1F44D-1F3FE:Class;
		[Embed(source = "smiles/1f44d-1f3ff.png")] public var SM_1F44D-1F3FF:Class;
		[Embed(source = "smiles/1f44e-1f3fb.png")] public var SM_1F44E-1F3FB:Class;
		[Embed(source = "smiles/1f44e-1f3fc.png")] public var SM_1F44E-1F3FC:Class;
		[Embed(source = "smiles/1f44e-1f3fd.png")] public var SM_1F44E-1F3FD:Class;
		[Embed(source = "smiles/1f44e-1f3fe.png")] public var SM_1F44E-1F3FE:Class;
		[Embed(source = "smiles/1f44e-1f3ff.png")] public var SM_1F44E-1F3FF:Class;
		[Embed(source = "smiles/1f44f-1f3fb.png")] public var SM_1F44F-1F3FB:Class;
		[Embed(source = "smiles/1f44f-1f3fc.png")] public var SM_1F44F-1F3FC:Class;
		[Embed(source = "smiles/1f44f-1f3fd.png")] public var SM_1F44F-1F3FD:Class;
		[Embed(source = "smiles/1f44f-1f3fe.png")] public var SM_1F44F-1F3FE:Class;
		[Embed(source = "smiles/1f44f-1f3ff.png")] public var SM_1F44F-1F3FF:Class;
		[Embed(source = "smiles/1f450-1f3fb.png")] public var SM_1F450-1F3FB:Class;
		[Embed(source = "smiles/1f450-1f3fc.png")] public var SM_1F450-1F3FC:Class;
		[Embed(source = "smiles/1f450-1f3fd.png")] public var SM_1F450-1F3FD:Class;
		[Embed(source = "smiles/1f450-1f3fe.png")] public var SM_1F450-1F3FE:Class;
		[Embed(source = "smiles/1f450-1f3ff.png")] public var SM_1F450-1F3FF:Class;
		[Embed(source = "smiles/1f1e6-1f1e8.png")] public var SM_1F1E6-1F1E8:Class;
		[Embed(source = "smiles/1f1e6-1f1e9.png")] public var SM_1F1E6-1F1E9:Class;
		[Embed(source = "smiles/1f1e6-1f1ea.png")] public var SM_1F1E6-1F1EA:Class;
		[Embed(source = "smiles/1f1e6-1f1eb.png")] public var SM_1F1E6-1F1EB:Class;
		[Embed(source = "smiles/1f1e6-1f1ec.png")] public var SM_1F1E6-1F1EC:Class;
		[Embed(source = "smiles/1f1e6-1f1ee.png")] public var SM_1F1E6-1F1EE:Class;
		[Embed(source = "smiles/1f1e6-1f1f1.png")] public var SM_1F1E6-1F1F1:Class;
		[Embed(source = "smiles/1f1e6-1f1f2.png")] public var SM_1F1E6-1F1F2:Class;
		[Embed(source = "smiles/1f1e6-1f1f4.png")] public var SM_1F1E6-1F1F4:Class;
		[Embed(source = "smiles/1f1e6-1f1f6.png")] public var SM_1F1E6-1F1F6:Class;
		[Embed(source = "smiles/1f1e6-1f1f7.png")] public var SM_1F1E6-1F1F7:Class;
		[Embed(source = "smiles/1f1e6-1f1f8.png")] public var SM_1F1E6-1F1F8:Class;
		[Embed(source = "smiles/1f1e6-1f1f9.png")] public var SM_1F1E6-1F1F9:Class;
		[Embed(source = "smiles/1f1e6-1f1fa.png")] public var SM_1F1E6-1F1FA:Class;
		[Embed(source = "smiles/1f1e6-1f1fc.png")] public var SM_1F1E6-1F1FC:Class;
		[Embed(source = "smiles/1f1e6-1f1fd.png")] public var SM_1F1E6-1F1FD:Class;
		[Embed(source = "smiles/1f1e6-1f1ff.png")] public var SM_1F1E6-1F1FF:Class;
		[Embed(source = "smiles/1f1e7-1f1e6.png")] public var SM_1F1E7-1F1E6:Class;
		[Embed(source = "smiles/1f1e7-1f1e7.png")] public var SM_1F1E7-1F1E7:Class;
		[Embed(source = "smiles/1f1e7-1f1e9.png")] public var SM_1F1E7-1F1E9:Class;
		[Embed(source = "smiles/1f1e7-1f1ea.png")] public var SM_1F1E7-1F1EA:Class;
		[Embed(source = "smiles/1f1e7-1f1eb.png")] public var SM_1F1E7-1F1EB:Class;
		[Embed(source = "smiles/1f1e7-1f1ec.png")] public var SM_1F1E7-1F1EC:Class;
		[Embed(source = "smiles/1f1e7-1f1ed.png")] public var SM_1F1E7-1F1ED:Class;
		[Embed(source = "smiles/1f1e7-1f1ee.png")] public var SM_1F1E7-1F1EE:Class;
		[Embed(source = "smiles/1f1e7-1f1ef.png")] public var SM_1F1E7-1F1EF:Class;
		[Embed(source = "smiles/1f1e7-1f1f1.png")] public var SM_1F1E7-1F1F1:Class;
		[Embed(source = "smiles/1f1e7-1f1f2.png")] public var SM_1F1E7-1F1F2:Class;
		[Embed(source = "smiles/1f1e7-1f1f3.png")] public var SM_1F1E7-1F1F3:Class;
		[Embed(source = "smiles/1f1e7-1f1f4.png")] public var SM_1F1E7-1F1F4:Class;
		[Embed(source = "smiles/1f1e7-1f1f6.png")] public var SM_1F1E7-1F1F6:Class;
		[Embed(source = "smiles/1f1e7-1f1f7.png")] public var SM_1F1E7-1F1F7:Class;
		[Embed(source = "smiles/1f1e7-1f1f8.png")] public var SM_1F1E7-1F1F8:Class;
		[Embed(source = "smiles/1f1e7-1f1f9.png")] public var SM_1F1E7-1F1F9:Class;
		[Embed(source = "smiles/1f1e7-1f1fb.png")] public var SM_1F1E7-1F1FB:Class;
		[Embed(source = "smiles/1f1e7-1f1fc.png")] public var SM_1F1E7-1F1FC:Class;
		[Embed(source = "smiles/1f1e7-1f1fe.png")] public var SM_1F1E7-1F1FE:Class;
		[Embed(source = "smiles/1f1e7-1f1ff.png")] public var SM_1F1E7-1F1FF:Class;
		[Embed(source = "smiles/1f1e8-1f1e6.png")] public var SM_1F1E8-1F1E6:Class;
		[Embed(source = "smiles/1f1e8-1f1e8.png")] public var SM_1F1E8-1F1E8:Class;
		[Embed(source = "smiles/1f1e8-1f1e9.png")] public var SM_1F1E8-1F1E9:Class;
		[Embed(source = "smiles/1f1e8-1f1eb.png")] public var SM_1F1E8-1F1EB:Class;
		[Embed(source = "smiles/1f1e8-1f1ec.png")] public var SM_1F1E8-1F1EC:Class;
		[Embed(source = "smiles/1f1e8-1f1ed.png")] public var SM_1F1E8-1F1ED:Class;
		[Embed(source = "smiles/1f1e8-1f1ee.png")] public var SM_1F1E8-1F1EE:Class;
		[Embed(source = "smiles/1f1e8-1f1f0.png")] public var SM_1F1E8-1F1F0:Class;
		[Embed(source = "smiles/1f1e8-1f1f1.png")] public var SM_1F1E8-1F1F1:Class;
		[Embed(source = "smiles/1f1e8-1f1f2.png")] public var SM_1F1E8-1F1F2:Class;
		[Embed(source = "smiles/1f1e8-1f1f3.png")] public var SM_1F1E8-1F1F3:Class;
		[Embed(source = "smiles/1f1e8-1f1f4.png")] public var SM_1F1E8-1F1F4:Class;
		[Embed(source = "smiles/1f1e8-1f1f5.png")] public var SM_1F1E8-1F1F5:Class;
		[Embed(source = "smiles/1f1e8-1f1f7.png")] public var SM_1F1E8-1F1F7:Class;
		[Embed(source = "smiles/1f1e8-1f1fa.png")] public var SM_1F1E8-1F1FA:Class;
		[Embed(source = "smiles/1f1e8-1f1fb.png")] public var SM_1F1E8-1F1FB:Class;
		[Embed(source = "smiles/1f1e8-1f1fc.png")] public var SM_1F1E8-1F1FC:Class;
		[Embed(source = "smiles/1f1e8-1f1fd.png")] public var SM_1F1E8-1F1FD:Class;
		[Embed(source = "smiles/1f1e8-1f1fe.png")] public var SM_1F1E8-1F1FE:Class;
		[Embed(source = "smiles/1f1e8-1f1ff.png")] public var SM_1F1E8-1F1FF:Class;
		[Embed(source = "smiles/1f1e9-1f1ea.png")] public var SM_1F1E9-1F1EA:Class;
		[Embed(source = "smiles/1f1e9-1f1ec.png")] public var SM_1F1E9-1F1EC:Class;
		[Embed(source = "smiles/1f1e9-1f1ef.png")] public var SM_1F1E9-1F1EF:Class;
		[Embed(source = "smiles/1f1e9-1f1f0.png")] public var SM_1F1E9-1F1F0:Class;
		[Embed(source = "smiles/1f1e9-1f1f2.png")] public var SM_1F1E9-1F1F2:Class;
		[Embed(source = "smiles/1f1e9-1f1f4.png")] public var SM_1F1E9-1F1F4:Class;
		[Embed(source = "smiles/1f1e9-1f1ff.png")] public var SM_1F1E9-1F1FF:Class;
		[Embed(source = "smiles/1f1ea-1f1e6.png")] public var SM_1F1EA-1F1E6:Class;
		[Embed(source = "smiles/1f1ea-1f1e8.png")] public var SM_1F1EA-1F1E8:Class;
		[Embed(source = "smiles/1f1ea-1f1ea.png")] public var SM_1F1EA-1F1EA:Class;
		[Embed(source = "smiles/1f1ea-1f1ec.png")] public var SM_1F1EA-1F1EC:Class;
		[Embed(source = "smiles/1f1ea-1f1ed.png")] public var SM_1F1EA-1F1ED:Class;
		[Embed(source = "smiles/1f1ea-1f1f7.png")] public var SM_1F1EA-1F1F7:Class;
		[Embed(source = "smiles/1f1ea-1f1f8.png")] public var SM_1F1EA-1F1F8:Class;
		[Embed(source = "smiles/1f1ea-1f1f9.png")] public var SM_1F1EA-1F1F9:Class;
		[Embed(source = "smiles/1f1ea-1f1fa.png")] public var SM_1F1EA-1F1FA:Class;
		[Embed(source = "smiles/1f1eb-1f1ee.png")] public var SM_1F1EB-1F1EE:Class;
		[Embed(source = "smiles/1f1eb-1f1ef.png")] public var SM_1F1EB-1F1EF:Class;
		[Embed(source = "smiles/1f1eb-1f1f0.png")] public var SM_1F1EB-1F1F0:Class;
		[Embed(source = "smiles/1f1eb-1f1f2.png")] public var SM_1F1EB-1F1F2:Class;
		[Embed(source = "smiles/1f1eb-1f1f4.png")] public var SM_1F1EB-1F1F4:Class;
		[Embed(source = "smiles/1f1eb-1f1f7.png")] public var SM_1F1EB-1F1F7:Class;
		[Embed(source = "smiles/1f1ec-1f1e6.png")] public var SM_1F1EC-1F1E6:Class;
		[Embed(source = "smiles/1f1ec-1f1e7.png")] public var SM_1F1EC-1F1E7:Class;
		[Embed(source = "smiles/1f1ec-1f1e9.png")] public var SM_1F1EC-1F1E9:Class;
		[Embed(source = "smiles/1f1ec-1f1ea.png")] public var SM_1F1EC-1F1EA:Class;
		[Embed(source = "smiles/1f1ec-1f1eb.png")] public var SM_1F1EC-1F1EB:Class;
		[Embed(source = "smiles/1f1ec-1f1ec.png")] public var SM_1F1EC-1F1EC:Class;
		[Embed(source = "smiles/1f1ec-1f1ed.png")] public var SM_1F1EC-1F1ED:Class;
		[Embed(source = "smiles/1f1ec-1f1ee.png")] public var SM_1F1EC-1F1EE:Class;
		[Embed(source = "smiles/1f1ec-1f1f1.png")] public var SM_1F1EC-1F1F1:Class;
		[Embed(source = "smiles/1f1ec-1f1f2.png")] public var SM_1F1EC-1F1F2:Class;
		[Embed(source = "smiles/1f1ec-1f1f3.png")] public var SM_1F1EC-1F1F3:Class;
		[Embed(source = "smiles/1f1ec-1f1f5.png")] public var SM_1F1EC-1F1F5:Class;
		[Embed(source = "smiles/1f1ec-1f1f6.png")] public var SM_1F1EC-1F1F6:Class;
		[Embed(source = "smiles/1f1ec-1f1f7.png")] public var SM_1F1EC-1F1F7:Class;
		[Embed(source = "smiles/1f1ec-1f1f8.png")] public var SM_1F1EC-1F1F8:Class;
		[Embed(source = "smiles/1f1ec-1f1f9.png")] public var SM_1F1EC-1F1F9:Class;
		[Embed(source = "smiles/1f1ec-1f1fa.png")] public var SM_1F1EC-1F1FA:Class;
		[Embed(source = "smiles/1f1ec-1f1fc.png")] public var SM_1F1EC-1F1FC:Class;
		[Embed(source = "smiles/1f1ec-1f1fe.png")] public var SM_1F1EC-1F1FE:Class;
		[Embed(source = "smiles/1f1ed-1f1f0.png")] public var SM_1F1ED-1F1F0:Class;
		[Embed(source = "smiles/1f1ed-1f1f2.png")] public var SM_1F1ED-1F1F2:Class;
		[Embed(source = "smiles/1f1ed-1f1f3.png")] public var SM_1F1ED-1F1F3:Class;
		[Embed(source = "smiles/1f1ed-1f1f7.png")] public var SM_1F1ED-1F1F7:Class;
		[Embed(source = "smiles/1f1ed-1f1f9.png")] public var SM_1F1ED-1F1F9:Class;
		[Embed(source = "smiles/1f1ed-1f1fa.png")] public var SM_1F1ED-1F1FA:Class;
		[Embed(source = "smiles/1f1ee-1f1e8.png")] public var SM_1F1EE-1F1E8:Class;
		[Embed(source = "smiles/1f1ee-1f1e9.png")] public var SM_1F1EE-1F1E9:Class;
		[Embed(source = "smiles/1f1ee-1f1ea.png")] public var SM_1F1EE-1F1EA:Class;
		[Embed(source = "smiles/1f1ee-1f1f1.png")] public var SM_1F1EE-1F1F1:Class;
		[Embed(source = "smiles/1f1ee-1f1f2.png")] public var SM_1F1EE-1F1F2:Class;
		[Embed(source = "smiles/1f1ee-1f1f3.png")] public var SM_1F1EE-1F1F3:Class;
		[Embed(source = "smiles/1f1ee-1f1f4.png")] public var SM_1F1EE-1F1F4:Class;
		[Embed(source = "smiles/1f1ee-1f1f6.png")] public var SM_1F1EE-1F1F6:Class;
		[Embed(source = "smiles/1f1ee-1f1f7.png")] public var SM_1F1EE-1F1F7:Class;
		[Embed(source = "smiles/1f1ee-1f1f8.png")] public var SM_1F1EE-1F1F8:Class;
		[Embed(source = "smiles/1f1ee-1f1f9.png")] public var SM_1F1EE-1F1F9:Class;
		[Embed(source = "smiles/1f1ef-1f1ea.png")] public var SM_1F1EF-1F1EA:Class;
		[Embed(source = "smiles/1f1ef-1f1f2.png")] public var SM_1F1EF-1F1F2:Class;
		[Embed(source = "smiles/1f1ef-1f1f4.png")] public var SM_1F1EF-1F1F4:Class;
		[Embed(source = "smiles/1f1ef-1f1f5.png")] public var SM_1F1EF-1F1F5:Class;
		[Embed(source = "smiles/1f1f0-1f1ea.png")] public var SM_1F1F0-1F1EA:Class;
		[Embed(source = "smiles/1f1f0-1f1ec.png")] public var SM_1F1F0-1F1EC:Class;
		[Embed(source = "smiles/1f1f0-1f1ed.png")] public var SM_1F1F0-1F1ED:Class;
		[Embed(source = "smiles/1f1f0-1f1ee.png")] public var SM_1F1F0-1F1EE:Class;
		[Embed(source = "smiles/1f1f0-1f1f2.png")] public var SM_1F1F0-1F1F2:Class;
		[Embed(source = "smiles/1f1f0-1f1f3.png")] public var SM_1F1F0-1F1F3:Class;
		[Embed(source = "smiles/1f1f0-1f1f5.png")] public var SM_1F1F0-1F1F5:Class;
		[Embed(source = "smiles/1f1f0-1f1f7.png")] public var SM_1F1F0-1F1F7:Class;
		[Embed(source = "smiles/1f1f0-1f1fc.png")] public var SM_1F1F0-1F1FC:Class;
		[Embed(source = "smiles/1f1f0-1f1fe.png")] public var SM_1F1F0-1F1FE:Class;
		[Embed(source = "smiles/1f1f0-1f1ff.png")] public var SM_1F1F0-1F1FF:Class;
		[Embed(source = "smiles/1f1f1-1f1e6.png")] public var SM_1F1F1-1F1E6:Class;
		[Embed(source = "smiles/1f1f1-1f1e7.png")] public var SM_1F1F1-1F1E7:Class;
		[Embed(source = "smiles/1f1f1-1f1e8.png")] public var SM_1F1F1-1F1E8:Class;
		[Embed(source = "smiles/1f1f1-1f1ee.png")] public var SM_1F1F1-1F1EE:Class;
		[Embed(source = "smiles/1f1f1-1f1f0.png")] public var SM_1F1F1-1F1F0:Class;
		[Embed(source = "smiles/1f1f1-1f1f7.png")] public var SM_1F1F1-1F1F7:Class;
		[Embed(source = "smiles/1f1f1-1f1f8.png")] public var SM_1F1F1-1F1F8:Class;
		[Embed(source = "smiles/1f1f1-1f1f9.png")] public var SM_1F1F1-1F1F9:Class;
		[Embed(source = "smiles/1f1f1-1f1fa.png")] public var SM_1F1F1-1F1FA:Class;
		[Embed(source = "smiles/1f1f1-1f1fb.png")] public var SM_1F1F1-1F1FB:Class;
		[Embed(source = "smiles/1f1f1-1f1fe.png")] public var SM_1F1F1-1F1FE:Class;
		[Embed(source = "smiles/1f1f2-1f1e6.png")] public var SM_1F1F2-1F1E6:Class;
		[Embed(source = "smiles/1f1f2-1f1e8.png")] public var SM_1F1F2-1F1E8:Class;
		[Embed(source = "smiles/1f1f2-1f1e9.png")] public var SM_1F1F2-1F1E9:Class;
		[Embed(source = "smiles/1f1f2-1f1ea.png")] public var SM_1F1F2-1F1EA:Class;
		[Embed(source = "smiles/1f1f2-1f1eb.png")] public var SM_1F1F2-1F1EB:Class;
		[Embed(source = "smiles/1f1f2-1f1ec.png")] public var SM_1F1F2-1F1EC:Class;
		[Embed(source = "smiles/1f1f2-1f1ed.png")] public var SM_1F1F2-1F1ED:Class;
		[Embed(source = "smiles/1f1f2-1f1f0.png")] public var SM_1F1F2-1F1F0:Class;
		[Embed(source = "smiles/1f1f2-1f1f1.png")] public var SM_1F1F2-1F1F1:Class;
		[Embed(source = "smiles/1f1f2-1f1f2.png")] public var SM_1F1F2-1F1F2:Class;
		[Embed(source = "smiles/1f1f2-1f1f3.png")] public var SM_1F1F2-1F1F3:Class;
		[Embed(source = "smiles/1f1f2-1f1f4.png")] public var SM_1F1F2-1F1F4:Class;
		[Embed(source = "smiles/1f1f2-1f1f5.png")] public var SM_1F1F2-1F1F5:Class;
		[Embed(source = "smiles/1f1f2-1f1f6.png")] public var SM_1F1F2-1F1F6:Class;
		[Embed(source = "smiles/1f1f2-1f1f7.png")] public var SM_1F1F2-1F1F7:Class;
		[Embed(source = "smiles/1f1f2-1f1f8.png")] public var SM_1F1F2-1F1F8:Class;
		[Embed(source = "smiles/1f1f2-1f1f9.png")] public var SM_1F1F2-1F1F9:Class;
		[Embed(source = "smiles/1f1f2-1f1fa.png")] public var SM_1F1F2-1F1FA:Class;
		[Embed(source = "smiles/1f1f2-1f1fb.png")] public var SM_1F1F2-1F1FB:Class;
		[Embed(source = "smiles/1f1f2-1f1fc.png")] public var SM_1F1F2-1F1FC:Class;
		[Embed(source = "smiles/1f1f2-1f1fd.png")] public var SM_1F1F2-1F1FD:Class;
		[Embed(source = "smiles/1f1f2-1f1fe.png")] public var SM_1F1F2-1F1FE:Class;
		[Embed(source = "smiles/1f1f2-1f1ff.png")] public var SM_1F1F2-1F1FF:Class;
		[Embed(source = "smiles/1f1f3-1f1e6.png")] public var SM_1F1F3-1F1E6:Class;
		[Embed(source = "smiles/1f1f3-1f1e8.png")] public var SM_1F1F3-1F1E8:Class;
		[Embed(source = "smiles/1f1f3-1f1ea.png")] public var SM_1F1F3-1F1EA:Class;
		[Embed(source = "smiles/1f1f3-1f1eb.png")] public var SM_1F1F3-1F1EB:Class;
		[Embed(source = "smiles/1f1f3-1f1ec.png")] public var SM_1F1F3-1F1EC:Class;
		[Embed(source = "smiles/1f1f3-1f1ee.png")] public var SM_1F1F3-1F1EE:Class;
		[Embed(source = "smiles/1f1f3-1f1f1.png")] public var SM_1F1F3-1F1F1:Class;
		[Embed(source = "smiles/1f1f3-1f1f4.png")] public var SM_1F1F3-1F1F4:Class;
		[Embed(source = "smiles/1f1f3-1f1f5.png")] public var SM_1F1F3-1F1F5:Class;
		[Embed(source = "smiles/1f1f3-1f1f7.png")] public var SM_1F1F3-1F1F7:Class;
		[Embed(source = "smiles/1f1f3-1f1fa.png")] public var SM_1F1F3-1F1FA:Class;
		[Embed(source = "smiles/1f1f3-1f1ff.png")] public var SM_1F1F3-1F1FF:Class;
		[Embed(source = "smiles/1f1f4-1f1f2.png")] public var SM_1F1F4-1F1F2:Class;
		[Embed(source = "smiles/1f1f5-1f1e6.png")] public var SM_1F1F5-1F1E6:Class;
		[Embed(source = "smiles/1f1f5-1f1ea.png")] public var SM_1F1F5-1F1EA:Class;
		[Embed(source = "smiles/1f1f5-1f1eb.png")] public var SM_1F1F5-1F1EB:Class;
		[Embed(source = "smiles/1f1f5-1f1ec.png")] public var SM_1F1F5-1F1EC:Class;
		[Embed(source = "smiles/1f1f5-1f1ed.png")] public var SM_1F1F5-1F1ED:Class;
		[Embed(source = "smiles/1f1f5-1f1f0.png")] public var SM_1F1F5-1F1F0:Class;
		[Embed(source = "smiles/1f1f5-1f1f1.png")] public var SM_1F1F5-1F1F1:Class;
		[Embed(source = "smiles/1f1f5-1f1f2.png")] public var SM_1F1F5-1F1F2:Class;
		[Embed(source = "smiles/1f1f5-1f1f3.png")] public var SM_1F1F5-1F1F3:Class;
		[Embed(source = "smiles/1f1f5-1f1f7.png")] public var SM_1F1F5-1F1F7:Class;
		[Embed(source = "smiles/1f1f5-1f1f8.png")] public var SM_1F1F5-1F1F8:Class;
		[Embed(source = "smiles/1f1f5-1f1f9.png")] public var SM_1F1F5-1F1F9:Class;
		[Embed(source = "smiles/1f1f5-1f1fc.png")] public var SM_1F1F5-1F1FC:Class;
		[Embed(source = "smiles/1f1f5-1f1fe.png")] public var SM_1F1F5-1F1FE:Class;
		[Embed(source = "smiles/1f1f6-1f1e6.png")] public var SM_1F1F6-1F1E6:Class;
		[Embed(source = "smiles/1f1f7-1f1ea.png")] public var SM_1F1F7-1F1EA:Class;
		[Embed(source = "smiles/1f1f7-1f1f4.png")] public var SM_1F1F7-1F1F4:Class;
		[Embed(source = "smiles/1f1f7-1f1f8.png")] public var SM_1F1F7-1F1F8:Class;
		[Embed(source = "smiles/1f1f7-1f1fa.png")] public var SM_1F1F7-1F1FA:Class;
		[Embed(source = "smiles/1f1f7-1f1fc.png")] public var SM_1F1F7-1F1FC:Class;
		[Embed(source = "smiles/1f1f8-1f1e6.png")] public var SM_1F1F8-1F1E6:Class;
		[Embed(source = "smiles/1f1f8-1f1e7.png")] public var SM_1F1F8-1F1E7:Class;
		[Embed(source = "smiles/1f1f8-1f1e8.png")] public var SM_1F1F8-1F1E8:Class;
		[Embed(source = "smiles/1f1f8-1f1e9.png")] public var SM_1F1F8-1F1E9:Class;
		[Embed(source = "smiles/1f1f8-1f1ea.png")] public var SM_1F1F8-1F1EA:Class;
		[Embed(source = "smiles/1f1f8-1f1ec.png")] public var SM_1F1F8-1F1EC:Class;
		[Embed(source = "smiles/1f1f8-1f1ed.png")] public var SM_1F1F8-1F1ED:Class;
		[Embed(source = "smiles/1f1f8-1f1ee.png")] public var SM_1F1F8-1F1EE:Class;
		[Embed(source = "smiles/1f1f8-1f1ef.png")] public var SM_1F1F8-1F1EF:Class;
		[Embed(source = "smiles/1f1f8-1f1f0.png")] public var SM_1F1F8-1F1F0:Class;
		[Embed(source = "smiles/1f1f8-1f1f1.png")] public var SM_1F1F8-1F1F1:Class;
		[Embed(source = "smiles/1f1f8-1f1f2.png")] public var SM_1F1F8-1F1F2:Class;
		[Embed(source = "smiles/1f1f8-1f1f3.png")] public var SM_1F1F8-1F1F3:Class;
		[Embed(source = "smiles/1f1f8-1f1f4.png")] public var SM_1F1F8-1F1F4:Class;
		[Embed(source = "smiles/1f1f8-1f1f7.png")] public var SM_1F1F8-1F1F7:Class;
		[Embed(source = "smiles/1f1f8-1f1f8.png")] public var SM_1F1F8-1F1F8:Class;
		[Embed(source = "smiles/1f1f8-1f1f9.png")] public var SM_1F1F8-1F1F9:Class;
		[Embed(source = "smiles/1f1f8-1f1fb.png")] public var SM_1F1F8-1F1FB:Class;
		[Embed(source = "smiles/1f1f8-1f1fd.png")] public var SM_1F1F8-1F1FD:Class;
		[Embed(source = "smiles/1f1f8-1f1fe.png")] public var SM_1F1F8-1F1FE:Class;
		[Embed(source = "smiles/1f1f8-1f1ff.png")] public var SM_1F1F8-1F1FF:Class;
		[Embed(source = "smiles/1f1f9-1f1e6.png")] public var SM_1F1F9-1F1E6:Class;
		[Embed(source = "smiles/1f1f9-1f1e8.png")] public var SM_1F1F9-1F1E8:Class;
		[Embed(source = "smiles/1f1f9-1f1e9.png")] public var SM_1F1F9-1F1E9:Class;
		[Embed(source = "smiles/1f1f9-1f1eb.png")] public var SM_1F1F9-1F1EB:Class;
		[Embed(source = "smiles/1f1f9-1f1ec.png")] public var SM_1F1F9-1F1EC:Class;
		[Embed(source = "smiles/1f1f9-1f1ed.png")] public var SM_1F1F9-1F1ED:Class;
		[Embed(source = "smiles/1f1f9-1f1ef.png")] public var SM_1F1F9-1F1EF:Class;
		[Embed(source = "smiles/1f1f9-1f1f0.png")] public var SM_1F1F9-1F1F0:Class;
		[Embed(source = "smiles/1f1f9-1f1f1.png")] public var SM_1F1F9-1F1F1:Class;
		[Embed(source = "smiles/1f1f9-1f1f2.png")] public var SM_1F1F9-1F1F2:Class;
		[Embed(source = "smiles/1f1f9-1f1f3.png")] public var SM_1F1F9-1F1F3:Class;
		[Embed(source = "smiles/1f1f9-1f1f4.png")] public var SM_1F1F9-1F1F4:Class;
		[Embed(source = "smiles/1f1f9-1f1f7.png")] public var SM_1F1F9-1F1F7:Class;
		[Embed(source = "smiles/1f1f9-1f1f9.png")] public var SM_1F1F9-1F1F9:Class;
		[Embed(source = "smiles/1f1f9-1f1fb.png")] public var SM_1F1F9-1F1FB:Class;
		[Embed(source = "smiles/1f1f9-1f1fc.png")] public var SM_1F1F9-1F1FC:Class;
		[Embed(source = "smiles/1f1f9-1f1ff.png")] public var SM_1F1F9-1F1FF:Class;
		[Embed(source = "smiles/1f1fa-1f1e6.png")] public var SM_1F1FA-1F1E6:Class;
		[Embed(source = "smiles/1f1fa-1f1ec.png")] public var SM_1F1FA-1F1EC:Class;
		[Embed(source = "smiles/1f1fa-1f1f2.png")] public var SM_1F1FA-1F1F2:Class;
		[Embed(source = "smiles/1f1fa-1f1f8.png")] public var SM_1F1FA-1F1F8:Class;
		[Embed(source = "smiles/1f1fa-1f1fe.png")] public var SM_1F1FA-1F1FE:Class;
		[Embed(source = "smiles/1f1fa-1f1ff.png")] public var SM_1F1FA-1F1FF:Class;
		[Embed(source = "smiles/1f1fb-1f1e6.png")] public var SM_1F1FB-1F1E6:Class;
		[Embed(source = "smiles/1f1fb-1f1e8.png")] public var SM_1F1FB-1F1E8:Class;
		[Embed(source = "smiles/1f1fb-1f1ea.png")] public var SM_1F1FB-1F1EA:Class;
		[Embed(source = "smiles/1f1fb-1f1ec.png")] public var SM_1F1FB-1F1EC:Class;
		[Embed(source = "smiles/1f1fb-1f1ee.png")] public var SM_1F1FB-1F1EE:Class;
		[Embed(source = "smiles/1f1fb-1f1f3.png")] public var SM_1F1FB-1F1F3:Class;
		[Embed(source = "smiles/1f1fb-1f1fa.png")] public var SM_1F1FB-1F1FA:Class;
		[Embed(source = "smiles/1f1fc-1f1eb.png")] public var SM_1F1FC-1F1EB:Class;
		[Embed(source = "smiles/1f1fc-1f1f8.png")] public var SM_1F1FC-1F1F8:Class;
		[Embed(source = "smiles/1f1fd-1f1f0.png")] public var SM_1F1FD-1F1F0:Class;
		[Embed(source = "smiles/1f1fe-1f1ea.png")] public var SM_1F1FE-1F1EA:Class;
		[Embed(source = "smiles/1f1fe-1f1f9.png")] public var SM_1F1FE-1F1F9:Class;
		[Embed(source = "smiles/1f1ff-1f1e6.png")] public var SM_1F1FF-1F1E6:Class;
		[Embed(source = "smiles/1f1ff-1f1f2.png")] public var SM_1F1FF-1F1F2:Class;
		[Embed(source = "smiles/1f1ff-1f1fc.png")] public var SM_1F1FF-1F1FC:Class;
		[Embed(source = "smiles/1f3c3-1f3fb.png")] public var SM_1F3C3-1F3FB:Class;
		[Embed(source = "smiles/1f3c3-1f3fc.png")] public var SM_1F3C3-1F3FC:Class;
		[Embed(source = "smiles/1f3c3-1f3fd.png")] public var SM_1F3C3-1F3FD:Class;
		[Embed(source = "smiles/1f3c3-1f3fe.png")] public var SM_1F3C3-1F3FE:Class;
		[Embed(source = "smiles/1f3c3-1f3ff.png")] public var SM_1F3C3-1F3FF:Class;
		[Embed(source = "smiles/1f3c4-1f3fb.png")] public var SM_1F3C4-1F3FB:Class;
		[Embed(source = "smiles/1f3c4-1f3fc.png")] public var SM_1F3C4-1F3FC:Class;
		[Embed(source = "smiles/1f3c4-1f3fd.png")] public var SM_1F3C4-1F3FD:Class;
		[Embed(source = "smiles/1f3c4-1f3fe.png")] public var SM_1F3C4-1F3FE:Class;
		[Embed(source = "smiles/1f3c4-1f3ff.png")] public var SM_1F3C4-1F3FF:Class;
		[Embed(source = "smiles/1f3c7-1f3fb.png")] public var SM_1F3C7-1F3FB:Class;
		[Embed(source = "smiles/1f3c7-1f3fc.png")] public var SM_1F3C7-1F3FC:Class;
		[Embed(source = "smiles/1f3c7-1f3fd.png")] public var SM_1F3C7-1F3FD:Class;
		[Embed(source = "smiles/1f3c7-1f3fe.png")] public var SM_1F3C7-1F3FE:Class;
		[Embed(source = "smiles/1f3c7-1f3ff.png")] public var SM_1F3C7-1F3FF:Class;
		[Embed(source = "smiles/1f3ca-1f3fb.png")] public var SM_1F3CA-1F3FB:Class;
		[Embed(source = "smiles/1f3ca-1f3fc.png")] public var SM_1F3CA-1F3FC:Class;
		[Embed(source = "smiles/1f3ca-1f3fd.png")] public var SM_1F3CA-1F3FD:Class;
		[Embed(source = "smiles/1f3ca-1f3fe.png")] public var SM_1F3CA-1F3FE:Class;
		[Embed(source = "smiles/1f3ca-1f3ff.png")] public var SM_1F3CA-1F3FF:Class;
		[Embed(source = "smiles/1f3cb-1f3fb.png")] public var SM_1F3CB-1F3FB:Class;
		[Embed(source = "smiles/1f3cb-1f3fc.png")] public var SM_1F3CB-1F3FC:Class;
		[Embed(source = "smiles/1f3cb-1f3fd.png")] public var SM_1F3CB-1F3FD:Class;
		[Embed(source = "smiles/1f3cb-1f3fe.png")] public var SM_1F3CB-1F3FE:Class;
		[Embed(source = "smiles/1f3cb-1f3ff.png")] public var SM_1F3CB-1F3FF:Class;
		[Embed(source = "smiles/1f385-1f3fb.png")] public var SM_1F385-1F3FB:Class;
		[Embed(source = "smiles/1f385-1f3fc.png")] public var SM_1F385-1F3FC:Class;
		[Embed(source = "smiles/1f385-1f3fd.png")] public var SM_1F385-1F3FD:Class;
		[Embed(source = "smiles/1f385-1f3fe.png")] public var SM_1F385-1F3FE:Class;
		[Embed(source = "smiles/1f385-1f3ff.png")] public var SM_1F385-1F3FF:Class;*/
		
		static public var recentLoading:Boolean = false;
		static public var recentLoaded:Boolean = false;
		static public var recentSmiles:Array = [];
		static public function addSmileToRecent(arr:Array):void {
			var rs:Array;
			var i:int = 0
			for (i; i < recentSmiles.length; i++) {
				if (recentSmiles[i][0] == arr[0]) {
					rs = recentSmiles[i];
					rs[2] ++;
					recentSmiles.splice(i, 1);
					i --;
					for (i; i > -1; i--) {
						if (recentSmiles[i][2] > rs[2]) {
							recentSmiles.splice(i + 1, 0, rs);
							break;
						}
					}
					if (i == -1)
						recentSmiles.unshift(rs);
					return;
				}
			}
			if (arr.length == 2)
				arr.push(1);
			for (i = recentSmiles.length; i > 0; i--) {
				if (recentSmiles[i - 1][2] > 1) {
					if (i != 60) {
						recentSmiles.splice(i, 0, arr);
						break;
					}
					break;
				}
			}
			if (i == 0)
				recentSmiles.unshift(arr);
			if (recentSmiles.length == 61)
				recentSmiles.splice(60, 1);
		}
		
		static public function saveRecentToStore():void {
			Store.save("recentSmiles", recentSmiles);
		}
		
		static public function loadRecentFromStore():void {
			if (recentLoaded == true || recentLoading == true)
				return;
			recentLoading = true;
			Store.load("recentSmiles", onRecentLoaded);
		}
		
		static private function onRecentLoaded(data:Object, err:Boolean):void {
			recentLoaded = true;
			recentLoading = false;
			if (err == true)
				return;
			recentSmiles = data as Array;
		}
		
		static public var emojiCategories:Array = [
			[
				[0x1f60a, "😊"],
				[0x1f60b, "😋"],
				[0x1f60d, "😍"],
				[0x1f60e, "😎"],
				[0x1f61a, "😚"],
				[0x1f61c, "😜"],
				[0x1f61d, "😝"],
				[0x1f61e, "😞"],
				[0x1f61f, "😟"],
				[0x1f62c, "😬"],
				[0x1f62f, "😯"],
				[0x1f600, "😀"],
				[0x1f601, "😁"],
				[0x1f602, "😂"],
				[0x1f603, "😃"],
				[0x1f604, "😄"],
				[0x1f606, "😆"],
				[0x1f607, "😇"],
				[0x1f608, "😈"],
				[0x1f609, "😉"],
				[0x1f610, "😐"],
				[0x1f612, "😒"],
				[0x1f615, "😕"],
				[0x1f618, "😘"],
				[0x1f621, "😡"],
				[0x1f623, "😣"],
				[0x1f625, "😥"],
				[0x1f626, "😦"],
				[0x1f628, "😨"],
				[0x1f631, "😱"],
				[0x1f632, "😲"],
				[0x1f634, "😴"],
				[0x1f637, "😷"],
				[0x1f643, "🙃"],
				[0x1f911, "🤑"],
				[0x1f912, "🤒"],
				[0x1f913, "🤓"],
				[0x1f915, "🤕"],
				[0x1f47f, "👿"],
				[0x263A, "☺"]
			], [
				[0x1f60c, "😌"],
				[0x1f60f, "😏"],
				[0x1f61b, "😛"],
				[0x1f62a, "😪"],
				[0x1f62b, "😫"],
				[0x1f62d, "😭"],
				[0x1f62e, "😮"],
				[0x1f605, "😅"],
				[0x1f611, "😑"],
				[0x1f613, "😓"],
				[0x1f614, "😔"],
				[0x1f616, "😖"],
				[0x1f617, "😗"],
				[0x1f619, "😙"],
				[0x1f620, "😠"],
				[0x1f622, "😢"],
				[0x1f624, "😤"],
				[0x1f627, "😧"],
				[0x1f629, "😩"],
				[0x1f630, "😰"],
				[0x1f633, "😳"],
				[0x1f635, "😵"],
				[0x1f636, "😶"],
				[0x1f641, "🙁"],
				[0x1f642, "🙂"],
				[0x1f644, "🙄"],
				[0x1f910, "🤐"],
				[0x1f914, "🤔"],
				[0x1f917, "🤗"]
			], [
				[0x1f638, "😸"],
				[0x1f639, "😹"],
				[0x1f63A, "😺"],
				[0x1f63b, "😻"],
				[0x1f63c, "😼"],
				[0x1f63d, "😽"],
				[0x1f63e, "😾"],
				[0x1f63f, "😿"],
				[0x1f640, "🙀"],
				[0x1f648, "🙈"],
				[0x1f649, "🙉"],
				[0x1f64a, "🙊"],
				[0x1f40c, "🐌"],
				[0x1f40d, "🐍"],
				[0x1f40e, "🐎"],
				[0x1f411, "🐑"],
				[0x1f412, "🐒"],
				[0x1f414, "🐔"],
				[0x1f417, "🐗"],
				[0x1f418, "🐘"],
				[0x1f419, "🐙"],
				[0x1f41a, "🐚"],
				[0x1f41b, "🐛"],
				[0x1f41c, "🐜"],
				[0x1f41d, "🐝"],
				[0x1f41e, "🐞"],
				[0x1f41f, "🐟"],
				[0x1f420, "🐠"],
				[0x1f421, "🐡"],
				[0x1f422, "🐢"],
				[0x1f423, "🐣"],
				[0x1f424, "🐤"],
				[0x1f425, "🐥"],
				[0x1f426, "🐦"],
				[0x1f427, "🐧"],
				[0x1f428, "🐨"],
				[0x1f429, "🐩"],
				[0x1f42b, "🐫"],
				[0x1f42c, "🐬"],
				[0x1f42d, "🐭"],
				[0x1f42e, "🐮"],
				[0x1f42f, "🐯"],
				[0x1f430, "🐰"],
				[0x1f431, "🐱"],
				[0x1f432, "🐲"],
				[0x1f433, "🐳"],
				[0x1f434, "🐴"],
				[0x1f435, "🐵"],
				[0x1f436, "🐶"],
				[0x1f437, "🐷"],
				[0x1f438, "🐸"],
				[0x1f439, "🐹"],
				[0x1f43a, "🐺"],
				[0x1f43b, "🐻"],
				[0x1f43c, "🐼"],
				[0x1f43d, "🐽"],
				[0x1f43e, "🐾"],
				[0x1f400, "🐀"],
				[0x1f401, "🐁"],
				[0x1f402, "🐂"],
				[0x1f403, "🐃"],
				[0x1f404, "🐄"],
				[0x1f405, "🐅"],
				[0x1f406, "🐆"],
				[0x1f407, "🐇"],
				[0x1f408, "🐈"],
				[0x1f409, "🐉"],
				[0x1f40a, "🐊"],
				[0x1f40b, "🐋"],
				[0x1f40f, "🐏"],
				[0x1f410, "🐐"],
				[0x1f413, "🐓"],
				[0x1f415, "🐕"],
				[0x1f416, "🐖"],
				[0x1f42a, "🐪"]
			], [
				[0x1f30f, "🌏"],
				[0x1f311, "🌑"],
				[0x1f313, "🌓"],
				[0x1f314, "🌔"],
				[0x1f315, "🌕"],
				[0x1f319, "🌙"],
				[0x1f31b, "🌛"],
				[0x1f31f, "🌟"],
				[0x1f330, "🌰"],
				[0x1f331, "🌱"],
				[0x1f334, "🌴"],
				[0x1f335, "🌵"],
				[0x1f337, "🌷"],
				[0x1f338, "🌸"],
				[0x1f339, "🌹"],
				[0x1f33a, "🌺"],
				[0x1f33b, "🌻"],
				[0x1f33c, "🌼"],
				[0x1f33d, "🌽"],
				[0x1f33e, "🌾"],
				[0x1f33f, "🌿"],
				[0x1f340, "🍀"],
				[0x1f341, "🍁"],
				[0x1f342, "🍂"],
				[0x1f343, "🍃"],
				[0x1f344, "🍄"],
				[0x1f345, "🍅"],
				[0x1f346, "🍆"],
				[0x1f347, "🍇"],
				[0x1f348, "🍈"],
				[0x1f349, "🍉"],
				[0x1f34a, "🍊"],
				[0x1f34c, "🍌"],
				[0x1f34d, "🍍"],
				[0x1f34e, "🍎"],
				[0x1f34f, "🍏"],
				[0x1f351, "🍑"],
				[0x1f352, "🍒"],
				[0x1f353, "🍓"],
				[0x1f354, "🍔"],
				[0x1f355, "🍕"],
				[0x1f356, "🍖"],
				[0x1f357, "🍗"],
				[0x1f358, "🍘"],
				[0x1f359, "🍙"],
				[0x1f35a, "🍚"],
				[0x1f35b, "🍛"],
				[0x1f35c, "🍜"],
				[0x1f35d, "🍝"],
				[0x1f35e, "🍞"],
				[0x1f35f, "🍟"],
				[0x1f360, "🍠"],
				[0x1f361, "🍡"],
				[0x1f362, "🍢"],
				[0x1f363, "🍣"],
				[0x1f364, "🍤"],
				[0x1f365, "🍥"],
				[0x1f366, "🍦"],
				[0x1f367, "🍧"],
				[0x1f368, "🍨"],
				[0x1f369, "🍩"],
				[0x1f36a, "🍪"],
				[0x1f36b, "🍫"],
				[0x1f36c, "🍬"],
				[0x1f36d, "🍭"],
				[0x1f36e, "🍮"],
				[0x1f36f, "🍯"],
				[0x1f370, "🍰"],
				[0x1f371, "🍱"],
				[0x1f372, "🍲"],
				[0x1f373, "🍳"],
				[0x1f374, "🍴"],
				[0x1f375, "🍵"],
				[0x1f376, "🍶"],
				[0x1f377, "🍷"],
				[0x1f378, "🍸"],
				[0x1f379, "🍹"],
				[0x1f37a, "🍺"],
				[0x1f37b, "🍻"],
				[0x1f380, "🎀"],
				[0x1f381, "🎁"],
				[0x1f382, "🎂"],
				[0x1f383, "🎃"],
				[0x1f384, "🎄"],
				[0x1f385, "🎅"],
				[0x2615, "☕"]
			], [
				[0x1f52d, "🔭"],
				[0x1f52c, "🔬"],
				[0x1f515, "🔕"],
				[0x1f509, "🔉"],
				[0x1f507, "🔇"],
				[0x1f4f5, "📵"],
				[0x1f4ef, "📯"],
				[0x1f4ed, "📭"],
				[0x1f4ec, "📬"],
				[0x1f4b6, "💶"],
				[0x1f4ad, "💭"],
				[0x1f3e4, "🏤"],
				[0x1f3c9, "🏉"],
				[0x1f3c7, "🏇"],
				[0x1f6c1, "🛁"],
				[0x1f6bf, "🚿"],
				[0x1f525, "🔥"],
				[0x1f526, "🔦"],
				[0x1f527, "🔧"],
				[0x1f528, "🔨"],
				[0x1f529, "🔩"],
				[0x1f52a, "🔪"],
				[0x1f52b, "🔫"],
				[0x1f52e, "🔮"],
				[0x1f517, "🔗"],
				[0x1f514, "🔔"],
				[0x1f513, "🔓"],
				[0x1f512, "🔒"],
				[0x1f511, "🔑"],
				[0x1f50e, "🔎"],
				[0x1f50a, "🔊"],
				[0x1f4f7, "📷"],
				[0x1f4f9, "📹"],
				[0x1f4fa, "📺"],
				[0x1f4fb, "📻"],
				[0x1f4e6, "📦"],
				[0x1f4e3, "📣"],
				[0x1f4e2, "📢"],
				[0x1f4e1, "📡"],
				[0x1f4de, "📞"],
				[0x1f4dc, "📜"],
				[0x1f4da, "📚"],
				[0x1f4d6, "📖"],
				[0x1f4d5, "📕"],
				[0x1f4ce, "📎"],
				[0x1f4cb, "📋"],
				[0x1f4c8, "📈"],
				[0x1f4c9, "📉"],
				[0x1f4c7, "📇"],
				[0x1f4b5, "💵"],
				[0x1f4b0, "💰"],
				[0x1f4aa, "💪"],
				[0x1f4a9, "💩"],
				[0x1f550, "🕐"],
				[0x1f551, "🕑"],
				[0x1f552, "🕒"],
				[0x1f553, "🕓"],
				[0x1f554, "🕔"],
				[0x1f555, "🕕"],
				[0x1f556, "🕖"],
				[0x1f557, "🕗"],
				[0x1f558, "🕘"],
				[0x1f559, "🕙"],
				[0x1f55a, "🕚"],
				[0x1f55b, "🕛"],
				[0x1f55c, "🕜"],
				[0x1f55d, "🕝"],
				[0x1f55e, "🕞"],
				[0x1f55f, "🕟"],
				[0x1f560, "🕠"],
				[0x1f561, "🕡"],
				[0x1f562, "🕢"],
				[0x1f563, "🕣"],
				[0x1f564, "🕤"],
				[0x1f565, "🕥"],
				[0x1f566, "🕦"],
				[0x1f567, "🕧"]
			], [
				[0x2708, "✈"],
				[0x2709, "✉"],
				[0x1f680, "🚀"],
				[0x1f683, "🚃"],
				[0x1f684, "🚄"],
				[0x1f685, "🚅"],
				[0x1f687, "🚇"],
				[0x1f689, "🚉"],
				[0x1f68c, "🚌"],
				[0x1f68f, "🚏"],
				[0x1f691, "🚑"],
				[0x1f692, "🚒"],
				[0x1f693, "🚓"],
				[0x1f695, "🚕"],
				[0x1f697, "🚗"],
				[0x1f699, "🚙"],
				[0x1f69a, "🚚"],
				[0x1f6a2, "🚢"],
				[0x1f6a4, "🚤"],
				[0x1f6a5, "🚥"],
				[0x1f6a7, "🚧"],
				[0x1f6a8, "🚨"],
				[0x1f6a9, "🚩"],
				[0x1f6aa, "🚪"],
				[0x1f6ab, "🚫"],
				[0x1f6ac, "🚬"],
				[0x1f6ad, "🚭"],
				[0x1f6b2, "🚲"],
				[0x1f6b6, "🚶"],
				[0x1f6b9, "🚹"],
				[0x1f6ba, "🚺"],
				[0x1f6bb, "🚻"],
				[0x1f6bc, "🚼"],
				[0x1f6bd, "🚽"],
				[0x1f6be, "🚾"],
				[0x1f6c0, "🛀"],
				[0x1f302, "🌂"],
				[0x1f392, "🎒"],
				[0x1f681, "🚁"],
				[0x1f682, "🚂"],
				[0x1f686, "🚆"],
				[0x1f688, "🚈"],
				[0x1f68a, "🚊"],
				[0x1f68d, "🚍"],
				[0x1f68e, "🚎"],
				[0x1f690, "🚐"],
				[0x1f694, "🚔"],
				[0x1f696, "🚖"],
				[0x1f698, "🚘"],
				[0x1f69b, "🚛"],
				[0x1f69c, "🚜"],
				[0x1f69d, "🚝"],
				[0x1f69e, "🚞"],
				[0x1f69f, "🚟"],
				[0x1f6a0, "🚠"],
				[0x1f6a1, "🚡"],
				[0x1f6a3, "🚣"],
				[0x1f6a6, "🚦"],
				[0x1f6ae, "🚮"],
				[0x1f6af, "🚯"],
				[0x1f6b0, "🚰"],
				[0x1f6b1, "🚱"],
				[0x1f6b3, "🚳"],
				[0x1f6b7, "🚷"]
			]
		];
		
		static private var ranges:Array = [
			[0xa9, 0xa9],
			[0xae, 0xae],
			[0x203c, 0x203c],
			[0x2049, 0x2049],
			[0x2122, 0x2122],
			[0x2139, 0x2139],
			[0x2194, 0x2199],
			[0x21a9, 0x21aa],
			[0x231a, 0x231b],
			[0x2328, 0x2328],
			[0x23e9, 0x23f3],
			[0x23f8, 0x23fa],
			[0x24c2, 0x24c2],
			[0x25aa, 0x25ab],
			[0x25b6, 0x25b6],
			[0x25c0, 0x25c0],
			[0x25fb, 0x25fe],
			[0x2600, 0x2604],
			[0x260e, 0x260e],
			[0x2611, 0x2611],
			[0x2614, 0x2615],
			[0x2618, 0x2618],
			[0x261d, 0x261d],
			[0x2620, 0x2620],
			[0x2622, 0x2623],
			[0x2626, 0x2626],
			[0x262a, 0x262a],
			[0x262e, 0x262f],
			[0x2638, 0x263a],
			[0x2648, 0x2653],
			[0x2660, 0x2660],
			[0x2663, 0x2663],
			[0x2665, 0x2666],
			[0x2668, 0x2668],
			[0x267b, 0x267b],
			[0x267f, 0x267f],
			[0x2692, 0x2694],
			[0x2696, 0x2697],
			[0x2699, 0x2699],
			[0x269b, 0x269c],
			[0x26a0, 0x26a1],
			[0x26aa, 0x26ab],
			[0x26b0, 0x26b1],
			[0x26bd, 0x26be],
			[0x26c4, 0x26c5],
			[0x26c8, 0x26c8],
			[0x26ce, 0x26cf],
			[0x26d1, 0x26d1],
			[0x26d3, 0x26d4],
			[0x26e9, 0x26ea],
			[0x26f0, 0x26f5],
			[0x26f7, 0x26fa],
			[0x26fd, 0x26fd],
			[0x2702, 0x2702],
			[0x2705, 0x2705],
			[0x2708, 0x270d],
			[0x270f, 0x270f],
			[0x2712, 0x2712],
			[0x2714, 0x2714],
			[0x2716, 0x2716],
			[0x271d, 0x271d],
			[0x2721, 0x2721],
			[0x2728, 0x2728],
			[0x2733, 0x2734],
			[0x2744, 0x2744],
			[0x2747, 0x2747],
			[0x274c, 0x274c],
			[0x274e, 0x274e],
			[0x2753, 0x2755],
			[0x2757, 0x2757],
			[0x2763, 0x2764],
			[0x2795, 0x2797],
			[0x27a1, 0x27a1],
			[0x27b0, 0x27b0],
			[0x27bf, 0x27bf],
			[0x2934, 0x2935],
			[0x2b05, 0x2b07],
			[0x2b1b, 0x2b1c],
			[0x2b50, 0x2b50],
			[0x2b55, 0x2b55],
			[0x3030, 0x3030],
			[0x303d, 0x303d],
			[0x3297, 0x3297],
			[0x3299, 0x3299],
			[0x1f004, 0x1f004],
			[0x1f0cf, 0x1f0cf],
			[0x1f170, 0x1f171],
			[0x1f17e, 0x1f17f],
			[0x1f18e, 0x1f18e],
			[0x1f191, 0x1f19a],
			[0x1f201, 0x1f202],
			[0x1f21a, 0x1f21a],
			[0x1f22f, 0x1f22f],
			[0x1f232, 0x1f23a],
			[0x1f250, 0x1f251],
			[0x1f300, 0x1f321],
			[0x1f324, 0x1f393],
			[0x1f396, 0x1f397],
			[0x1f399, 0x1f39b],
			[0x1f39e, 0x1f3f0],
			[0x1f3f3, 0x1f3f5],
			[0x1f3f7, 0x1f4fd],
			[0x1f4ff, 0x1f53d],
			[0x1f549, 0x1f54e],
			[0x1f550, 0x1f567],
			[0x1f56f, 0x1f570],
			[0x1f573, 0x1f579],
			[0x1f587, 0x1f587],
			[0x1f58a, 0x1f58d],
			[0x1f590, 0x1f590],
			[0x1f595, 0x1f596],
			[0x1f5a5, 0x1f5a5],
			[0x1f5a8, 0x1f5a8],
			[0x1f5b1, 0x1f5b2],
			[0x1f5bc, 0x1f5bc],
			[0x1f5c2, 0x1f5c4],
			[0x1f5d1, 0x1f5d3],
			[0x1f5dc, 0x1f5de],
			[0x1f5e1, 0x1f5e1],
			[0x1f5e3, 0x1f5e3],
			[0x1f5e8, 0x1f5e8],
			[0x1f5ef, 0x1f5ef],
			[0x1f5f3, 0x1f5f3],
			[0x1f5fa, 0x1f64f],
			[0x1f680, 0x1f6c5],
			[0x1f6cb, 0x1f6d0],
			[0x1f6e0, 0x1f6e5],
			[0x1f6e9, 0x1f6e9],
			[0x1f6eb, 0x1f6ec],
			[0x1f6f0, 0x1f6f0],
			[0x1f6f3, 0x1f6f3],
			[0x1f910, 0x1f918],
			[0x1f980, 0x1f984]
		];
		
		static private var smiles:Array = [];
		static private var codes:RichTextSmilesCodes = null;
		
		public function RichTextSmilesCodes(nah:Nah) { };
		
		static public function checkSmile(code:int):Boolean {
			/* *
			if (codes == null)
				codes = new RichTextSmilesCodes(new Nah());
			var className:String = "SM_" + code.toString(16).toUpperCase();
			return className in code;
			
			/* */
			var l:int = ranges.length;
			for (var n:int = 0; n < l; n++) {
				var r:Array = ranges[n];
				if (code >= r[0] && code <= r[1])
					return true;
			}
			return false;
			/* */
		}
		
		static public function getSmileByCode(str:String):BitmapData {
			if (codes == null)
				codes = new RichTextSmilesCodes(new Nah());
			var n:int = 0;
			var l:int = smiles.length;
			for (n; n < l; n++) {
				if (smiles[n][0] == str)
					return smiles[n][1];
			}
			var className:String = "SM_" + str.toUpperCase();
			var bmp:Bitmap = null;
			try{
				bmp = new codes[className]() as Bitmap;
			}catch (e:Error) {
				bmp=new codes.SM_1F600() as Bitmap;
			}
			
			bmp.smoothing = true;
			smiles.push([str, bmp.bitmapData]);
			return bmp.bitmapData;
		}
		
		static public function getAllCodes():void {
			var f:File = new File("c://smiles");
			var a:Array = [];
			
			var __removeListeners:Function = function():void {
				f.removeEventListener(FileListEvent.DIRECTORY_LISTING, __onDirectoryListed);
				f.removeEventListener(IOErrorEvent.IO_ERROR, __onDirIOError);
				f.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, __onDirSecError);
			}
			
			var __onDirIOError:Function = function(e:IOErrorEvent):void {
				__removeListeners();
			}
			
			var __onDirSecError:Function = function(e:SecurityErrorEvent):void {
				__removeListeners();
			}
			
			var __onDirectoryListed:Function = function(e:FileListEvent):void {
				__removeListeners();
				var l:int = e.files.length;
				var n:int = 0;
				var fle:File;
				for (n; n < l; n++) {
					fle = e.files[n];
					if (fle.exists && fle.name.indexOf("-") == -1) {
						a.push(int('0x' + fle.name.substring(0, fle.name.indexOf('.'))));
						a.sort(function(a:int, b:int):int {
							if (a < b)
								return -1;
							if (a > b)
								return 1;
							return 0;
						});
					}
				}
				var first:int = 0;
				var current:int = 0;
				var last:int = 0;
				for (var i:int = 0; i < a.length; i++) {
					first = a[i];
					last = a[i];
					for (i = i+1; i < a.length; i++) {
						current = a[i];
						if (current - 1 == last) {
							last = current;
							continue;
						}
						trace("[0x" + first.toString(16) +", 0x" + last.toString(16) + "]");
						i--;
						break;
					}
				}
			}
			
			if (f.exists && f.isDirectory) {
				f.addEventListener(FileListEvent.DIRECTORY_LISTING, __onDirectoryListed);
				f.addEventListener(IOErrorEvent.IO_ERROR, __onDirIOError);
				f.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __onDirSecError);
				f.getDirectoryListingAsync();
			}
		}
		
		static public function getSmileStringByCode(code:uint):String {
			for (var i:int = 0; i < emojiCategories.length; i++) {
				for (var j:int = 0; j < emojiCategories[i].length; j++) {
					if (emojiCategories[i][j][0] == code)
						return emojiCategories[i][j][1];
				}
			}
			return "";
		}
	}
}
class Nah { };