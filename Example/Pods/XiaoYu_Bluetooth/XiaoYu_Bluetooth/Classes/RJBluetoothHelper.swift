//
//  BluetoothManager.swift
//  Pods-XiaoYu_Bluetooth_Example
//
//  Created by RJ on 2018/8/30.
//

import UIKit
@_exported import RJBluetooth_Mediator
import iOSDFULibrary
/// 网络环境 true 是生产环境 false s是测试环境
let NETWORK_ENVIRONMENT = true
let baseUrlString = NETWORK_ENVIRONMENT ? "http://appserv.coollang.com" : "http://mlf.f3322.net:83"
let firmwareUrlString = "VersionController/getLastVersion"



//新版操作服务和特征值
var kNewOperationServiceUUIDString = "0001"
var kNewCharacteristicWriteUUIDString   = "0002"
var kNewCharacteristicNotifyUUIDString  = "0003"
var kNewCharacteristicReadMacUUIDString = "0004"

//旧版操作服务和特征值
var kOldWiriteServiceUUIDString = "ffe5"
var kOldCharacteristicWriteUUIDString   = "ffe9"

var kOldNotifyServiceUUIDString = "ffe0"
var kOldCharacteristicNotifyUUIDString   = "ffe4"

var kOldReadServiceUUIDString = "180a"
var kOldCharacteristicReadUUIDString   = "2a23"

/// 蓝牙指令
enum RJBluetoothCommadType : String {
    case None
    case SetDate
    case RequestBatteryEnergy
    case RequestVersion
    case UpdateFirmware
    case AutoSleep
    case ModifyEquipmentName
    case SetLeftRightHand
    
    case RequestHomepageData
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
    
    //羽教监控系统
    case BeginClass
    case EndClass
    
}
/// 蓝牙断开连接类型
enum RJBluetoothDisconnnectType :String{
    case Active
    case UpdateFirmware
    case Passive
}

typealias SensorInfo = [String:Any]
typealias ScanSensorResultHandler_XiaoYu        = (_ peripherals:[SensorInfo])->Void
typealias ConnectSensorResultHandler_XiaoYu     = (_ success:Bool )->Void
typealias DisConnectSensorResultHandler_XiaoYu  = (_ success:Bool )->Void


/// 日期设置处理
typealias SetDateHandler = (_ success:Bool) -> Void
/// 主界面数据处理
typealias RequestHomeDataWithFirstFeedbackDataInOneDayHandler      = (_ info:[String:Any]?) -> Void
/// 主界面数据处理
typealias RequestHomeDataWithSecondFeedbackDataInOneDayHandler     = (_ info:[String:Any]?) -> Void
/// 主界面数据处理
typealias RequestHomepageDataWithReceiveAllDataHandler             = (_ success:Bool) -> Void
/// 进入实时模式状态
typealias EnterRealTimeModelStateHandler = (_ success:Bool) -> Void
/// 进入实时模式后的蓝牙返回数据处理
typealias EnterRealTimeModelDataHandler = (_ responceValue:[String:Any]?) -> Void

/// 详情界面 处理数据上传
typealias DetailPageUploadDataHandler = (_ responceValue:[String:Any]?) -> Void
/// 详情界面 处理数据上传完成
typealias DetailPageUploadDataCompleteHandler = (_ success:Bool) -> Void

/// 3D挥拍曲线 一拍的总数据
typealias TotalDataOfSingleSwingHandler = (_ infoDic:[String:Any]?) -> Void
/// 3D挥拍曲线 一拍的3D运动曲线数据
typealias U3DDataOfSingleSwingHandler = (_ infoDic:[String:Any]?) -> Void

/// 固件升级:准备工作
typealias CheckPreparationForUpdateFirmwareHandler = (_ info:[String:Any]?) -> Void
/// 固件升级:进度
typealias requestBattryEnergyHandler = (_ batteryEnergy:Int?) -> Void
/// 请求电池电量
typealias UpdateFirmwareProgressHandler = (_ progress:Double?) -> Void


/// 请求版本号
typealias RequestVersionHandler = (_ version:[String:Any]?) -> Void
/// 读取MAC地址
typealias ReadMacAddressHandler = (_ macAddress:String?) -> Void
/// 蓝牙指令原句返回
typealias ReturnTheSameCommandHanler = (_ success:Bool) -> Void


/// 羽教监控系统 开始上课
typealias BeginClassHandler = (_ infoDic:[String:Any]?) -> Void
/// 羽教监控系统 开始下课:处理数据上传
typealias EndClassUploadDataHandler   = (_ infoDic:[String:Any]?) -> Void
/// 羽教监控系统 开始下课:处理数据上传完成
typealias EndClassUploadDataCompleteHandler = (_ success:Bool) -> Void


class RJBluetoothHelper: NSObject {
    
    /// 日期设置回调
    var SetDateHandler : SetDateHandler?
    /// 主界面:一天数据统计
    var requestHomeDataWithFirstFeedbackDataInOneDayHandler      : RequestHomeDataWithFirstFeedbackDataInOneDayHandler?
    /// 主界面:一天数据详情
    var requestHomeDataWithSecondFeedbackDataInOneDayHandler     : RequestHomeDataWithSecondFeedbackDataInOneDayHandler?
    /// 主界面:球拍上传数据完毕
    var requestHomepageDataWithReceiveAllDataHandler             : RequestHomepageDataWithReceiveAllDataHandler?
    /// 实时模式:进入状态
    var enterRealTimeModelStateHandler    :EnterRealTimeModelStateHandler?
    /// 实时模式:进入后的蓝牙返回数据处理
    var enterRealTimeModelDataHandler     : EnterRealTimeModelDataHandler?
    
    /// 详情界面:处理数据上传
    var detailPageUploadDataHandler      : DetailPageUploadDataHandler?
    /// 详情界面:处理数据上传完成
    var detailPageUploadDataCompleteHandler     : DetailPageUploadDataCompleteHandler?
    
    /// 3D挥拍曲线:一拍的总数据
    var totalDataOfSingleSwingHandler      : TotalDataOfSingleSwingHandler?
    /// 3D挥拍曲线:一拍的3D运动曲线数据
    var u3DDataOfSingleSwingHandler        : U3DDataOfSingleSwingHandler?
    
    /// 固件升级:准备工作
    var checkPreparationForUpdateFirmwareHandler : CheckPreparationForUpdateFirmwareHandler?
    /// 固件升级:进度
    var updateFirmwareProgressHandler       : UpdateFirmwareProgressHandler?
    /// 固件升级:新版本固件模型
    var newFirmwareVersionModel             :RJFirmwareVersionModel?
    /// 固件升级:下载的固件地址
    var firmwareFilePath                    :URL?
    
    /// 请求电池电量
    var requestBattryEnergyHandler     : requestBattryEnergyHandler?
    /// 请求版本号
    var requestVersionHandler     : RequestVersionHandler?
    /// 读取MAC地址
    var readMacAddressHandler     : ReadMacAddressHandler?
    /// 蓝牙指令原句返回
    var returnTheSameCommandHanler     : ReturnTheSameCommandHanler?
    
    
    /// 羽教监控系统 开始上课
    var beginClassHandler     : BeginClassHandler?
    /// 羽教监控系统 开始下课:处理数据上传
    var endClassUploadDataHandler      : EndClassUploadDataHandler?
    /// 羽教监控系统 开始下课:处理数据上传完成
    var endClassUploadDataCompleteHandler     : EndClassUploadDataCompleteHandler?
    
    
    
    
    
