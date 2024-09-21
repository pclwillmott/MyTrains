//
//  ESUCVExtract.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/07/2024.
//

import Foundation

public func esuCVExtract() {
  
  var sort : [ManufacturerInfo] = []
  
  for (_, item) in NMRA.manufacturers {
    sort.append(item)
  }
  
  sort.sort {$0.codeNMRA < $1.codeNMRA}
  
  for item in sort {
    
    if item.codeNMRA >= 0 {
      
      var enumName = item.name.replacingOccurrences(of: " ", with: "")
      
      enumName = enumName.replacingOccurrences(of: ".", with: "")
      enumName = enumName.replacingOccurrences(of: "-", with: "_")
      enumName = enumName.replacingOccurrences(of: ",", with: "")
      enumName = enumName.replacingOccurrences(of: "(", with: "")
      enumName = enumName.replacingOccurrences(of: ")", with: "")
      enumName = enumName.replacingOccurrences(of: "&", with: "_")
      enumName = enumName.replacingOccurrences(of: "/", with: "")
      enumName = enumName.replacingOccurrences(of: "–", with: "_")
      
      let first = enumName.removeFirst()
      
      enumName = "\(first.lowercased())\(enumName)"
      
//      print("  case \(enumName) = 0x\(UInt8(item.codeNMRA).hex().lowercased())")
      
      print("    .\(enumName) : \"\(item.name)\",")
    }
    
  }
  
  var cv : CV = .cv_000_000_001
  
  cv = cv + 1
  
  print(cv)
  return
  
  let fm = FileManager.default
  
  let path = "/Users/paul/Desktop/CV EXPORTS"
  
  var indexNumber = 1

  do {
    
    var cvsFound : Set<UInt64> = []
    
    let items = try fm.contentsOfDirectory(atPath: path)

    for item in items {
      
      let string = try String(contentsOfFile: "\(path)/\(item)", encoding: String.Encoding.utf8)
      
      let lines = string.split(separator: "\r\n")
      
      var decoder = lines[0]
      decoder.removeFirst(10)
      decoder.removeLast(1)
      
      let parts = decoder.split(separator: "(")
      
      var decoderTitle = String(parts[0].trimmingCharacters(in: .whitespaces))
      var versionNumber = String(parts[1].trimmingCharacters(in: .whitespaces))
      
      if parts.count == 3 {
        decoderTitle += " \(versionNumber)"
        versionNumber = String(parts[2].trimmingCharacters(in: .whitespaces))
      }
      
      var enumName = decoderTitle.replacingOccurrences(of: " ", with: "")
      enumName = enumName.replacingOccurrences(of: ".", with: "_")
      enumName = enumName.replacingOccurrences(of: "/", with: "_")

 //     print("\"\(decoderTitle)\" \"\(versionNumber)\" \"\(enumName)\"" )
      
      
      if let first = enumName.first {
        enumName.removeFirst()
        enumName = "\(first.lowercased())\(enumName)"
      }
      
 //     print("  case \(enumName) = \(indexNumber) // \"\(decoderTitle)\" \"\(versionNumber)\"")

      let parts2 = item.split(separator: "[")
      
 //     print("    .\(enumName) : \"\(parts2[0].trimmingCharacters(in: .whitespaces))\",")
      
      indexNumber += 1
      
      var usingIndex = false
      
      var cv31 : UInt8 = 0
      
      var cv32 : UInt8 = 0
      
      var index = 2
      
      while index < lines.count {
        
        let line = lines[index].trimmingCharacters(in: .whitespaces)
        
        if !line.isEmpty && line != "--------------------------------" {
          
          if line.prefix(7) == "Index: " {
            
            usingIndex = true
            
            let parts = line.suffix(line.count - 7).split(separator: "(")
            
            let pageIndex = UInt32(parts[0].trimmingCharacters(in: .whitespaces))!
            
            cv31 = UInt8(pageIndex / 256)
            cv32 = UInt8(pageIndex % 256)
            
   //         print("\(pageIndex) CV31=\(cv31) CV32=\(cv32)")
            
          }
          else {
            
            let parts = line.split(separator: "=")
            
            var cvName = String(parts[0].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: ""))
            cvName.removeFirst(2)
            
            let cv = UInt16(cvName)!
            
            let enumName = String(format: "cv_%03i_%03i_%03i", cv31, cv32, cv)
            
            cvsFound.insert(CV.encodeRawValue(cv31: cv31, cv32: cv32, cv: cv, indexMethod: .cv3132))
            
          }
          
        }
        
        index += 1
        
      }
      
    }
    
    var sorted : [UInt64] = []
    
    for item in cvsFound {
      sorted.append(item)
    }
    
    sorted.sort {$0 < $1}
    
    for item in sorted {
      
      let cv = ((item & 0x0000ffff00000000) >> 32) + 1
      
      let cv32 = (item & 0x00ff000000000000) >> 48
      
      let cv31 = (item & 0xff00000000000000) >> 56
      
//      print("\(String(format:"    case cv_%03i_%03i_%03i", cv31, cv32, cv)) = 0x\(item.hex(numberOfBytes: 8)!)")
    }
    
//    print(sorted.count)

  } 
  catch {
    print("error")
  }
  
}
