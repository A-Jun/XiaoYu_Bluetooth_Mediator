//
//  da.swift
//  XiaoYu_Bluetooth_Example
//
//  Created by RJ on 2018/8/30.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
@_exported import CoreBluetooth
@_exported import CTMediator

public typealias SensorInfo = [String:Any]
public typealias ScanSensorResultHandler_XiaoYu        = (_ peripherals:[SensorInfo])->Void
public typealias ConnectSensorResultHandler_XiaoYu     = (_ success:Bool )->Void
public typealias DisConnectSensorResultHandler_XiaoYu  = (_ success:Bool )->Void

public typealias ScanSensorResultHandler        = (_ central:CBCentralManager,_ peripheral: CBPeripheral,_ advertisementData: [String : Any],_ RSSI: NSNumber) -> Void

/// 日期设置处理 参数为 success:Bool 表示日期设置处理结果
public typealias SetDateHandler = (_ success:Bool) -> Void

/// 主界面数据处理:第一部分数据 参数为 info:[String:Any]? 表示具体某一天第一部分数据 字典关键字 类型全为 Int: 日期 date,卡路里 calories,运动量 amounts,运动时间 minutes,运动场次  sessions,
public typealias RequestHomeDataWithFirstFeedbackDataInOneDayHandler      = (_ info:[String:Any]?) -> Void

/// 主界面数据处理:第二部分数据 参数为 info:[String:Any]?  表示具体某一天第二部分数据字典关键字 类型全为 Int: 扣次数 smashCount, 挡次数 blockCount, 挑次数 dropCount, 空挥次数 emptyCount, 最大速度 maxSpeed,   高远次数 clearCount, 平抽次数 driveCount, 搓球次数 chopCount
public typealias RequestHomeDataWithSecondFeedbackDataInOneDayHandler     = (_ info:[String:Any]?) -> Void

/// 主界面数据处理:接收完所有数据 参数 success:Bool 表示是否成功接收所有数据
public typealias RequestHomepageDataWithReceiveAllDataHandler             = (_ success:Bool) -> Void

/// 进入实时模式状态 参数 success:Bool 表示是否成功进入实时状态
public typealias EnterRealTimeModelStateHandler = (_ success:Bool) -> Void

/// 进入实时模式后的蓝牙返回数据处理 参数为 info:[String:Any]? 表示在实时模式下，当球拍有挥拍动作时，实时往 APP 上传数据  字典关键字  类型全为 Int: 姿态 poseType,速度 speed ,力量 strength,角度 arc,时间戳 timeStamp,是否击中 hasHitTheBall,上下手球 upDownHandBall,正反手 foreBackHandBall,出球方向 hitBallDirection,击球时间  hitBallTime
public typealias EnterRealTimeModelDataHandler = (_ info:[String:Any]?) -> Void

/// 详情界面 处理数据上传 参数为 info:[String:Any]? 表示每一拍数据详情  字典关键字 : 姿态 poseType:Int,速度 speed:Int,力量 strength:Int,角度 arc:Int,时间戳 timeStamp:Int,场次下标 sessionIndex:Int,挥拍属性 property:[String:Any] (类型全为 Int: 是否击中 hasHitTheBall,上下手球 upDownHandBall,正反手 foreBackHandBall,出球方向 hitBallDirection),详情包的序号 detailPageIndex:Int
public typealias DetailPageUploadDataHandler = (_ responceValue:[String:Any]?) -> Void

/// 详情界面 处理数据上传完成 参数 success:Bool 表示是否接收详情数据完毕
public typealias DetailPageUploadDataCompleteHandler = (_ success:Bool) -> Void


/// 3D挥拍曲线 一拍的总数据 参数为 info:[String:Any]? 表示3D模式下每一拍数据详情  字典关键字 : DTW的数据总包数 DTWTotalDataPackets:Int,姿态 poseType:Int,速度 speed:Int,力量 strength:Int,角度 arc:Int,时间戳 timeStamp:Int,场次下标 sessionIndex:Int,挥拍属性 property:[String:Any] (类型全为 Int: 是否击中 hasHitTheBall,上下手球 upDownHandBall,正反手 foreBackHandBall,出球方向 hitBallDirection),详情包的序号 detailPageIndex:Int
public typealias TotalDataOfSingleSwingHandler = (_ infoDic:[String:Any]?) -> Void

/// 3D挥拍曲线 一拍的3D运动曲线数据 参数为 info:[String:Any]? 表示3D模式下每一拍绘制曲线的数据  字典关键字 类型全为 Int: q0,q1,q2,q3,gx,gy,gz,ax,ay,az,数据下标 index
public typealias U3DDataOfSingleSwingHandler = (_ infoDic:[String:Any]?) -> Void

