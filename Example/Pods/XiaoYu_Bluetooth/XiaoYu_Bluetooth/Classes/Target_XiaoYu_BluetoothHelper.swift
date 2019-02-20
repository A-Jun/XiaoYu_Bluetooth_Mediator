//
//  Target_XiaoYu_Bluetooth.swift
//  CTMediator
//
//  Created by RJ on 2018/8/30.
//

import UIKit


@objc class Target_XiaoYu_BluetoothHelper: NSObject {
    var bluetoothHelper = RJBluetoothHelper.shareInstance
    /// 搜索外设
    ///
    /// - Parameters:
    ///   - services: 服务 [String]?
    ///   - options: 可选字典， [String : Any]? 指定用于自定义扫描的选项 是否重复扫描已发现的设备 默认为NO
    ///              CBCentralManagerScanOptionAllowDuplicatesKey:false
    @objc func Action_ScanSensor(_ params:[AnyHashable:Any]) {
        let services = params["services"] as? [CBUUID]
        let options  = params["options"]  as? [String : Any]
        let handler  = params["handler"]  as? ScanSensorResultHandler_XiaoYu
        bluetoothHelper.scanSensor(withServices: services, options: options, handler: handler)
    }
    /// 搜索外设
    ///
    /// - Parameters:
    ///   - services: 服务 [String]?
    ///   - options: 可选字典， [String : Any]? 指定用于自定义扫描的选项 是否重复扫描已发现的设备 默认为NO
    ///              CBCentralManagerScanOptionAllowDuplicatesKey:false
    @objc func Action_ScanSensorWithOriginData(_ params:[AnyHashable:Any]) {
        let services = params["services"] as? [CBUUID]
        let options  = params["options"]  as? [String : Any]
        let handler  = params["handler"]  as? ScanSensorResultHandler
        bluetoothHelper.scanSensorWithOriginData(withServices: services, options: options, handler: handler)
    }
    /// 结束搜索外设
    @objc func Action_StopScan(_ params:[AnyHashable:Any])  {
        bluetoothHelper.stopScan()
    }
    /// 连接外设
    ///
    /// - Parameters:
    ///   - sensor: 外设模型
    ///   - options: 可选字典，指定用于连接状态的提示的选项
    @objc func Action_Connect(_ params:[AnyHashable:Any]) -> Void {
        let peripheral = params["peripheral"] as! CBPeripheral
        let options    = params["options"]   as? [String : Any]
        let connectHandler    = params["connectHandler"]   as? ConnectSensorResultHandler_XiaoYu
        let disConnectHandler = params["disConnectHandler"] as? DisConnectSensorResultHandler_XiaoYu
        bluetoothHelper.connect(peripheral, options, connectHandler: connectHandler, disConnectHandler)
    }
    /// 断开与外设的连接
    @objc func Action_DisConnect(_ params:[AnyHashable:Any]) -> Void {
        bluetoothHelper.disConncet()
    }
    
}


extension Target_XiaoYu_BluetoothHelper{
    /// 请求日期设置
    ///
    /// - Parameter params: 字典 参数 handler : ((_ success:Bool) -> Void)?
    @objc func Action_SetDate(_ params:[AnyHashable: Any]) -> Void {
        let handler = params["handler"] as? SetDateHandler
        bluetoothHelper.SetDate(handler)
    }
    
    /// 主界面
    @objc func Action_RequestHomePageData(_ params:[AnyHashable: Any]) -> Void {
        let day     = params["day"]     as! Int
        let firstHandler = params["first"]     as? RequestHomeDataWithFirstFeedbackDataInOneDayHandler
        let sencondHandler = params["second"] as? RequestHomeDataWithSecondFeedbackDataInOneDayHandler
        let handler = params["handler"]        as? RequestHomepageDataWithReceiveAllDataHandler
        bluetoothHelper.requestHomePageData(day,firstHandler, sencondHandler, handler)
    }
    
    /// 实时模式
    @objc func Action_EnterRealTimeMode(_ params:[AnyHashable: Any]) -> Void {
        let state = params["state"] as? EnterRealTimeModelStateHandler
        let handler = params["handler"] as? EnterRealTimeModelDataHandler
        bluetoothHelper.enterRealTimeMode(state, handler)
    }
    /// 退出实时模式
    @objc func Action_ExitRealTimeModel(_ params:[AnyHashable: Any]) -> Void {
        bluetoothHelper.exitRealTimeModel()
    }
    
    /// 详情界面
    ///
    /// - Parameter params:
    @objc func Action_DetailPage(_ params:[AnyHashable: Any]) -> Void {
        let day = params["day"] as! Int
        let startIndex = params["startIndex"] as! Int
        let needIndexs = params["needIndexs"] as! Int
        let uploadHandler = params["uploadHandler"] as? DetailPageUploadDataHandler
        let completeHandler = params["completeHandler"] as? DetailPageUploadDataCompleteHandler
        bluetoothHelper.detailPage(day, startIndex, needIndexs, uploadHnaler: uploadHandler, completeHandler: completeHandler)
    }
    
