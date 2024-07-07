//
//  ManufacturerCode.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/07/2024.
//

import Foundation

public enum ManufacturerCode : UInt16, CaseIterable {
  
  // MARK: Enumeration
  
  case cMLElectronicsLimited = 0x01
  case trainTechnology = 0x02
  case nCECorporationformerlyNorthCoastEngineering = 0x0b
  case wangrowElectronics = 0x0c
  case publicDomain_Do_It_YourselfDecoders = 0x0d
  case pSI_Dynatrol = 0x0e
  case ramfixxTechnologiesWangrow = 0x0f
  case advanceICEngineering = 0x11
  case jMRI = 0x12
  case aMW = 0x13
  case t4T_TechnologyforTrainsGmbH = 0x14
  case kreischerDatentechnik = 0x15
  case kAMIndustries = 0x16
  case sHelperService = 0x17
  case moBaTronde = 0x18
  case teamDigitalLLC = 0x19
  case mBTronik_PiNGITmBH = 0x1a
  case mTHElectricTrainsInc = 0x1b
  case heljanAS = 0x1c
  case mistralTrainModels = 0x1d
  case digsight = 0x1e
  case brelec = 0x1f
  case regalWayCoLtd = 0x20
  case praecipuus = 0x21
  case aristo_CraftTrains = 0x22
  case electronik_ModelProduktion = 0x23
  case dCCconcepts = 0x24
  case nACServicesInc = 0x25
  case broadwayLimitedImportsLLC = 0x26
  case educationalComputerInc = 0x27
  case kATOPrecisionModels = 0x28
  case passmann = 0x29
  case digikeijs = 0x2a
  case ngineering = 0x2b
  case sPROG_DCC = 0x2c
  case aNEModelCoLtd = 0x2d
  case gFBDesigns = 0x2e
  case capecom = 0x2f
  case hornbyHobbiesLtd = 0x30
  case jokaElectronic = 0x31
  case n_QElectronics = 0x32
  case dCCSuppliesLtd = 0x33
  case krois_Modell = 0x34
  case rautenhausDigitalVertrieb = 0x35
  case tCHTechnology = 0x36
  case qElectronicsGmbH = 0x37
  case lDH = 0x38
  case rampinoElektronik = 0x39
  case tamValleyDepot = 0x3b
  case bluecher_Electronic = 0x3c
  case trainModules = 0x3d
  case tamsElektronikGmbH = 0x3e
  case noarail = 0x3f
  case digitalBahn = 0x40
  case gaugemaster = 0x41
  case railnetSolutionsLLC = 0x42
  case hellerModenlbahn = 0x43
  case mAWEElektronik = 0x44
  case e_Modell = 0x45
  case rocrail = 0x46
  case newYorkByanoLimited = 0x47
  case mTBModel = 0x48
  case theElectricRailroadCompany = 0x49
  case ppPDigital = 0x4a
  case digitoolsElektronikaKft = 0x4b
  case auvidel = 0x4c
  case lSModelsSprl = 0x4d
  case tehnologistictrain_O_matic = 0x4e
  case hattonsModelRailways = 0x4f
  case spectrumEngineering = 0x50
  case gooVerModels = 0x51
  case hAGModelleisenbahnAG = 0x52
  case jSS_Elektronic = 0x53
  case railflyerModelPrototypesInc = 0x54
  case uhlenbrockGmbH = 0x55
  case wekommEngineeringGmbH = 0x56
  case rR_CirKits = 0x57
  case hONSModel = 0x58
  case pojezdyEU = 0x59
  case shourtLine = 0x5a
  case railstarsLimited = 0x5b
  case tawcrafts = 0x5c
  case kevtronicscc = 0x5d
  case electroniscriptInc = 0x5e
  case sandaKanIndustrialLtd = 0x5f
  case pRICOMDesign = 0x60
  case doehler_Haas = 0x61
  case harmanDCC = 0x62
  case lenzElektronikGmbH = 0x63
  case trenesDigitales = 0x64
  case bachmannTrains = 0x65
  case integratedSignalSystems = 0x66
  case nagasueSystemDesignOffice = 0x67
  case trainTech = 0x68
  case computerDialysisFrance = 0x69
  case opherline1 = 0x6a
  case phoenixSoundSystemsInc = 0x6b
  case nagoden = 0x6c
  case viessmannModellspielwarenGmbH = 0x6d
  case aXJElectronics = 0x6e
  case haber_KoenigElectronicsGmbHHKE = 0x6f
  case lSdigital = 0x70
  case qSIndustriesQSI = 0x71
  case benezanElectronics = 0x72
  case dietzModellbahntechnik = 0x73
  case myLocoSound = 0x74
  case cTElektronik = 0x75
  case mÜTGmbH = 0x76
  case wSAtarasEngineering = 0x77
  case csikos_muhely = 0x78
  case berros = 0x7a
  case massothElektronikGmbH = 0x7b
  case dCC_Gaspar_Electronic = 0x7c
  case profiLokModellbahntechnikGmbH = 0x7d
  case möllehemGårdsproduktion = 0x7e
  case atlasModelRailroadProducts = 0x7f
  case frateschiModelTrains = 0x80
  case digitrax = 0x81
  case cmOSEngineering = 0x82
  case trixModelleisenbahn = 0x83
  case zTC = 0x84
  case intelligentCommandControl = 0x85
  case laisDCC = 0x86
  case cVPProducts = 0x87
  case nYRS = 0x88
  case trainIDSystems = 0x8a
  case realRailEffects = 0x8b
  case desktopStation = 0x8c
  case throttle_UpSoundtraxx = 0x8d
  case sLOMORailroadModels = 0x8e
  case modelRectifierCorp = 0x8f
  case dCCTrainAutomation = 0x90
  case zimoElektronik = 0x91
  case railsEuropExpress = 0x92
  case umelecIngBuero = 0x93
  case bLOCKsignalling = 0x94
  case rockJunctionControls = 0x95
  case wmKWalthersInc = 0x96
  case electronicSolutionsUlmGmbH = 0x97
  case digi_CZ = 0x98
  case trainControlSystems = 0x99
  case dapolLimited = 0x9a
  case gebrFleischmannGmbH_Co = 0x9b
  case nucky = 0x9c
  case kuehnIng = 0x9d
  case fucik = 0x9e
  case lGBErnstPaulLehmannPatentwerk = 0x9f
  case mDElectronics = 0xa0
  case modelleisenbahnGmbHformerlyRoco = 0xa1
  case pIKO = 0xa2
  case wPRailshops = 0xa3
  case drM = 0xa4
  case modelElectronicRailwayGroup = 0xa5
  case maisondeDCC = 0xa6
  case helvestSystemsGmbH = 0xa7
  case modelTrainTechnology = 0xa8
  case aEElectronicLtd = 0xa9
  case auroTrains = 0xaa
  case arnold_Rivarossi = 0xad
  case bRAWAModellspielwarenGmbH_Co = 0xba
  case con_ComGmbH = 0xcc
  case blueDigital = 0xe1
  
  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [ManufacturerCode:String] = [
      .cMLElectronicsLimited : "CML Electronics Limited",
      .trainTechnology : "Train Technology",
      .nCECorporationformerlyNorthCoastEngineering : "NCE Corporation (formerly North Coast Engineering)",
      .wangrowElectronics : "Wangrow Electronics",
      .publicDomain_Do_It_YourselfDecoders : "Public Domain & Do-It-Yourself Decoders",
      .pSI_Dynatrol : "PSI–Dynatrol",
      .ramfixxTechnologiesWangrow : "Ramfixx Technologies (Wangrow)",
      .advanceICEngineering : "Advance IC Engineering",
      .jMRI : "JMRI",
      .aMW : "AMW",
      .t4T_TechnologyforTrainsGmbH : "T4T – Technology for Trains GmbH",
      .kreischerDatentechnik : "Kreischer Datentechnik",
      .kAMIndustries : "KAM Industries",
      .sHelperService : "S Helper Service",
      .moBaTronde : "MoBaTron.de",
      .teamDigitalLLC : "Team Digital, LLC",
      .mBTronik_PiNGITmBH : "MBTronik – PiN GITmBH",
      .mTHElectricTrainsInc : "MTH Electric Trains, Inc.",
      .heljanAS : "Heljan A/S",
      .mistralTrainModels : "Mistral Train Models",
      .digsight : "Digsight",
      .brelec : "Brelec",
      .regalWayCoLtd : "Regal Way Co. Ltd",
      .praecipuus : "Praecipuus",
      .aristo_CraftTrains : "Aristo-Craft Trains",
      .electronik_ModelProduktion : "Electronik & Model Produktion",
      .dCCconcepts : "DCCconcepts",
      .nACServicesInc : "NAC Services, Inc",
      .broadwayLimitedImportsLLC : "Broadway Limited Imports, LLC",
      .educationalComputerInc : "Educational Computer, Inc.",
      .kATOPrecisionModels : "KATO Precision Models",
      .passmann : "Passmann",
      .digikeijs : "Digikeijs",
      .ngineering : "Ngineering",
      .sPROG_DCC : "SPROG-DCC",
      .aNEModelCoLtd : "ANE Model Co, Ltd",
      .gFBDesigns : "GFB Designs",
      .capecom : "Capecom",
      .hornbyHobbiesLtd : "Hornby Hobbies Ltd",
      .jokaElectronic : "Joka Electronic",
      .n_QElectronics : "N&Q Electronics",
      .dCCSuppliesLtd : "DCC Supplies, Ltd",
      .krois_Modell : "Krois-Modell",
      .rautenhausDigitalVertrieb : "Rautenhaus Digital Vertrieb",
      .tCHTechnology : "TCH Technology",
      .qElectronicsGmbH : "QElectronics GmbH",
      .lDH : "LDH",
      .rampinoElektronik : "Rampino Elektronik",
      .tamValleyDepot : "Tam Valley Depot",
      .bluecher_Electronic : "Bluecher-Electronic",
      .trainModules : "TrainModules",
      .tamsElektronikGmbH : "Tams Elektronik GmbH",
      .noarail : "Noarail",
      .digitalBahn : "Digital Bahn",
      .gaugemaster : "Gaugemaster",
      .railnetSolutionsLLC : "Railnet Solutions, LLC",
      .hellerModenlbahn : "Heller Modenlbahn",
      .mAWEElektronik : "MAWE Elektronik",
      .e_Modell : "E-Modell",
      .rocrail : "Rocrail",
      .newYorkByanoLimited : "New York Byano Limited",
      .mTBModel : "MTB Model",
      .theElectricRailroadCompany : "The Electric Railroad Company",
      .ppPDigital : "PpP Digital",
      .digitoolsElektronikaKft : "Digitools Elektronika, Kft",
      .auvidel : "Auvidel",
      .lSModelsSprl : "LS Models Sprl",
      .tehnologistictrain_O_matic : "Tehnologistic (train-O-matic)",
      .hattonsModelRailways : "Hattons Model Railways",
      .spectrumEngineering : "Spectrum Engineering",
      .gooVerModels : "GooVerModels",
      .hAGModelleisenbahnAG : "HAG Modelleisenbahn AG",
      .jSS_Elektronic : "JSS-Elektronic",
      .railflyerModelPrototypesInc : "Railflyer Model Prototypes, Inc.",
      .uhlenbrockGmbH : "Uhlenbrock GmbH",
      .wekommEngineeringGmbH : "Wekomm Engineering, GmbH",
      .rR_CirKits : "RR-CirKits",
      .hONSModel : "HONS Model",
      .pojezdyEU : "Pojezdy.EU",
      .shourtLine : "Shourt Line",
      .railstarsLimited : "Railstars Limited",
      .tawcrafts : "Tawcrafts",
      .kevtronicscc : "Kevtronics cc",
      .electroniscriptInc : "Electroniscript, Inc.",
      .sandaKanIndustrialLtd : "Sanda Kan Industrial, Ltd.",
      .pRICOMDesign : "PRICOM Design",
      .doehler_Haas : "Doehler & Haas",
      .harmanDCC : "Harman DCC",
      .lenzElektronikGmbH : "Lenz Elektronik GmbH",
      .trenesDigitales : "Trenes Digitales",
      .bachmannTrains : "Bachmann Trains",
      .integratedSignalSystems : "Integrated Signal Systems",
      .nagasueSystemDesignOffice : "Nagasue System Design Office",
      .trainTech : "TrainTech",
      .computerDialysisFrance : "Computer Dialysis France",
      .opherline1 : "Opherline1",
      .phoenixSoundSystemsInc : "Phoenix Sound Systems, Inc.",
      .nagoden : "Nagoden",
      .viessmannModellspielwarenGmbH : "Viessmann Modellspielwaren GmbH",
      .aXJElectronics : "AXJ Electronics",
      .haber_KoenigElectronicsGmbHHKE : "Haber & Koenig Electronics GmbH (HKE)",
      .lSdigital : "LSdigital",
      .qSIndustriesQSI : "QS Industries (QSI)",
      .benezanElectronics : "Benezan Electronics",
      .dietzModellbahntechnik : "Dietz Modellbahntechnik",
      .myLocoSound : "MyLocoSound",
      .cTElektronik : "cT Elektronik",
      .mÜTGmbH : "MÜT GmbH",
      .wSAtarasEngineering : "W. S. Ataras Engineering",
      .csikos_muhely : "csikos-muhely",
      .berros : "Berros",
      .massothElektronikGmbH : "Massoth Elektronik, GmbH",
      .dCC_Gaspar_Electronic : "DCC-Gaspar-Electronic",
      .profiLokModellbahntechnikGmbH : "ProfiLok Modellbahntechnik GmbH",
      .möllehemGårdsproduktion : "Möllehem Gårdsproduktion",
      .atlasModelRailroadProducts : "Atlas Model Railroad Products",
      .frateschiModelTrains : "Frateschi Model Trains",
      .digitrax : "Digitrax",
      .cmOSEngineering : "cmOS Engineering",
      .trixModelleisenbahn : "Trix Modelleisenbahn",
      .zTC : "ZTC",
      .intelligentCommandControl : "Intelligent Command Control",
      .laisDCC : "LaisDCC",
      .cVPProducts : "CVP Products",
      .nYRS : "NYRS",
      .trainIDSystems : "Train ID Systems",
      .realRailEffects : "RealRail Effects",
      .desktopStation : "Desktop Station",
      .throttle_UpSoundtraxx : "Throttle-Up (Soundtraxx)",
      .sLOMORailroadModels : "SLOMO Railroad Models",
      .modelRectifierCorp : "Model Rectifier Corp.",
      .dCCTrainAutomation : "DCC Train Automation",
      .zimoElektronik : "Zimo Elektronik",
      .railsEuropExpress : "Rails Europ Express",
      .umelecIngBuero : "Umelec Ing. Buero",
      .bLOCKsignalling : "BLOCKsignalling",
      .rockJunctionControls : "Rock Junction Controls",
      .wmKWalthersInc : "Wm. K. Walthers, Inc.",
      .electronicSolutionsUlmGmbH : "Electronic Solutions Ulm GmbH",
      .digi_CZ : "Digi-CZ",
      .trainControlSystems : "Train Control Systems",
      .dapolLimited : "Dapol Limited",
      .gebrFleischmannGmbH_Co : "Gebr. Fleischmann GmbH & Co.",
      .nucky : "Nucky",
      .kuehnIng : "Kuehn Ing.",
      .fucik : "Fucik",
      .lGBErnstPaulLehmannPatentwerk : "LGB (Ernst Paul Lehmann Patentwerk)",
      .mDElectronics : "MD Electronics",
      .modelleisenbahnGmbHformerlyRoco : "Modelleisenbahn GmbH (formerly Roco)",
      .pIKO : "PIKO",
      .wPRailshops : "WP Railshops",
      .drM : "drM",
      .modelElectronicRailwayGroup : "Model Electronic Railway Group",
      .maisondeDCC : "Maison de DCC",
      .helvestSystemsGmbH : "Helvest Systems GmbH",
      .modelTrainTechnology : "Model Train Technology",
      .aEElectronicLtd : "AE Electronic Ltd.",
      .auroTrains : "AuroTrains",
      .arnold_Rivarossi : "Arnold – Rivarossi",
      .bRAWAModellspielwarenGmbH_Co : "BRAWA Modellspielwaren GmbH & Co.",
      .con_ComGmbH : "Con-Com GmbH",
      .blueDigital : "Blue Digital",
    ]
    
    return titles[self]!
    
  }
  
}
