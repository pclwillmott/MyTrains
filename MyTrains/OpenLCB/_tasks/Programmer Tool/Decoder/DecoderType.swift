//
//  DecoderType.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/07/2024.
//

import Foundation

public enum DecoderType : UInt64, CaseIterable {
  
  // MARK: Enumeration
  
  case nmra = 0
  case lokSound5 = 1 // "LokSound 5" "5.10.166"
  case lokSoundV4_0M4OEM = 2 // "LokSound V4.0 M4 OEM" "4.17.9249"
  case lokPilotV4_0DCC = 3 // "LokPilot V4.0 DCC" "4.16.9247"
  case lokPilotV3_0DCC = 4 // "LokPilot V3.0 DCC" "0.0.6607"
  case lokPilot5Fx = 5 // "LokPilot 5 Fx" "5.10.166"
  case lokSoundmicroV3_5 = 6 // "LokSound micro V3.5" "0.0.6093"
  case lokSound5microDCC = 7 // "LokSound 5 micro DCC" "5.10.166"
  case lokSoundXLV4_0 = 8 // "LokSound XL V4.0" "4.17.9249"
  case lokPilot5Basic = 9 // "LokPilot 5 Basic" "5.1.6"
  case lokPilot5MKLDCC = 10 // "LokPilot 5 MKL DCC" "5.10.166"
  case lokPilotV4_0M4 = 11 // "LokPilot V4.0 M4" "4.16.9247"
  case lokSound5microKATO = 12 // "LokSound 5 micro KATO" "5.10.166"
  case lokPilotXLV4_0 = 13 // "LokPilot XL V4.0" "4.16.9247"
  case lokSoundV4_0M4 = 14 // "LokSound V4.0 M4" "4.17.9249"
  case lokSound5nanoDCCNext18 = 15 // "LokSound 5 nano DCC Next18" "5.10.166"
  case lokPilotmicroV3_0DCC = 16 // "LokPilot micro V3.0 DCC" "0.0.6607"
  case lokSound5XL = 17 // "LokSound 5 XL" "5.10.166"
  case lokPilotmicroV4_0DCC = 18 // "LokPilot micro V4.0 DCC" "4.16.9247"
  case lokPilot5microNext18DCC = 19 // "LokPilot 5 micro Next18 DCC" "5.10.166"
  case lokPilot5FxmicroDCC = 20 // "LokPilot 5 Fx micro DCC" "5.10.166"
  case lokPilotXLV3_0 = 21 // "LokPilot XL V3.0" "0.0.6607"
  case lokPilotNanoStandardV1_0 = 22 // "LokPilot Nano Standard V1.0" "1.2.1415"
  case lokPilot5FxmicroNext18DCC = 23 // "LokPilot 5 Fx micro Next18 DCC" "5.10.166"
  case lokSound5Fx = 24 // "LokSound 5 Fx" "5.10.166"
  case lokPilot5 = 25 // "LokPilot 5" "5.10.166"
  case lokSoundSelectL = 26 // "LokSound Select L" "4.17.9249"
  case lokPilot5FxDCC = 27 // "LokPilot 5 Fx DCC" "5.10.166"
  case lokPilot5microDCC = 28 // "LokPilot 5 micro DCC" "5.10.166"
  case lokPilot5L = 29 // "LokPilot 5 L" "5.10.166"
  case lokSound5microDCCDirectAtlasLegacy = 30 // "LokSound 5 micro DCC Direct Atlas Legacy" "5.10.166"
  case lokPilot5FxmicroNext18 = 31 // "LokPilot 5 Fx micro Next18" "5.10.166"
  case lokPilotFxmicroV3_0 = 32 // "LokPilot Fx micro V3.0" "0.0.6607"
  case lokSoundV3_5 = 33 // "LokSound V3.5" "0.0.6093"
  case lokPilotBasic = 34 // "LokPilot Basic" "0.9.0"
  case lokSoundSelectdirect_micro = 35 // "LokSound Select direct / micro" "4.17.9249"
  case lokSound5microDCCDirect = 36 // "LokSound 5 micro DCC Direct" "5.10.166"
  case lokSoundSelectOEM = 37 // "LokSound Select OEM" "4.17.9249"
  case lokSoundXLV3_5 = 38 // "LokSound XL V3.5" "0.0.6093su"
  case lokSound5MKL = 39 // "LokSound 5 MKL" "5.10.166"
  case essentialSoundUnit = 40 // "Essential Sound Unit" "5.10.166"
  case lokPilotFxNanoV1_0 = 41 // "LokPilot Fx Nano V1.0" "1.2.1415"
  case lokPilotV3_0OEM = 42 // "LokPilot V3.0 OEM" "0.0.5973"
  case lokSoundmicroV4_0 = 43 // "LokSound micro V4.0" "4.17.9249"
  case lokSoundLV4_0 = 44 // "LokSound L V4.0" "4.17.9249"
  case lokSound5L = 45 // "LokSound 5 L" "5.10.166"
  case lokPilot5Fxmicro = 46 // "LokPilot 5 Fx micro" "5.10.166"
  case lokPilot5microDCCDirect = 47 // "LokPilot 5 micro DCC Direct" "5.10.166"
  case lokPilotFxV3_0 = 48 // "LokPilot Fx V3.0" "0.0.6442"
  case lokSound5DCC = 49 // "LokSound 5 DCC" "5.10.166"
  case lokPilotV4_0 = 50 // "LokPilot V4.0" "4.16.9247"
  case lokSound5nanoDCC = 51 // "LokSound 5 nano DCC" "5.10.166"
  case lokPilotmicroV3_0 = 52 // "LokPilot micro V3.0" "0.0.6607"
  case lokPilotFxV4_0 = 53 // "LokPilot Fx V4.0" "4.16.9247"
  case lokPilot5LDCC = 54 // "LokPilot 5 L DCC" "5.10.166"
  case lokPilot5micro = 55 // "LokPilot 5 micro" "5.10.166"
  case lokPilotV3_0 = 56 // "LokPilot V3.0" "0.0.6607"
  case lokSound5FxDCC = 57 // "LokSound 5 Fx DCC" "5.10.166"
  case lokPilotV4_0DCCPX = 58 // "LokPilot V4.0 DCC PX" "4.16.9247"
  case lokSoundV3_0M4 = 59 // "LokSound V3.0 M4" "0.0.6354"
  case lokPilotmicroV4_0 = 60 // "LokPilot micro V4.0" "4.16.9247"
  case lokPilot5DCC = 61 // "LokPilot 5 DCC" "5.10.166"
  case lokPilotMicroSlideInV4_0DCC = 62 // "LokPilot Micro SlideIn V4.0 DCC" "4.16.9247"
  case lokPilot5nanoDCC = 63 // "LokPilot 5 nano DCC" "5.10.166"
  case lokSoundV4_0 = 64 // "LokSound V4.0" "4.17.9249"
  case lokPilotV4_0M4MKL = 65 // "LokPilot V4.0 M4 MKL" "4.16.9247"
  case lokPilotV3_0M4 = 66 // "LokPilot V3.0 M4" "0.0.6445"
  case lokPilotBasicLA = 67 // "LokPilot Basic" "0.9.0)"
  case lokSound5microDCCDirectAtlasS2 = 68 // "LokSound 5 micro DCC Direct Atlas S2" "5.10.166"
  case lokPilot5microNext18 = 69 // "LokPilot 5 micro Next18" "5.10.166"
  case lokSoundSelect = 70 // "LokSound Select" "4.17.9249"
  case lokPilotStandardV1_0 = 71 // "LokPilot Standard V1.0" "1.2.1415"
  case lokPilot5MKL = 72 // "LokPilot 5 MKL" "5.10.166"
  case lokSound5LDCC = 73 // "LokSound 5 L DCC" "5.10.166"
  case lokSound5micro = 74 // "LokSound 5 micro" "5.10.166"
  