    /// 小羽设备搜索结果回调
    var scanSensorResultHandler_XiaoYu    : ScanSensorResultHandler_XiaoYu?
    /// 小羽连接设备回调
    var connectSensorResultHandler_XiaoYu : ConnectSensorResultHandler_XiaoYu?
    /// 处理设备连接结果
    let connectSensorResultHandler : ConnectSensorResultHandler         = {( central:CBCentralManager, peripheral :CBPeripheral, success:Bool ) in
        if success {
            //连接成功保存设备
            RJBluetoothHelper.shareInstance.connecterPeripheral = peripheral
            for sensor in RJBluetoothHelper.shareInstance.sensorList {
                if sensor.cbPeripheral == peripheral {
                    RJBluetoothHelper.shareInstance.connectedSensorModel = sensor
                }
            }
            //搜索设备服务
            RJBluetoothHelper.shareInstance.discoverServices(nil)
        }else{
            
        }
    }
    /// 小羽断开连接设备回调
    var disConnectSensorResultHandler_XiaoYu : DisConnectSensorResultHandler_XiaoYu?
    /// 处理设备断开连接结果
    let disConnectSensorResultHandler : DisConnectSensorResultHandler   = {( central:CBCentralManager,peripheral :CBPeripheral, error:Error? ) in
        RJBluetoothHelper.shareInstance.isConnected = false
        guard let coluse = RJBluetoothHelper.shareInstance.disConnectSensorResultHandler_XiaoYu else { return }
        coluse(error == nil)
        switch RJBluetoothHelper.shareInstance.disconncetType {
        case .Active:
            RJBluetoothHelper.shareInstance.connecterPeripheral = nil
        case .Passive:
            RJBluetoothHelper.shareInstance.reconnectForPassive()
        case .UpdateFirmware:
            RJBluetoothHelper.shareInstance.reconnectForUpdateFirmware()
        }
    }
    
    /// 单例
    static let shareInstance = RJBluetoothHelper()
    /// 中心设备管理器
    var centralManager : CBCentralManager?
    /// 新版本设备
    var isNewDevice = true
    /// 蓝牙断开连接类型 默认为被动断开连接
    var disconncetType :RJBluetoothDisconnnectType = .Passive
    /// 自动断线重连
    var autoReConnect = true
    
    /// 是否已连接外设
    var isConnected         :Bool = false
    /// 最远信号
    var minRSSI             :Int  = -100
    /// 过滤设备 允许显示的设备类型
    lazy var filter_OEM_TYPE : [OemType]  = {
        let array:[OemType] = [.KU,.M1,.M2,.M3,.M4,.M5,.M6,.M7,.M8,.M9,.MA,.N0,.N1,.N2,.N3,.N4,.N5,.N6,.N7,.N8,.N9,.NA,
                               .NB,.NC,.ND,.NE,.NF,.NG,.NH,.NI,.NJ,.L0,.LD,.H0,.H1,.H3,.H4]
        
        return array
    }()
    ///扫描到的外设
    private lazy var sensorList:[RJSensorModel] = {
        return [RJSensorModel]()
    }()
    /// 连接的外设
    var connecterPeripheral :CBPeripheral? {
        didSet{
            isConnected = connecterPeripheral != nil
        }
    }
    /// 连接的外设模型
    var connectedSensorModel : RJSensorModel?
    
    /// 要传递数据的特征值
    var writeCharacteristic : CBCharacteristic?
    /// 订阅的特征值
    var notifyCharacteristic : CBCharacteristic?
    /// 读的特征值
    var readCharacteristic : CBCharacteristic?
    
    /// 帧头码
    private var FH:[UInt8] {
        var fh:[UInt8] = [0x5F,0x60]
        if connectedSensorModel?.oemType == OemType.H4 {
            fh = [0x5A,0xA5]
        }
        return fh
    }
    /// 指令类型
    var commandType : RJBluetoothCommadType = .None
    /// 发送的指令
    var sendCommand :Data?
    /// 外设反馈的数据
    var feedbackValue = Data()
    
    /// 固件升级要发送的总包数
    var needSendPacketsOfFirmware :Int = 0
    /// 成功发送的固件升级包数目
    var successSendPacketsOfFirmware:Int = 0
    
    
    /// DTW 的数据总包数 = 数据总包数
    var DTWCount :Int = 0
    
}
//MARK: - 设备连接
extension RJBluetoothHelper {
    
    /// 是否可以断线重连
    ///
    /// - Parameter ReConnect: 重连 布尔值
    func autoReConnect(_ ReConnect:Bool) -> Void {
        autoReConnect = ReConnect
    }
    //MARK: 搜索外设
    /// 搜索外设
    func scanSensor(withServices services: [CBUUID]?, options: [String:Any]? , handler:ScanSensorResultHandler_XiaoYu? ) -> Void {
        scanSensorResultHandler_XiaoYu  = handler
        /// 处理设备搜索结果
        let scanSensorResultHandler : ScanSensorResultHandler               = {(central:CBCentralManager, peripheral: CBPeripheral, advertisementData: [String : Any],RSSI: NSNumber) in
            self.centralManager = central
            //1.过滤外设
            let result = self.filterSensor(withRSSI: RSSI, AdvertisementData: advertisementData)
            if !result {
                return
            }
            
            //2.创建外设模型对象
            let sensorModel = RJSensorModel.init(peripheral, advertisementData, RSSI)
            //3.添加对象
            let sensorInfos =  self.addSensorModel(sensorModel)
            guard let coluse = self.scanSensorResultHandler_XiaoYu else { return }
            coluse(sensorInfos)
        }
        CTMediator.scanSensor(withServices: services, options: options, handler: scanSensorResultHandler)
    }
    //过滤外设
    private func filterSensor(withRSSI RSSI: NSNumber, AdvertisementData: [String : Any]) -> Bool {
        //1.过滤 信号差的
        if RSSI.intValue < minRSSI {
            return false
        }
        //2.过滤 OEM_ID 不匹配的
        guard let advertisementDataManufacturerData = AdvertisementData[CBAdvertisementDataManufacturerDataKey] else { return false }
        let manufacturerData = advertisementDataManufacturerData as! Data
        guard let manufacturerString = String(data: manufacturerData.prefix(upTo: 6), encoding:.utf8) else { return false }
        
        for index in 0 ..< filter_OEM_TYPE.count {
            let oemType = filter_OEM_TYPE[index]
            if manufacturerString.contains(oemType.rawValue) {
                return true
            }
        }
        return false
    }
    //添加数组对象
    private func addSensorModel(_ sensorModel:RJSensorModel) -> [SensorInfo] {
        //1.根据外设名称判断是否已包含该外设
        var hadContain = false
        
        for index in 0 ..< sensorList.count {
            let model = sensorList[index]
            if model.name == sensorModel.name {
                hadContain = true
            }
            
        }
        //2.根据是否包含 跟新外设表
        if hadContain { //包含
            for index in 0 ..< sensorList.count {
                let model = sensorList[index]
                if model.name == sensorModel.name {
                    sensorList[index] = sensorModel
                }
                
            }
        }else{//不包含
            sensorList.append(sensorModel)
        }
        //3.将外设表 按RSSI 大小排序
        sensorList.sort {$0.RSSI < $1.RSSI}
        var sensorInfos = [SensorInfo]()
        for sensorModel in sensorList {
            sensorInfos.append(sensorModel.infoDic())
        }
        return sensorInfos
    }
    /// 搜索外设
    func scanSensorWithOriginData(withServices services: [CBUUID]?, options: [String:Any]? , handler:ScanSensorResultHandler? ) -> Void {
        CTMediator.scanSensor(withServices: services, options: options, handler: handler)
    }
    //MARK: 结束搜索外设
    /// 结束搜索外设
    func stopScan() -> Void {
        CTMediator.stopScan()
    }
    //MARK: 连接外设
    /// 连接外设
    ///
    /// - Parameters:
    ///   - sensor: 外设模型
    ///   - options: 可选字典，指定用于连接状态的提示的选项
    func connect(_ peripheral:CBPeripheral, _ options:[String : Any]? ,connectHandler:ConnectSensorResultHandler_XiaoYu? , _ disConnectHandler:DisConnectSensorResultHandler_XiaoYu?) -> Void {
        connectSensorResultHandler_XiaoYu = connectHandler
        disConnectSensorResultHandler_XiaoYu = disConnectHandler
        
        CTMediator.connect(peripheral, options, connnectHandler: connectSensorResultHandler, disConnectSensorResultHandler)
    }
    /// 搜索服务
    ///
    /// - Parameter serviceUUIDs: 服务数组
    func discoverServices( _ serviceUUIDs:[CBUUID]?) -> Void {
        /// 处理搜索设备服务结果
        let discoverServicesHandler : DiscoverServicesHandler               = {( peripheral :CBPeripheral , error: Error?) in
            guard let services = peripheral.services else { return }
            print("搜索服务 : \(String(describing: peripheral.services)) 成功")
            
            //遍历服务数组找到指定的服务
            for index in 0 ..< services.count {
                let service = services[index]
                if  service.uuid .isEqual(CBUUID(string: kOldReadServiceUUIDString)) {
                    self.isNewDevice = false
                }
                if  service.uuid .isEqual(CBUUID(string: kOldNotifyServiceUUIDString)) {
                    self.isNewDevice = false
                }
                if  service.uuid .isEqual(CBUUID(string: kOldWiriteServiceUUIDString)) {
                    self.isNewDevice = false
                }
                self.discoverCharacteristics(nil, for: service)
            }
        }
        CTMediator.discoverServices(serviceUUIDs, discoverServicesHandler)
    }
    /// 搜索设备服务特征值
    ///
    /// - Parameters:
    ///   - characteristicUUIDs: 特征值
    ///   - service: 服务
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) -> Void {
        /// 处理搜索设备服务特征值结果
        let discoverCharacteristicsHandler : DiscoverCharacteristicsHandler = {( peripheral: CBPeripheral, service: CBService,              error:Error?) in
            guard let characteristics = service.characteristics else { return }
            print("搜索特征值 : \(String(describing: service.characteristics)) 成功")
            //遍历特征值数组找到对应特征值
            for index in 0 ..< characteristics.count {
                let characteristic = characteristics[index]
                self.handleCharacteristic(characteristic)
            }
        }
        CTMediator.discoverCharacteristics(characteristicUUIDs, for: service, discoverCharacteristicsHandler)
    }
    func handleCharacteristic(_ characteristic:CBCharacteristic) -> Void {
        //读MacAddress 特征值
        if  characteristic.uuid .isEqual(CBUUID(string: kNewCharacteristicReadMacUUIDString)) || characteristic.uuid .isEqual( CBUUID(string: kOldCharacteristicWriteUUIDString)){
            readValue(for: characteristic)
        }
        //写数据 特征值
        if  characteristic.uuid .isEqual(CBUUID(string: kNewCharacteristicWriteUUIDString))   || characteristic.uuid .isEqual( CBUUID(string: kOldCharacteristicWriteUUIDString)){
            writeCharacteristic = characteristic
        }
        //订阅 特征值
        if  characteristic.uuid .isEqual(CBUUID(string: kNewCharacteristicNotifyUUIDString))  || characteristic.uuid .isEqual( CBUUID(string: kOldCharacteristicNotifyUUIDString)){
            setNotifyValue(true, for: characteristic)
        }
    }
    /// 读取设备服务特征值
    ///
    /// - Parameters:
    ///   - characteristic: 要读的特征值
    ///   - handler: 回调
    func readValue(for characteristic: CBCharacteristic) -> Void {
        /// 处理读取设备服务特征值结果
        let readValueHandler : ReadValueHandler                             = {( peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?) in
            if error == nil {
                self.readCharacteristic = characteristic
                print("读取MacAddress成功")
                guard let value = characteristic.value else { return }
                self.connectedSensorModel?.MacAdress = String(data: value, encoding: .utf8)
            }
        }
        CTMediator.readValue(for: characteristic,readValueHandler)
    }
    /// 订阅设备服务特征值
    ///
    /// - Parameters:
    ///   - enabled: 当启用通知/指示时，将通过委托方法接收特征值的更新
    ///   - characteristic: 要订阅的特征值
    func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) -> Void {
        /// 处理订阅设备服务特征值结果
        let setNotifyValueHandler : SetNotifyValueHandler                   = {( peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?) in
            if error == nil {
                self.notifyCharacteristic = characteristic
                self.determineConnectState()
                print("订阅成功")
            }
        }
        CTMediator.setNotifyValue(enabled, for: characteristic, setNotifyValueHandler)
    }
    /// 判断连接是否真实成功 : 要获取到对应的特征值才算连接成功
    private func determineConnectState() -> Void {
        guard let coluse = self.connectSensorResultHandler_XiaoYu else { return }
        if notifyCharacteristic != nil && writeCharacteristic != nil {
            coluse(true)
            disconncetType = .Passive
        }else{
            coluse(false)
        }
    }
    //MARK: 断开与外设的连接
    /// 断开与外设的连接
    func disConncet() -> Void {
        disconncetType = .Active
        CTMediator.disConnect()
        readCharacteristic   = nil
        notifyCharacteristic = nil
        writeCharacteristic  = nil
    }
    //MARK: - 断线重连
    /// 断线重连：被动
    func reconnectForPassive() -> Void {
        if autoReConnect {
            guard let peripheral = connecterPeripheral else {return}
            connect(peripheral, nil, connectHandler: connectSensorResultHandler_XiaoYu, disConnectSensorResultHandler_XiaoYu)
        }
    }
    /// 断线重连：固件升级
    func reconnectForUpdateFirmware() -> Void {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.downloadNewFirmware()
        }
    }
}

