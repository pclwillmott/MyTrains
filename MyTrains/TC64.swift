//
//  TC64.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2022.
//

import Foundation

public class TC64 {
  
  // MARK: Private Class Properties
  
  private static var _cvDescriptions : [Int:String]?
  
  // MARK: Public Class Properties
  
  public class var cvDescriptions : [Int:String] {
    
    get {
      if let descriptions = _cvDescriptions {
        return descriptions
      }
      var temp : [(cvNumber:Int, cvDescription:String)] = [
        (1, "Primary Address"),
        (7, "Software Version Number"),
        (8, "Manufacturer ID"),
        (9, "Hardware ID"),
        (17, "Extended Address MSBits"),
        (18, "Extended Address LSBits"),
        (28, "Bi-Directional Communication Configuration"),
        (29, "Configurations Supported"),
        (31, "Index High Byte"),
        (32, "Index Low Byte"),
        (33, "Manufacturer Unique"),
        (34, "Manufacturer Unique"),
        (35, "Manufacturer Unique"),
        (36, "Manufacturer Unique"),
        (37, "Manufacturer Unique"),
        (38, "Manufacturer Unique"),
        (39, "Manufacturer Unique"),
        (40, "Manufacturer Unique"),
        (41, "Manufacturer Unique"),
        (42, "Manufacturer Unique"),
        (43, "Manufacturer Unique"),
        (44, "Manufacturer Unique"),
        (45, "Manufacturer Unique"),
        (46, "Manufacturer Unique"),
        (47, "Manufacturer Unique"),
        (48, "Manufacturer Unique"),
        (49, "Manufacturer Unique"),
        (50, "Manufacturer Unique"),
        (51, "Manufacturer Unique"),
        (52, "Manufacturer Unique"),
        (53, "Manufacturer Unique"),
        (54, "Manufacturer Unique"),
        (55, "Manufacturer Unique"),
        (56, "Manufacturer Unique"),
        (57, "Manufacturer Unique"),
        (58, "Manufacturer Unique"),
        (59, "Manufacturer Unique"),
        (60, "Manufacturer Unique"),
        (61, "Manufacturer Unique"),
        (62, "Manufacturer Unique"),
        (63, "Manufacturer Unique"),
        (64, "Manufacturer Unique"),
        (96, "NMRA Reserved"),
        (97, "NMRA Reserved"),
        (98, "NMRA Reserved"),
        (99, "NMRA Reserved"),
        (100, "NMRA Reserved"),
        (101, "NMRA Reserved"),
        (102, "NMRA Reserved"),
        (103, "NMRA Reserved"),
        (104, "NMRA Reserved"),
        (105, "User Identification #1"),
        (106, "User Identification #2"),
        (107, "NMRA Reserved"),
        (108, "NMRA Reserved"),
        (109, "NMRA Reserved"),
        (110, "NMRA Reserved"),
        (111, "NMRA Reserved"),
        (112, "Configuration Options"),
        (113, "Flash Rewrite LSB"),
        (114, "Flash Rewrite Middle Bits"),
        (115, "Flash Rewrite MSB"),
        (116, "Stepper Mode Enable"),
        (117, "Stepper Mode Enable"),
      ]
      
      for port in 1...64 {
        let base = 129 + (port - 1) * 8
        temp.append((base + 0, "I/O #\(port) - Primary Low Address"))
        temp.append((base + 1, "I/O #\(port) - Control / Primary High Address"))
        temp.append((base + 2, "I/O #\(port) - Primary Dir and Transition"))
        temp.append((base + 3, "I/O #\(port) - I/O Control"))
        temp.append((base + 4, "I/O #\(port) - Secondary Low Address"))
        temp.append((base + 5, "I/O #\(port) - Secondary Dir and Transition"))
        temp.append((base + 6, "I/O #\(port) - Tertiary Low Address"))
        temp.append((base + 7, "I/O #\(port) - Tertiary Dir and Transition"))
      }
      
      _cvDescriptions = [:]
      
      for x in temp {
        _cvDescriptions![x.cvNumber] = x.cvDescription
      }
      
      return _cvDescriptions!
      
    }
  }

}
