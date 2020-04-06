//
//  CommonData.swift
//  FirstP2P
//
//  Created by fengquanwang on 2018/9/7.
//  Copyright © 2018 9888. All rights reserved.
//

import UIKit

class CommonData: NSObject {

    @objc static let sharedInstance = CommonData()
    @objc static let KEY_FINGERPRINT        = "fingerPrint"


    @objc var fingerPrint: String?
    
    class func getSettingPath(userID: String?) -> String?{
        var realID = "default"
        if let tempID = String.validateString(str: userID){
            realID = tempID
        }
        
        if let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first{
            let settingsDirectory = directory +  "/settings/"
            try? FileManager.default.createDirectory(atPath: settingsDirectory, withIntermediateDirectories: true, attributes: nil)
            let result = settingsDirectory + realID
            return result
        }
        
        return nil
    }
    
    @objc class func getSetting(keyStr: String, userID: String?) -> Any?{
        if let path = CommonData.getSettingPath(userID: userID){
            let dic = NSDictionary(contentsOfFile: path) as? [String: Any]
            return  dic?[keyStr]
        }
        
        return nil
    }
    
    @objc class func setSetting(keyStr: String, value: Any, userID: String?){
        if let path = CommonData.getSettingPath(userID: userID){
            var dic = NSMutableDictionary(contentsOfFile: path)
            if dic == nil{
                dic = NSMutableDictionary()
            }
            dic?.setValue(value, forKey: keyStr)
            dic?.write(toFile: path, atomically: true)
        }
    }
    
    @objc class func deleteSetting(keyStr: String, userID: String?){
        if let path = CommonData.getSettingPath(userID: userID){
            var dic = NSMutableDictionary(contentsOfFile: path)
            if dic == nil{
                dic = NSMutableDictionary()
            }
            dic?.removeObject(forKey: keyStr)
            dic?.write(toFile: path, atomically: true)
        }
    }

    override init() {
        super.init()
        self.fingerPrint = CommonData.getSetting(keyStr: CommonData.KEY_FINGERPRINT, userID: nil) as? String
    }
    
    
    
    //MARK:-  TouchID
    @objc func getTouchIDStatus(userID: String) -> Bool{
        if let number = CommonData.getSetting(keyStr: "touchid_set", userID: userID) as? NSNumber{
            return number.boolValue
        }
        
        return false
    }
    
    @objc func updateTouchIDStatus(userID: String, enable: Bool){
        CommonData.setSetting(keyStr: "touchid_set", value: NSNumber(value: enable), userID: userID)
    }
    
    
}
