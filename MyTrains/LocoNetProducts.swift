//
//  LocoNetProducts.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/05/2022.
//

import Foundation

public enum LocoNetDeviceAttribute {
  case CommandStation
  case Booster
  case Throttle
  case StationaryDecoder
  case OccupancyDetector
  case ComputerInterface
  case LocoNetInterface
  case Programmer
  case IRPanel
  case SimplexRadioPanel
  case DuplexRadioPanel
  case WiFiPanel
  case SimplexRadioTransmitter
  case DuplexRadioTransceiver
  case IRTransmitter
  case PowerManager
  case SignalDecoder
  case Repeater
  case Transponding
}

public enum LocoNetProductId : Int {
  case UNKNOWN = -1
  case CT4 = 1
  case DB100 = 2
  case DB100PLUS = 3
  case DB100A = 4
  case DB99 = 5
  case DT200 = 6
  case BT2 = 7
  case UP1 = 8
  case UP2 = 9
  case UP3 = 10
  case UT1 = 11
  case DCS100 = 12
  case DT100 = 13
  case MS100 = 14
  case PR1 = 15
  case DB200PLUS = 16
  case DT100R = 17
  case UR90 = 18
  case UR91 = 19
  case UT2 = 20
  case DCS200 = 21
  case DB150 = 22
  case BDL16 = 23
  case DT300 = 24
  case DT300R = 25
  case PM4 = 26
  case BDL162 = 27
  case PM42 = 28
  case SE8C = 29
  case BDL168 = 30
  case DB200OPTO = 31
  case DCS50 = 32
  case DT400 = 33
  case DT400R = 34
  case PR2 = 35
  case UP5 = 36
  case UR92 = 37
  case UR93 = 38
  case UR93E = 39
  case UT4 = 40
  case UT4R = 41
  case DS54 = 42
  case DS64 = 43
  case LNRP = 44
  case PR3 = 45
  case DT402 = 46
  case DT402D = 47
  case DT402R = 48
  case UT4D = 49
  case DCS51 = 50
  case DT402DCE = 51
  case UR92CE = 52
  case UT4DCE = 53
  case UP6Z = 54
  case LNRPXTRA = 55
  case PR3XTRA = 56
  case DCS210 = 57
  case DCS240 = 58
  case DT500 = 59
  case DT500D = 60
  case DT500DCE = 61
  case BXP88 = 62
  case DB210 = 63
  case DB210OPTO = 64
  case DB220 = 65
  case LNWI = 66
  case PR4 = 67
  case BXPA1 = 68
  case DCS52 = 69
  case DCS210PLUS = 70
  case DT602 = 71
  case DT602D = 72
  case DT602DE = 73
  case UT6 = 74
  case UT6D = 75
  case UT6DE = 76
  case DS74 = 77
  case DS78V = 78
}

public typealias LocoNetDeviceAttributes = Set<LocoNetDeviceAttribute>

public typealias LocoNetProduct = (id: LocoNetProductId, productName: String, description: String, approxDate: Int, productCode: ProductCode, attributes: LocoNetDeviceAttributes)

public class LocoNetProductDictionaryItem : EditorObject {

  init(product: LocoNetProduct) {
    self.product = product
    super.init(primaryKey: product.id.rawValue)
  }
  
  private var product : LocoNetProduct
  
  override public func displayString() -> String {
    return "Digitrax \(product.productName)"
  }
  
}

public class LocoNetProducts {

  // MARK: Class Private Properties
  
