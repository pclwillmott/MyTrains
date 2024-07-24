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
  
  // MARK: Constructors
  
  init?(esuProductId:UInt32) {
    guard let id = DecoderType.esuProductIdLookup[esuProductId] else {
      return nil
    }
    self = id
  }
  
  // MARK: Public Properties
  
  public var allCVlists : [CVList] {
  
    var result : [CVList] = []
    
    do {
      
      let docsArray = try FileManager.default.contentsOfDirectory(atPath: Bundle.main.resourcePath!)
      
      for item in docsArray {
        
        if item.suffix(7) == ".cvlist" {
          
          let parts = item.split(separator: "[")
          
          if parts[0].trimmingCharacters(in: .whitespaces) == self.cvListPrefix {
            var parts2 = parts[1].split(separator: ".")
            parts2[2].removeLast()
            
            if let major = UInt8(parts2[0]), let minor = UInt8(parts2[1]), let build = UInt16(parts2[2]) {
              result.append((major, minor, build, item))
            }
          }
          
        }
        
      }
      
    }
    catch {
    //  debugLog("Error")
    }
    
    result.sort {
      ((UInt32($0.major) << 24) | (UInt32($0.minor) << 16) | UInt32(($0.build))) >
        ((UInt32($1.major) << 24) | (UInt32($1.minor) << 16) | UInt32(($1.build)))
    }
    
    return result
    
  }
  
  public var title : String {
    
    let lookup : [DecoderType: String] = [
      .nmra : "NMRA Standard Decoder",
      .lokPilotV4_0DCCPX : "LokPilot V4.0 DCC PX",
      .lokPilot5L : "LokPilot 5 L",
      .lokPilotV3_0 : "LokPilot V3.0",
      .lokPilot5FxmicroDCC : "LokPilot 5 Fx micro DCC",
      .lokSoundmicroV4_0 : "LokSound micro V4.0",
      .lokPilotBasic : "LokPilot Basic",
      .lokSoundSelect : "LokSound Select",
      .lokSound5 : "LokSound 5",
      .lokPilot5FxmicroNext18DCC : "LokPilot 5 Fx micro Next18 DCC",
      .lokPilotV4_0M4 : "LokPilot V4.0 M4",
      .lokSoundSelectL : "LokSound Select L",
      .lokSound5micro : "LokSound 5 micro",
      .lokPilot5Basic : "LokPilot 5 Basic",
      .lokPilot5micro : "LokPilot 5 micro",
      .lokPilotmicroV4_0 : "LokPilot micro V4.0",
      .lokPilotFxNanoV1_0 : "LokPilot Fx Nano V1.0",
      .lokPilotMicroSlideInV4_0DCC : "LokPilot Micro SlideIn V4.0 DCC",
      .lokSoundV4_0M4 : "LokSound V4.0 M4",
      .lokSound5microDCC : "LokSound 5 micro DCC",
      .lokPilotStandardV1_0 : "LokPilot Standard V1.0",
      .lokPilot5 : "LokPilot 5",
      .lokSoundV3_5 : "LokSound V3.5",
      .lokPilot5microNext18 : "LokPilot 5 micro Next18",
      .lokSound5XL : "LokSound 5 XL",
      .lokSoundV4_0M4OEM : "LokSound V4.0 M4 OEM",
      .lokSoundXLV3_5 : "LokSound XL V3.5",
      .lokSound5microDCCDirect : "LokSound 5 micro DCC Direct",
      .lokPilot5MKL : "LokPilot 5 MKL",
      .lokPilot5FxDCC : "LokPilot 5 Fx DCC",
      .lokPilot5Fxmicro : "LokPilot 5 Fx micro",
      .lokSound5microDCCDirectAtlasS2 : "LokSound 5 micro DCC Direct Atlas S2",
      .lokPilot5Fx : "LokPilot 5 Fx",
      .lokSound5MKL : "LokSound 5 MKL",
      .lokSound5nanoDCCNext18 : "LokSound 5 nano DCC Next18",
      .lokSoundV4_0 : "LokSound V4.0",
      .lokSound5Fx : "LokSound 5 Fx",
      .lokPilot5MKLDCC : "LokPilot 5 MKL DCC",
      .lokPilot5microDCCDirect : "LokPilot 5 micro DCC Direct",
      .lokPilot5LDCC : "LokPilot 5 L DCC",
      .lokPilotV4_0DCC : "LokPilot V4.0 DCC",
      .lokPilotXLV4_0 : "LokPilot XL V4.0",
      .lokPilotmicroV3_0 : "LokPilot micro V3.0",
      .lokPilotmicroV4_0DCC : "LokPilot micro V4.0 DCC",
      .lokSoundSelectdirect_micro : "LokSound Select direct / micro",
      .lokPilotmicroV3_0DCC : "LokPilot micro V3.0 DCC",
      .lokSoundmicroV3_5 : "LokSound micro V3.5",
      .lokPilotBasicLA : "LokPilot Basic (LA)",
      .lokPilotFxmicroV3_0 : "LokPilot Fx micro V3.0",
      .lokSoundXLV4_0 : "LokSound XL V4.0",
      .lokSoundSelectOEM : "LokSound Select OEM",
      .lokSound5nanoDCC : "LokSound 5 nano DCC",
      .essentialSoundUnit : "Essential Sound Unit",
      .lokPilotNanoStandardV1_0 : "LokPilot Nano Standard V1.0",
      .lokSoundV3_0M4 : "LokSound V3.0 M4",
      .lokSound5LDCC : "LokSound 5 L DCC",
      .lokPilotV3_0OEM : "LokPilot V3.0 OEM",
      .lokPilotFxV3_0 : "LokPilot Fx V3.0",
      .lokPilotXLV3_0 : "LokPilot XL V3.0",
      .lokPilot5DCC : "LokPilot 5 DCC",
      .lokSound5microDCCDirectAtlasLegacy : "LokSound 5 micro DCC Direct Atlas Legacy",
      .lokSound5L : "LokSound 5 L",
      .lokPilotV4_0M4MKL : "LokPilot V4.0 M4 MKL",
      .lokSoundLV4_0 : "LokSound L V4.0",
      .lokPilotV3_0M4 : "LokPilot V3.0 M4",
      .lokPilot5FxmicroNext18 : "LokPilot 5 Fx micro Next18",
      .lokSound5FxDCC : "LokSound 5 Fx DCC",
      .lokPilot5microDCC : "LokPilot 5 micro DCC",
      .lokPilotFxV4_0 : "LokPilot Fx V4.0",
      .lokPilot5nanoDCC : "LokPilot 5 nano DCC",
      .lokPilotV4_0 : "LokPilot V4.0",
      .lokPilotV3_0DCC : "LokPilot V3.0 DCC",
      .lokPilot5microNext18DCC : "LokPilot 5 micro Next18 DCC",
      .lokSound5DCC : "LokSound 5 DCC",
      .lokSound5microKATO : "LokSound 5 micro KATO",
    ]
    
    return lookup[self]!
    
  }
  
  public var cvListPrefix : String {
    
    let lookup : [DecoderType:String] = [
      .nmra : "NMRA Standard Decoder",
      .lokPilotV4_0DCCPX : "LokPilot V4.0 DCC PX",
      .lokPilot5L : "LokPilot 5 L",
      .lokPilotV3_0 : "LokPilot V3.0",
      .lokPilot5FxmicroDCC : "LokPilot 5 Fx micro DCC",
      .lokSoundmicroV4_0 : "LokSound micro V4.0",
      .lokPilotBasic : "LokPilot Basic",
      .lokSoundSelect : "LokSound Select",
      .lokSound5 : "LokSound 5",
      .lokPilot5FxmicroNext18DCC : "LokPilot 5 Fx micro Next18 DCC",
      .lokPilotV4_0M4 : "LokPilot V4.0 M4",
      .lokSoundSelectL : "LokSound Select L",
      .lokSound5micro : "LokSound 5 micro",
      .lokPilot5Basic : "LokPilot 5 Basic",
      .lokPilot5micro : "LokPilot 5 micro",
      .lokPilotmicroV4_0 : "LokPilot micro V4.0",
      .lokPilotFxNanoV1_0 : "LokPilot Fx Nano V1.0",
      .lokPilotMicroSlideInV4_0DCC : "LokPilot Micro SlideIn V4.0 DCC",
      .lokSoundV4_0M4 : "LokSound V4.0 M4",
      .lokSound5microDCC : "LokSound 5 micro DCC",
      .lokPilotStandardV1_0 : "LokPilot Standard V1.0",
      .lokPilot5 : "LokPilot 5",
      .lokSoundV3_5 : "LokSound V3.5",
      .lokPilot5microNext18 : "LokPilot 5 micro Next18",
      .lokSound5XL : "LokSound 5 XL",
      .lokSoundV4_0M4OEM : "LokSound V4.0 M4 OEM",
      .lokSoundXLV3_5 : "LokSound XL V3.5",
      .lokSound5microDCCDirect : "LokSound micro DCC Direct",
      .lokPilot5MKL : "LokPilot 5 MKL",
      .lokPilot5FxDCC : "LokPilot 5 Fx DCC",
      .lokPilot5Fxmicro : "LokPilot 5 Fx micro",
      .lokSound5microDCCDirectAtlasS2 : "LokSound micro DCC Direct Atlas S2",
      .lokPilot5Fx : "LokPilot 5 Fx",
      .lokSound5MKL : "LokSound 5 MKL",
      .lokSound5nanoDCCNext18 : "LokSound 5 nano DCC Next18",
      .lokSoundV4_0 : "LokSound V4.0",
      .lokSound5Fx : "LokSound 5 Fx",
      .lokPilot5MKLDCC : "LokPilot 5 MKL DCC",
      .lokPilot5microDCCDirect : "LokPilot 5 micro DCC Direct",
      .lokPilot5LDCC : "LokPilot 5 L DCC",
      .lokPilotV4_0DCC : "LokPilot V4.0 DCC",
      .lokPilotXLV4_0 : "LokPilot XL V4.0",
      .lokPilotmicroV3_0 : "LokPilot micro V3.0",
      .lokPilotmicroV4_0DCC : "LokPilot micro V4.0 DCC",
      .lokSoundSelectdirect_micro : "LokSound Select direct - micro",
      .lokPilotmicroV3_0DCC : "LokPilot micro V3.0 DCC",
      .lokSoundmicroV3_5 : "LokSound micro V3.5",
      .lokPilotBasicLA : "LokPilot Basic (LA)",
      .lokPilotFxmicroV3_0 : "LokPilot Fx micro V3.0",
      .lokSoundXLV4_0 : "LokSound XL V4.0",
      .lokSoundSelectOEM : "LokSound Select OEM",
      .lokSound5nanoDCC : "LokSound 5 nano DCC",
      .essentialSoundUnit : "Essential Sound Unit",
      .lokPilotNanoStandardV1_0 : "LokPilot Nano Standard V1.0",
      .lokSoundV3_0M4 : "LokSound V3.0 M4",
      .lokSound5LDCC : "LokSound 5 L DCC",
      .lokPilotV3_0OEM : "LokPilot V3.0 OEM",
      .lokPilotFxV3_0 : "LokPilot Fx V3.0",
      .lokPilotXLV3_0 : "LokPilot XL V3.0",
      .lokPilot5DCC : "LokPilot 5 DCC",
      .lokSound5microDCCDirectAtlasLegacy : "LokSound micro DCC Direct Atlas Legacy",
      .lokSound5L : "LokSound 5 L",
      .lokPilotV4_0M4MKL : "LokPilot V4.0 M4 MKL",
      .lokSoundLV4_0 : "LokSound L V4.0",
      .lokPilotV3_0M4 : "LokPilot V3.0 M4",
      .lokPilot5FxmicroNext18 : "LokPilot 5 Fx micro Next18",
      .lokSound5FxDCC : "LokSound 5 Fx DCC",
      .lokPilot5microDCC : "LokPilot 5 micro DCC",
      .lokPilotFxV4_0 : "LokPilot Fx V4.0",
      .lokPilot5nanoDCC : "LokPilot 5 nano DCC",
      .lokPilotV4_0 : "LokPilot V4.0",
      .lokPilotV3_0DCC : "LokPilot V3.0 DCC",
      .lokPilot5microNext18DCC : "LokPilot 5 micro Next18 DCC",
      .lokSound5DCC : "LokSound 5 DCC",
      .lokSound5microKATO : "LokSound 5 micro KATO",
      
    ]
    
    return lookup[self]!
    
  }
  
  // MARK: Public Methods
  
  public func isSettingsPropertySupported(property:ProgrammerToolSettingsProperty) -> Bool {
//    let requiredCapabilities = property.requiredCapabilities
//    return requiredCapabilities.intersection(self.capabilities) == requiredCapabilities
    return true
  }
  
  public func isInspectorPropertySupported(property:ProgrammerToolInspectorProperty) -> Bool {
    let requiredCapabilities = property.requiredCapabilities
    return requiredCapabilities.intersection(self.capabilities) == requiredCapabilities
  }

  public func cvList(filename:String) -> [(cv: CV, defaultValue:UInt8)] {
    
    var result : [(cv: CV, defaultValue:UInt8)] = []
    
    do {
      
      let text = try String(contentsOfFile: "\(Bundle.main.resourcePath!)/\(filename)", encoding: String.Encoding.utf8)
      
      let lines = text.split(separator: "\r\n")
      
      var cv31 : UInt8 = 0
      
      var cv32 : UInt8 = 0
      
      var index = 2
      
      var addESUDecoderInfoCDs = false
      
      while index < lines.count {
        
        let line = lines[index].trimmingCharacters(in: .whitespaces)
        
        if !line.isEmpty && line != "--------------------------------" {
          
          if line.prefix(7) == "Index: " {
            
            let parts = line.suffix(line.count - 7).split(separator: "(")
            
            let pageIndex = UInt32(parts[0].trimmingCharacters(in: .whitespaces))!
            
            cv31 = UInt8(pageIndex / 256)
            cv32 = UInt8(pageIndex % 256)
            
          }
          else {
            
            let parts = line.split(separator: "=")
            
            var cvName = String(parts[0].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: ""))
            cvName.removeFirst(2)
            
            let cv = UInt16(cvName)!
            
            if let cvConstant = CV(cv31: cv31, cv32: cv32, cv: cv, indexMethod: .cv3132), let cvValue = UInt8(parts[1].trimmingCharacters(in: .whitespaces)) {
              
              if cvConstant.index > 255 && addESUDecoderInfoCDs {
                
                for cv : UInt16 in 261 ... 296 {
                  if let cvConstant = CV(cv31: 0, cv32: 255, cv: cv, indexMethod: .cv3132, isHidden: true, isReadOnly: false) {
                    result.append((cvConstant, 0))
                  }
                  else {
                //    debugLog("error: \(cv)")
                  }
                }
                
                addESUDecoderInfoCDs = false
                
              }
              
              result.append((cvConstant, cvValue))
              
              if cvConstant == .cv_000_000_008 && cvValue == 0x97 {
                addESUDecoderInfoCDs = true
              }
              
            }
            else {
              debugLog("CV Not Found: CV31:\(cv31) CV32:\(cv32) CV:\(cv) \"\(parts[1])\"")
            }
            
          }
          
        }
        
        index += 1
        
      }
    
    }
    catch {
      debugLog("error: \(filename)")
    }
    
    return result

  }
  
  // MARK: Public Class Properties
  
  public static let esuProductIdLookup : [UInt32:DecoderType] = [
   
    0x02000096 : lokSound5,
    0x020000F7 : lokSound5,
    0x020000DA : lokSound5,
    0x0200009C : lokSound5DCC,
    0x020000F8 : lokSound5DCC,
    0x020000DB : lokSound5DCC,
    0x0200009B : lokSound5micro,
    0x0200009E : lokSound5microDCC,
    0x0100009A : lokSound5microDCCDirect,
    0x010000D8 : lokSound5microDCCDirectAtlasLegacy,
    0x010000FB : lokSound5microDCCDirectAtlasS2,
    0x010000BC : lokSound5nanoDCC,
    0x010000E4 : lokSound5nanoDCCNext18,
    0x0200009D : lokSound5L,
    0x020000E2 : lokSound5L,
    0x020000DD : lokSound5L,
    0x020000A0 : lokSound5LDCC,
    0x020000E3 : lokSound5LDCC,
    0x020000DE : lokSound5LDCC,
    0x0200009F : lokSound5XL,
    0x020000C5 : lokSound5Fx,
    0x020000C6 : lokSound5FxDCC,
    0x020000A6 : lokSound5MKL,
    0x020000F9 : lokSound5MKL,
    0x020000DC : lokSound5MKL,
    0x010000BD : lokSound5microKATO,
    0x0200003D : lokSoundV4_0,
    0x02000047 : lokSoundV4_0,
    0x0200006A : lokSoundV4_0,
    0x0200003C : lokSoundSelect,
    0x0200004F : lokSoundSelect,
    0x0200005F : lokSoundSelect,
    0x02000089 : lokSoundSelect,
    0x02000041 : lokSoundmicroV4_0,
    0x02000078 : lokSoundmicroV4_0,
    0x0200004A : lokSoundSelectdirect_micro,
    0x0200006F : lokSoundSelectdirect_micro,
    0x02000080 : lokSoundSelectdirect_micro,
    0x02000065 : lokSoundSelectOEM,
    0x0200008A : lokSoundSelectOEM,
    0x0200004B : lokSoundXLV4_0,
    0x0200006D : lokSoundXLV4_0,
    0x02000044 : lokSoundV4_0M4,
    0x02000068 : lokSoundV4_0M4,
    0x02000059 : lokSoundV4_0M4OEM,
    0x02000073 : lokSoundV4_0M4OEM,
    0x02000070 : lokSoundLV4_0,
    0x02000079 : lokSoundSelectL,
    0x0100000D : lokSoundV3_5,
    0x01000012 : lokSoundV3_5,
    0x01000017 : lokSoundV3_5,
    0x01000020 : lokSoundV3_5,
    0x0100000E : lokSoundXLV3_5,
    0x01000014 : lokSoundXLV3_5,
    0x01000024 : lokSoundXLV3_5,
    0x0200000E : lokSoundV3_0M4,
    0x02000015 : lokSoundV3_0M4,
    0x02000021 : lokSoundV3_0M4,
    0x01000019 : lokSoundmicroV3_5,
    0x0100001E : lokSoundmicroV3_5,
    0x020000A8 : lokPilot5,
    0x020000CC : lokPilot5,
    0x020000AA : lokPilot5DCC,
    0x020000CE : lokPilot5DCC,
    0x010000AE : lokPilot5micro,
    0x010000AF : lokPilot5microDCC,
    0x010000E1 : lokPilot5microDCCDirect,
    0x020000AC : lokPilot5microNext18,
    0x020000AD : lokPilot5microNext18DCC,
    0x010000FC : lokPilot5nanoDCC,
    0x020000B1 : lokPilot5L,
    0x020000CF : lokPilot5L,
    0x020000F0 : lokPilot5L,
    0x020000B2 : lokPilot5LDCC,
    0x020000D0 : lokPilot5LDCC,
    0x020000F1 : lokPilot5LDCC,
    0x010000BE : lokPilot5Fx,
    0x010000D1 : lokPilot5Fx,
    0x010000BF : lokPilot5FxDCC,
    0x010000D2 : lokPilot5FxDCC,
    0x020000B3 : lokPilot5Fxmicro,
    0x020000B4 : lokPilot5FxmicroDCC,
    0x020000B8 : lokPilot5FxmicroNext18,
    0x020000B9 : lokPilot5FxmicroNext18DCC,
    0x020000A9 : lokPilot5MKL,
    0x020000CD : lokPilot5MKL,
    0x020000B0 : lokPilot5MKLDCC,
    0x020000D3 : lokPilot5MKLDCC,
    0x010000C7 : lokPilot5Basic,
    0x0200003F : lokPilotV4_0,
    0x02000084 : lokPilotV4_0,
    0x02000042 : lokPilotV4_0DCC,
    0x02000085 : lokPilotV4_0DCC,
    0x0200005B : lokPilotV4_0DCCPX,
    0x02000040 : lokPilotmicroV4_0,
    0x02000046 : lokPilotmicroV4_0DCC,
    0x02000043 : lokPilotV4_0M4,
    0x02000086 : lokPilotV4_0M4,
    0x02000055 : lokPilotXLV4_0,
    0x02000056 : lokPilotFxV4_0,
    0x0200008B : lokPilotV4_0M4MKL,
    0x0200008E : lokPilotMicroSlideInV4_0DCC,
    0x0100005C : lokPilotStandardV1_0,
    0x01000091 : lokPilotStandardV1_0,
    0x01000088 : lokPilotNanoStandardV1_0,
    0x0100008D : lokPilotFxNanoV1_0,
    0x0200001C : lokPilotV3_0,
    0x02000026 : lokPilotV3_0,
    0x02000029 : lokPilotV3_0,
    0x0200001D : lokPilotV3_0DCC,
    0x02000027 : lokPilotV3_0DCC,
    0x0200002A : lokPilotV3_0DCC,
    0x0200001F : lokPilotV3_0M4,
    0x02000028 : lokPilotV3_0M4,
    0x0200002B : lokPilotV3_0M4,
    0x02000023 : lokPilotV3_0OEM,
    0x02000030 : lokPilotV3_0OEM,
    0x02000031 : lokPilotV3_0OEM,
    0x0200002E : lokPilotmicroV3_0,
    0x0200002F : lokPilotmicroV3_0DCC,
    0x02000033 : lokPilotXLV3_0,
    0x0200002C : lokPilotFxV3_0,
    0x02000036 : lokPilotFxmicroV3_0,
//    0x010000A7 : signalPilot,
//    0x010000FE : signalPilot,
//    0x020000C0 : switchPilot3,
//    0x020000D4 : switchPilot3,
//    0x020000C1 : switchPilot3Plus,
//    0x020000D5 : switchPilot3Plus,
//    0x020000C2 : switchPilot3Servo,
//    0x020000D6 : switchPilot3Servo,
//    0x02000058 : switchPilotV2_0,
//    0x0200005A : switchPilotServoV2_0,
    0x01000093 : essentialSoundUnit,
    0x010000CB : essentialSoundUnit,
    0x010000DF : essentialSoundUnit,
//    0x02000062 : testCoachEHG388,
//    0x02000076 : testCoachEHG388M4,
//    0x02000083 : clubCarWgye,
//    0x01000061 : smokeUnitGauge0G,
//    0x02000045 : kM1SmokeUnit,
//    0x01000064 : esudigitalinteriorlight,
//    0x01000081 : scaleTrainsTenderLight,
//    0x0100008F : pullmanpanoramacarBEX,
//    0x010000A2 : pullmanSilberling,
//    0x010000F4 : pullmanBLSBt9,
//    0x01000090 : mbwSilberling,
//    0x01000092 : bachmannMK2F,
//    0x01000097 : walthersML8,
//    0x010000A3 : zeitgeistModelszugspitzcar,
    
  ]
  
}
