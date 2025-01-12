//
//  LocoNetMessageType.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/06/2023.
//

import Foundation

// LocoNet Message Types are for internal MyTrains usage.
// Unlike the LocoNet Message Opcode, these constants uniquely
// identify a LocoNet Message Type.

public enum LocoNetMessageType {
  case unknown
  case uninitialized
  case brdOpSwState
  case busy
  case consistDirF0F4
  case d4Error
  case dispatchGetP1
  case dispatchGetP2
  case dispatchPutP1
  case dispatchPutP2
  case duplexGroupChannel
  case duplexGroupData
  case duplexGroupID
  case duplexGroupPassword
  case duplexSignalStrength
  case ezRouteConfirm
  case fastClockData
  case findLoco
  case findReceiver
  case getBrdOpSwState
  case getOpSwDataAP1
  case getOpSwDataBP1
  case getOpSwDataP2
  case getDuplexGroupChannel
  case getDuplexGroupData
  case getDuplexGroupID
  case getDuplexGroupPassword
  case getDuplexSignalStrength
  case getFastClockData
  case getLocoSlotData
  case getLocoSlotDataLAdrP1
  case getLocoSlotDataLAdrP2
  case getLocoSlotDataSAdrP1
  case getLocoSlotDataSAdrP2
  case getQuerySlot
  case getRosterEntry
  case getRosterTableInfo
  case getRouteTableInfoA
  case getRouteTableInfoB
  case getRouteTablePage
  case getSwState
  case illegalMoveP1
  case immPacket
  case immPacketOK
  case immPacketLMOK // What does this do?
  case immPacketBufferFull
  case interfaceData
  case interfaceDataLB
  case interfaceDataPR3
  case interrogate
  case invalidLinkP1
  case invalidUnlinkP1
  case iplDataLoad
  case iplDevData
  case iplDiscover
  case iplEndLoad
  case iplSetAddr
  case iplSetup
  case linkSlotsP1
  case linkSlotsP2
  case lnwiData
  case locoDirF0F4P1
  case locoF0F6P2
  case locoF5F8P1

  case locoF5F11U
  case locoF13F19U
  case locoF21F27U
  case locoF12F20F28U
  case locoBinStateU
  case progOnMainU
  case enterProgTrkModeU
  case exitProgTrkModeU
  case getLNCVU
  case lncvDataU
  case setLNCVU
  case readCVU
  case writeCVU
  case readLocoAddrU
  case writeLocoAddrU
  case setDataFormatU
  case getDataFormatU
  case dataFormatU
  case ukAU // Unknown A Uhlenbrock
  case ukBU // Unknown B Uhlenbrock
  case ukCU // Unknown C Uhlenbrock
  case ukDU // Unknown D Uhlenbrock
  
  case locoF7F13P2
  case locoF9F12IMMLAdr
  case locoF9F12IMMSAdr
  case locoF9F12P1
  case locoF13F20IMMLAdr
  case locoF13F20IMMSAdr
  case locoF14F20P2
  case locoF21F28IMMLAdr
  case locoF21F28IMMSAdr
  case locoF21F28P2
  case locoRep
  case locoSlotDataP1
  case locoSlotDataP2
  case locoSpdDirP2
  case locoSpdP1
  case moveSlotP1
  case moveSlotP2
  case noFreeSlotsP1
  case noFreeSlotsP2
  case opSwDataAP1
  case opSwDataBP1
  case opSwDataP2
  case peerXfer16
  case pmRep
  case pmRepBXP88
  case pmRepBXPA1
  case prMode
  case progCmdAccepted
  case progCmdAcceptedBlind
  case progCV
  case progSlotDataP1
  case programmerBusy
  case pwrOff
  case pwrOn
  case querySlot1
  case querySlot2
  case querySlot3
  case querySlot4
  case querySlot5
  case receiverRep
  case reset
  case resetQuerySlot4
  case rosterEntry
  case rosterTableInfo
  case routeTableInfoA
  case routeTableInfoB
  case routeTablePage
  case routesDisabled
  case s7CVRW
  case s7CVState
  case s7Info
  case s7Identify
  case sensRepGenIn
  case sensRepTurnIn
  case sensRepTurnOut
  case setBrdOpSwOK
  case setBrdOpSwState
  case setOpSwDataAP1
  case setOpSwDataBP1
  case setOpSwDataP2
  case setDuplexGroupChannel
  case setDuplexGroupData
  case setDuplexGroupID
  case setDuplexGroupPassword
  case setFastClockData
  case setIdleState
  case setLocoNetID
  case setLocoSlotDataP1
  case setLocoSlotDataP2
  case setLocoSlotInUseP1
  case setLocoSlotInUseP2
  case setLocoSlotStat1P1
  case setLocoSlotStat1P2
  case setRosterEntry
  case setRouteTablePage
  case setS7BaseAddr
  case setSlotDataOKP1
  case setSlotDataOKP2
  case setSw
  case setSwAccepted
  case setSwRejected
  case setSwWithAck
  case setSwWithAckAccepted
  case setSwWithAckRejected
  case slotNotImplemented
  case swState
  case timeout
  case transRep
  case trkShortRep
  case unlinkSlotsP1
  case unlinkSlotsP2
  case zapped
}
