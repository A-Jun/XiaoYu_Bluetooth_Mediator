//
//  RJSensorModel.swift
//  swiftTest
//
//  Created by RJ on 2018/7/16.
//  Copyright © 2018年 RJ. All rights reserved.
//

import UIKit
import CoreBluetooth
enum OemType : String {
    //小羽2.0
    case KU               = "UK"
    case M1               = "1M"
    case M2               = "2M"
    case M3               = "3M"
    case M4               = "4M"
    case M5               = "5M"
    case M6               = "6M"
    case M7               = "7M"
    case M8               = "8M"
    case M9               = "9M"
    case MA               = "AM"
    //小羽2S
    case N0               = "0N"
    case N1               = "1N"
    case N2               = "2N"
    case N3               = "3N"
    case N4               = "4N"
    case N5               = "5N"
    case N6               = "6N"
    case N7               = "7N"
    case N8               = "8N"
    case N9               = "9N"
    case NA               = "AN"
    case NB               = "BN"
    case NC               = "CN"
    case ND               = "DN"
    case NE               = "EN"
    case NF               = "FN"
    case NG               = "GN"
    case NH               = "HN"
    case NI               = "IN"
    case NJ               = "JN"
    //小羽低成本
    case L0               = "0L"
    case LD               = "DL"
    //小羽3.0
    case H0               = "0H"
    case H1               = "1H"
    case H3               = "3H"
    case H4               = "4H"
    
}
class RJSensorModel: NSObject {
    var cbPeripheral          : CBPeripheral?
    var name                  : String?
    var RSSI                  : NSInteger = 0
    var MacAdress             : String?
    var oemData               : String?
    var oemType               : OemType?
    var version               : String?
    var advertisementData     : [String : Any]?
    override init() {
        super.init()
    }
    convenience init(_ sensor:CBPeripheral, _ advertisement:[String : Any], _ rssi:NSNumber) {
        self.init()
        cbPeripheral      = sensor
        name              = sensor.name
        RSSI              = NSInteger(fabs(rssi.doubleValue))
        advertisementData = advertisement
        let manuFactureData = advertisement[CBAdvertisementDataManufacturerDataKey] as! Data
        guard let manuFactureSting = String(data: manuFactureData.prefix(6), encoding: .utf8) else { return  }
        
        oemType             = OemType(rawValue: String(manuFactureSting.prefix(2)))
        oemData             = String(manuFactureSting.suffix(4))
    }
    convenience init(_ infoDic:[String:Any]?) {
        self.init()
        guard let info = infoDic else { return  }
        cbPeripheral        = info["cbPeripheral"] as? CBPeripheral
        name                = info["name"] as? String
        MacAdress           = info["MacAdress"] as? String
        RSSI                = info["RSSI"] as! NSInteger
        oemData               = info["oemData"] as? String
        oemType             = info["oemType"] as? OemType
        version             = info["version"] as? String
        advertisementData   = info["advertisementData"] as? [String:Any]
    }
    func infoDic() -> [String:Any] {
        var infoDic = [String:Any]()
        infoDic["cbPeripheral"]      = cbPeripheral
        infoDic["name"]              = name
        infoDic["RSSI"]              = RSSI
        infoDic["MacAdress"]         = MacAdress
        infoDic["oemData"]           = oemData
        infoDic["oemType"]           = oemType
        infoDic["version"]           = version
        infoDic["advertisementData"] = advertisementData
        
        return infoDic
    }
    func correctOrderOemType() -> String {
        let string = oemType?.rawValue
        return  String(string!.suffix(1) + string!.prefix(1))
    }
    
}
