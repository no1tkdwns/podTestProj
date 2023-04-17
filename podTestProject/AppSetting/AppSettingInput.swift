//
//  AppSettingInput.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/03/08.
//

import Foundation

public struct AppSettingInput: Encodable {
    public let sdkKey : String?
    
    public init(sdkKey: String?) {
        self.sdkKey = sdkKey
    }
}