/// 固件升级:准备工作 参数为 info:[String:Any]? 表示固件升级准备状态  字典关键字 : 是否可以升级 state:Bool,状态描述 :description:String? ,新固件版本 newVersion:String?,当前固件版本 currentVersion:String?
public typealias CheckPreparationForUpdateFirmwareHandler = (_ infoDic:[String:Any]?) -> Void
/// 固件升级进度   参数为  progress:Double? 表示固件升级文件写入进度
public typealias UpdateFirmwareProgressHandler = (_ progress:Double?) -> Void
/// 请求电池电量   参数为  batteryEnergy:Int? 表示电量 100 以上为充电状态
public typealias requestBattryEnergyHandler = (_ batteryEnergy:Int?) -> Void


/// 请求版本号     参数为  version:[String:Any]? 字典关键字 : 版本号 version:String
public typealias RequestVersionHandler = (_ version:[String:Any]?) -> Void
/// 读取MAC地址    参数为  macAddress:String?
public typealias ReadMacAddressHandler = (_ macAddress:String?) -> Void
/// 蓝牙指令原句返回 参数为 success:Bool  表示请求指令的恢复状态
public typealias ReturnTheSameCommandHanler = (_ success:Bool) -> Void


/// 羽教监控系统 开始上课 参数为 info:[String:Any]?  表示具体某一天第二部分数据字典关键字 类型全为 Int: 扣次数 smashCount, 挡次数 blockCount, 挑次数 dropCount, 空挥次数 emptyCount, 高远次数 clearCount, 平抽次数 driveCount, 搓球次数 chopCount , 详情起始ID detailStartIndex
public typealias BeginClassHandler = (_ infoDic:[String:Any]?) -> Void
/// 羽教监控系统 开始下课:处理数据上传 参数为 info:[String:Any]? 表示每一拍数据详情  字典关键字 : 姿态 poseType:Int,速度 speed:Int,力量 strength:Int,角度 arc:Int,时间戳 timeStamp:Int,场次下标 sessionIndex:Int,挥拍属性 property:[String:Any] (类型全为 Int: 是否击中 hasHitTheBall,上下手球 upDownHandBall,正反手 foreBackHandBall,出球方向 hitBallDirection),详情包的序号 detailPageIndex:Int
public typealias EndClassUploadDataHandler   = (_ infoDic:[String:Any]?) -> Void
/// 羽教监控系统 开始下课:处理数据上传完成 参数 success:Bool 表示是否接收详情数据完毕
public typealias EndClassUploadDataCompleteHandler = (_ success:Bool) -> Void

private let targaetName = "XiaoYu_BluetoothHelper"
private var defaultParams :[AnyHashable :Any] = ["defaultKey":"defaultValue",
                                         kCTMediatorParamsKeySwiftTargetModuleName:"XiaoYu_Bluetooth"]
private enum ActionName:String {
    case ScanSensor
    case ScanSensorWithOriginData
    case StopScan
    case Connect
    case DisConnect
    
    case SetDate
    case RequestBatteryEnergy
    case RequestVersion
    case CheckPreparationForUpdateFirmware
    case UpdateFirmware
    case AutoSleep
    case ModifyEquipmentName
    case SetLeftRightHand
    
    case RequestHomePageData
    case EnterRealTimeMode
    case ExitRealTimeModel
    case DetailPage
    case Enter3DSwingTrainingCurvePage
    case Recive3DSwingTrainingCurveDataAtIndex
    case ReciveAll3DSwingTrainingCurveDataEnd
    case Exit3DSwingTrainingCurvePage
    
    //小羽2.0指令
    case ReadMacAddress
    case ShutDown
    case StandBy
    case ReStart
    case ClearCache
    case ReStored

    case BeginClass
    case EndClass
}

//MARK: - 连接外设
extension CTMediator {
    /// 搜索外设
    ///
    /// - Parameters:
    ///   - services: 服务
    ///   - options: 可选字典，指定用于自定义扫描的选项 是否重复扫描已发现的设备 默认为NO
    ///              CBCentralManagerScanOptionAllowDuplicatesKey:false
    public class func scanSensor(withServices services :[CBUUID]?, options:[String : Any]? , handler:ScanSensorResultHandler_XiaoYu?)  {
        defaultParams["services"] = services
        defaultParams["options"]  = options
        defaultParams["handler"]  = handler
        performAction(.ScanSensor)
    }
    /// 搜索外设
    ///
    /// - Parameters:
    ///   - services: 服务
    ///   - options: 可选字典，指定用于自定义扫描的选项 是否重复扫描已发现的设备 默认为NO
    ///              CBCentralManagerScanOptionAllowDuplicatesKey:false
    public class func scanSensorWithOriginData(withServices services :[CBUUID]?, options:[String : Any]? , handler:ScanSensorResultHandler?)  {
        defaultParams["services"] = services
        defaultParams["options"]  = options
        defaultParams["handler"]  = handler
        performAction(.ScanSensorWithOriginData)
    }
    /// 结束搜索外设
    public class func stopScan()  {
        performAction(.StopScan)
    }
    