extension RJBluetoothHelper {
    
    //MARK: - 创建指令
    
    /// 创建蓝牙指令
    ///
    /// - Parameters:
    ///   - headCode: 帧头
    ///   - functionCode: 功能码
    ///   - validData: 参数数据
    ///   - length: 字节长度
    /// - Returns: 蓝牙指令
    private func createCommad(_ functionCode:[UInt8]?  ,_ validData:[UInt8]?  , length:Int) -> Data {
        var bytes = [UInt8]()
        
        //1.添加帧
        bytes.append(contentsOf: FH)
        //2.添加功能码
        guard let function = functionCode else { return Data() }
        bytes.append(contentsOf: function)
        //3.是否有数据参数发送
        //3.1 无参数 创建指令
        guard let valid = validData  else { return creatData(value: bytes ,length: length) }
        //3.2 有参数 添加参数数据
        bytes.append(contentsOf: valid)
        return creatData(value: bytes ,length: length)
    }
    //和校验
    private func creatData(value:[UInt8] , length:Int) -> Data {
        guard value.count < length else { return Data(bytes: value) }
        //无数字位已0补足
        var bytes = value
        for _ in bytes.count ..< length - 1 {
            bytes.append(0x00)
        }
        //校验和
        var count = 0
        for index in 0..<bytes.count {
            let num = Int(bytes[index])
            count += num
        }
        if connectedSensorModel?.oemType == OemType.H4 { //累加和、右移一位、取低8位
            count = count >> 1
        }
        let verifyCode = UInt8(count & 0xFF)
        bytes.append(verifyCode)
        return Data(bytes: bytes)
    }
    //MARK: - 发送指令
    /// 发送指令
    ///
    /// - Parameter type: 指令类型
    func sendCommand(_ command:Data?) -> Void {
        if !isConnected {
            return
        }
        sendCommand  = command
        /// 处理发送指令
        let sendCommandResultHandler:SendCommandResultHandler               = {( peripheral: CBPeripheral, characteristic: CBCharacteristic,  error: Error?)  in
            RJBluetoothHelper.shareInstance.handleSendCommadResult(characteristic.value, error)
        }
        /// 处理外设反馈的数据
        let receiveCommandResultHandler:ReceiveCommandResultHandler         = {( peripheral: CBPeripheral, value: Data,  error: Error?)  in
            RJBluetoothHelper.shareInstance.handleFeedback(value, error)
        }
        CTMediator.sendConmand(sendCommand, for: writeCharacteristic,.withResponse, sendCommandResultHandler, receiveCommandResultHandler)
    }
    //MARK: - 处理发送指令结果
    /// 处理发送指令结果
    ///
    /// - Parameters:
    ///   - value: 发送的数据
    ///   - error: 错误
    func handleSendCommadResult(_ value:Data? , _ error:Error?) -> Void {
        
        if error == nil{
            print("\(RJBluetoothHelper.shareInstance.commandType.rawValue)指令发送成功\(sendCommand!)")
            //            dump(sendCommand)
        }else{
            print("\(RJBluetoothHelper.shareInstance.commandType.rawValue)指令发送失败\n\(String(describing: error))")
        }
    }
    
