//
//  DMF.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/05/2022.
//

import Foundation
import Cocoa

public typealias DMFData = (recordLength: Int, loadOffset: Int, data: [UInt8])

@objc public protocol DMFDelegate {
  @objc optional func update(progress: Double)
  @objc optional func aborted()
  @objc optional func completed()
}

private enum NextAction {
  case idle
  case bl2SendSetup
  case bl2SendAddr
  case bl2SendBlock
  case bl2SendEnd
}

public class DMF : NSObject {
  
  // MARK: Constructors
  
  init?(path: String) {
    
    guard FileManager.default.fileExists(atPath: path) else {
      return nil
    }
    
    var contents = ""
    
    do {
      contents = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
    }
    catch {
      return nil
    }
    
    var done = false
    
    let lines = contents.split(separator: "\n")
    
    for line in lines {
      
      switch line.prefix(1) {
      case "!":
        
        let parts = line.split(separator: ":")
        
        let valuePart = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let value = Int(valuePart) {
          
          let keyParts = parts[0].split(separator: "!")
          
          let key = String(keyParts[0]).trimmingCharacters(in: .whitespacesAndNewlines)
          
          switch key {
          case "Bootloader Version":
            bootloaderVersion = value
          case "Manufacturer Code":
            manufacturerCode = UInt8(value)
          case "Product Code":
            productCode = UInt8(value)
          case "Hardware Version":
            hardwareVersion = UInt8(value)
          case "Software Version":
            softwareVersion = UInt8(value)
          case "Chunk Size":
            chunkSize = value
          case "Delay":
            txDelay = value
          case "Options":
            options = UInt8(value)
          case "First Address":
            firstAddress = value
          case "Last Address":
            lastAddress = value
          case "Prog Blk Size":
            progBlockSize = value
          case "Erase Blk Size":
            eraseBlockSize = value
          case "Erase Dly":
            eraseDelay = value
          default:
            print("unknown key: \(key)")
          }
          
        }
        else {
          print("invalid value: \(valuePart)")
          return nil
        }
        
      case ":":
        
        if line == ":0000000001FF" {
          done = true
          break
        }
        
        var index = 0
        
        var pair = ""
        
        var recordLength = 0
        
        var loadOffset = 0
        
        var dataByteCount = 0
        
        var data : [UInt8] = []
        
        var checksumCheck : Int = 0
        
        for char in line {
          
          if index > 0 {
            
            pair += String(char)
            
            if index % 2 == 0 {
              if let value = Int(pair, radix: 16) {
                
                checksumCheck += value
                
                if index == 2 {
                  recordLength = value
                }
                else if index < 9 {
                  loadOffset = (loadOffset << 8) | value
                }
                else if index < 11 {
                  if value != 0 {
                    print("invalid record type: \(value)")
                    return nil
                  }
                }
                else if dataByteCount < recordLength {
                  data.append(UInt8(value))
                  dataByteCount += 1
                }
                else if (checksumCheck & 0xff) != 0 {
                  print("checksum error:")
                  return nil
                }
                
              }
              else {
                return nil
              }
              pair = ""
            }
            
          }
          
          index += 1
          
        }
        
        dataRecords.append((recordLength: recordLength, loadOffset: loadOffset, data: data))

      default:
        break
      }
      
      if done {
        break
      }
      
    }
    
    if bootloaderVersion != 2 {
      print("bootloader version not supported: \(bootloaderVersion)")
      return nil
    }
    
  }
  
  // MARK: Private Properties
  
  private var interface : Interface?
  
  private var delegate : DMFDelegate?
  
  private var timer : Timer?
  
  private var nextAction : NextAction = .idle
  
  private var blockIndex : Int = 0
  
  private var byteIndex : Int = 0
  
  private var _cancel = false
  
  // MARK: Public Properties
  
  public var productCode : UInt8 = 0
  
  public var bootloaderVersion : Int = 0
  
  public var manufacturerCode : UInt8 = 0
  
  public var hardwareVersion : UInt8 = 0
  
  public var softwareVersion : UInt8 = 0
  
  public var chunkSize : Int = 0
  
  public var txDelay : Int = 0
  
  public var options : UInt8 = 0
  
  public var firstAddress : Int = 0
  
  public var lastAddress : Int = 0
  
  public var progBlockSize : Int = 0
  
  public var eraseBlockSize : Int = 0
  
  public var eraseDelay : Int = 0
  
  public var dataRecords : [DMFData] = []
  
  public var locoNetProductInfo : LocoNetProduct? {
    get {
      return LocoNetProducts.product(id: locoNetProductId)
    }
  }
  