  // MARK: Public Properties
  
  public var cvListFilename : String {
    
    let lookup : [DecoderType:String] = [
      
      .lokPilotV4_0DCCPX : "LokPilot V4.0 DCC PX [4.16.9247].cvlist",
      .lokPilot5L : "LokPilot 5 L [5.10.166].cvlist",
      .lokPilotV3_0 : "LokPilot V3.0 [0.0.6607].cvlist",
      .lokPilot5FxmicroDCC : "LokPilot 5 Fx micro DCC [5.10.166].cvlist",
      .lokSoundmicroV4_0 : "LokSound micro V4.0 [4.17.9249].cvlist",
      .lokPilotBasic : "LokPilot Basic [0.9.0].cvlist",
      .lokSoundSelect : "LokSound Select [4.17.9249].cvlist",
      .lokSound5 : "LokSound 5 [5.10.166].cvlist",
      .lokPilot5FxmicroNext18DCC : "LokPilot 5 Fx micro Next18 DCC [5.10.166].cvlist",
      .lokPilotV4_0M4 : "LokPilot V4.0 M4 [4.16.9247].cvlist",
      .lokSoundSelectL : "LokSound Select L [4.17.9249].cvlist",
      .lokSound5micro : "LokSound 5 micro [5.10.166].cvlist",
      .lokPilot5Basic : "LokPilot 5 Basic [5.1.6].cvlist",
      .lokPilot5micro : "LokPilot 5 micro [5.10.166].cvlist",
      .lokPilotmicroV4_0 : "LokPilot micro V4.0 [4.16.9247].cvlist",
      .lokPilotFxNanoV1_0 : "LokPilot Fx Nano V1.0 [1.2.1415].cvlist",
      .lokPilotMicroSlideInV4_0DCC : "LokPilot Micro SlideIn V4.0 DCC [4.16.9247].cvlist",
      .lokSoundV4_0M4 : "LokSound V4.0 M4 [4.17.9249].cvlist",
      .lokSound5microDCC : "LokSound 5 micro DCC [5.10.166].cvlist",
      .lokPilotStandardV1_0 : "LokPilot Standard V1.0 [1.2.1415].cvlist",
      .lokPilot5 : "LokPilot 5 [5.10.166].cvlist",
      .lokSoundV3_5 : "LokSound V3.5 [0.0.6093].cvlist",
      .lokPilot5microNext18 : "LokPilot 5 micro Next18 [5.10.166].cvlist",
      .lokSound5XL : "LokSound 5 XL [5.10.166].cvlist",
      .lokSoundV4_0M4OEM : "LokSound V4.0 M4 OEM [4.17.9249].cvlist",
      .lokSoundXLV3_5 : "LokSound XL V3.5 [0.0.6093su].cvlist",
      .lokSound5microDCCDirect : "LokSound micro DCC Direct [5.10.166].cvlist",
      .lokPilot5MKL : "LokPilot 5 MKL [5.10.166].cvlist",
      .lokPilot5FxDCC : "LokPilot 5 Fx DCC [5.10.166].cvlist",
      .lokPilot5Fxmicro : "LokPilot 5 Fx micro [5.10.166].cvlist",
      .lokSound5microDCCDirectAtlasS2 : "LokSound micro DCC Direct Atlas S2 [5.10.166].cvlist",
      .lokPilot5Fx : "LokPilot 5 Fx [5.10.166].cvlist",
      .lokSound5MKL : "LokSound 5 MKL [5.10.166].cvlist",
      .lokSound5nanoDCCNext18 : "LokSound 5 nano DCC Next18 [5.10.166].cvlist",
      .lokSoundV4_0 : "LokSound V4.0 [4.17.9249].cvlist",
      .lokSound5Fx : "LokSound 5 Fx [5.10.166].cvlist",
      .lokPilot5MKLDCC : "LokPilot 5 MKL DCC [5.10.166].cvlist",
      .lokPilot5microDCCDirect : "LokPilot 5 micro DCC Direct [5.10.166].cvlist",
      .lokPilot5LDCC : "LokPilot 5 L DCC [5.10.166].cvlist",
      .lokPilotV4_0DCC : "LokPilot V4.0 DCC [4.16.9247].cvlist",
      .lokPilotXLV4_0 : "LokPilot XL V4.0 [4.16.9247].cvlist",
      .lokPilotmicroV3_0 : "LokPilot micro V3.0 [0.0.6607].cvlist",
      .lokPilotmicroV4_0DCC : "LokPilot micro V4.0 DCC [4.16.9247].cvlist",
      .lokSoundSelectdirect_micro : "LokSound Select direct - micro [4.17.9249].cvlist",
      .lokPilotmicroV3_0DCC : "LokPilot micro V3.0 DCC [0.0.6607].cvlist",
      .lokSoundmicroV3_5 : "LokSound micro V3.5 [0.0.6093].cvlist",
      .lokPilotBasicLA : "LokPilot Basic (LA) [0.9.0].cvlist",
      .lokPilotFxmicroV3_0 : "LokPilot Fx micro V3.0 [0.0.6607].cvlist",
      .lokSoundXLV4_0 : "LokSound XL V4.0 [4.17.9249].cvlist",
      .lokSoundSelectOEM : "LokSound Select OEM [4.17.9249].cvlist",
      .lokSound5nanoDCC : "LokSound 5 nano DCC [5.10.166].cvlist",
      .essentialSoundUnit : "Essential Sound Unit [5.10.166].cvlist",
      .lokPilotNanoStandardV1_0 : "LokPilot Nano Standard V1.0 [1.2.1415].cvlist",
      .lokSoundV3_0M4 : "LokSound V3.0 M4 [0.0.6354].cvlist",
      .lokSound5LDCC : "LokSound 5 L DCC [5.10.166].cvlist",
      .lokPilotV3_0OEM : "LokPilot V3.0 OEM [0.0.5973].cvlist",
      .lokPilotFxV3_0 : "LokPilot Fx V3.0 [0.0.6442].cvlist",
      .lokPilotXLV3_0 : "LokPilot XL V3.0 [0.0.6607].cvlist",
      .lokPilot5DCC : "LokPilot 5 DCC [5.10.166].cvlist",
      .lokSound5microDCCDirectAtlasLegacy : "LokSound micro DCC Direct Atlas Legacy [5.10.166].cvlist",
      .lokSound5L : "LokSound 5 L [5.10.166].cvlist",
      .lokPilotV4_0M4MKL : "LokPilot V4.0 M4 MKL [4.16.9247].cvlist",
      .lokSoundLV4_0 : "LokSound L V4.0 [4.17.9249].cvlist",
      .lokPilotV3_0M4 : "LokPilot V3.0 M4 [0.0.6445].cvlist",
      .lokPilot5FxmicroNext18 : "LokPilot 5 Fx micro Next18 [5.10.166].cvlist",
      .lokSound5FxDCC : "LokSound 5 Fx DCC [5.10.166].cvlist",
      .lokPilot5microDCC : "LokPilot 5 micro DCC [5.10.166].cvlist",
      .lokPilotFxV4_0 : "LokPilot Fx V4.0 [4.16.9247].cvlist",
      .lokPilot5nanoDCC : "LokPilot 5 nano DCC [5.10.166].cvlist",
      .lokPilotV4_0 : "LokPilot V4.0 [4.16.9247].cvlist",
      .lokPilotV3_0DCC : "LokPilot V3.0 DCC [0.0.6607].cvlist",
      .lokPilot5microNext18DCC : "LokPilot 5 micro Next18 DCC [5.10.166].cvlist",
      .lokSound5DCC : "LokSound 5 DCC [5.10.166].cvlist",
      .lokSound5microKATO : "LokSound 5 micro KATO [5.10.166].cvlist",
    
    ]
    
    return lookup[self]!
    
  }
  
