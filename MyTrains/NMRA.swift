//
//  NMRA.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/01/2022.
//

import Foundation

public typealias ManufacturerInfo = (name: String, codeNMRA: Int, country: String, codeDigitrax: Int, code: Int)

public class NMRA {
  
  // MARK: Private Class Propoerties
  
  private static var _manufacturersNMRA     : [Int:ManufacturerInfo]?
  private static var _manufacturersDigitrax : [Int:ManufacturerInfo]?
  private static var _manufacturers         : [Int:ManufacturerInfo]?

  private static var _cvDescriptions : [Int:String]?
  
  // MARK: Public Class Properties
  
  public static func cvDescription(cv: Int) -> String {
    return cvDescriptions[cv]?.description ?? ""
  }
  
  public static var cvDescriptions : [Int:String] {
    
    get {
      if let descriptions = _cvDescriptions {
        return descriptions
      }
      var temp : [(cvNumber:Int, cvDescription:String)] = [
        (1, "Primary Address"),
        (2, "Vstart"),
        (3, "Acceleration Rate"),
        (4, "Decleration Rate"),
        (5, "Vhigh"),
        (6, "Vmid"),
        (7, "Manufacturer Version Number"),
        (8, "Manufacturer ID"),
        (9, "Total PWM Period"),
        (10, "EMF Feedback Cutout"),
        (11, "Packet time-out Value"),
        (12, "Power Source Conversion"),
        (13, "Alternate Mode Function Status"),
        (14, "Alternate Mode Function 2 Status"),
        (15, "Decoder Lock"),
        (16, "Decoder Lock"),
        (17, "Extended Address MSBits"),
        (18, "Extended Address LSBits"),
        (19, "Consist Address"),
        (21, "Consist Address Active for F1-F8"),
        (22, "Consist Address Active for FL and F9-F12"),
        (23, "Acceleration Adjustment"),
        (24, "Decleration Adjustment"),
        (25, "Speed Table/Mid Range Cab Speed Step"),
        (27, "Decoder Automatic Stopping Configuration"),
        (28, "Bi-Directional Communication Configuration"),
        (29, "Configurations Supported"),
        (30, "ERROR Information"),
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
        (65, "Kick Start"),
        (66, "Forward Trim"),
        (67, "Speed Table #1"),
        (68, "Speed Table #2"),
        (69, "Speed Table #3"),
        (70, "Speed Table #4"),
        (71, "Speed Table #5"),
        (72, "Speed Table #6"),
        (73, "Speed Table #7"),
        (74, "Speed Table #8"),
        (75, "Speed Table #9"),
        (76, "Speed Table #10"),
        (77, "Speed Table #11"),
        (78, "Speed Table #12"),
        (79, "Speed Table #13"),
        (80, "Speed Table #14"),
        (81, "Speed Table #15"),
        (82, "Speed Table #16"),
        (83, "Speed Table #17"),
        (84, "Speed Table #18"),
        (85, "Speed Table #19"),
        (86, "Speed Table #20"),
        (87, "Speed Table #21"),
        (88, "Speed Table #22"),
        (89, "Speed Table #23"),
        (90, "Speed Table #24"),
        (91, "Speed Table #25"),
        (92, "Speed Table #26"),
        (93, "Speed Table #27"),
        (94, "Speed Table #28"),
        (95, "Reverse Trim"),
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
        (892, "Decoder Load"),
        (893, "Flags"),
        (894, "Fuel/Coal"),
        (895, "Water"),
      ]
      
      for cv in 112...256 {
        temp.append((cv, "Manufacturer Unique"))
      }
      
      _cvDescriptions = [:]
      
      for x in temp {
        _cvDescriptions![x.cvNumber] = x.cvDescription
      }
      
      return _cvDescriptions!
      
    }
    
  }
  
  public static func manufacturerNameNMRA(codeNMRA: Int) -> String {
    return manufacturersNMRA[codeNMRA]?.name ?? "Unknown"
  }
  
  public static func manufacturerNameDigitrax(codeDigitrax: Int) -> String {
    return manufacturersDigitrax[codeDigitrax]?.name ?? "Unknown"
  }
  
  public static func manufacturerName(code: Int) -> String {
    return manufacturers[code]?.name ?? "Unknown"
  }
  
  public static func code(codeNMRA: Int) -> Int {
    if let manufacturer = manufacturersNMRA[codeNMRA] {
      return manufacturer.code
    }
    return -1
  }
  
  public static func code(codeDigitrax: Int) -> Int {
    if let manufacturer = manufacturersDigitrax[codeDigitrax] {
      return manufacturer.code
    }
    return -1
  }
  