  private static let products : [LocoNetProduct] = [
    (.CT4, "CT4", "Quad Throttle", 1993, .none, [.Throttle]),
    (.DB100, "DB100", "5 Amp DCC Booster with Auto Reversing", 1993, .none, [.Booster]),
    (.DB100PLUS, "DB100+", "5 Amp DCC Booster with Auto Reversing", 1993, .none, [.Booster]),
    (.DB100A, "DB100a", "5 Amp DCC Booster with Auto Reversing", 1994, .none, [.Booster]),
    (.DB99, "DB99", "4.5 Amp DCC Booster", 1994, .none, [.Booster]),
    (.DT200, "DT200", "Command Station & Throttle", 1994, .none, [.CommandStation, .Throttle]),
    (.BT2, "BT2", "Buddy Throttle", 1995, .none, [.Throttle]),
    (.UP1, "UP1", "Universal Panel, RJ12, 5 Pin Din & 1/4\" Stereo Plug", 1995, .none, []),
    (.UP2, "UP2", "Universal Panel", 1995, .none, []),
    (.UP3, "UP3", "Universal Panel", 1995, .none, []),
    (.UT1, "UT1", "Utility Throttle", 1995, .none, [.Throttle]),
    (.DCS100, "DCS100", "5 Amp DCC Command Station & Booster", 1996, .none, [.CommandStation, .Booster, .Programmer]),
    (.DT100, "DT100", "Advanced Throttle", 1996, .none, [.Throttle]),
    (.MS100, "MS100", "LocoNet PC Computer Interface - RS232", 1996, .none, [.ComputerInterface, .LocoNetInterface]),
    (.PR1, "PR1", "Computer Decoder Programmer - Serial", 1996, .none, [.ComputerInterface, .Programmer]),
    (.DB200PLUS, "DB200+", "8 Amp DCC Booster", 1998, .none, [.Booster]),
    (.DT100R, "DT100R", "Advanced Radio Equipped Throttle", 1998, .none, [.Throttle, .SimplexRadioTransmitter]),
    (.UR90, "UR90", "Infrared Receiver Front Panel", 1998, .none, [.IRPanel]),
    (.UR91, "UR91", "Simplex Radio Equipped / IR Receiver Panel", 1998 , .none, [.SimplexRadioPanel]),
    (.UT2, "UT2", "Utility Throttle", 1998, .none, [.Throttle]),
    (.DCS200, "DCS200", "8 Amp DCC Command Station & Booster", 2000, .none, [.CommandStation, .Booster, .Programmer]),
    (.DB150, "DB150", "5 Amp DCC Command Station/Booster with intelligent Auto Reverse", 1999, .none, [.CommandStation, .Booster]),
    (.BDL16, "BDL16", "LocoNet Occupancy Detector, 16 Detection Sections", 2000, .none, [.OccupancyDetector]),
    (.DT300, "DT300", "Advanced LocoNet Throttle", 2000, .none, [.Throttle]),
    (.DT300R, "DT300R", "Radio Equipped Advanced LocoNet Throttle", 2000, .none, [.Throttle, .SimplexRadioTransmitter]),
    (.PM4, "PM4", "Power Manager", 2000, .none, [.PowerManager]),
    (.BDL162, "BDL162", "LocoNet Occupancy Detector, 16 Detection Sections", 2002, .none, [.OccupancyDetector]),
    (.PM42, "PM42", "Quad Power Manager", 2002, .none, [.PowerManager]),
    (.SE8C, "SE8C", "Signal Decoder", 2003, .none, [.SignalDecoder]),
    (.BDL168, "BDL168", "LocoNet Occupancy Detector, 16 Detection Sections", 2004, .none, [.OccupancyDetector]),
    (.DB200OPTO, "DB200-OPTO", "OPTO 8 Amp DCC Opto Booster", 2006, .none, [.Booster]),
    (.DCS50, "DCS50", "All-in-one Command Station / Booster / Throttle", 2006, .none, [.CommandStation, .Booster, .Throttle]),
    (.DT400, "DT400", " Super Walkaround / IR Throttle", 2006, .none, [.Throttle, .IRTransmitter]),
    (.DT400R, "DT400R", "Super Radio Throttle", 2006, .none, [.Throttle, .SimplexRadioTransmitter]),
    (.PR2, "PR2", "SoundFX Serial Port Decoder Programmer", 2006, .none, [.ComputerInterface, .Programmer]),
    (.UP5, "UP5", "LocoNet Universal Interconnect Panel", 2006, .none, []),
    (.UR92, "UR92", "Duplex Radio Transceiver / IR Receiver Panel", 2006, .UR92, [.DuplexRadioPanel]),
    (.UR93, "UR93", "Duplex Radio Transceiver / IR Receiver Panel", 2006, .UR93, [.DuplexRadioPanel]),
    (.UR93E, "UR93E", "Duplex Radio Transceiver / IR Receiver Panel", 2006, .UR93, [.DuplexRadioPanel]),
    (.UT4, "UT4", "Utility Throttle with 4 Digit Addressing and Infrared Capability", 2006, .UT4, [.Throttle]),
    (.UT4R, "UT4R", "Simplex Radio Equipped Utility Throttle with 4 Digit Addressing", 2006, .UT4, [.Throttle, .SimplexRadioTransmitter]),
    (.DS54, "DS54", " Quad Stationary Decoder with Programmable LocoNet Inputs & Outputs", 2006, .none, [.StationaryDecoder]),
    (.DS64, "DS64", "Quad Stationary Decoder", 2006, .none, [.StationaryDecoder]),
    (.LNRP, "LNRP", "Loconet Repeater Module", 2007, .LNRP, [.Repeater]),
    (.PR3, "PR3", "SoundFX USB Decoder Programmer", 2008, .PR3, [.ComputerInterface, .LocoNetInterface, .Programmer]),
    (.DT402, "DT402", "Super Throttle with Infrared Capability", 2009, .DT402, [.Throttle, .IRTransmitter]),
    (.DT402D, "DT402D", "Duplex Radio Equipped Super Throttle", 2009, .DT402, [.Throttle, .DuplexRadioTransceiver]),
    (.DT402R, "DT402R", "Simplex Radio Equipped Super Throttle", 2009 , .DT402, [.Throttle, .SimplexRadioTransmitter]),
    (.UT4D, "UT4D", "Duplex Radio Equipped Utility Throttle with 4 Digit Addressing", 2009 , .UT4, [.Throttle, .DuplexRadioTransceiver] ),
    (.DCS51, "DCS51", "All-in-one Command Station / Booster / Throttle", 2010, .DCS51, [.CommandStation, .Booster, .Throttle]),
    (.DT402DCE, "DT402DCE", "DCE Duplex Radio Equipped Super Throttle for Europe", 2011, .DT402, [.Throttle, .DuplexRadioTransceiver]),
    (.UR92CE, "UR92CE", "Duplex Radio Transceiver / IR Receiver Panel for Europe", 2011, .UR92, [.DuplexRadioPanel]),
    (.UT4DCE, "UT4DCE", "Duplex Radio Equipped Utility Throttle with 4 Digit Addressing for Europe", 2011, .UT4, [.Throttle, .DuplexRadioTransceiver]),
    (.UP6Z, "UP6Z", "LocoNet Universal Interconnect Panel and 3 Amp Z Scale Voltage Reducer", 2012 , .none, []),
    (.LNRPXTRA, "LNRPXTRA", "LocoNet Repeter Module", 2013, .none, [.Repeater]),
    (.PR3XTRA, "PR3XTRA", "SoundFX USB Decoder Programmer", 2013, .none, [.ComputerInterface, .LocoNetInterface, .Programmer]),
    (.DCS210, "DCS210", "5/8 Amp DCC Command Station & Booster", 2016, .DCS210, [.CommandStation, .Booster, .Programmer]),
    (.DCS240, "DCS240", "5/8 Amp DCC Command Station & Booster", 2016, .DCS240, [.CommandStation, .Booster, .ComputerInterface, .LocoNetInterface, .Programmer]),
    (.DT500, "DT500", "Advanced Super Throttle with Infrared Capability", 2016, .DT500, [.Throttle, .IRTransmitter]),
    (.DT500D, "DT500D", "Advanced Duplex Radio Equipped Super Throttle", 2016, .DT500, [.Throttle, .DuplexRadioTransceiver]),
    (.DT500DCE, "DT500DCE", "Advanced Duplex Radio Equipped Super Throttle CE (for Europe)", 2016, .DT500, [.Throttle, .DuplexRadioTransceiver]),
    (.BXP88, "BXP88", "LocoNet Occupancy Detector, 8 Detection Sections with Transponding & Power Management", 2017, .BXP88, [.OccupancyDetector, .PowerManager, .Transponding]),
    (.DB210, "DB210", "3/5/8 Amp Auto Reverseing DCC Booster", 2017, .DB210, [.Booster]),
    (.DB210OPTO, "DB210-OPTO", "3/5/8 Amp Auto Reverseing DCC Booster that is Opto-Isolated for layouts with common rail wiring", 2017, .DB210Opto, [.Booster]),
    (.DB220, "DB220", "Dual 3/5/8 Amp AutoReverseing DCC Booster", 2017, .DB220, [.Booster]),
    (.LNWI, "LNWI", "LocoNet WiFi Interface", 2017, .LNWI, [.WiFiPanel]),
    (.PR4, "PR4", "SoundFX USB Decoder Programmer", 2017, .PR4, [.ComputerInterface, .LocoNetInterface, .Programmer]),
    (.BXPA1, "BXPA1", "LocoNet DCC Auto-Reverser with Detection, Transponding and Power Management", 2018, .BXPA1, [.OccupancyDetector, .PowerManager, .Transponding]),
    (.DCS52, "DCS52", "All-in-one Command Station / Booster / Throttle", 2019, .DCS52, [.CommandStation, .Booster, .Throttle]),
    (.DCS210PLUS, "DCS210+", "DCC Command Station & Booster" , 2020, .DCS210Plus, [.CommandStation, .Booster, .ComputerInterface, .LocoNetInterface, .Programmer]),
    (.DT602, "DT602", "DT602 Advanced Super Throttle", 2020, .DT602, [.Throttle]),
    (.DT602D, "DT602D", "Advanced Duplex Super Throttle", 2020, .DT602, [.Throttle, .DuplexRadioTransceiver]),
    (.DT602DE, "DT602DE", "Advanced Duplex Super Throttle CE (For Europe)", 2020, .DT602, [.Throttle, .DuplexRadioTransceiver]),
    (.UT6, "UT6", " Utility Throttle", 2020, .UT6, [.Throttle]),
    (.UT6D, "UT6D", "Duplex Radio Utility Throttle", 2020, .UT6, [.Throttle, .DuplexRadioTransceiver]),
    (.UT6DE, "UT6DE", "Duplex Radio Utility Throttle CE (For Europe)", 2020, .UT6, [.Throttle, .DuplexRadioTransceiver]),
    (.DS74, "DS74", "Quad Switch Stationary Decoder", 2021, .none, [.StationaryDecoder]),
    (.DS78V, "DS78V", "Eight Servo LocoNet Stationary & Accessory decoder for turnout control", 2021, .none, [.StationaryDecoder]),
  ]
  
