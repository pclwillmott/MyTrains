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
      return (18.0 * Double(eraseDelay) + 125.0) / 1000.0
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
  
  // MARK: Public Methods
  
  public func start(interface: Interface, delegate: DMFDelegate) {
    
    self.interface = interface
    
    self.delegate = delegate
    
  }
 
}