    /// 3D挥拍练习曲线界面
    ///
    /// - Parameters:
    ///   - enter3DHandler: 进入3D挥拍练习模式成功与否的回调
    ///   - totalDataHandler: 单次挥拍的总数据
    ///   - u3DDataHandler:   单次挥拍的U3D数据
    @objc func Action_Enter3DSwingTrainingCurvePage(_ params:[AnyHashable: Any]) -> Void {
        let enter3DHandler   = params["enter3DHandler"]   as? ReturnTheSameCommandHanler
        let totalDataHandler = params["totalDataHandler"] as? TotalDataOfSingleSwingHandler
        let u3DDataHandler   = params["u3DDataHandler"]   as? U3DDataOfSingleSwingHandler
        bluetoothHelper.enter3DSwingTrainCurvePage(enter3DHandler, totalDataHandler, u3DDataHandler)
    }
    /// APP 退出3D挥拍练习曲线模式: 球拍原句返回
    ///
    /// - Parameter handler: 回调
    @objc func Action_Exit3DSwingTrainingCurvePage(_ params:[AnyHashable: Any]) -> Void {
        let handler   = params["handler"]   as? ReturnTheSameCommandHanler
        bluetoothHelper.exitSwingTrainCurvePage(handler)
    }
    /// 请求电池电量
    ///
    /// - Parameter params: 回调
    @objc func Action_RequestBatteryEnergy(_ params:[AnyHashable: Any]) -> Void {
        let handler = params["handler"] as? requestBattryEnergyHandler
        bluetoothHelper.requestBattryEnergy(handler)
    }
    
    /// 检查固件升级准备工作
    ///
    /// - Parameter handler: 回调
    @objc func Action_CheckPreparationForUpdateFirmware(_ params:[AnyHashable: Any]) -> Void {
        let handler = params["handler"] as? CheckPreparationForUpdateFirmwareHandler
        bluetoothHelper.checkPreparationForUpdateFirmware(handler)
    }
    /// 固件升级
    ///
    /// - Parameter params: 回调
    @objc func Action_UpdateFirmware(_ params:[AnyHashable: Any]) -> Void {
        let progressHandler = params["progressHandler"] as? UpdateFirmwareProgressHandler
        let handler = params["handler"] as? ReturnTheSameCommandHanler
        bluetoothHelper.updateFirmware(progressHandler, handler)
    }
    /// 请求版本号
    ///
    /// - Parameter handler: 回调
    @objc func Action_RequestVersion(_ params:[AnyHashable: Any]) -> Void {
        let handler = params["handler"] as? RequestVersionHandler
        bluetoothHelper.requestVersion(handler)
    }
    /// 自动休眠
    ///
    /// - Parameter handler: 回调
    @objc func Action_AutoSleep(_ params:[AnyHashable: Any]) -> Void {
        let sleep = params["sleep"] as! Bool
        let handler = params["handler"] as? ReturnTheSameCommandHanler
        bluetoothHelper.autoSleep(sleep, handler)
    }
    /// 修改设备名称 16个字节 5个中文字符 16个英文字符
    ///
    /// - Parameter handler: 回调
    @objc func Action_ModifyEquipmentName(_ params:[AnyHashable: Any]) -> Void {
        let name = params["name"] as? String
        let handler = params["handler"] as? ReturnTheSameCommandHanler
        bluetoothHelper.modifyEquipmentName(name, handler)
    }
    /// 设置左右手
    ///
    /// - Parameter handler: 回调
    @objc func Action_SetLeftRightHand(_ params:[AnyHashable: Any]) -> Void {
        let right = params["right"] as! Bool
        let handler = params["handler"] as? ReturnTheSameCommandHanler
        bluetoothHelper.setLeftRightHand(right,handler)
    }
    
    
    
    
    //MARK: -   --------------------------------------------  小羽2.0有效  --------------------------------------------
    /// 读取MAC地址
    ///
    /// - Parameter handler: 回调
    @objc func Action_ReadMacAddress(_ params:[AnyHashable: Any]) -> Void {
        let handler = params["handler"] as? ReadMacAddressHandler
        bluetoothHelper.readMacAddress(handler)
    }
    /// 关机
    ///
    /// - Parameter handler: 回调
    @objc func Action_ShutDown(_ params:[AnyHashable: Any]) -> Void {
        let handler = params["handler"] as? ReturnTheSameCommandHanler
        bluetoothHelper.shutDown(handler)
    }
    /// 待机
    ///
    /// - Parameter handler: 回调
    @objc func Action_StandBy(_ params:[AnyHashable: Any]) -> Void {
        let handler = params["handler"] as? ReturnTheSameCommandHanler
        bluetoothHelper.standBy(handler)
    }
    /// 重启
    ///
    /// - Parameter handler: 回调
    @objc func Action_ReStart(_ params:[AnyHashable: Any]) -> Void {
        let handler = params["handler"] as? ReturnTheSameCommandHanler
        bluetoothHelper.reStart(handler)
    }
    /// 清空缓存
    ///
    /// - Parameter handler: 回调
    @objc func Action_ClearCache(_ params:[AnyHashable: Any]) -> Void {
        let handler = params["handler"] as? ReturnTheSameCommandHanler
        bluetoothHelper.clearCache(handler)
    }
    /// 还原出厂设置
    ///
    /// - Parameter handler: 回调
    @objc func Action_ReStored(_ params:[AnyHashable: Any]) -> Void {
        let handler = params["handler"] as? ReturnTheSameCommandHanler
        bluetoothHelper.reStored(handler)
    }
    
    //MARK: -   --------------------------------------------  羽教监控系统  --------------------------------------------
    /// 开始上课
    ///
    /// - Parameter params: 回调
    @objc func Action_BeginClass(_ params:[AnyHashable: Any]) -> Void {
        let handler = params["handler"] as? BeginClassHandler
        bluetoothHelper.beginClass(handler)
    }
    @objc func Action_EndClass(_ params:[AnyHashable: Any]) -> Void {
        let startIndex = params["startIndex"] as! Int
        let endClassUpload = params["endClassUpload"] as? EndClassUploadDataHandler
        let endClassUploadComplete = params["endClassUploadComplete"] as? EndClassUploadDataCompleteHandler
        bluetoothHelper.endClass(startIndex, endClassUpload, endClassUploadComplete)
    }
}