  public static var manufacturersNMRA : [Int:ManufacturerInfo] {
    get {

      if let info = _manufacturersNMRA {
        return info
      }
      
      var info : [Int:ManufacturerInfo] = [:]
      
      for manufacturer in baseData {
        if manufacturer.codeNMRA != -1 {
          info[manufacturer.codeNMRA] = manufacturer
        }
      }
      
      _manufacturersNMRA = info
      
      return info
      
    }
  }
  
  public static var manufacturersDigitrax : [Int:ManufacturerInfo] {
    get {

      if let info = _manufacturersDigitrax {
        return info
      }
      
      var info : [Int:ManufacturerInfo] = [:]
      
      for manufacturer in baseData {
        if manufacturer.codeDigitrax != -1 {
          info[manufacturer.codeDigitrax] = manufacturer
        }
      }
      
      _manufacturersDigitrax = info
      
      return info
      
    }
  }
  
  public static var manufacturers : [Int:ManufacturerInfo] {
    get {

      if let info = _manufacturers {
        return info
      }
      
      var info : [Int:ManufacturerInfo] = [:]
      
      for manufacturer in baseData {
        if manufacturer.code != -1 {
          info[manufacturer.code] = manufacturer
        }
      }
      
      _manufacturers = info
      
      return info
      
    }
  }
  