  public static let esuProductIdLookup : [UInt32:DecoderType] = [
   
    0x02000096 : lokSound5,
    0x020000F7 : lokSound5,
    0x020000DA : lokSound5,
    0x0200009C : lokSound5DCC,
    0x020000F8 : lokSound5DCC,
    0x020000DB : lokSound5DCC,
   /*
   0x0200009B  LokSound 5 micro
   0x0200009E  LokSound 5 micro DCC
   0x0100009A  LokSound 5 micro DCC Direct
   0x010000D8  LokSound 5 micro DCC Direct Atlas Legacy
   0x010000FB  LokSound 5 micro DCC Direct Atlas S2
   0x010000BC  LokSound 5 nano DCC
   0x010000E4  LokSound 5 nano DCC Next18
   0x0200009D  LokSound 5 L
   0x020000E2  LokSound 5 L
   0x020000DD  LokSound 5 L
   0x020000A0  LokSound 5 L DCC
   0x020000E3  LokSound 5 L DCC
   0x020000DE  LokSound 5 L DCC
   0x0200009F  LokSound 5 XL
   0x020000C5  LokSound 5 Fx
   0x020000C6  LokSound 5 Fx DCC
   0x020000A6  LokSound 5 MKL
   0x020000F9  LokSound 5 MKL
   0x020000DC  LokSound 5 MKL
   0x010000BD  LokSound 5 micro KATO
   0x0200003D  LokSound V4.0
   0x02000047  LokSound V4.0
   0x0200006A  LokSound V4.0
   0x0200003C  LokSound Select
   0x0200004F  LokSound Select
   0x0200005F  LokSound Select
   0x02000089  LokSound Select
   0x02000041  LokSound micro V4.0
   0x02000078  LokSound micro V4.0
   0x0200004A  LokSound Select direct / micro
   0x0200006F  LokSound Select direct / micro
   0x02000080  LokSound Select direct / micro
   0x02000065  LokSound Select OEM
   0x0200008A  LokSound Select OEM
   0x0200004B  LokSound XL V4.0
   0x0200006D  LokSound XL V4.0
   0x02000044  LokSound V4.0 M4
   0x02000068  LokSound V4.0 M4
   0x02000059  LokSound V4.0 M4 OEM
   0x02000073  LokSound V4.0 M4 OEM
   0x02000070  LokSound L V4.0
   0x02000079  LokSound Select L
   0x0100000D  LokSound V3.5
   0x01000012  LokSound V3.5
   0x01000017  LokSound V3.5
   0x01000020  LokSound V3.5
   0x0100000E  LokSound XL V3.5
   0x01000014  LokSound XL V3.5
   0x01000024  LokSound XL V3.5
   0x0200000E  LokSound V3.0 M4
   0x02000015  LokSound V3.0 M4
   0x02000021  LokSound V3.0 M4
   0x01000019  LokSound micro V3.5
   0x0100001E  LokSound micro V3.5
   0x020000A8  LokPilot 5
   0x020000CC  LokPilot 5
   0x020000AA  LokPilot 5 DCC
   0x020000CE  LokPilot 5 DCC
   0x010000AE  LokPilot 5 micro
   0x010000AF  LokPilot 5 micro DCC
   0x010000E1  LokPilot 5 micro DCC Direct
   0x020000AC  LokPilot 5 micro Next18
   0x020000AD  LokPilot 5 micro Next18 DCC
   0x010000FC  LokPilot 5 nano DCC
   0x020000B1  LokPilot 5 L
   0x020000CF  LokPilot 5 L
   0x020000F0  LokPilot 5 L
   0x020000B2  LokPilot 5 L DCC
   0x020000D0  LokPilot 5 L DCC
   0x020000F1  LokPilot 5 L DCC
   0x010000BE  LokPilot 5 Fx
   0x010000D1  LokPilot 5 Fx
   0x010000BF  LokPilot 5 Fx DCC
   0x010000D2  LokPilot 5 Fx DCC
   0x020000B3  LokPilot 5 Fx micro
   0x020000B4  LokPilot 5 Fx micro DCC
   0x020000B8  LokPilot 5 Fx micro Next18
   0x020000B9  LokPilot 5 Fx micro Next18 DCC
   0x020000A9  LokPilot 5 MKL
   0x020000CD  LokPilot 5 MKL
   0x020000B0  LokPilot 5 MKL DCC
   0x020000D3  LokPilot 5 MKL DCC
   0x010000C7  LokPilot 5 Basic
   0x0200003F  LokPilot V4.0
   0x02000084  LokPilot V4.0
   0x02000042  LokPilot V4.0 DCC
   0x02000085  LokPilot V4.0 DCC
   0x0200005B  LokPilot V4.0 DCC PX
   0x02000040  LokPilot micro V4.0
   0x02000046  LokPilot micro V4.0 DCC
   0x02000043  LokPilot V4.0 M4
   0x02000086  LokPilot V4.0 M4
   0x02000055  LokPilot XL V4.0
   0x02000056  LokPilot Fx V4.0
   0x0200008B  LokPilot V4.0 M4 MKL
   0x0200008E  LokPilot Micro SlideIn V4.0 DCC
   0x0100005C  LokPilot Standard V1.0
   0x01000091  LokPilot Standard V1.0
   0x01000088  LokPilot Nano Standard V1.0
   0x0100008D  LokPilot Fx Nano V1.0
   0x0200001C  LokPilot V3.0
   0x02000026  LokPilot V3.0
   0x02000029  LokPilot V3.0
   0x0200001D  LokPilot V3.0 DCC
   0x02000027  LokPilot V3.0 DCC
   0x0200002A  LokPilot V3.0 DCC
   0x0200001F  LokPilot V3.0 M4
   0x02000028  LokPilot V3.0 M4
   0x0200002B  LokPilot V3.0 M4
   0x02000023  LokPilot V3.0 OEM
   0x02000030  LokPilot V3.0 OEM
   0x02000031  LokPilot V3.0 OEM
   0x0200002E  LokPilot micro V3.0
   0x0200002F  LokPilot micro V3.0 DCC
   0x02000033  LokPilot XL V3.0
   0x0200002C  LokPilot Fx V3.0
   0x02000036  LokPilot Fx micro V3.0
   0x010000A7  SignalPilot
   0x010000FE  SignalPilot
   0x020000C0  SwitchPilot 3
   0x020000D4  SwitchPilot 3
   0x020000C1  SwitchPilot 3 Plus
   0x020000D5  SwitchPilot 3 Plus
   0x020000C2  SwitchPilot 3 Servo
   0x020000D6  SwitchPilot 3 Servo
   0x02000058  SwitchPilot V2.0
   0x0200005A  SwitchPilot Servo V2.0
   0x01000093  Essential Sound Unit
   0x010000CB  Essential Sound Unit
   0x010000DF  Essential Sound Unit
   0x02000062  Test Coach EHG388
   0x02000076  Test Coach EHG388 M4
   0x02000083  Club Car Wgye
   0x01000061  Smoke Unit (Gauge 0, G)
   0x02000045  KM1 Smoke Unit
   0x01000064  ESU digital interior light
   0x01000081  Scale Trains Tender Light
   0x0100008F  Pullman panorama car BEX
   0x010000A2  Pullman Silberling
   0x010000F4  Pullman BLS Bt9
   0x01000090  MBW Silberling
   0x01000092  Bachmann MK2F
   0x01000097  Walthers ML8
   0x010000A3  Zeitgeist Models zugspitz car
   
   */
    
  ]
  
}