    /// 连接外设
    ///
    /// - Parameters:
    ///   - sensor: 外设模型
    ///   - options: 可选字典，指定用于连接状态的提示的选项
    public class func connect(_ peripheral: CBPeripheral?, _ options:[String : Any]? , connnectHandler:ConnectSensorResultHandler_XiaoYu?,_ disConnectHandler:DisConnectSensorResultHandler_XiaoYu? ) -> Void {
        defaultParams["options"]    = options
        defaultParams["connectHandler"]    = connnectHandler
        defaultParams["disConnectHandler"]    = disConnectHandler
        defaultParams["peripheral"] = peripheral
        performAction(.Connect)
    }
    /// 断开与外设的连接
    public class func disConnect() -> Void {
        performAction(.DisConnect)
    }
}


extension CTMediator {
    
    /// 请求日期设置
    ///
    /// - Parameter params: 字典 参数 handler : ((_ success:Bool) -> Void)?
    public class func SetDate(_ handler:SetDateHandler?) -> Void  {
        defaultParams["handler"] = handler
        performAction(.SetDate)
    }

    /// 请求主界面数据
    ///
    /// - Parameters:
    ///   - day: 指定请求具体日期 默认为0  返回最近10天数据
    ///   - handler: 回调
    public class func requestHomePageData(_ day:Int = 0 , FirstFeedbackDataInOneDay:RequestHomeDataWithFirstFeedbackDataInOneDayHandler?
                                                 , SecondFeedbackDataInOneDay:RequestHomeDataWithSecondFeedbackDataInOneDayHandler?
                                                 , handler:RequestHomepageDataWithReceiveAllDataHandler?) -> Void {
        defaultParams["day"] = day
        defaultParams["first"]  = FirstFeedbackDataInOneDay
        defaultParams["second"]  = SecondFeedbackDataInOneDay
        defaultParams["handler"]  = handler
        performAction(.RequestHomePageData)
    }
    /// 进入实时模式
    ///
    /// - Parameter handler: 回调
    public class func enterRealTimeMode(state:EnterRealTimeModelStateHandler? , _ handler:EnterRealTimeModelDataHandler?) -> Void {
        defaultParams["state"]  = state
        defaultParams["handler"]  = handler
        performAction(.EnterRealTimeMode)
    }
    
    /// 退出实时模式
    public class func exitRealTimeModel() -> Void {
        performAction(.ExitRealTimeModel)
    }
    
