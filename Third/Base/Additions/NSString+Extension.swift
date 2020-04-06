//
//  NSString+Extension.swift
//  FirstP2P
//
//  Created by fengquanwang on 07/03/2017.
//  Copyright © 2017 9888. All rights reserved.
//

import UIKit

extension String{
    
    static func validateString(str: String?) -> String?{
        if let s = str, s.length > 0 {
            return s
        }
        
        return nil
    }
    
    static func isEmptyString(str: String?) -> Bool{
        if let s = str, s.length > 0{
            return false
        }
        else{
            return true
        }
    }
    
    
    func suggestedSize(font : UIFont, width : CGFloat) -> CGSize {
        let str = self as NSString
        let tempSize = str.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                        options: .usesLineFragmentOrigin,
                                        attributes: [NSAttributedString.Key.font:font],
                                        context: nil);
        return tempSize.size
    }
    
    func suggestedSize(font:UIFont)  -> CGSize{
        let str = self as NSString
        return str.size(withAttributes: [NSAttributedString.Key.font:font])
    }
    
    var length: Int{
        return self.characters.count
    }
    
    func subString(location: NSInteger, length: NSInteger) -> String{
        return String(self[self.index(self.startIndex, offsetBy: location)..<self.index(self.startIndex, offsetBy: location + length)])
    }
    
    func nsrangeFrom(subStr: String) -> NSRange{
        if let range = self.range(of: subStr){
            let start = self.distance(from: self.startIndex, to: range.lowerBound)
            let end = self.distance(from: self.startIndex, to: range.upperBound)
            return NSRange(location: start, length: end - start)
        }
        
        return NSRange(location: NSNotFound, length: 0)
        
    }
    
    func stringToRange(range: NSRange) -> Range<String.Index> {
        let startIndex = self.index(self.startIndex, offsetBy: range.location)
        let endIndex = self.index(self.startIndex, offsetBy: (range.length + range.location))
        return startIndex..<endIndex
    }
    
    func getParamDic() -> [String:String]{
        var paramDic:[String:String] = [:]
        let paramArr = self.characters.split(separator: "&").map(String.init)
        for str in paramArr{
            let array = str.characters.split(separator: "=").map(String.init)
            if array.count > 1{
                if let key = array.first,let value = array.last{
                    paramDic[key] = value
                }
            }else{
                if let key = array.first{
                    paramDic[key] = ""
                }
            }
        }
        return paramDic
    }
    
    func moneyFormat() -> String?{
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4 //千位符
        formatter.numberStyle = .decimal
        formatter.positiveFormat = "###,##0.00;"
        let money = self.replacingOccurrences(of: ",", with: "")
        if let number = formatter.number(from: money){
            return formatter.string(from: number)
        }
        return nil
    }
    
}
