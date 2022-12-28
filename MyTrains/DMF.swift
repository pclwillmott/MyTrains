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
  case sendSetup
  case sendAddr
  case sendBlock
  case sendEnd
}

public class DMF : NSObject {
  
  // MARK: Constructors
  
  init?(path: String) {
    
    super.init()
    
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
    
    var lines = contents.split(separator: "\n")
    
    if lines.count == 1 {
      lines = contents.split(separator: "\r\n")
    }
    
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
    
    guard bootloaderVersion >= 0 && bootloaderVersion <= 2 else {
      print("bootloader version not supported: \(bootloaderVersion)")
      return nil
    }
    
    var current : UInt8 = 0xff
    var count = 0
    var maxCount = 0
    var maxChar : UInt8 = 0xff
    
    var data : [UInt8] = []
    for record in dataRecords {
      for byte in record.data {
        data.append(byte)
        if byte == current {
          count += 1
        }
        else {
          if count > maxCount {
            maxChar = current
            maxCount = count
          }
          current = byte
          count = 1
        }
      }
    }

    if count > maxCount {
      maxChar = current
      maxCount = count
    }

    print("character: \(maxChar) count: \(maxCount)")
  
    decode(data: data)
  //    writeToFile(data: Data(data), fileName: "DECODED")
    
    
  }
  
  enum XForm {
    case xor
    case invert
    case shuffle
  }
  
  func decode(data:[UInt8]) {
    
    let step = 8
    
    var index = 0
    
    var last : [UInt8] = [UInt8](repeating: 0, count: 8)
    
    var lastBlock = -1
    
    var k1 : UInt8 = 0
    var k2 : UInt8 = 0
    var k3 : UInt8 = 0
    var k4 : UInt8 = 0
    
    my_srand(2212);

    while index < data.count - step {
      
      let block = index / 64
      
      if block != lastBlock {
        k2 = UInt8(my_rand() & 0xff)
        k1 = UInt8(my_rand() & 0xff)
        k4 = UInt8(my_rand() & 0xff)
        k3 = UInt8(my_rand() & 0xff)
        lastBlock = block
        print("\(block) \(k1) \(k2) \(k3) \(k4)")
      }
      
      if data[index+0] == data[index+step+0] &&
         data[index+1] == data[index+step+1] &&
         data[index+2] == data[index+step+2] &&
         data[index+3] == data[index+step+3] &&
         data[index+4] == data[index+step+4] &&
         data[index+5] == data[index+step+5] &&
         data[index+6] == data[index+step+6] &&
         data[index+7] == data[index+step+7] {
        
        var mask : [UInt8] = []
        
        mask.append(data[index+0] ^ k1)
        mask.append(data[index+1] ^ k2 )
        mask.append(data[index+2] ^ k3 )
        mask.append(data[index+3] ^ k4 )
        mask.append(data[index+4] ^ k1 )
        mask.append(data[index+5] ^ k2 )
        mask.append(data[index+6] ^ k3 )
        mask.append(data[index+7] ^ k4 )
        
        
        var diff : [Int] = []
        
        var total = 0
        for ii in 0...7 {
          diff.append(Int(mask[ii]) - Int(last[ii]))
          last[ii] = mask[ii]
          total += diff[ii]
        }
        if true || total != 0 {
          print("\(block)\t\(mask[0])\t\(mask[1])\t\(mask[2])\t\(mask[3])\t\(mask[4])\t\(mask[5])\t\(mask[6])\t\(mask[7])")
        }
      }

      index += step
    }
    
    print(index)
    
    // 21  248  79  97
    
    var numbers : Set<UInt8> = [21, 248, 79, 97]
    
    for seed in 0...32767 {
      my_srand(UInt16(seed))
      for block in 0...3000 {
        let k2 = UInt8(my_rand() & 0xff)
        let k1 = UInt8(my_rand() & 0xff)
        let k4 = UInt8(my_rand() & 0xff)
        let k3 = UInt8(my_rand() & 0xff)
        if numbers.contains(k1) && numbers.contains(k2) && numbers.contains(k3) && numbers.contains(k4) {
          print("found with seed: \(seed) \(k1) \(k2) \(k3) \(k4)")
        }
      }
    }
    
    /*
    let permutations : [[XForm]] = [
      [],
      [.xor],
      [.invert],
      [.shuffle],
      [.xor, .invert],
      [.xor, .shuffle],
      [.invert, .xor],
      [.invert, .shuffle],
      [.shuffle, .xor],
      [.shuffle, .invert],
      [.xor, .invert, .shuffle ],
      [.xor, .shuffle, .invert],
      [.invert, .xor, .shuffle],
      [.invert, .shuffle, .xor],
      [.shuffle, .xor, .invert],
      [.shuffle, .invert, .xor],
    ]
    
    for permutation in permutations {
      print(permutation)
      attempt(data:data, level: 0, permutation: permutation, xorKey: 0, invertMask: 0, shuffleSequence: [])
    }
     */
    /*
    var maxChar : UInt8 = 0
    var maxCount = 0
    var character : UInt8 = 0xff
    var count = 0

    for seed in 0...255 {
      
      let reset = 999999999
      
      for increment in -255...255 {
        
        var resetCount = 0
        
        var xorKey = seed
        
        for byte in data {
          
          let decode = byte ^ UInt8(xorKey & 0xff)
          
          xorKey += increment
          
          resetCount += 1
          
          if resetCount == reset {
            xorKey = seed
            resetCount = 0
          }
          
          if decode == character {
            count += 1
          }
          else {
            if count > maxCount {
              maxCount = count
              maxChar = character
              print("maxChar: \(maxChar) maxCount: \(maxCount) seed:\(seed) increment: \(increment)")
            }
            count = 1
            character = decode
          }
        }
      }
    }
    */
    
    
  }
  
