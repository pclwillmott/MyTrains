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

}