    /// 详情界面
    ///
    /// - Parameters:
    ///   - day: 哪天:1BYTE，范围 1~10，1 表示当天，2 表示有数据记录的前一天，依此类推，0 则连 续发送 10 天数据
    ///   - startIndex: 第几条:2BYTE，从第几条数据开始发送，从 0 开始
    ///   - needIndexs: 多少条:2BYTE，要发送多少条数据，0 表示发送该天所有数据
    public class func detailPage(_ day:Int ,_  startIndex:Int ,_  needIndexs:Int , uploadHnaler:DetailPageUploadDataHandler? , completeHandler:DetailPageUploadDataCompleteHandler?) -> Void {
        defaultParams["day"]  = day
        defaultParams["startIndex"]  = startIndex
        defaultParams["needIndexs"]  = needIndexs
        defaultParams["uploadHandler"]  = uploadHnaler
        defaultParams["completeHandler"]  = completeHandler
        performAction(.DetailPage)
    }
    /// 3D挥拍练习曲线界面
    ///
    /// - Parameters:
    ///   - enter3DHandler: 进入3D挥拍练习模式成功与否的回调
    ///   - totalDataHandler: 单次挥拍的总数据
    ///   - u3DDataHandler:   单次挥拍的U3D数据
    public class func enter3DSwingTrainCurvePage(_ enter3DHandler:ReturnTheSameCommandHanler? , _ totalDataHandler:TotalDataOfSingleSwingHandler? ,_ u3DDataHandler:U3DDataOfSingleSwingHandler?) -> Void{
        defaultParams["enter3DHandler"]  = enter3DHandler
        defaultParams["totalDataHandler"]  = totalDataHandler
        defaultParams["u3DDataHandler"]  = u3DDataHandler
        performAction(.Enter3DSwingTrainingCurvePage)
    }
    /// APP 退出3D挥拍练习曲线模式: 球拍原句返回
    ///
    /// - Parameter handler: 回调
    public class func exit3DSwingTrainingCurvePage(_ handler:ReturnTheSameCommandHanler?) -> Void{
        defaultParams["handler"]  = handler
        performAction(.Exit3DSwingTrainingCurvePage)
    }
    /// 请求电池电量
    ///
    /// - Parameter handler: 回调
    public class func requestBatteryEnergy(_ handler:requestBattryEnergyHandler?) -> Void {
        defaultParams["handler"]  = handler
        performAction(.RequestBatteryEnergy)
    }
    /// 检查固件升级准备工作
    ///
    /// - Parameter handler: 回调
    public class func checkPreparationForUpdateFirmware(_ handler:CheckPreparationForUpdateFirmwareHandler?) -> Void {
        defaultParams["handler"]  = handler
        performAction(.CheckPreparationForUpdateFirmware)
    }
    /// 固件升级
    ///
    /// - Parameter handler: 回调
    public class func updateFirmware(_ progressHandler:UpdateFirmwareProgressHandler? , _ handler:ReturnTheSameCommandHanler?) -> Void {
        defaultParams["progressHandler"]  = progressHandler
        defaultParams["handler"]  = handler
        performAction(.UpdateFirmware)
    }
    /// 请求版本号
    ///
    /// - Parameter handler: 回调
    public class func requestVersion(_ handler:RequestVersionHandler?) -> Void {
        defaultParams["handler"]  = handler
        performAction(.RequestVersion)
    }
    /// 自动休眠
    ///
    /// - Parameter handler: 回调
    public class func autoSleep(_ sleep:Bool , _ handler:ReturnTheSameCommandHanler?) -> Void {
        defaultParams["sleep"]  = sleep
        defaultParams["handler"]  = handler
        performAction(.AutoSleep)
    }
    /// 修改设备名称
    ///
    /// - Parameter handler: 回调
    public class func modifyEquipmentName(_ name:String? ,_ handler:ReturnTheSameCommandHanler?) -> Void {
        defaultParams["name"]  = name
        defaultParams["handler"]  = handler
        performAction(.ModifyEquipmentName)
    }
    /// 设置左右手
    ///
    /// - Parameter handler: 回调
    public class func SetLeftRightHand(_ right:Bool ,_ handler:ReturnTheSameCommandHanler?) -> Void {
        defaultParams["right"]    = right
        defaultParams["handler"]  = handler
        performAction(.SetLeftRightHand)
    }
    
    /// 读取MAC地址
    ///
    /// - Parameter handler: 回调
    public class func readMacAddress(_ handler:ReadMacAddressHandler?) -> Void {
        defaultParams["handler"]  = handler
        performAction(.ReadMacAddress)
    }
    /// 关机
    ///
    /// - Parameter handler: 回调
    public class func shutDown(_ handler:ReturnTheSameCommandHanler?) -> Void {
        defaultParams["handler"]  = handler
        performAction(.ShutDown)
    }
    /// 待机
    ///
    /// - Parameter handler: 回调
    public class func standBy(_ handler:ReturnTheSameCommandHanler?) -> Void {
        defaultParams["handler"]  = handler
        performAction(.StandBy)
    }
    /// 重启
    ///
    /// - Parameter handler: 回调
    public class func reStart(_ handler:ReturnTheSameCommandHanler?) -> Void {
        defaultParams["handler"]  = handler
        performAction(.ReStart)
    }
    /// 清空缓存
    ///
    /// - Parameter handler: 回调
    public class func clearCache(_ handler:ReturnTheSameCommandHanler?) -> Void {
        defaultParams["handler"]  = handler
        performAction(.ClearCache)
    }
    /// 还原出厂设置
    ///
    /// - Parameter handler: 回调
    public class func reStored(_ handler:ReturnTheSameCommandHanler?) -> Void {
        defaultParams["handler"]  = handler
        performAction(.ReStored)
    }
    /// 开始上课
    ///
    /// - Parameter handler: 回调
    public class func beginClass(_ handler:BeginClassHandler?) -> Void {
        defaultParams["handler"]  = handler
        performAction(.BeginClass)
    }
    /// 开始下课
    ///
    /// - Parameter handler: 回调
    public class func endClass(_ startIndex:Int ,_ endClassUpload:EndClassUploadDataHandler?,_ endClassUploadComplete:EndClassUploadDataCompleteHandler?) -> Void {
        defaultParams["startIndex"]  = startIndex
        defaultParams["endClassUpload"]  = endClassUpload
        defaultParams["endClassUploadComplete"]  = endClassUploadComplete
        performAction(.EndClass)
    }
    /// 选择方法执行
    ///
    /// - Parameter action: 方法类型
    private class func performAction(_ action:ActionName) -> Void {
        CTMediator.sharedInstance().performTarget(targaetName, action: action.rawValue, params: defaultParams, shouldCacheTarget: true)
    }
}

