//
//  CommandStationOptionSwitch.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/02/2022.
//

import Foundation

public class OptionSwitch {
  
  // MARK: Class Properties
  
  public static let enterSetSwitchAddressModeInstructions : [LocoNetDeviceId:String] = [
    .DS64 : "On the DS64's control panel, press and hold the \"ID\" button for 3 seconds until the green \"LED\" slowly blinks on and off."
  ]
  
  public static let enterSetBoardIdModeInstructions : [LocoNetDeviceId:String] = [
    .BXP88 : "Press and hold the \"ID\" button on the BXP88 for approximately 4 seconds until the \"ID\" LED flashes red, then release it. The \"ID\" LED will flash alternating red and green.",
    .DS74 : "Press and hold the \"ID\" button on the DS74 for about 3 seconds until the \"RTS\" and \"OPS\" LEDs blink alternately, then release the \"ID\" button.",
    .DS64 : "Press and hold the \"STAT\" button on the DS64 down for approximately 10 seconds. The \"STAT\" LED will blink at a fast rate and after approximately 10 seconds it will change to a slow blink rate, alternating between red and green. You must release the \"STAT\" button as soon as the blink rate changes or the DS64 will time out and you'll have to start again.",
  ]

  public static let exitSetBoardIdModeInstructions : [LocoNetDeviceId:String] = [:]

  public static let enterOptionSwitchModeInstructions : [LocoNetDeviceId:String] = [
    .BXP88 : "Press and hold the \"OPS\" button on the BXP88 for about 2 seconds, then release it. The red \"OPS\" and green \"ID\" LEDs will flash alternately.",
    .DS74 : "Press and hold the \"OPS\" button on the DS74 for about 3 seconds until the green \"ID\" and \"RTS\" LEDs blink alternately, then release the \"OPS\" button.",
    .DS64 : "Press and hold the \"OPS\" button on the DS64 for about 3 seconds until the red \"OPS\" LED and green \"ID\" LED begin to blink alternately.",
    .DCS210 : "Move the Mode toggle switch on the front of the DCS210 to the \"OP\" position. The PWR indicator will flash green alternating with the PROG indicator flashing red.",
    .DCS240 : "Move the Mode toggle switch on the front of the DCS240 to the \"OP\" position. The PWR indicator will flash green alternating with the PROG indicator flashing red.",
    .DCS100 : "Move the Mode toggle switch on the front of the DCS100 to the \"OP\" position. The PWR indicator will flash green alternating with the PROG indicator flashing red.",
    .DCS200 : "Move the Mode toggle switch on the front of the DCS200 to the \"OP\" position. The PWR indicator will flash green alternating with the PROG indicator flashing red.",
    .DB150 : "Move the Mode toggle switch on the front of the DB150 to the \"OP\" position.",
    .DCS240PLUS : "Move the Mode toggle switch on the front of the DCS240+ to the \"OP\" position. The PWR indicator will flash green alternating with the PROG indicator flashing red.",
  ]
  
  public static let exitOptionSwitchModeInstructions : [LocoNetDeviceId:String] = [
    .BXP88 : "Press and hold the \"OPS\" button on the BXP88 for about 2 seconds and release it.",
    .DS74 : "Press and hold the \"OPS\" button on the DS74 for 3 seconds and release it.",
    .DS64 : "Press and hold the \"OPS\" button on the DS64 until the red LED stops blinking.",
    .DCS210 : "Move the Mode toggle switch on the DCS210 to the \"RUN\" position.",
    .DCS240 : "Move the Mode toggle switch on the DCS240 to the \"RUN\" position.",
    .DCS100 : "Move the Mode toggle switch on the DCS100 to the \"RUN\" position.",
    .DCS200 : "Move the Mode toggle switch on the DCS200 to the \"RUN\" position.",
    .DB150 : "Move the Mode toggle switch on the DB150 to the \"RUN\" position.",
    .DCS240PLUS : "Move the Mode toggle switch on the DCS240+ to the \"RUN\" position.",
  ]
  
}