    //MARK: - 处理蓝牙对指令反馈数据
    /// 处理蓝牙对指令反馈数据
    ///
    /// - Parameters:
    ///   - value: 返回的数据
    ///   - error: 错误
    func handleFeedback(_ value:Data? , _ error:Error?) -> Void {
        guard let data = value else { return  }
        if error == nil{
            print(Thread.current)
            //            dump(data)
            print("接收\(RJBluetoothHelper.shareInstance.commandType.rawValue)指令返回数据成功\(data)")
            
        }else{
            print("接收\(RJBluetoothHelper.shareInstance.commandType.rawValue)指令返回数据失败\n\(String(describing: error))")
        }
        
        let helper = RJBluetoothHelper.shareInstance
        helper.feedbackValue = data
        switch helper.commandType {
        case .None:
            break
        case .SetDate:
            handleSetDateFeedbackData()
        case .RequestHomepageData:
            handleRequestHomepageFeedbackData()
        case .EnterRealTimeMode:
            hanleEnterRealTimeModelFeedbackData()
        case .DetailPage:
            hanleDetailPageFeedbackData()
        case .RequestBatteryEnergy:
            hanleRequestBatteryEnergyFeedbackData()
        case .RequestVersion:
            hanleRequestVersionFeedbackData()
        case .UpdateFirmware:
            handleUpdateFirmwareFeedbackData()
        case .AutoSleep:
            handleReturnTheSameCommandFeedbackData()
        case .ModifyEquipmentName:
            handleReturnTheSameCommandFeedbackData()
        case .ReadMacAddress:
            hanleReadMacAddressFeedbackData()
        case .ShutDown:
            handleReturnTheSameCommandFeedbackData()
        case .StandBy:
            handleReturnTheSameCommandFeedbackData()
        case .ReStart:
            handleReturnTheSameCommandFeedbackData()
        case .ClearCache:
            handleReturnTheSameCommandFeedbackData()
        case .ReStored:
            handleReturnTheSameCommandFeedbackData()
        case .SetLeftRightHand:
            handleReturnTheSameCommandFeedbackData()
        case .ExitRealTimeModel:
            break
        case .Enter3DSwingTrainingCurvePage:
            hanleEnter3DSwingTrainingCurvePageFeedbackData()
        case .Recive3DSwingTrainingCurveDataAtIndex:
            break
        case .ReciveAll3DSwingTrainingCurveDataEnd:
            hanleEnter3DSwingTrainingCurvePageFeedbackData()
        case .Exit3DSwingTrainingCurvePage:
            handleReturnTheSameCommandFeedbackData()
        case .BeginClass:
            handleBeginClassFeedbackData()
        case .EndClass:
            handleEndClassFeedbackData()
        }
    }
    
}

//MARK: - 功能码
extension RJBluetoothHelper :DFUProgressDelegate , DFUServiceDelegate{
    
    //MARK: - 日期设置
    /// 请求日期设置
    ///
    /// - Parameter handler: 日期设置结果回调
    func SetDate(_ handler:SetDateHandler?) -> Void {
        SetDateHandler = handler
        sendCommand(createSetDateCommand())
    }
    /// 创建日期设置指令
    ///
    /// - Returns: 日期设置指令
    func createSetDateCommand() -> Data {
        commandType = .SetDate
        return createCommad([0x02], timeStamp(), length: 8)
    }
    func timeStamp() -> [UInt8] {
        var bytes = [UInt8]()
        
        let date = Date()
        let second = Int(date.timeIntervalSince1970)
        let timeZone = TimeZone.current
        let seconds = timeZone.secondsFromGMT(for: date)
        let timeStamp = second + seconds
        
        bytes.append(UInt8((timeStamp >> 24) & 0xFF))
        bytes.append(UInt8((timeStamp >> 16) & 0xFF))
        bytes.append(UInt8((timeStamp >>  8) & 0xFF))
        bytes.append(UInt8((timeStamp >>  0) & 0xFF))
        
        return bytes
    }
    /// 处理蓝牙对日期设置指令反馈数据
    func handleSetDateFeedbackData() -> Void {
        guard let coluse = SetDateHandler else { return }
        let bytes = [UInt8](feedbackValue)
        coluse(bytes[3] == 0)
    }
    //MARK: - 请求电池电量
    /// 请求电池电量
    ///
    /// - Parameter handler: 回调
    func requestBattryEnergy(_ handler:requestBattryEnergyHandler?) -> Void {
        requestBattryEnergyHandler = handler
        sendCommand(createRequestBatteryEnergyCommand())
    }
    private func createRequestBatteryEnergyCommand() -> Data? {
        commandType = .RequestBatteryEnergy
        return createCommad([0x28], nil, length: 6)
    }
    private func hanleRequestBatteryEnergyFeedbackData() -> Void {
        guard let handler = requestBattryEnergyHandler else { return }
        let bytes = [UInt8](feedbackValue)
        let energy = Int(bytes[3]) * 256 + Int(bytes[4])
        handler(energy)
    }
    //MARK: - 请求版本号
    /// 请求版本号
    ///
    /// - Parameter handler: 回调
    func requestVersion(_ handler:RequestVersionHandler?) -> Void {
        requestVersionHandler = handler
        sendCommand(createRequestVersionCommand())
    }
    private func createRequestVersionCommand() -> Data? {
        commandType = .RequestVersion
        return createCommad([0x30,0x01], nil, length: 6)
    }
    private func hanleRequestVersionFeedbackData() -> Void {
        guard let handler = requestVersionHandler else { return }
        let versionData = feedbackValue.subdata(in: 4 ..< 18)
        let version = String(data: versionData, encoding: .utf8)
        var infoDic = [String:Any]()
        infoDic["version"] = version
        handler(infoDic)
    }
    
    //MARK: - 自动休眠
    /// 自动休眠
    ///
    /// - Parameter handler: 回调
    func autoSleep(_ spleep:Bool, _ handler:ReturnTheSameCommandHanler?) -> Void {
        returnTheSameCommandHanler = handler
        sendCommand(createAutoSleepCommand(spleep))
    }
    private func createAutoSleepCommand(_ spleep:Bool) -> Data? {
        commandType = .AutoSleep
        var validData = [UInt8]()
        validData.append(UInt8(spleep ? 1 : 0))
        return createCommad([0xA1], validData, length: 20)
    }
    