  private static var _productDictionary : [LocoNetProductId:LocoNetProduct]?
  
  // MARK: Class Public Properties
  
  public static var productDictionary : [LocoNetProductId:LocoNetProduct] {
    
    get {
      
      if let dictionary = _productDictionary {
        return dictionary
      }
      
      var dictionary : [LocoNetProductId:LocoNetProduct] = [:]
      
      for product in products {
        dictionary[product.id] = product
      }
      
      _productDictionary = dictionary
      
      return dictionary
      
    }
    
  }
  
  // MARK: Class Public Methods
  
  public static func product(id: LocoNetProductId) -> LocoNetProduct? {
    
    return productDictionary[id]
    
  }
  
  public static func product(productCode:UInt8) -> LocoNetProduct? {
    
    for product in products {
      if product.productCode.rawValue == productCode {
        return product
      }
    }
    
    return nil
    
  }
  
  public static func computerInterfaces() -> [LocoNetProductId:LocoNetProduct] {
    
    var result : [LocoNetProductId:LocoNetProduct] = [:]
    
    for product in products {
      
      if product.attributes.contains(.ComputerInterface) {
        result[product.id] = product
      }
    }
    
    return result
    
  }
  
  public static func productDictionary(attributes: LocoNetDeviceAttributes) -> [LocoNetProductId:LocoNetProductDictionaryItem] {
    
    var result : [LocoNetProductId:LocoNetProductDictionaryItem] = [:]
    
    for product in products {
      if product.attributes.intersection(attributes) == attributes {
        result[product.id] = LocoNetProductDictionaryItem(product: product)
      }
    }
    
    return result
  }
  
}