  func attempt(data:[UInt8], level:Int, permutation:[XForm], xorKey:UInt8, invertMask:UInt8, shuffleSequence:[UInt8]) {
 
    let d7 : UInt8 = 0b10000000
    let d6 : UInt8 = 0b01000000
    let d5 : UInt8 = 0b00100000
    let d4 : UInt8 = 0b00010000
    let d3 : UInt8 = 0b00001000
    let d2 : UInt8 = 0b00000100
    let d1 : UInt8 = 0b00000010
    let d0 : UInt8 = 0b00000001

    if level == permutation.count {
      
      var decoded : [UInt8] = []
      
      var asciiBytes : [UInt8] = []
      
      var index = 0x5000
      while index < data.count {
        
        let byte = data[index]
        
        var decodedByte = byte
        
        for xform in permutation {
          
          switch xform {
            
          case .xor:
            
            decodedByte ^= xorKey
            
          case .invert:
            
            var inverted : UInt8 = 0
            
            // 1 in the mask means invert it
            
            inverted |= (invertMask & d7) == d7 ? ((decodedByte & d7) == 0 ? d7 : 0) : (decodedByte & d7)
            inverted |= (invertMask & d6) == d6 ? ((decodedByte & d6) == 0 ? d6 : 0) : (decodedByte & d6)
            inverted |= (invertMask & d5) == d5 ? ((decodedByte & d5) == 0 ? d5 : 0) : (decodedByte & d5)
            inverted |= (invertMask & d4) == d4 ? ((decodedByte & d4) == 0 ? d4 : 0) : (decodedByte & d4)
            inverted |= (invertMask & d3) == d3 ? ((decodedByte & d3) == 0 ? d3 : 0) : (decodedByte & d3)
            inverted |= (invertMask & d2) == d2 ? ((decodedByte & d2) == 0 ? d2 : 0) : (decodedByte & d2)
            inverted |= (invertMask & d1) == d1 ? ((decodedByte & d1) == 0 ? d1 : 0) : (decodedByte & d1)
            inverted |= (invertMask & d0) == d0 ? ((decodedByte & d0) == 0 ? d0 : 0) : (decodedByte & d0)
            
            decodedByte = inverted

          case .shuffle:
            
            var shuffleByte : UInt8 = 0
            
            var mask : UInt8 = 1
            
            for targetMask in shuffleSequence {
              
              shuffleByte |= (decodedByte & mask) == mask ? targetMask : 0
              
              mask <<= 1
              
            }
            
            decodedByte = shuffleByte
            
          }
          
        }
        
        decoded.append(decodedByte)
        
        if (32...127).contains(decodedByte) {
          asciiBytes.append(decodedByte)
        }
        else if asciiBytes.count > 0 {
          if let s = String(bytes: asciiBytes, encoding: .ascii), s.uppercased().hasPrefix("STEAL") || s.uppercased().hasPrefix("DIGITRAX") {
            print("xorKey: \(xorKey)")
            print("invertMask: \(invertMask)")
            print("shuffleSequence: \(shuffleSequence)")
            print(s)
          }
          asciiBytes.removeAll()
         }
        
        index += 1
        
     }
      
    }
    else {
    
      switch permutation[level] {
        
      case .xor:
        
        for key in 0...255 {
          attempt(data: data, level: level + 1, permutation: permutation, xorKey: UInt8(key), invertMask: invertMask, shuffleSequence: shuffleSequence)
        }
        
      case .invert:
        
        for mask in 0...255 {
          attempt(data: data, level: level + 1, permutation: permutation, xorKey: xorKey, invertMask: UInt8(mask), shuffleSequence: shuffleSequence)
        }
        
      case .shuffle:
        
        var sequence : [UInt8] = [UInt8](repeating: 0, count: 8)
        
        var inUse : Set<Int> = []
        
        for bit0 in 0...7 {
          
          inUse.insert(bit0)
          
          sequence[0] = 1 << bit0
          
          for bit1 in 0...7 {
            
            if !inUse.contains(bit1) {
              
              inUse.insert(bit1)
              
              sequence[1] = 1 << bit1
              
              for bit2 in 0...7 {

                if !inUse.contains(bit2) {
                  
                  inUse.insert(bit2)
                  
                  sequence[2] = 1 << bit2
                  
                  for bit3 in 0...7 {
                    
                    if !inUse.contains(bit3) {
                      
                      inUse.insert(bit3)
                      
                      sequence[3] = 1 << bit3
                      
                      for bit4 in 0...7 {
                        
                        if !inUse.contains(bit4) {
                          
                          inUse.insert(bit4)
                          
                          sequence[4] = 1 << bit4
                          
                          for bit5 in 0...7 {
                            
                            if !inUse.contains(bit5) {
                              
                              inUse.insert(bit5)
                              
                              sequence[5] = 1 << bit5
                              
                              for bit6 in 0...7 {
                                
                                if !inUse.contains(bit6) {
                                  
                                  inUse.insert(bit6)
                                  
                                  sequence[6] = 1 << bit6
                                  
                                  for bit7 in 0...7 {
                                    
                                    if !inUse.contains(bit7) {
                                      
                                      inUse.insert(bit7)
                                      
                                      sequence[7] = 1 << bit7
                                      
                              //        print(sequence)
                                      
                                      attempt(data: data, level: level + 1, permutation: permutation, xorKey: xorKey, invertMask: invertMask, shuffleSequence: sequence)
                                      
                                      inUse.remove(bit7)
                                      
                                    }
                                    
                                  }
                                  
                                  inUse.remove(bit6)
                                  
                                }
                                
                              }
                              
                              inUse.remove(bit5)
                              
                            }
                            
                          }
                            
                          inUse.remove(bit4)
                            
                        }
                          
                      }
                        
                      inUse.remove(bit3)
                        
                    }
                    
                  }
                  
                  inUse.remove(bit2)
                  
                }

              }
              
              inUse.remove(bit1)
              
            }
            
          }

          inUse.remove(bit0)
          
        }
        
      }
      
    }
    
  }
  
