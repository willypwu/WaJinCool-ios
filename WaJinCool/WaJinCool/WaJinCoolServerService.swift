//
//  WaJinCoolServerService.swift
//  WaJinCool
//
//  Created by Willy Wu on 2017/9/19.
//  Copyright © 2017年 Willy Wu. All rights reserved.
//

import Foundation

class WaJinCoolServerService : NSObject{
    
    static var sService = WaJinCoolServerService()
    
    override init() {
        super.init()
    }
    
    func getCategories(callback: @escaping ([String]) -> Void) {
        var request = URLRequest(url: URL(string: "https://wajincool.appspot.com/categories")!)
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
    
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            if let jsonResult = json as? [String: Any] {
                var categoryResult = [String]()
                for field in jsonResult["categories"] as? [AnyObject] ?? [] {
                    if let cate = field["cate"] as? String {
                        categoryResult.append(cate)
                    }
                }
                DispatchQueue.main.async {
                    callback(categoryResult)
                }
            }
        }
        task.resume()
    }
    
    func addCategory(type: String, cate: String,
                     successCallback: @escaping (String, String) -> Void,
                     failedCallback: @escaping (Void) -> Void) {
        var params = [String: Any]()
        params["cate_name"] = cate
        params["cate_type"] = type
        
        guard let url = URL(string: "https://wajincool.appspot.com/categories"), var componenets = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            DispatchQueue.main.async {
                failedCallback()
            }
            return
        }
        
        var queryItems = componenets.queryItems ?? [URLQueryItem]()
        for (key, value) in params {
            if let strValue = value as? String {
                queryItems.append(URLQueryItem(name: key, value: strValue))
            } else if let intValue = value as? NSNumber {
                queryItems.append(URLQueryItem(name: key, value: String(describing: intValue)))
            } else if let values = value as? [String] {
                for value in values {
                    queryItems.append(URLQueryItem(name: key, value: value))
                }
            }
        }
        componenets.queryItems = queryItems
        
        var request = URLRequest(url: componenets.url!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { // check for fundamental networking error
                print("error=\(String(describing: error))")
                DispatchQueue.main.async {
                    failedCallback()
                }
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                DispatchQueue.main.async {
                    failedCallback()
                }
                return
            }
            
            DispatchQueue.main.async {
                successCallback(type, cate)
            }
        }
        task.resume()
    }
    
    func deleteCategory(failedCallback: @escaping (Void) -> Void) {
        DispatchQueue.main.async {
            failedCallback()
        }
    }
    
    func getRecords(yearAndMonth: String, callback: @escaping ([AnyObject]) -> Void) {
        let yearAndMonthArr = yearAndMonth.components(separatedBy: "-")
        let year: String = yearAndMonthArr[0]
        let month: String = yearAndMonthArr[1]
        let params = "select_year=" + year + "&select_month=" + month
        var request = URLRequest(url: URL(string: "https://wajincool.appspot.com/moneyHandle?"+params)!)
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            if let jsonResult = json as? [String: Any] {
                var recordResult = [AnyObject]()
                for content in jsonResult["content"] as? [AnyObject] ?? [] {
                    recordResult.append(content)
                }
                DispatchQueue.main.async {
                    callback(recordResult)
                }
            }
        }
        task.resume()
    }
    
    func addRecord(date: String, cost: Int, category: String, comment: String,
                   successCallback: @escaping (String, String, String, String, String) -> Void,
                   failedCallback: @escaping (Void) -> Void) {
        var params = [String: Any]()
        params["date"] = date
        params["cost"] = cost
        params["category"] = category
        params["comment"] = comment
        
        guard let url = URL(string: "https://wajincool.appspot.com/moneyHandle"), var componenets = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            DispatchQueue.main.async {
                failedCallback()
            }
            return
        }
        
        var queryItems = componenets.queryItems ?? [URLQueryItem]()
        for (key, value) in params {
            if let strValue = value as? String {
                queryItems.append(URLQueryItem(name: key, value: strValue))
            } else if let intValue = value as? NSNumber {
                queryItems.append(URLQueryItem(name: key, value: String(describing: intValue)))
            } else if let values = value as? [String] {
                for value in values {
                    queryItems.append(URLQueryItem(name: key, value: value))
                }
            }
        }
        componenets.queryItems = queryItems
        
        var request = URLRequest(url: componenets.url!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { // check for fundamental networking error
                print("error=\(String(describing: error))")
                DispatchQueue.main.async {
                    failedCallback()
                }
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                DispatchQueue.main.async {
                    failedCallback()
                }
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            if let jsonResult = json as? [String: Any] {
                let category = jsonResult["category"] as! String
                let cateArr = category.components(separatedBy: ".")
                let comment = jsonResult["comment"] as! String
                let cost = jsonResult["cost"] as! String
                let date = jsonResult["date"] as! String
                let id = jsonResult["id"] as! String
                DispatchQueue.main.async {
                    successCallback(id, date, cost, cateArr[1], comment)
                }
            } else {
                DispatchQueue.main.async {
                    failedCallback()
                }
            }
        }
        task.resume()
    }
    
    func updateRecord(id: String, date: String, cost: Int, category: String, comment: String,
                   successCallback: @escaping (String, String, String, String, String) -> Void,
                   failedCallback: @escaping (Void) -> Void) {
        var params = [String: Any]()
        params["date"] = date
        params["cost"] = cost
        params["category"] = category
        params["comment"] = comment
        guard let url = URL(string: "https://wajincool.appspot.com/moneyHandle/\(id)"), var componenets = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            DispatchQueue.main.async {
                failedCallback()
            }
            return
        }
        
        var queryItems = componenets.queryItems ?? [URLQueryItem]()
        for (key, value) in params {
            if let strValue = value as? String {
                queryItems.append(URLQueryItem(name: key, value: strValue))
            } else if let intValue = value as? NSNumber {
                queryItems.append(URLQueryItem(name: key, value: String(describing: intValue)))
            } else if let values = value as? [String] {
                for value in values {
                    queryItems.append(URLQueryItem(name: key, value: value))
                }
            }
        }
        componenets.queryItems = queryItems
        
        var request = URLRequest(url: componenets.url!)
        request.httpMethod = "PUT"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { // check for fundamental networking error
                print("error=\(String(describing: error))")
                DispatchQueue.main.async {
                    failedCallback()
                }
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                DispatchQueue.main.async {
                    failedCallback()
                }
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            if let jsonResult = json as? [String: Any] {
                let category = jsonResult["category"] as! String
                let cateArr = category.components(separatedBy: ".")
                let comment = jsonResult["comment"] as! String
                let cost = jsonResult["cost"] as! String
                let date = jsonResult["date"] as! String
                DispatchQueue.main.async {
                    successCallback(id, date, cost, cateArr[1], comment)
                }
            } else {
                DispatchQueue.main.async {
                    failedCallback()
                }
            }
        }
        task.resume()
    }
    
    func deleteRecord(id: String,
                      successCallback: @escaping (Void) -> Void,
                      failedCallback: @escaping (Void) -> Void) {
        var request = URLRequest(url: URL(string: "https://wajincool.appspot.com/moneyHandle/\(id)")!)
        request.httpMethod = "DELETE"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { // check for fundamental networking error
                print("error=\(String(describing: error))")
                DispatchQueue.main.async {
                    failedCallback()
                }
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                DispatchQueue.main.async {
                    failedCallback()
                }
            } else {
                DispatchQueue.main.async {
                    successCallback()
                }
            }
        }
        task.resume()
    }
}