    //MARK: - 修改设备名称
    /// 修改设备名称 16个字节 5个中文字符 16个英文字符
    ///
    /// - Parameter handler: 回调
    func modifyEquipmentName(_ name:String?, _ handler:ReturnTheSameCommandHanler?) -> Void {
        returnTheSameCommandHanler = handler
        sendCommand(createModifyEquipmentNameCommand(name))
    }
    private func createModifyEquipmentNameCommand(_ name:String?) -> Data? {
        commandType = .ModifyEquipmentName
        var validData : [UInt8]?
        if name != nil {
            let nameData = name!.data(using: .utf8)
            validData = [UInt8](nameData!)
        }
        return createCommad([0xA2], validData, length: 20)
    }
    //MARK: - 固件升级
    func checkPreparationForUpdateFirmware(_ preparationHandler:CheckPreparationForUpdateFirmwareHandler?) -> Void {
        checkPreparationForUpdateFirmwareHandler = preparationHandler
        checkDeviceVersion()
    }
    private func checkDeviceVersion() -> Void {
        if isNewDevice {
            checkBattryEnergy()
        }else{
            guard let colsure = self.checkPreparationForUpdateFirmwareHandler else {return}
            var info = [String:Any]()
            info["state"]          = false
            info["description"]    = "已是最新版本固件"
            colsure(info)
        }
    }
    private func checkBattryEnergy() -> Void {
        requestBattryEnergy { (energy:Int?) in
            var info = [String:Any]()
            guard let colsure = self.checkPreparationForUpdateFirmwareHandler else {return}
            guard let battery = energy else {
                info["state"]          = false
                info["description"] = "未能获取电量"
                colsure(info)
                return
            }
            if battery <= 50 {
                info["state"]          = false
                info["description"] = "电量不足"
                colsure(info)
            }else{
                self.checkFirmwareVersion()
            }
        }
    }
    private func checkFirmwareVersion() -> Void {
        requestVersion { (versionInfoDic:[String:Any]?) in
            var info = [String:Any]()
            guard let colsure = self.checkPreparationForUpdateFirmwareHandler else {return}
            guard let versionInfo = versionInfoDic else {
                info["state"]          = false
                info["description"] = "未能获取当前设备版本"
                colsure(info)
                return
            }
            guard let versionAny = versionInfo["version"]  else {
                info["state"]          = false
                info["description"] = "未能获取当前设备版本"
                colsure(info)
                return
            }
            let versionString = versionAny as! String
            let arr = versionString.components(separatedBy: "-")
            let currentVersion = arr[0]
            self.requsetNewFirmwareVersion(currentVersion)
        }
    }
    func requsetNewFirmwareVersion(_ currentVersion:String) -> Void {
        guard let colsure = self.checkPreparationForUpdateFirmwareHandler else {return}
        var info = [String:Any]()
        let urlString = baseUrlString + "/" + firmwareUrlString
        guard let url = URL(string: urlString) else {
            info["state"]          = false
            info["description"] = "请求最新版本的URL丢失"
            colsure(info)
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = "oemType=\(connectedSensorModel!.correctOrderOemType())&lang=\(currentLanguage())&appCommonVersion=3".data(using: .utf8)
        urlRequest.httpShouldHandleCookies = true
        let configuration = URLSessionConfiguration.default
        let manager = URLSession(configuration: configuration)
        let task = manager.dataTask(with: urlRequest) { (data:Data?, resonce:URLResponse?, error:Error?) in
            let nerVersionModel = RJFirmwareVersionModel(self.getNewVersionInfiDic(data))
            self.newFirmwareVersionModel = nerVersionModel
            DispatchQueue.main.async {
                self.wetherUpdate(currentVersion, newVersion: nerVersionModel.Version ?? "")
            }
        }
        task.resume()
    }
    private func currentLanguage() -> String {
        let languages = Locale.preferredLanguages
        let language = languages[0]
        if language.contains("zh-Hans") {
            return language
        }else if language.contains("id") {
            return language
        }
        return "english"
    }
    
    private func getNewVersionInfiDic(_ data:Data?) -> [String:Any]? {
        guard let result = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) else {return nil}
        let resultDic = result as! [String:Any]
        let ret = resultDic["ret"]
        let errDesc = resultDic["errDesc"]
        if ret is String {
            let retString = ret as! String
            if retString == "0" {
                if errDesc is [String : Any] {
                    return  errDesc as? [String : Any]
                }
            }
        }
        return nil
        
    }
    func wetherUpdate(_ currentVersion:String , newVersion: String) -> Void{
        guard let colsure = self.checkPreparationForUpdateFirmwareHandler else {return}
        var info = [String:Any]()
        if currentVersion.count != newVersion.count || currentVersion.count != 6 {
            info["state"]          = false
            info["description"]    = "版本信息错误"
        }
        let currenrVersionArray = String(currentVersion.suffix(5)).components(separatedBy: ".")
        let newVersionArray     = String(currentVersion.suffix(5)).components(separatedBy: ".")
        var update = false
        
        for index in 0 ..< currenrVersionArray.count {
            if Int(newVersionArray[index])! > Int(currenrVersionArray[index])! {
                update = true
            }
        }
        if update {
            info["state"]          = true
            info["currentVersion"] = currentVersion
            info["newVersion"]     = newVersion
        }else{
            info["state"]          = false
            info["description"]    = "已经是最新版本"
        }
        colsure(info)
        
    }
    func updateFirmware(_ progressHandler:UpdateFirmwareProgressHandler? , _ handler:ReturnTheSameCommandHanler?) -> Void {
        returnTheSameCommandHanler = handler
        updateFirmwareProgressHandler = progressHandler
        sendCommand(createUpdateFirmwareCommand())
        //        downloadNewFirmware()
    }
    private func createUpdateFirmwareCommand() -> Data? {
        commandType = .UpdateFirmware
        var functionCode : [UInt8]?
        let omeType = connectedSensorModel!.oemType!
        switch omeType {
        case .KU:
            functionCode = [0x31,0x00]
        case .M1:
            functionCode = [0x31,0x01]
        case .M2:
            functionCode = [0x31,0x02]
        case .M3:
            functionCode = [0x31,0x03]
        case .M4:
            functionCode = [0x31,0x04]
        case .M5:
            functionCode = [0x31,0x05]
        case .M6:
            functionCode = [0x31,0x06]
        case .M7:
            functionCode = [0x31,0x07]
        case .M8:
            functionCode = [0x31,0x08]
        case .M9:
            functionCode = [0x31,0x09]
        case .MA:
            functionCode = [0x31,0x0A]
        case .N0:
            functionCode = [0x41,0x00]
        case .N1:
            functionCode = [0x41,0x01]
        case .N2:
            functionCode = [0x41,0x02]
        case .N3:
            functionCode = [0x41,0x03]
        case .N4:
            functionCode = [0x41,0x04]
        case .N5:
            functionCode = [0x41,0x05]
        case .N6:
            functionCode = [0x41,0x06]
        case .N7:
            functionCode = [0x41,0x07]
        case .N8:
            functionCode = [0x41,0x08]
        case .N9:
            functionCode = [0x41,0x09]
        case .NA:
            functionCode = [0x41,0x0A]
        case .NB:
            functionCode = [0x41,0x0B]
        case .NC:
            functionCode = [0x41,0x0C]
        case .ND:
            functionCode = [0x41,0x0D]
        case .NE:
            functionCode = [0x41,0x0E]
        case .NF:
            functionCode = [0x41,0x0F]
        case .NG:
            functionCode = [0x41,0x10]
        case .NH:
            functionCode = [0x41,0x11]
        case .NI:
            functionCode = [0x41,0x12]
        case .NJ:
            functionCode = [0x41,0x13]
        case .L0:
            functionCode = [0x51,0x00]
        case .LD:
            functionCode = [0x51,0x0D]
        case .H0:
            functionCode = [0x61,0x00]
        case .H1:
            functionCode = [0x61,0x01]
        case .H3:
            functionCode = [0x61,0x03]
        case .H4:
            functionCode = [0x61,0x03]
        }
        
        return createCommad(functionCode, nil, length: 5)
    }
    private func handleUpdateFirmwareFeedbackData() -> Void {
        if sendCommand == feedbackValue {
            disconncetType = .UpdateFirmware
        }else{
            guard let colsure = returnTheSameCommandHanler else {return}
            colsure(false)
        }
    }
    
    func downloadNewFirmware() -> Void {
        let path = newFirmwareVersionModel?.Path ?? ""
        guard let url = URL(string: path) else { return  }
        let configuration = URLSessionConfiguration.default
        let manager = URLSession(configuration: configuration)
        let downloadTask = manager.downloadTask(with: url) { (filePath:URL?, responce:URLResponse?, error:Error?) in
            let documentsDirectoryURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let newFilePath = documentsDirectoryURL?.appendingPathComponent((responce?.suggestedFilename)!)
            try? FileManager.default.moveItem(at: filePath!, to: newFilePath!)
            self.firmwareFilePath = newFilePath
            DispatchQueue.main.async {
                self.updateWithiniOSDFULirary()
            }
        }
        downloadTask.resume()
    }
    private func updateWithiniOSDFULirary() -> Void {
        let selectFirmware = DFUFirmware(urlToBinOrHexFile:firmwareFilePath! , urlToDatFile: nil, type: .application)
        
        let initiator = DFUServiceInitiator(centralManager: centralManager!, target: connecterPeripheral!).with(firmware: selectFirmware!)
        initiator.progressDelegate = self
        initiator.delegate         = self
        let _ = initiator.start()
    }
    func updateFirmwareSuccess() -> Void {
        returnTheSameCommandHanler!(true)
        CTMediator.resetCBCentralManagerDelegate()
        //        connect(connecterPeripheral!, nil, connectHandler: connectSensorResultHandler_XiaoYu, disConnectSensorResultHandler_XiaoYu)
    }
    