  func writeToFile(data: Data, fileName: String){
      // get path of directory
      guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
          return
      }
      // create file url
      let fileurl =  directory.appendingPathComponent("\(fileName).txt")
  // if file exists then write data
      if FileManager.default.fileExists(atPath: fileurl.path) {
          if let fileHandle = FileHandle(forWritingAtPath: fileurl.path) {
              // seekToEndOfFile, writes data at the last of file(appends not override)
              fileHandle.seekToEndOfFile()
              fileHandle.write(data)
              fileHandle.closeFile()
          }
          else {
              print("Can't open file to write.")
          }
      }
      else {
          // if file does not exist write data for the first time
          do{
              try data.write(to: fileurl, options: .atomic)
          }catch {
              print("Unable to write in new file.")
          }
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
  
  private var chunkCount : Int = 0
  
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
  
  public var eraseBlockSize : Int = 1024
  
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
      let delay = bootloaderVersion == 2 ? 59.2 : bootloaderVersion == 0 ? 124.0 : 124.0
      return delay / 1000.0
    }
  }
  
  public var eraseDelayInSeconds : TimeInterval {
    get {
      return (Double(numberOfBlocksToErase) * Double(eraseDelay) + 123.8) / 1000.0
    }
  
  }
  
  public var blockDelayInSeconds : TimeInterval {
    get {
      let delay = bootloaderVersion == 2 ? 17.65 : bootloaderVersion == 0 ? 26.0 : 25.25
      return delay / 1000.0
    }
  }
  
  public var endOfChunkDelay : TimeInterval {
    let delay = bootloaderVersion == 2 ? 0.0 :
                bootloaderVersion == 0 ? 50.8 + Double(txDelay) :
                                         50.8 + Double(txDelay)
    return delay / 1000.0 + blockDelayInSeconds
  }
  
  public var endOfProgBlockDelay : TimeInterval {
    let delay = bootloaderVersion == 2 ? (Double(txDelay) - 0.61) / 1000.0 : 0.0
    return delay
  }

  public var setAddrDelayInSeconds : TimeInterval {
    let delay = bootloaderVersion == 2 ? blockDelayInSeconds + 0.49 / 1000.0 : 22.2 / 1000.0
    return delay
  }

  public var chunksPerProgBlock : Int {
    return progBlockSize / chunkSize
  }
  
  public var numberOfBlocksToErase : UInt8 {
    get {
      var nb : Int = (lastAddress - firstAddress) / eraseBlockSize
      if (lastAddress - firstAddress) % eraseBlockSize != 0 {
        nb += 1
      }
      return UInt8(nb & 0xff)
    }
  }
  
  // MARK: Private Methods
  
  @objc func timerAction() {
    
    if _cancel {
      interface?.iplEndLoad()
      DispatchQueue.main.async { [self] in
        self.delegate?.aborted?()
      }
      return
    }
    
    switch nextAction {
    case .idle:
      break
    case .sendSetup:
      nextAction = .sendAddr
      interface?.iplSetup(dmf: self)
      startTimer(timeInterval: eraseDelayInSeconds, repeats: false)
    case .sendAddr:
      nextAction = .sendBlock
      let dataRecord = dataRecords[blockIndex]
      byteIndex = 0
      interface?.iplSetAddr(loadAddress: dataRecord.loadOffset)
      startTimer(timeInterval: setAddrDelayInSeconds, repeats: false)
      DispatchQueue.main.async { [self] in
        self.delegate?.update?(progress: Double(self.blockIndex) / Double(self.dataRecords.count) * 100.0)
      }
    case .sendBlock:
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
      var delay = blockDelayInSeconds
      if byteIndex == dataRecord.recordLength {
        delay = endOfChunkDelay
        blockIndex += 1
        byteIndex = 0
        if blockIndex == dataRecords.count {
          nextAction = .sendEnd
        }
        else {
          nextAction = .sendAddr
        }
        if chunkCount != -1 {
          chunkCount -= 1
          if chunkCount == 0 {
            delay += endOfProgBlockDelay
            chunkCount = chunksPerProgBlock
          }
        }
      }
      else {
        nextAction = .sendBlock
      }
      startTimer(timeInterval: delay, repeats: false)
    case .sendEnd:
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
    RunLoop.current.add(timer!, forMode: .common)
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
      chunkCount = chunksPerProgBlock
      nextAction = .sendSetup
      interface.iplSetup(dmf: self)
      startTimer(timeInterval: setupDelayInSeconds, repeats: false)
    case 0, 1:
      blockIndex = 0
      byteIndex = 0
      chunkCount = -1
      nextAction = .sendAddr
      interface.iplSetup(dmf: self)
      startTimer(timeInterval: setupDelayInSeconds, repeats: false)
    default:
      break
    }
    
  }
  
  public func cancel() {
    _cancel = true
  }
 
}
