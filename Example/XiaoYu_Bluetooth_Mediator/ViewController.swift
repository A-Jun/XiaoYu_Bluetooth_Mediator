//
//  ViewController.swift
//  RJBluetooth
//
//  Created by A-Jun on 08/28/2018.
//  Copyright (c) 2018 A-Jun. All rights reserved.
//

import UIKit
import XiaoYu_Bluetooth_Mediator

typealias zidian = [String : Any]
class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    var sensor : [String : Any]?
    
    /// 过滤设备 允许显示的设备类型
    var filter_OEM_TYPE : [String]?
    /// 最远信号值
    var minRSSI         :NSInteger?
    lazy var sensorList: [RJSensorModel] = {
        let array = [RJSensorModel]()
        return array
    }()
    
    @IBOutlet weak var outPutTitle: UILabel!
    @IBOutlet weak var outPut: UITextView!
    @IBOutlet weak var deviceName: UITextField!
    @IBOutlet weak var autoSleepValue: UITextField!
    @IBOutlet weak var leftRightHandValue: UITextField!
    @IBOutlet weak var homePageDay: UITextField!
    @IBOutlet weak var detailPageDay: UITextField!
    @IBOutlet weak var scan: UIButton!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        outPut.isHidden = true
        outPutTitle.text = "点击链接"
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensorList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "UITableViewCell")
        }
        let modelInfo = sensorList[indexPath.row]
        cell?.textLabel?.text = modelInfo.name
        cell?.detailTextLabel?.text = String(modelInfo.RSSI)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = sensorList[indexPath.row]
        connectSensor(model)
    }
    
    func connectSensor(_ model:RJSensorModel) {
        CTMediator.connect(model.cbPeripheral, nil, connnectHandler: { (success) in
            if success {
                self.outPut.isHidden = false
                self.tableView.isHidden = true
                self.outPutTitle.text = "输出结果"
                self.outPut.text = String(format: "连接外设 :%@ 成功", model.name!)
            }else{
                self.outPut.text = String(format: "连接外设 :%@ 失败", model.name!)
            }
        }) { (success) in
            print("断开连接")
        }
    }
    @IBAction func scanClick(_ sender: UIButton) {
        self.outPut.isHidden = true
        self.tableView.isHidden = false
        self.outPutTitle.text = "点击链接"
        
        let services = [CBUUID(string: "0001")]
        let options  = [CBCentralManagerScanOptionAllowDuplicatesKey:true]
        
        CTMediator.scanSensor(withServices: services, options: options) {(sensorInfos:[SensorInfo]) in
            self.sensorList.removeAll()
            for sensorInfo in sensorInfos {
                let sensorModel = RJSensorModel.init(sensorInfo)
                self.sensorList.append(sensorModel)
            }
            self.tableView.reloadData()
        }
    }
    @IBAction func stopClick(_ sender: UIButton) {
        CTMediator.stopScan()
    }
    
    @IBAction func disConncect(_ sender: UIButton) {
        CTMediator.disConnect()
    }
    
    @IBAction func SetDate(_ sender: Any) {
        
        CTMediator.SetDate {
            if $0 {
                self.outPut.text = String(format: "校准时间戳成功")
            }else{
                self.outPut.text = String(format: "校准时间戳失败")
            }
        }
        
    }
    @IBAction func requsetHomePageData(_ sender: Any) {
        outPut.text  = ""
        let value = Int(homePageDay.text ?? "0")
        CTMediator.requestHomePageData(value ?? 0, FirstFeedbackDataInOneDay: { (infoDic) in
            if infoDic != nil {
                self.outPut.text = self.outPut.text + "\n" + String(format: "接收主界面数据 :%@ ", infoDic!)
                print("接收主界面数据 :\(infoDic!)")
            }
        }, SecondFeedbackDataInOneDay: { (infoDic) in
            if infoDic != nil {
                self.outPut.text = self.outPut.text + String(format: "\(infoDic!)")
                print("接收主界面数据 :\(infoDic!)")
            }
        }) { (success:Bool) in
            if success {
                self.outPut.text = self.outPut.text + "\n" + String(format: "接收完一天数据")
                print("接收完一天数据")
            }
        }
    }
    @IBAction func enterRealTimeModel(_ sender: Any) {
        self.outPut.text  = ""
        CTMediator.enterRealTimeMode(state: {
            if $0 {
                self.outPut.text = self.outPut.text + "\n" + String(format: "进入实时成功")
            }else{
                self.outPut.text = self.outPut.text + "\n" + String(format: "进入实时失败")
            }
        }) { (info) in
            self.outPut.text = String(format: "接收实时模式数据: %@",String(describing: info!))
        }
    }
    @IBAction func exitRealTimeModel(_ sender: Any) {
        CTMediator.exitRealTimeModel()
        self.outPut.text = String(format: "退出实时模式")
    }
    @IBAction func detailPage(_ sender: Any) {
        self.outPut.text  = ""
        let value = Int(detailPageDay.text ?? "0")
        CTMediator.detailPage(value ?? 0, 0, 0, uploadHnaler: { (info) in
            self.outPut.text = self.outPut.text + "\n" +  String(format: "接收详情数据: %@",String(describing: info!))
        }) {
            if $0 {
                self.outPut.text = self.outPut.text + "\n" +  String(format: "详情数据发送完毕")
        }else{
                self.outPut.text = self.outPut.text + "\n" +  String(format: "详情数据发送没完毕")
            }
        }
    }
    
    @IBAction func enter3D(_ sender: Any) {
        CTMediator.enter3DSwingTrainCurvePage({
            if $0 {
                self.outPut.text = "进入3D成功"
            }else{
                self.outPut.text = "进入3D失败"
            }
        }, { (infoDic) in
            self.outPut.text = String(format: "接收实时模式数据: %@",String(describing: infoDic!))
        }) { (infoDic) in
             self.outPut.text = self.outPut.text + "\n" + String(format: "接收实时模式数据: %@",String(describing: infoDic!))
        }
    }
    
    @IBAction func exit3D(_ sender: Any) {
        CTMediator.exit3DSwingTrainingCurvePage {
            if $0 {
                self.outPut.text = "退出3D成功"
            }else{
                self.outPut.text = "退出3D失败"
            }
        }
    }
    @IBAction func batteryEnergy(_ sender: Any) {
        CTMediator.requestBatteryEnergy { (energy) in
            self.outPut.text = String(format: "电池电量 \n\(String(describing: energy))")
        }
    }
    
    @IBAction func checkForFirmwareUpdate(_ sender: Any) {
        CTMediator.checkPreparationForUpdateFirmware { (result:[String:Any]?) in
            guard let info = result else {return}
            let state = info["state"] as! Bool
            if state {
                self.outPut.text = String(format: "更新信息 \n\(String(describing: result))")
            }else{
                self.outPut.text = String(format: "更新信息 \n\(String(describing: result))")
            }
        }
    }
    @IBAction func updateFirmware(_ sender: Any) {
        self.outPut.text  = ""
        CTMediator.updateFirmware({ (progress:Double?) in
            self.outPut.text = self.outPut.text + "\n" + String(describing:progress)
        }) { if $0 {
            self.outPut.text = self.outPut.text + "\n" + String(format: "固件升级成功")
        }else{
            self.outPut.text = self.outPut.text + "\n" +  String(format: "固件升级失败")
            }
        }
    }
    @IBAction func version(_ sender: Any) {
        CTMediator.requestVersion { (infoDic) in
             self.outPut.text = String(format: "版本号 \n\(String(describing: infoDic))")
        }
    }
    @IBAction func autoSleep(_ sender: Any) {
        
        let value = Bool(autoSleepValue.text ?? "0")
        CTMediator.autoSleep(value ?? false) {
            if $0 {
                self.outPut.text = String(format: "设置自动睡眠成功")
            }else{
                self.outPut.text = String(format: "设置自动睡眠失败")
            }
        }
    }
    
    @IBAction func modifyName(_ sender: Any) {
        CTMediator.modifyEquipmentName(deviceName.text) {
            if $0 {
                self.outPut.text = String(format: "修改设备名成功")
            }else{
                self.outPut.text = String(format: "修改设备名失败")
            }
        }
    }
    @IBAction func readMacAddress(_ sender: Any) {
        CTMediator.readMacAddress { (macAddress) in
            self.outPut.text = String(format: "外设物理地址 \n\(String(describing: macAddress))")
        }
    }
    
    @IBAction func shutDown(_ sender: Any) {
        CTMediator.shutDown {
            if $0 {
            self.outPut.text = String(format: "关机成功")
            }else{
            self.outPut.text = String(format: "关机失败")
            }
        }
    }
    @IBAction func standBy(_ sender: Any) {
        CTMediator.standBy {
            if $0 {
                self.outPut.text = String(format: "待机成功")
            }else{
                self.outPut.text = String(format: "待机失败")
            }
        }
    }
    
    @IBAction func restart(_ sender: Any) {
        CTMediator.reStart {
            if $0 {
                self.outPut.text = String(format: "重启成功")
            }else{
                self.outPut.text = String(format: "重启失败")
            }
        }
    }
    
    @IBAction func clearCache(_ sender: Any) {
        CTMediator.clearCache {
            if $0 {
                self.outPut.text = String(format: "清除缓存成功")
            }else{
                self.outPut.text = String(format: "清除缓存失败")
            }
        }
    }
    
    @IBAction func restored(_ sender: Any) {
        CTMediator.reStored {
            if $0 {
                self.outPut.text = String(format: "还原出厂设置成功")
            }else{
                self.outPut.text = String(format: "还原出厂设置失败")
            }
        }
    }
    @IBAction func leftRightHand(_ sender: Any) {
        let value = Bool(autoSleepValue.text ?? "0")
        CTMediator.SetLeftRightHand(value ?? false) {
            if $0 {
                self.outPut.text = String(format: "设置左右手成功")
            }else{
                self.outPut.text = String(format: "设置左右手失败")
            }
        }
    }
    
}