    func dfuStateDidChange(to state: DFUState) {
        switch state {
        case .completed:
            print("升级完成")
            updateFirmwareSuccess()
        default:
            break
        }
    }
    
    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        print("\(message)")
    }
    
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        updateFirmwareProgressHandler!(Double(progress)/100.0)
    }
    //MARK: - 主界面
    
    func requestHomePageData(_ day:Int = 0 ,_ FirstFeedbackDataInOneDay:RequestHomeDataWithFirstFeedbackDataInOneDayHandler?
        ,_ SecondFeedbackDataInOneDay:RequestHomeDataWithSecondFeedbackDataInOneDayHandler?
        ,_ handler:RequestHomepageDataWithReceiveAllDataHandler?) -> Void {
        requestHomeDataWithFirstFeedbackDataInOneDayHandler  = FirstFeedbackDataInOneDay
        requestHomeDataWithSecondFeedbackDataInOneDayHandler = SecondFeedbackDataInOneDay
        requestHomepageDataWithReceiveAllDataHandler         = handler
        sendCommand(createRequestHomepageDataCommand(day))
    }
    
    func createRequestHomepageDataCommand(_ day:Int) -> Data {
        commandType = .RequestHomepageData
        return createCommad([0x03,0x02], [UInt8(day)], length: 6)
    }
    private func handleRequestHomepageFeedbackData() -> Void {
        let bytes = [UInt8](feedbackValue)
        if bytes[2] == 0x07 {
            handleRequestHomepageDataWithFirstFeedbackDataInOneDayFeedbackData(bytes)
        }
        if bytes[2] == 0x08 {
            handleRequestHomepageDataWithSecondFeedbackDataInOneDayFeedbackData(bytes)
        }
        if bytes[2] == 0x20 {
            handleRequestHomepageDataWithReceiveAllDataFeedbackData(bytes)
        }
    }
    private func handleRequestHomepageDataWithFirstFeedbackDataInOneDayFeedbackData(_ bytes:[UInt8]) -> Void {
        
        guard let coluse = requestHomeDataWithFirstFeedbackDataInOneDayHandler else { return  }
        var infoDic = [String:Any]()
        //日期
        let senconds = (Int(bytes[3]) * 256 + Int(bytes[4])) * 86400 - TimeZone.current.secondsFromGMT()
        let date     = Date(timeIntervalSince1970: TimeInterval(senconds))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        //卡路里
        let calories = Int(bytes[5]) * 256 + Int(bytes[6])
        //运动量
        let amounts = Int(bytes[7]) * 256 + Int(bytes[8])
        //时间
        let minutes = Int(bytes[9]) * 256 + Int(bytes[10])
        //场次
        let sessions = Int(bytes[11]) * 256 + Int(bytes[12])
        infoDic["date"]     = dateString
        infoDic["calories"] = calories
        infoDic["amounts"]  = amounts
        infoDic["minutes"]  = minutes
        infoDic["sessions"] = sessions
        coluse(infoDic)
    }
    private func handleRequestHomepageDataWithSecondFeedbackDataInOneDayFeedbackData(_ bytes:[UInt8]) -> Void {
        
        guard let coluse = requestHomeDataWithSecondFeedbackDataInOneDayHandler else { return  }
        var infoDic = [String:Any]()
        
        //扣次数
        let smashCount = Int(bytes[3]) * 256 + Int(bytes[4])
        //挡次数
        let blockCount = Int(bytes[5]) * 256 + Int(bytes[6])
        //挑次数
        let dropCount  = Int(bytes[7]) * 256 + Int(bytes[8])
        //空挥次数
        let emptyCount = Int(bytes[9]) * 256 + Int(bytes[10])
        //最大速度
        let maxSpeed   = min(Int(bytes[11]) * 256 + Int(bytes[12]), 300)
        //高远次数
        let clearCount = Int(bytes[13]) * 256 + Int(bytes[14])
        //平抽次数
        let driveCount = Int(bytes[15]) * 256 + Int(bytes[16])
        //搓球次数
        let chopCount  = Int(bytes[17]) * 256 + Int(bytes[18])
        infoDic["smashCount"]  = smashCount
        infoDic["blockCount"]  = blockCount
        infoDic["dropCount"]   = dropCount
        infoDic["emptyCount"]  = emptyCount
        infoDic["maxSpeed"]    = maxSpeed
        infoDic["clearCount"]  = clearCount
        infoDic["driveCount"]  = driveCount
        infoDic["chopCount"]   = chopCount
        coluse(infoDic)
    }
    private func handleRequestHomepageDataWithReceiveAllDataFeedbackData(_ bytes:[UInt8]) -> Void {
        guard let coluse = requestHomepageDataWithReceiveAllDataHandler else { return  }
        coluse(bytes[3] == 0)
    }
    //MARK: - 进入实时模式
    /// 进入实时模式
    ///
    /// - Parameter handler: 回调
    func enterRealTimeMode(_ state:EnterRealTimeModelStateHandler? ,_ handler:EnterRealTimeModelDataHandler?) -> Void {
        enterRealTimeModelStateHandler = state
        enterRealTimeModelDataHandler  = handler
        sendCommand(createEnterRealTimeModelCommand())
    }
    func createEnterRealTimeModelCommand() -> Data? {
        commandType = .EnterRealTimeMode
        return createCommad([0x03,0x03], nil, length: 6)
    }
    private func hanleEnterRealTimeModelFeedbackData() -> Void {
        let bytes = [UInt8](feedbackValue)
        if bytes[2] == 0x03 {
            guard let state = enterRealTimeModelStateHandler else { return }
            state(feedbackValue == sendCommand)
        }
        if bytes[2] == 0x0A{
            hanleEnterRealTimeModelDataOfUpLoadSwingSportFeedbackData()
        }
    }
    private func hanleEnterRealTimeModelDataOfUpLoadSwingSportFeedbackData() -> Void {
        guard let handler = enterRealTimeModelDataHandler else { return }
        let bytes = [UInt8](feedbackValue)
        var infoDic = [String:Any]()
        //姿态
        let poseType = Int(bytes[3])
        //速度
        let speed = min(Int(bytes[4]) * 256 + Int(bytes[5]), 350)
        //力量
        let strength  = min(Int(bytes[6]) * 256 + Int(bytes[7]), 350) / 10
        //角度
        let arc = min(Int(bytes[8]) * 256 + Int(bytes[9]), 360)
        //时间戳
        let timeStamp   = Int(bytes[10]) * 256*256*256 + Int(bytes[11]) * 256*256 + Int(bytes[12]) * 256 + Int(bytes[13])
        //是否击中
        let hasHitTheBall  = !( bytes[14] == 0xff )
        //上下手球(1字节): 0，上手球; 其他，下手球;
        let upDownHandBall = bytes[15] == 0x00 ? 0 : 1
        //正反手(1 字节): 0，正手; 其他，反手;
        let foreBackHandBall = bytes[16] == 0x00 ? 0 : 1
        //出球方向(1 字节):带符号，范围-128~+127。0，中;负数，左;正数，右;
        let hitBallDirection = bytes[17] == 0x00 ? 0 : (bytes[17] > 0 ? 1 : -1)
        //击球时间(1 字节):单位为 10ms，即如果单位是 ms，收到的数据要*10;
        let hitBallTime = Int(bytes[18])
        
        infoDic["smashCount"]          = poseType
        infoDic["speed"]               = speed
        infoDic["strength"]            = strength
        infoDic["arc"]                 = arc
        infoDic["timeStamp"]           = timeStamp
        infoDic["hasHitTheBall"]       = hasHitTheBall
        infoDic["upDownHandBall"]      = upDownHandBall
        infoDic["foreBackHandBall"]    = foreBackHandBall
        infoDic["hitBallDirection"]    = hitBallDirection
        infoDic["hitBallTime"]         = hitBallTime
        handler(infoDic)
    }
    //MARK: - 退出实时模式
    /// 退出实时模式
    func exitRealTimeModel() -> Void {
        commandType = .ExitRealTimeModel
        sendCommand(createExitRealTimeModelCommand())
    }
    private func createExitRealTimeModelCommand() -> Data? {
        return createCommad([0x03,0x03], [0x01], length: 6)
    }
    //MARK: - 详情界面
    
    /// 详情界面
    ///
    /// - Parameters:
    ///   - day: 哪天:1BYTE，范围 1~10，1 表示当天，2 表示有数据记录的前一天，依此类推，0 则连 续发送 10 天数据
    ///   - startIndex: 第几条:2BYTE，从第几条数据开始发送，从 0 开始
    ///   - needIndexs: 多少条:2BYTE，要发送多少条数据，0 表示发送该天所有数据
    func detailPage(_ day:Int ,_  startIndex:Int ,_  needIndexs:Int , uploadHnaler:DetailPageUploadDataHandler? , completeHandler:DetailPageUploadDataCompleteHandler?) -> Void {
        detailPageUploadDataHandler = uploadHnaler
        detailPageUploadDataCompleteHandler = completeHandler
        sendCommand(createDetailPageCommand(day, startIndex, needIndexs))
    }
    private func createDetailPageCommand(_ day:Int , _ startIndex:Int , _ needIndexs:Int) -> Data? {
        commandType = .DetailPage
        var validData = [UInt8]()
        validData.append(UInt8(day))
        validData.append(UInt8(startIndex / 256))
        validData.append(UInt8(startIndex % 256))
        validData.append(UInt8(needIndexs / 256))
        validData.append(UInt8(needIndexs % 256))
        return createCommad([0x04], validData, length: 20)
    }
    private func hanleDetailPageFeedbackData() -> Void {
        let bytes = [UInt8](feedbackValue)
        if bytes[2] == 0x05 {
            hanleDetailPageUploadFeedbackData()
        }
        if bytes[2] == 0x22 {
            hanleDetailPageUploadDataCompleteFeedbackData()
        }
    }
    private func hanleDetailPageUploadFeedbackData() -> Void {
        guard let handler = detailPageUploadDataHandler else { return }
        let bytes = [UInt8](feedbackValue)
        var infoDic = [String:Any]()
        //姿态
        let poseType        = Int(bytes[3])
        //速度
        let speed           = min(Int(bytes[4]) * 256 + Int(bytes[5]), 350)
        //力量
        let strength        = min(Int(bytes[6]) * 256 + Int(bytes[7]), 350) / 10
        //角度
        let arc             = min(Int(bytes[8]) * 256 + Int(bytes[9]), 360)
        //时间戳
        let timeStamp       = Int(bytes[10]) * 256*256*256 + Int(bytes[11]) * 256*256 + Int(bytes[12]) * 256 + Int(bytes[13])
        //场次下标
        let sessionIndex    = Int( bytes[14])
        //挥拍属性
        let property        = swingProperty(bytes[15])
        //详情包的序号
        let detailPageIndex = Int(bytes[17]) * 256 + Int(bytes[18])
        
        infoDic["smashCount"]          = poseType
        infoDic["speed"]               = speed
        infoDic["strength"]            = strength
        infoDic["arc"]                 = arc
        infoDic["timeStamp"]           = timeStamp
        infoDic["sessionIndex"]        = sessionIndex
        infoDic["property"]            = property
        infoDic["detailPageIndex"]     = detailPageIndex
        handler(infoDic)
    }
    private func hanleDetailPageUploadDataCompleteFeedbackData() -> Void {
        guard let handler = detailPageUploadDataCompleteHandler else { return }
        let bytes = [UInt8](feedbackValue)
        handler( bytes[3] == 0x00 )
    }
    //MARK: - 3D挥拍练习曲线界面
    
    /// 3D挥拍练习曲线界面
    ///
    /// - Parameters:
    ///   - enter3DHandler: 进入3D挥拍练习模式成功与否的回调
    ///   - totalDataHandler: 单次挥拍的总数据
    ///   - u3DDataHandler: 单次挥拍的U3D数据
    func enter3DSwingTrainCurvePage(_ enter3DHandler:ReturnTheSameCommandHanler? , _ totalDataHandler:TotalDataOfSingleSwingHandler? ,_ u3DDataHandler:U3DDataOfSingleSwingHandler?) -> Void{
        returnTheSameCommandHanler = enter3DHandler
        totalDataOfSingleSwingHandler = totalDataHandler
        u3DDataOfSingleSwingHandler   = u3DDataHandler
        sendCommand(createEnter3DSwingTrainingCurvePageCommand())
    }
    private func createEnter3DSwingTrainingCurvePageCommand() -> Data? {
        commandType = .Enter3DSwingTrainingCurvePage
        return createCommad([0xD0], nil, length: 20)
    }
    private func hanleEnter3DSwingTrainingCurvePageFeedbackData() -> Void {
        let bytes = [UInt8](feedbackValue)
        if bytes[2] == 0xD0 {
            guard let colsure = returnTheSameCommandHanler else { return }
            colsure(feedbackValue == sendCommand)
        }
        if bytes[2] == 0xD1 {
            handleTotalDataOfSingleSwingFeedbackData()
        }
        if bytes[1] == 0x61 {
            handleU3DOfSingleSwingFeedbackData()
        }
        if bytes[1] == 0x62 {
            reciveAll3DSwingTrainingCurveDataEnd()
        }
    }
    private func handleTotalDataOfSingleSwingFeedbackData() -> Void {
        guard let colsure = totalDataOfSingleSwingHandler else { return }
        let bytes = [UInt8](feedbackValue)
        var infoDic = [String:Any]()
        //DTW 的数据总包数
        let DTWTotalDataPackets = Int(bytes[3])
        //姿态
        let poseType        = Int(bytes[4])
        //速度
        let speed           = min(Int(bytes[5]) * 256 + Int(bytes[6]), 350)
        //力量
        let strength        = min(Int(bytes[7]) * 256 + Int(bytes[8]), 350) / 10
        //角度
        let arc             = min(Int(bytes[9]) * 256 + Int(bytes[10]), 360)
        //时间戳
        let timeStamp       = Int(bytes[11]) * 256*256*256 + Int(bytes[12]) * 256*256 + Int(bytes[13]) * 256 + Int(bytes[14])
        //挥拍属性
        let property        = swingProperty(bytes[15])
        //3D 有效数据_开始下标
        let valid3DStartIndex   = Int(bytes[16])
        //3D 有效数据_ 结束下标
        let valid3DEndIndex     = Int(bytes[17])
        
        DTWCount    = valid3DStartIndex - valid3DEndIndex
        
        infoDic["DTWTotalDataPackets"]          = DTWTotalDataPackets
        infoDic["smashCount"]                   = poseType
        infoDic["speed"]                        = speed
        infoDic["strength"]                     = strength
        infoDic["arc"]                          = arc
        infoDic["timeStamp"]                    = timeStamp
        infoDic["property"]                     = property
        infoDic["valid3DStartIndex"]            = valid3DStartIndex
        infoDic["valid3DEndIndex"]              = valid3DEndIndex
        
        colsure(infoDic)
    }
    private func swingProperty(_ byte:UInt8) -> [String:Any]{
        
        var value = [Int](repeating: 0, count: 8)
        for index in 0..<value.count {
            value[value.count - index - 1] = Int(byte) % Int(pow(2.0, Double(index + 1)))
            
        }
        var propertyDic = [String:Any]()
        propertyDic["hitBallDirection"] = value[6]*2 + value[7]
        propertyDic["foreBackHand"]     = value[5]
        propertyDic["upDownHand"]       = value[4]
        propertyDic["hitBall"]          = value[3]
        return propertyDic
    }
    private func handleU3DOfSingleSwingFeedbackData() -> Void {
        guard let colsure = u3DDataOfSingleSwingHandler else { return  }
        let bytes = [UInt8](feedbackValue)
        var infoDic = [String:Any]()
        infoDic["q0"]          = Int(bytes[2])
        infoDic["q1"]          = Int(bytes[3])
        infoDic["q2"]          = Int(bytes[4])
        infoDic["q3"]          = Int(bytes[5])
        infoDic["gx"]          = Int(bytes[6])
        infoDic["gy"]          = Int(bytes[7])
        infoDic["gz"]          = Int(bytes[8])
        infoDic["ax"]          = Int(bytes[9])
        infoDic["ay"]          = Int(bytes[10])
        infoDic["az"]          = Int(bytes[11])
        infoDic["index"]       = Int(bytes[12])
        
        if DTWCount - 1 == Int(bytes[12]) {
            reciveAll3DSwingTrainingCurveDataEnd()
        }
        colsure(infoDic)
    }
    /// APP 接收完3D挥拍练习曲线数据后，发送结束指令 球拍不用原句返回。
    private func reciveAll3DSwingTrainingCurveDataEnd() -> Void{
        sendCommand(createReciveAll3DSwingTrainingCurveDataEndCommand())
    }
    private func createReciveAll3DSwingTrainingCurveDataEndCommand() -> Data? {
        commandType = .ReciveAll3DSwingTrainingCurveDataEnd
        return createCommad([0xD3], nil, length: 20)
    }
    /// APP 退出3D挥拍练习曲线模式: 球拍原句返回
    ///
    /// - Parameter handler: 回调
    func exitSwingTrainCurvePage(_ handler:ReturnTheSameCommandHanler?) -> Void{
        returnTheSameCommandHanler = handler
        sendCommand(createExitSwingTrainCurvePageCommand())
    }
    private func createExitSwingTrainCurvePageCommand() -> Data? {
        commandType = .Exit3DSwingTrainingCurvePage
        return createCommad([0xD4], nil, length: 20)
    }
    
    //MARK: - ***********以下指令在小羽(2.0有效)*****************
    //MARK: - 读取MAC地址(2.0有效)
    /// 读取MAC地址(2.0有效)
    ///
    /// - Parameter handler: 回调
    func readMacAddress(_ handler:ReadMacAddressHandler?) -> Void {
        readMacAddressHandler = handler
        sendCommand(createReadMacAddressCommand())
    }
    private func createReadMacAddressCommand() -> Data? {
        commandType = .ReadMacAddress
        return createCommad([0xA3], nil, length: 20)
    }
    func hanleReadMacAddressFeedbackData() -> Void {
        guard let handler = readMacAddressHandler else { return }
        let macData = feedbackValue.subdata(in: 3..<15)
        let macAddress = String(data: macData, encoding: .utf8)
        handler(macAddress)
    }
    //MARK: - 关机
    /// 关机
    ///
    /// - Parameter handler: 回调
    func shutDown(_ handler:ReturnTheSameCommandHanler?) -> Void {
        returnTheSameCommandHanler = handler
        sendCommand(createShutDownCommand())
    }
    private func createShutDownCommand() -> Data? {
        commandType = .ShutDown
        return createCommad([0xA5], [0x01], length: 20)
    }
    //MARK: - 待机
    /// 待机
    ///
    /// - Parameter handler: 回调
    func standBy(_ handler:ReturnTheSameCommandHanler?) -> Void {
        returnTheSameCommandHanler = handler
        sendCommand(createStandByCommand())
    }
    private func createStandByCommand() -> Data? {
        commandType = .StandBy
        return createCommad([0xA5], [0x02], length: 20)
    }
    //MARK: - 重启
    /// 重启
    ///
    /// - Parameter handler: 回调
    func reStart(_ handler:ReturnTheSameCommandHanler?) -> Void {
        returnTheSameCommandHanler = handler
        sendCommand(createReStartCommand())
    }
    private func createReStartCommand() -> Data? {
        commandType = .ReStart
        return createCommad([0xA5], [0x03], length: 20)
    }
    //MARK: - 清空缓存
    /// 清空缓存
    ///
    /// - Parameter handler: 回调
    func clearCache(_ handler:ReturnTheSameCommandHanler?) -> Void {
        returnTheSameCommandHanler = handler
        sendCommand(createClearCacheCommand())
    }
    private func createClearCacheCommand() -> Data? {
        commandType = .ClearCache
        return createCommad([0xA5], [0x04], length: 20)
    }
    //MARK: - 还原出厂设置
    /// 还原出厂设置
    ///
    /// - Parameter handler: 回调
    func reStored(_ handler:ReturnTheSameCommandHanler?) -> Void {
        returnTheSameCommandHanler = handler
        sendCommand(createReStoredCommand())
    }
    private func createReStoredCommand() -> Data? {
        commandType = .ReStored
        return createCommad([0xA5], [0x05], length: 20)
    }
    //MARK: - 设置左右手
    /// 设置左右手
    ///
    /// - Parameter handler: 回调
    func setLeftRightHand(_ right:Bool ,_ handler:ReturnTheSameCommandHanler?) -> Void {
        returnTheSameCommandHanler = handler
        sendCommand(createSetLeftRightHandCommand(right))
    }
    private func createSetLeftRightHandCommand(_ right:Bool) -> Data? {
        commandType = .SetLeftRightHand
        let validData:[UInt8] = right ? [0x01] : [0x00]
        return createCommad([0x10], validData, length: 20)
    }
    /// 统一处理原句返回的蓝牙反馈指令
    func handleReturnTheSameCommandFeedbackData() -> Void {
        guard let handler = returnTheSameCommandHanler else { return }
        handler(sendCommand == feedbackValue)
    }
    
}
//MARK: - ****************************     羽教监控系统     ****************************
extension RJBluetoothHelper {
    /// 开始上课
    ///
    /// - Parameter beginClass: 回调
    func beginClass(_ beginClass:BeginClassHandler?) -> Void {
        beginClassHandler = beginClass
        sendCommand(createBeginClassCommand())
    }
    private func createBeginClassCommand() -> Data? {
        commandType = .BeginClass
        var valid = timeStamp()
        valid.append(0x04)
        return createCommad([0xD6] ,valid,length: 20)
    }
    private func handleBeginClassFeedbackData() -> Void {
        guard let handler = beginClassHandler else { return }
        let bytes = [UInt8](feedbackValue)
        //        if bytes[0] == 0x5F,bytes[1] == 0x60 , bytes[1] == 0xD6 {
        if bytes.count == 20 {
            var infoDic = [String:Any]()
            //空挥次数
            let emptyCount = Int(bytes[3]) * 256 + Int(bytes[4])
            //扣杀次数
            let smashCount = Int(bytes[5]) * 256 + Int(bytes[6])
            //高远次数
            let clearCount = Int(bytes[7]) * 256 + Int(bytes[8])
            //平挡次数
            let blockCount = Int(bytes[9]) * 256 + Int(bytes[10])
            //平抽次数
            let driveCount = Int(bytes[11]) * 256 + Int(bytes[12])
            //挑球次数
            let dropCount  = Int(bytes[13]) * 256 + Int(bytes[14])
            //搓球次数
            let chopCount  = Int(bytes[15]) * 256 + Int(bytes[16])
            //详情起始IDID
            let detailStartIndex  = Int(bytes[17]) * 256 + Int(bytes[18])
            infoDic["smashCount"]  = smashCount
            infoDic["blockCount"]  = blockCount
            infoDic["dropCount"]   = dropCount
            infoDic["emptyCount"]  = emptyCount
            infoDic["clearCount"]  = clearCount
            infoDic["driveCount"]  = driveCount
            infoDic["chopCount"]   = chopCount
            infoDic["detailStartIndex"]   = detailStartIndex
            handler(infoDic)
        }
    }
    /// 下课指令
    ///
    /// - Parameters:
    ///   - startIndex: 详情起始ID
    ///   - endClass: 回调
    func endClass(_ startIndex:Int ,_ endClassUpload:EndClassUploadDataHandler? , _ endClassUploadComplete:EndClassUploadDataCompleteHandler?) -> Void {
        endClassUploadDataHandler = endClassUpload
        endClassUploadDataCompleteHandler = endClassUploadComplete
        sendCommand(createEndClassCommand(1, startIndex, 0))
    }
    private func createEndClassCommand(_ day:Int , _ startIndex:Int , _ needIndexs:Int) -> Data? {
        commandType = .EndClass
        var validData = [UInt8]()
        validData.append(UInt8(day))
        validData.append(UInt8(startIndex / 256))
        validData.append(UInt8(startIndex % 256))
        validData.append(UInt8(needIndexs / 256))
        validData.append(UInt8(needIndexs % 256))
        return createCommad([0x04], validData, length: 20)
    }
    private func handleEndClassFeedbackData() -> Void {
        let bytes = [UInt8](feedbackValue)
        if bytes[2] == 0x05 {
            hanleEndClassUploadFeedbackData()
        }
        if bytes[2] == 0x22 {
            hanleEndClassUploadDataCompleteFeedbackData()
        }
    }
    private func hanleEndClassUploadFeedbackData() -> Void {
        guard let handler = endClassUploadDataHandler else { return }
        let bytes = [UInt8](feedbackValue)
        var infoDic = [String:Any]()
        //姿态
        let poseType        = Int(bytes[3])
        //速度
        let speed           = min(Int(bytes[4]) * 256 + Int(bytes[5]), 350)
        //力量
        let strength        = min(Int(bytes[6]) * 256 + Int(bytes[7]), 350) / 10
        //角度
        let arc             = min(Int(bytes[8]) * 256 + Int(bytes[9]), 360)
        //时间戳
        let timeStamp       = Int(bytes[10]) * 256*256*256 + Int(bytes[11]) * 256*256 + Int(bytes[12]) * 256 + Int(bytes[13])
        //场次下标
        let sessionIndex    = Int( bytes[14])
        //挥拍属性
        let property        = swingProperty(bytes[15])
        //详情包的序号
        let detailPageIndex = Int(bytes[17]) * 256 + Int(bytes[18])
        
        infoDic["smashCount"]          = poseType
        infoDic["speed"]               = speed
        infoDic["strength"]            = strength
        infoDic["arc"]                 = arc
        infoDic["timeStamp"]           = timeStamp
        infoDic["sessionIndex"]        = sessionIndex
        infoDic["property"]            = property
        infoDic["detailPageIndex"]     = detailPageIndex
        handler(infoDic)
    }
    private func hanleEndClassUploadDataCompleteFeedbackData() -> Void {
        guard let handler = endClassUploadDataCompleteHandler else { return }
        let bytes = [UInt8](feedbackValue)
        handler( bytes[3] == 0x00 )
    }
}