  private static let baseData : [ManufacturerInfo] = [
    ("CML Electronics Limited", 0x01, "UK", -1, 1),
    ("Train Technology", 0x02, "BE", -1, 2),
    ("NCE Corporation (formerly North Coast Engineering)", 0x0B, "US", -1, 3),
    ("Wangrow Electronics", 0x0C, "US", -1, 4),
    ("Public Domain & Do-It-Yourself Decoders", 0x0D, "-", -1, 5),
    ("PSI–Dynatrol", 0x0E, "US", -1, 6),
    ("Ramfixx Technologies (Wangrow)", 0x0F, "CA/US", -1, 7),
    ("Advance IC Engineering", 0x11, "US", -1, 8),
    ("JMRI", 0x12, "US", -1, 9),
    ("AMW", 0x13, "AT", -1, 10),
    ("T4T – Technology for Trains GmbH", 0x14, "DE", -1, 11),
    ("Kreischer Datentechnik", 0x15, "DE", -1, 12),
    ("KAM Industries", 0x16, "US", -1, 13),
    ("S Helper Service", 0x17, "US", -1, 14),
    ("MoBaTron.de", 0x18, "DE", -1, 15),
    ("Team Digital, LLC", 0x19, "US", -1, 16),
    ("MBTronik – PiN GITmBH", 0x1A, "DE", -1, 17),
    ("MTH Electric Trains, Inc.", 0x1B, "US", -1, 18),
    ("Heljan A/S", 0x1C, "DK", -1, 19),
    ("Mistral Train Models", 0x1D, "BE", -1, 20),
    ("Digsight", 0x1E, "CN", -1, 21),
    ("Brelec", 0x1F, "BE", -1, 22),
    ("Regal Way Co. Ltd", 0x20, "HKG", -1, 23),
    ("Praecipuus", 0x21, "CA", -1, 24),
    ("Aristo-Craft Trains", 0x22, "US", -1, 25),
    ("Electronik & Model Produktion", 0x23, "SE", -1, 26),
    ("DCCconcepts", 0x24, "AU", -1, 27),
    ("NAC Services, Inc", 0x25, "US", -1, 28),
    ("Broadway Limited Imports, LLC", 0x26, "US", -1, 29),
    ("Educational Computer, Inc.", 0x27, "US", -1, 30),
    ("KATO Precision Models", 0x28, "JP", -1, 31),
    ("Passmann", 0x29, "DE", -1, 32),
    ("Digikeijs", 0x2A, "NL", -1, 33),
    ("Ngineering", 0x2B, "US", -1, 34),
    ("SPROG-DCC", 0x2C, "UK", -1, 35),
    ("ANE Model Co, Ltd", 0x2D, "TWN", -1, 36),
    ("GFB Designs", 0x2E, "UK", -1, 37),
    ("Capecom", 0x2F, "AU", -1, 38),
    ("Hornby Hobbies Ltd", 0x30, "UK", -1, 39),
    ("Joka Electronic", 0x31, "DE", -1, 40),
    ("N&Q Electronics", 0x32, "ESP", -1, 41),
    ("DCC Supplies, Ltd", 0x33, "UK", -1, 42),
    ("Krois-Modell", 0x34, "AT", -1, 43),
    ("Rautenhaus Digital Vertrieb", 0x35, "DE", -1, 44),
    ("TCH Technology", 0x36, "US", -1, 45),
    ("QElectronics GmbH", 0x37, "DE", -1, 46),
    ("LDH", 0x38, "ARG", -1, 47),
    ("Rampino Elektronik", 0x39, "DE", -1, 48),
    ("KRES GmbH", 0x3A, "DE", -1, 49),
    ("Tam Valley Depot", 0x3B, "US", -1, 49),
    ("Bluecher-Electronic", 0x3C, "DE", -1, 50),
    ("TrainModules", 0x3D, "HUN", -1, 51),
    ("Tams Elektronik GmbH", 0x3E, "DE", -1, 52),
    ("Noarail", 0x3F, "AUS", -1, 53),
    ("Digital Bahn", 0x40, "DE", -1, 54),
    ("Gaugemaster", 0x41, "UK", -1, 55),
    ("Railnet Solutions, LLC", 0x42, "US", -1, 56),
    ("Heller Modenlbahn", 0x43, "DE", -1, 57),
    ("MAWE Elektronik", 0x44, "CH", -1, 58),
    ("E-Modell", 0x45, "DE", -1, 59),
    ("Rocrail", 0x46, "DE", -1, 60),
    ("New York Byano Limited", 0x47, "HK", -1, 61),
    ("MTB Model", 0x48, "CZE", -1, 62),
    ("The Electric Railroad Company", 0x49, "US", -1, 63),
    ("PpP Digital", 0x4A, "ESP", -1, 64),
    ("Digitools Elektronika, Kft", 0x4B, "HUN", -1, 65),
    ("Auvidel", 0x4C, "DE", -1, 66),
    ("LS Models Sprl", 0x4D, "BEL", -1, 67),
    ("Tehnologistic (train-O-matic)", 0x4E, "ROM", -1, 68),
    ("Hattons Model Railways", 0x4F, "UK", -1, 69),
    ("Spectrum Engineering", 0x50, "US", -1, 70),
    ("GooVerModels", 0x51, "BEL", -1, 71),
    ("HAG Modelleisenbahn AG", 0x52, "CHE", -1, 72),
    ("JSS-Elektronic", 0x53, "DE", -1, 73),
    ("Railflyer Model Prototypes, Inc.", 0x54, "CAN", -1, 74),
    ("Uhlenbrock GmbH", 0x55, "DE", -1, 75),
    ("Wekomm Engineering, GmbH", 0x56, "DE", -1, 76),
    ("RR-Cirkits", 0x57, "US", -1, 77),
    ("HONS Model", 0x58, "HKG", -1, 78),
    ("Pojezdy.EU", 0x59, "CZE", -1, 79),
    ("Shourt Line", 0x5A, "US", -1, 80),
    ("Railstars Limited", 0x5B, "US", -1, 81),
    ("Tawcrafts", 0x5C, "UK", -1, 82),
    ("Kevtronics cc", 0x5D, "ZAF", -1, 83),
    ("Electroniscript, Inc.", 0x5E, "US", -1, 84),
    ("Sanda Kan Industrial, Ltd.", 0x5F, "HKG", -1, 85),
    ("PRICOM Design", 0x60, "US", -1, 86),
    ("Doehler & Haas", 0x61, "DE", -1, 87),
    ("Harman DCC", 0x62, "UK", -1, 88),
    ("Lenz Elektronik GmbH", 0x63, "DE", -1, 89),
    ("Trenes Digitales", 0x64, "ARG", -1, 90),
    ("Bachmann Trains", 0x65, "US", -1, 91),
    ("Integrated Signal Systems", 0x66, "US", -1, 92),
    ("Nagasue System Design Office", 0x67, "JP", -1, 93),
    ("TrainTech", 0x68, "NL", -1, 94),
    ("Computer Dialysis France",  0x69, "FR", -1, 95),
    ("Opherline1", 0x6A, "FR", -1, 96),
    ("Phoenix Sound Systems, Inc.", 0x6B, "US", -1, 97),
    ("Nagoden", 0x6C, "JP", -1, 98),
    ("Viessmann Modellspielwaren GmbH", 0x6D, "DE", -1, 99),
    ("AXJ Electronics", 0x6E, "CHN", -1, 100),
    ("Haber & Koenig Electronics GmbH (HKE)", 0x6F, "AT", -1, 101),
    ("LSdigital", 0x70, "DE", -1, 102),
    ("QS Industries (QSI)", 0x71, "US", -1, 103),
    ("Benezan Electronics", 0x72, "ESP", -1, 104),
    ("Dietz Modellbahntechnik", 0x73, "DE", -1, 105),
    ("MyLocoSound", 0x74, "AUS", -1, 106),
    ("cT Elektronik", 0x75, "AT", -1, 107),
    ("MÜT GmbH", 0x76, "DE", -1, 108),
    ("W. S. Ataras Engineering", 0x77, "US", -1, 109),
    ("csikos-muhely", 0x78, "HUN", -1, 110),
    ("Berros", 0x7A, "NL", -1, 111),
    ("Massoth Elektronik, GmbH", 0x7B, "DE", -1, 112),
    ("DCC-Gaspar-Electronic", 0x7C, "HUN", -1, 113),
    ("ProfiLok Modellbahntechnik GmbH", 0x7D, "DE", -1, 114),
    ("Möllehem Gårdsproduktion", 0x7E, "SE", -1, 115),
    ("Atlas Model Railroad Products", 0x7F, "US", -1, 116),
    ("Frateschi Model Trains", 0x80, "BRA", -1, 117),
    ("Digitrax", 0x81, "US", 0, 118),
    ("cmOS Engineering", 0x82, "AUS", -1, 119),
    ("Trix Modelleisenbahn", 0x83, "DE", -1, 120),
    ("ZTC", 0x84, "UK", -1, 121),
    ("Intelligent Command Control", 0x85, "US", -1, 122),
    ("LaisDCC", 0x86, "CHN", -1, 123),
    ("CVP Products", 0x87, "US", -1, 124),
    ("NYRS", 0x88, "US", -1, 125),
    ("Train ID Systems", 0x8A, "US", -1, 126),
    ("RealRail Effects", 0x8B, "US", -1, 127),
    ("Desktop Station", 0x8C, "JP", -1, 128),
    ("Throttle-Up (Soundtraxx)", 0x8D, "US", -1, 129),
    ("SLOMO Railroad Models", 0x8E, "JP", -1, 130),
    ("Model Rectifier Corp.", 0x8F, "US", -1, 131),
    ("DCC Train Automation", 0x90, "UK", -1, 132),
    ("Zimo Elektronik", 0x91, "AT", -1, 133),
    ("Rails Europ Express", 0x92, "FR", -1, 134),
    ("Umelec Ing. Buero", 0x93, "CH", -1, 135),
    ("BLOCKsignalling", 0x94, "UK", -1, 136),
    ("Rock Junction Controls", 0x95, "US", -1, 137),
    ("Wm. K. Walthers, Inc.", 0x96, "US", -1, 138),
    ("Electronic Solutions Ulm GmbH", 0x97, "DE", -1, 139),
    ("Digi-CZ", 0x98, "CZE", -1, 140),
    ("Train Control Systems", 0x99, "US", -1, 141),
    ("Dapol Limited", 0x9A, "UK", -1, 142),
    ("Gebr. Fleischmann GmbH & Co.", 0x9B, "DE", -1, 143),
    ("Nucky", 0x9C, "JP", -1, 144),
    ("Kuehn Ing.", 0x9D, "DE", -1, 145),
    ("Fucik", 0x9E, "CZE", -1, 146),
    ("LGB (Ernst Paul Lehmann Patentwerk)", 0x9F, "DE", -1, 147),
    ("MD Electronics", 0xA0, "DE", -1, 148),
    ("Modelleisenbahn GmbH (formerly Roco)", 0xA1, "AT", -1, 149),
    ("PIKO", 0xA2, "DE", -1, 150),
    ("WP Railshops", 0xA3, "CA", -1, 151),
    ("drM", 0xA4, "TWN", -1, 152),
    ("Model Electronic Railway Group", 0xA5, "UK", -1, 153),
    ("Maison de DCC", 0xA6, "JP", -1, 154),
    ("Helvest Systems GmbH", 0xA7, "CH", -1, 155),
    ("Model Train Technology", 0xA8, "US", -1, 156),
    ("AE Electronic Ltd.", 0xA9, "CHN", -1, 157),
    ("AuroTrains", 0xAA, "US/IT", -1, 158),
    ("Arnold – Rivarossi", 0xAD, "DE", -1, 159),
    ("BRAWA Modellspielwaren GmbH & Co.", 0xBA, "DE", -1, 160),
    ("Con-Com GmbH", 0xCC, "AT", -1, 161),
    ("Blue Digital", 0xE1, "POL", -1, 162),
    ("PECO", -1, "UK", -1, 163),
//  ("NMRA Reserved (for extended ID #’s)", 0xEE, "US", -1, 163),
  ]

}
