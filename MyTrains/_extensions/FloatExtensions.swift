//
//  FloatExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/05/2023.
//

import Foundation

extension Float {
  
  init(float16:float16_t) {
    
    self.init()
    
    self = float16_to_float(float16)
    
  }
  
  public var float16 : float16_t {
    get {
      return float_to_float16(self)
    }
  }

  public var sign : Float {
    get {
      return self < 0.0 ? -1.0 : 1.0
    }
  }

}

extension Double {

  init(float16:float16_t) {
    
    self.init()
    
    self = Double(float16_to_float(float16))
    
  }
  
  public var float16 : float16_t {
    get {
      let f = Float(self)
      return float_to_float16(f)
    }
  }
  
  public var sign : Double {
    get {
      return self < 0.0 ? -1.0 : 1.0
    }
  }
  
  init(openLCBClockRate: UInt16) {
    
    self.init()
    
    var temp = openLCBClockRate
    
    let isNegative = (temp & 0x0800) == 0x0800
    
    if isNegative {
      temp |= 0b1111000000000000
      temp = ~(temp - 1)
    }
    
    let fraction = Double(temp & 0b11) * 0.25
    
    temp >>= 2
    
    self = (Double(temp) + fraction) * (isNegative ? -1.0 : 1.0)

  }
  
  public var openLCBClockRate : UInt16 {
    get {
      
      // -512.00 = 0x800 = 0b100000000000
      // -511.75 = 0x801 = 0b100000000001
      // -511.50 = 0x802 = 0b100000000010
      // -511.25 = 0x803 = 0b100000000011
      //   -0.25 = 0xfff = 0b111111111111
      //    0.00 = 0x000 = 0b000000000000
      //    0.25 = 0x001 = 0b000000000001
      //  511.00 = 0x7fc = 0b011111111100
      //  511.25 = 0x7fd = 0b011111111101
      //  511.50 = 0x7fe = 0b011111111110
      //  511.75 = 0x7ff = 0b011111111111
      
      var temp = abs(self)
      
      var dp = temp.truncatingRemainder(dividingBy: 1.0)
      
      temp -= dp
      
      var uintValue = (UInt32(temp.rounded()) << 2) | UInt32(dp * 4.0)
      
      if self < 0.0 {
        uintValue = ~uintValue + 1
      }
      
      return UInt16(uintValue & 0x0fff)
      
    }
    
  }

}
