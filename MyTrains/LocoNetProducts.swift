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

public typealias LocoNetDeviceAttributes = Set<LocoNetDeviceAttribute>

public typealias LocoNetProduct = (id: Int, productName: String, description: String, approxDate: Int, productCode: Int, attributes: LocoNetDeviceAttributes)

class LocoNetProducts {
  
  private static let products : [LocoNetProduct] = [
    (1, "CT4", "Quad Throttle", 1993, -1, [.Throttle]),
    (2, "DB100", "5 Amp DCC Booster with Auto Reversing", 1993, -1, [.Booster]),
    (3, "DB100+", "5 Amp DCC Booster with Auto Reversing", 1993, -1, [.Booster]),
    (4, "DB100a", "5 Amp DCC Booster with Auto Reversing", 1994, -1, [.Booster]),
    (5, "DB99", "4.5 Amp DCC Booster", 1994, -1, [.Booster]),
    (6, "DT200", "Command Station & Throttle", 1994, -1, [.CommandStation, .Throttle]),
    (7, "BT2", "Buddy Throttle", 1995, -1, [.Throttle]),
    (8, "UP1", "Universal Panel, RJ12, 5 Pin Din & 1/4\" Stereo Plug", 1995, -1, []),
    (9, "UP2", "Universal Panel", 1995, -1, []),
    (10, "UP3", "Universal Panel", 1995, -1, []),
    (11, "UT1", "Utility Throttle", 1995, -1, [.Throttle]),
    (12, "DCS100", "5 Amp DCC Command Station & Booster", 1996, -1, [.CommandStation, .Booster]),
    (13, "DT100", "Advanced Throttle", 1996, -1, [.Throttle]),
    (14, "MS100", "LocoNet PC Computer Interface - RS232", 1996, -1, [.ComputerInterface]),
    (15, "PR1", "Computer Decoder Programmer - Serial", 1996, -1, [.ComputerInterface]),
    (16, "DB200+", "8 Amp DCC Booster", 1998, -1, [.Booster]),
    (17, "DT100R", "Advanced Radio Equipped Throttle", 1998, -1, [.Throttle, .SimplexRadioTransmitter]),
    (18, "UR90", "Infrared Receiver Front Panel", 1998, -1, [.IRPanel]),
    (19, "UR91", "Simplex Radio Equipped / IR Receiver Panel", 1998 , -1, [.SimplexRadioPanel]),
    (20, "UT2", "Utility Throttle", 1998, -1, [.Throttle]),
    (21, "DCS200", "8 Amp DCC Command Station & Booster", 2000, -1, [.CommandStation, .Booster]),
    (22, "DB150", "5 Amp DCC Command Station/Booster with intelligent Auto Reverse", 1999, -1, [.CommandStation, .Booster]),
    (23, "BDL16", "LocoNet Occupancy Detector, 16 Detection Sections", 2000, -1, [.OccupancyDetector]),
    (24, "DT300", "Advanced LocoNet Throttle", 2000, -1, [.Throttle]),
    (25, "DT300R", "Radio Equipped Advanced LocoNet Throttle", 2000, -1, [.Throttle, .SimplexRadioTransmitter]),
    (26, "PM4", "Power Manager", 2000, -1, [.PowerManager]),
    (27, "BDL162", "LocoNet Occupancy Detector, 16 Detection Sections", 2002, -1, [.OccupancyDetector]),
    (28, "PM42", "Quad Power Manager", 2002, -1, [.PowerManager]),
    (29, "SE8C", "Signal Decoder", 2003, -1, [.SignalDecoder]),
    (30, "BDL168", "LocoNet Occupancy Detector, 16 Detection Sections", 2004, -1, [.OccupancyDetector]),
    (31, "DB200-OPTO", "OPTO 8 Amp DCC Opto Booster", 2006, -1, [.Booster]),
    (32, "DCS50", "All-in-one Command Station / Booster / Throttle", 2006, -1, [.CommandStation, .Booster, .Throttle]),
    (33, "DT400", " Super Walkaround / IR Throttle", 2006, -1, [.Throttle, .IRTransmitter]),
    (34, "DT400R", "Super Radio Throttle", 2006, -1, [.Throttle, .SimplexRadioTransmitter]),
    (35, "PR2", "SoundFX Serial Port Decoder Programmer", 2006, -1, [.ComputerInterface]),
    (36, "UP5", "LocoNet Universal Interconnect Panel", 2006, -1, []),
    (37, "UR92", "Duplex Radio Transceiver / IR Receiver Panel", 2006, 0x5C, [.DuplexRadioPanel]),
    (38, "UR93", "Duplex Radio Transceiver / IR Receiver Panel", 2006, 0x5D, [.DuplexRadioPanel]),
    (39, "UR93E", "Duplex Radio Transceiver / IR Receiver Panel", 2006, -1, [.DuplexRadioPanel]),
    (40, "UT4", "Utility Throttle with 4 Digit Addressing and Infrared Capability", 2006, 0x04, [.Throttle]),
    (41, "UT4R", "Simplex Radio Equipped Utility Throttle with 4 Digit Addressing", 2006, 0x04, [.Throttle, .SimplexRadioTransmitter]),
    (42, "DS54", " Quad Stationary Decoder with Programmable LocoNet Inputs & Outputs", 2006, -1, [.StationaryDecoder]),
    (43, "DS64", "Quad Stationary Decoder", 2006, -1, [.StationaryDecoder]),
    (44, "LNRP", "Loconet Repeater Module", 2007, 0x01, [.Repeater]),
    (45, "PR3", "SoundFX USB Decoder Programmer", 2008, 0x23, [.ComputerInterface]),
    (46, "DT402", "Super Throttle with Infrared Capability", 2009, 0x2A, [.Throttle, .IRTransmitter]),
    (47, "DT402D", "Duplex Radio Equipped Super Throttle", 2009, 0x2A, [.Throttle, .DuplexRadioTransceiver]),
    (48, "DT402R", "Simplex Radio Equipped Super Throttle", 2009 , 0x2A, [.Throttle, .SimplexRadioTransmitter]),
    (49, "UT4D", "Duplex Radio Equipped Utility Throttle with 4 Digit Addressing", 2009 , 0x04, [.Throttle, .DuplexRadioTransceiver] ),
    (50, "DCS51", "All-in-one Command Station / Booster / Throttle", 2010, 0x33, [.CommandStation, .Booster, .Throttle]),
    (51, "DT402DCE", "DCE Duplex Radio Equipped Super Throttle for Europe", 2011,0x2A, [.Throttle, .DuplexRadioTransceiver]),
    (52, "UR92CE", "Duplex Radio Transceiver / IR Receiver Panel for Europe", 2011, -1, [.DuplexRadioPanel]),
    (53, "UT4DCE", "Duplex Radio Equipped Utility Throttle with 4 Digit Addressing for Europe", 2011, -1, [.Throttle, .DuplexRadioTransceiver]),
    (54, "UP6Z", "LocoNet Universal Interconnect Panel and 3 Amp Z Scale Voltage Reducer", 2012 , -1, []),
    (55, "LNRPXTRA", "LocoNet Repeter Module", 2013, -1, [.Repeater]),
    (56, "PR3XTRA", "SoundFX USB Decoder Programmer", 2013, -1, [.ComputerInterface]),
    (57, "DCS210", "5/8 Amp DCC Command Station & Booster", 2016, 0x1B, [.CommandStation, .Booster]),
    (58, "DCS240", "5/8 Amp DCC Command Station & Booster", 2016, 0x1C, [.CommandStation, .Booster, .ComputerInterface]),
    (59, "DT500", "Advanced Super Throttle with Infrared Capability", 2016, 0x32, [.Throttle, .IRTransmitter]),
    (60, "DT500D", "Advanced Duplex Radio Equipped Super Throttle", 2016, -1, [.Throttle, .DuplexRadioTransceiver]),
    (61, "DT500DCE", "Advanced Duplex Radio Equipped Super Throttle CE (for Europe)", 2016, -1, [.Throttle, .DuplexRadioTransceiver]),
    (62, "BXP88", "LocoNet Occupancy Detector, 8 Detection Sections with Transponding & Power Management", 2017, 0x58, [.OccupancyDetector, .PowerManager, .Transponding]),
    (63, "DB210", "3/5/8 Amp Auto Reverseing DCC Booster", 2017, 0x15, [.Booster]),
    (64, "DB210-OPTO", "3/5/8 Amp Auto Reverseing DCC Booster that is Opto-Isolated for layouts with common rail wiring", 2017, 0x14, [.Booster]),
    (65, "DB220", "Dual 3/5/8 Amp AutoReverseing DCC Booster", 2017, 0x16, [.Booster]),
    (66, "LNWI", "LocoNet WiFi Interface", 2017, 0x63, [.WiFiPanel]),
    (67, "PR4", "SoundFX USB Decoder Programmer", 2017, 0x24, [.ComputerInterface]),
    (68, "BXPA1", "LocoNet DCC Auto-Reverser with Detection, Transponding and Power Management", 2018, 0x51, [.OccupancyDetector, .PowerManager, .Transponding]),
    (69, "DCS52", "All-in-one Command Station / Booster / Throttle", 2019, 0x34, [.CommandStation, .Booster, .Throttle]),
    (70, "DCS210+", "DCC Command Station & Booster" , 2020, 0x1A, [.CommandStation, .Booster, .ComputerInterface]),
    (71, "DT602", "DT602 Advanced Super Throttle", 2020, 0x3E, [.Throttle]),
    (72, "DT602D", "Advanced Duplex Super Throttle", 2020, 0x3E, [.Throttle, .DuplexRadioTransceiver]),
    (73, "DT602DE", "Advanced Duplex Super Throttle CE (For Europe)", 2020, 0x3E, [.Throttle, .DuplexRadioTransceiver]),
    (74, "UT6", " Utility Throttle", 2020, 0x06, [.Throttle]),
    (75, "UT6D", "Duplex Radio Utility Throttle", 2020, 0x06, [.Throttle, .DuplexRadioTransceiver]),
    (76, "UT6DE", "Duplex Radio Utility Throttle CE (For Europe)", 2020, 0x06, [.Throttle, .DuplexRadioTransceiver]),
    (77, "DS74", "Quad Switch Stationary Decoder", 2021,-1, [.StationaryDecoder]),
    (78, "DS78V", "Eight Servo LocoNet Stationary & Accessory decoder for turnout control", 2021,-1, [.StationaryDecoder]),
  ]
}
