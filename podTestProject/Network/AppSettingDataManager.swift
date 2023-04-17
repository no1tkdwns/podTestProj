//
//  AppSettingDataManager.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/03/08.
//

import Foundation
import Alamofire

public class AppSettingDataManager{
    public init(){
        
    }
    
    public func AppSettingDataManger(parameters: AppSettingInput, completion: @escaping (AppSettingModel) -> Void){
        let header : HTTPHeaders = ["Authorization": "Basic OThkNGQ0YzM1ZDU5NDQ1MWIyMWY1NDcxOGUyYmM5ODY6YzM5NWRiZTIwMGFkNDQ5M2FkZTk2ZmI5MmM5ODhmY2YxYzhkZjJkMzY4N2Q0OWE5YWI2ZjMxZjdjMDVlMmJmNA=="]

        AF.request(APIConstants.appSettingURL,
                   method: .get,
                   parameters: parameters,
                   headers: header).validate().responseDecodable(of: AppSettingModel.self) { response in
            switch response.result{
            case .success(let result):
                print("LIM: Success")
                print(result.advertise?.network.buzzvil ?? "")
                completion(result)
            case .failure(let error):
                print("LIM:L APPPSETTIgn")
                print("LIM: \(error)")
            }
        }
        
    }
}