  public var locoNetProductId : LocoNetProductId {
    get {
      if let product = LocoNetProducts.product(productCode: productCode) {
        return product.id
      }
      return .UNKNOWN
    }
  }
  
  public var setupDelayInSeconds : TimeInterval {
    get {
      return 60.0 / 1000.0
    }
  }
  
  public var eraseDelayInSeconds : TimeInterval {
    get {
      
      let paramaters : [ProductCode:(A:Int, B:Int)] = [
        .DB210     : (A: 8, B: 125),
        .DB210Opto : (A: 8, B: 125),
        .DB220     : (A: 8, B: 125),
        .UT6       : (A:46, B:  90),
        .DT602     : (A:48, B: 125),
        .DCS52     : (A:46, B:-220),
        .DCS210    : (A:44, B: 125),
 //       .DCS240    : (A:44, B: 125), // *** THIS IS A GUESS ***
        .BXP88     : (A:24, B: 125),
        .LNWI      : (A:18, B: 125),
        .BXPA1     : (A:10, B: 125),
        .UR93      : (A:10, B: 125),
        .DS74      : (A:10, B: 125),
      ]
      
      if let pc = ProductCode(rawValue: productCode), let p = paramaters[pc] {
        return Double(p.A * eraseDelay + p.B) / 1000.0
      }
      
      return 2.5
      
    }
  
  }
  
  public var blockDelayInSeconds : TimeInterval {
    get {
      return 18.0 / 1000.0
    }
  }
  
  public var numberOfBlocksToErase : UInt8 {
    get {
      return UInt8((lastAddress - firstAddress) / eraseBlockSize)
    }
  }
  
  // MARK: Private Methods
  
  @objc func timerAction() {
    
    if _cancel {
      DispatchQueue.main.async { [self] in
        self.delegate?.aborted?()
      }
      return
    }
    
    switch nextAction {
    case .idle:
      break
    case .bl2SendSetup:
      nextAction = .bl2SendAddr
      interface?.iplSetupBL2(dmf: self)
      startTimer(timeInterval: eraseDelayInSeconds, repeats: false)
    case .bl2SendAddr:
      nextAction = .bl2SendBlock
      let dataRecord = dataRecords[blockIndex]
      byteIndex = 0
      interface?.iplSetAddr(loadAddress: dataRecord.loadOffset)
      startTimer(timeInterval: blockDelayInSeconds, repeats: false)
      DispatchQueue.main.async { [self] in
        self.delegate?.update?(progress: Double(self.blockIndex) / Double(self.dataRecords.count) * 100.0)
      }
    case .bl2SendBlock:
      let dataRecord = dataRecords[blockIndex]
      let d1 : UInt8 = dataRecord.data[byteIndex+0]
      let d2 : UInt8 = dataRecord.data[byteIndex+1]
      let d3 : UInt8 = dataRecord.data[byteIndex+2]
      let d4 : UInt8 = dataRecord.data[byteIndex+3]
      let d5 : UInt8 = dataRecord.data[byteIndex+4]
      let d6 : UInt8 = dataRecord.data[byteIndex+5]
      let d7 : UInt8 = dataRecord.data[byteIndex+6]
      let d8 : UInt8 = dataRecord.data[byteIndex+7]
      interface?.iplDataLoad(D1: d1, D2: d2, D3: d3, D4: d4, D5: d5, D6: d6, D7: d7, D8: d8)
      byteIndex += 8
      if byteIndex == dataRecord.recordLength {
        blockIndex += 1
        byteIndex = 0
        if blockIndex == dataRecords.count {
          nextAction = .bl2SendEnd
        }
        else {
          nextAction = .bl2SendAddr
        }
      }
      else {
        nextAction = .bl2SendBlock
      }
      startTimer(timeInterval: blockDelayInSeconds, repeats: false)
    case .bl2SendEnd:
      nextAction = .idle
      interface?.iplEndLoad()
      DispatchQueue.main.async { [self] in
        self.delegate?.update?(progress: 100.0)
        self.delegate?.completed?()
      }
    }
  }
  
  func startTimer(timeInterval:TimeInterval, repeats: Bool) {
    stopTimer()
    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: repeats)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  

  // MARK: Public Methods
  
  public func start(interface: Interface, delegate: DMFDelegate) {
    
    _cancel = false
    
    self.interface = interface
    
    self.delegate = delegate
    
    switch bootloaderVersion {
    case 2:
      blockIndex = 0
      byteIndex = 0
      nextAction = .bl2SendSetup
      interface.iplSetupBL2(dmf: self)
      startTimer(timeInterval: setupDelayInSeconds, repeats: false)
    default:
      break
    }
    
  }
  
  public func cancel() {
    _cancel = true
  }
 
}
