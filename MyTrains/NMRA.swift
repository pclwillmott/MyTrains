//
//  NMRA.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/01/2022.
//

import Foundation

public typealias ManufacturerInfo = (name: String, code: Int, country: String)

public class NMRA {
  
  // MARK: Private Class Propoerties
  
  private static var _manufacturers : [Int:ManufacturerInfo]?
  
  private static var _cvDescriptions : [Int:String]?
  
  // MARK: Public Class Properties
  
  public static func cvDescription(cv: Int) -> String {
    return cvDescriptions[cv]?.description ?? "CV\(cv)"
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
  
  public static func manufacturerName(code: Int) -> String {
    return manufacturers[code]?.name ?? "Unknown"
  }
  
  public static var manufacturers : [Int:ManufacturerInfo] {
    get {
      if let info = _manufacturers {
        return info
      }
      let temp : [ManufacturerInfo] = [
        ("CML Electronics Limited", 0x01, "UK"),
        ("Train Technology", 0x02, "BE"),
        ("NCE Corporation (formerly North Coast Engineering)", 0x0B, "US"),
        ("Wangrow Electronics", 0x0C, "US"),
        ("Public Domain & Do-It-Yourself Decoders", 0x0D, "-"),
        ("PSI–Dynatrol", 0x0E, "US"),
        ("Ramfixx Technologies (Wangrow)", 0x0F, "CA/US"),
        ("Advance IC Engineering", 0x11, "US"),
        ("JMRI", 0x12, "US"),
        ("AMW", 0x13, "AT"),
        ("T4T – Technology for Trains GmbH", 0x14, "DE"),
        ("Kreischer Datentechnik", 0x15, "DE"),
        ("KAM Industries", 0x16, "US"),
        ("S Helper Service", 0x17, "US"),
        ("MoBaTron.de", 0x18, "DE"),
        ("Team Digital, LLC", 0x19, "US"),
        ("MBTronik – PiN GITmBH", 0x1A, "DE"),
        ("MTH Electric Trains, Inc.", 0x1B, "US"),
        ("Heljan A/S", 0x1C, "DK"),
        ("Mistral Train Models", 0x1D, "BE"),
        ("Digsight", 0x1E, "CN"),
        ("Brelec", 0x1F, "BE"),
        ("Regal Way Co. Ltd", 0x20, "HKG"),
        ("Praecipuus", 0x21, "CA"),
        ("Aristo-Craft Trains", 0x22, "US"),
        ("Electronik & Model Produktion", 0x23, "SE"),
        ("DCCconcepts", 0x24, "AU"),
        ("NAC Services, Inc", 0x25, "US"),
        ("Broadway Limited Imports, LLC", 0x26, "US"),
        ("Educational Computer, Inc.", 0x27, "US"),
        ("KATO Precision Models", 0x28, "JP"),
        ("Passmann", 0x29, "DE"),
        ("Digikeijs", 0x2A, "NL"),
        ("Ngineering", 0x2B, "US"),
        ("SPROG-DCC", 0x2C, "UK"),
        ("ANE Model Co, Ltd", 0x2D, "TWN"),
        ("GFB Designs", 0x2E, "UK"),
        ("Capecom", 0x2F, "AU"),
        ("Hornby Hobbies Ltd", 0x30, "UK"),
        ("Joka Electronic", 0x31, "DE"),
        ("N&Q Electronics", 0x32, "ESP"),
        ("DCC Supplies, Ltd", 0x33, "UK"),
        ("Krois-Modell", 0x34, "AT"),
        ("Rautenhaus Digital Vertrieb", 0x35, "DE"),
        ("TCH Technology", 0x36, "US"),
        ("QElectronics GmbH", 0x37, "DE"),
        ("LDH", 0x38, "ARG"),
        ("Rampino Elektronik", 0x39, "DE"),
        ("KRES GmbH", 0x3A, "DE"),
        ("Tam Valley Depot", 0x3B, "US"),
        ("Bluecher-Electronic", 0x3C, "DE"),
        ("TrainModules", 0x3D, "HUN"),
        ("Tams Elektronik GmbH", 0x3E, "DE"),
        ("Noarail", 0x3F, "AUS"),
        ("Digital Bahn", 0x40, "DE"),
        ("Gaugemaster", 0x41, "UK"),
        ("Railnet Solutions, LLC", 0x42, "US"),
        ("Heller Modenlbahn", 0x43, "DE"),
        ("MAWE Elektronik", 0x44, "CH"),
        ("E-Modell", 0x45, "DE"),
        ("Rocrail", 0x46, "DE"),
        ("New York Byano Limited", 0x47, "HK"),
        ("MTB Model", 0x48, "CZE"),
        ("The Electric Railroad Company", 0x49, "US"),
        ("PpP Digital", 0x4A, "ESP"),
        ("Digitools Elektronika, Kft", 0x4B, "HUN"),
        ("Auvidel", 0x4C, "DE"),
        ("LS Models Sprl", 0x4D, "BEL"),
        ("Tehnologistic (train-O-matic)", 0x4E, "ROM"),
        ("Hattons Model Railways", 0x4F, "UK"),
        ("Spectrum Engineering", 0x50, "US"),
        ("GooVerModels", 0x51, "BEL"),
        ("HAG Modelleisenbahn AG", 0x52, "CHE"),
        ("JSS-Elektronic", 0x53, "DE"),
        ("Railflyer Model Prototypes, Inc.", 0x54, "CAN"),
        ("Uhlenbrock GmbH", 0x55, "DE"),
        ("Wekomm Engineering, GmbH", 0x56, "DE"),
        ("RR-Cirkits", 0x57, "US"),
        ("HONS Model", 0x58, "HKG"),
        ("Pojezdy.EU", 0x59, "CZE"),
        ("Shourt Line", 0x5A, "US"),
        ("Railstars Limited", 0x5B, "US"),
        ("Tawcrafts", 0x5C, "UK"),
        ("Kevtronics cc", 0x5D, "ZAF"),
        ("Electroniscript, Inc.", 0x5E, "US"),
        ("Sanda Kan Industrial, Ltd.", 0x5F, "HKG"),
        ("PRICOM Design", 0x60, "US"),
        ("Doehler & Haas", 0x61, "DE"),
        ("Harman DCC", 0x62, "UK"),
        ("Lenz Elektronik GmbH", 0x63, "DE"),
        ("Trenes Digitales", 0x64, "ARG"),
        ("Bachmann Trains", 0x65, "US"),
        ("Integrated Signal Systems", 0x66, "US"),
        ("Nagasue System Design Office", 0x67, "JP"),
        ("TrainTech", 0x68, "NL"),
        ("Computer Dialysis France",  0x69, "FR"),
        ("Opherline1", 0x6A, "FR"),
        ("Phoenix Sound Systems, Inc.", 0x6B, "US"),
        ("Nagoden", 0x6C, "JP"),
        ("Viessmann Modellspielwaren GmbH", 0x6D, "DE"),
        ("AXJ Electronics", 0x6E, "CHN"),
        ("Haber & Koenig Electronics GmbH (HKE)", 0x6F, "AT"),
        ("LSdigital", 0x70, "DE"),
        ("QS Industries (QSI)", 0x71, "US"),
        ("Benezan Electronics", 0x72, "ESP"),
        ("Dietz Modellbahntechnik", 0x73, "DE"),
        ("MyLocoSound", 0x74, "AUS"),
        ("cT Elektronik", 0x75, "AT"),
        ("MÜT GmbH", 0x76, "DE"),
        ("W. S. Ataras Engineering", 0x77, "US"),
        ("csikos-muhely", 0x78, "HUN"),
        ("Berros", 0x7A, "NL"),
        ("Massoth Elektronik, GmbH", 0x7B, "DE"),
        ("DCC-Gaspar-Electronic", 0x7C, "HUN"),
        ("ProfiLok Modellbahntechnik GmbH", 0x7D, "DE"),
        ("Möllehem Gårdsproduktion", 0x7E, "SE"),
        ("Atlas Model Railroad Products", 0x7F, "US"),
        ("Frateschi Model Trains", 0x80, "BRA"),
        ("Digitrax", 0x81, "US"),
        ("cmOS Engineering", 0x82, "AUS"),
        ("Trix Modelleisenbahn", 0x83, "DE"),
        ("ZTC", 0x84, "UK"),
        ("Intelligent Command Control", 0x85, "US"),
        ("LaisDCC", 0x86, "CHN"),
        ("CVP Products", 0x87, "US"),
        ("NYRS", 0x88, "US"),
        ("Train ID Systems", 0x8A, "US"),
        ("RealRail Effects", 0x8B, "US"),
        ("Desktop Station", 0x8C, "JP"),
        ("Throttle-Up (Soundtraxx)", 0x8D, "US"),
        ("SLOMO Railroad Models", 0x8E, "JP"),
        ("Model Rectifier Corp.", 0x8F, "US"),
        ("DCC Train Automation", 0x90, "UK"),
        ("Zimo Elektronik", 0x91, "AT"),
        ("Rails Europ Express", 0x92, "FR"),
        ("Umelec Ing. Buero", 0x93, "CH"),
        ("BLOCKsignalling", 0x94, "UK"),
        ("Rock Junction Controls", 0x95, "US"),
        ("Wm. K. Walthers, Inc.", 0x96, "US"),
        ("Electronic Solutions Ulm GmbH", 0x97, "DE"),
        ("Digi-CZ", 0x98, "CZE"),
        ("Train Control Systems", 0x99, "US"),
        ("Dapol Limited", 0x9A, "UK"),
        ("Gebr. Fleischmann GmbH & Co.", 0x9B, "DE"),
        ("Nucky", 0x9C, "JP"),
        ("Kuehn Ing.", 0x9D, "DE"),
        ("Fucik", 0x9E, "CZE"),
        ("LGB (Ernst Paul Lehmann Patentwerk)", 0x9F, "DE"),
        ("MD Electronics", 0xA0, "DE"),
        ("Modelleisenbahn GmbH (formerly Roco)", 0xA1, "AT"),
        ("PIKO", 0xA2, "DE"),
        ("WP Railshops", 0xA3, "CA"),
        ("drM", 0xA4, "TWN"),
        ("Model Electronic Railway Group", 0xA5, "UK"),
        ("Maison de DCC", 0xA6, "JP"),
        ("Helvest Systems GmbH", 0xA7, "CH"),
        ("Model Train Technology", 0xA8, "US"),
        ("AE Electronic Ltd.", 0xA9, "CHN"),
        ("AuroTrains", 0xAA, "US/IT"),
        ("Arnold – Rivarossi", 0xAD, "DE"),
        ("BRAWA Modellspielwaren GmbH & Co.", 0xBA, "DE"),
        ("Con-Com GmbH", 0xCC, "AT"),
        ("Blue Digital", 0xE1, "POL"),
        ("NMRA Reserved (for extended ID #’s)", 0xEE, "US"),
      ]
      
      var info : [Int:ManufacturerInfo] = [:]
      
      for manufacturer in temp {
        info[manufacturer.code] = manufacturer
      }
      
      _manufacturers = info
      
      return info
      
    }
  }
}
