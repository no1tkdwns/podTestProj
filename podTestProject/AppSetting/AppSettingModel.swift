//
//  AppSettingModel.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/03/08.
//

import UIKit

public struct AppSettingModel: Decodable{
    var cvs: ASCVS?
    var main: ASMain?
    var advertise: ASAdvertise?
}

struct ASCVS :Decodable{
    var commission: Int
    var exchangeRate: Int
    var onetimeLimit: Int
}

struct ASMain: Decodable{
    var display : ASMainDisplay?
    var menu : ASMainMenu?
}

struct ASMainDisplay: Decodable{
    var card : ASMainDisplayCard?
}

struct ASMainMenu: Decodable{
    var feed: Bool
    var news: Bool
    var invite: Bool
    var cashUse: Bool
    var exchange: Bool
    var roulette: Bool
    var inventory: Bool
    var offerwall: Bool
    var cashAccumulate: Bool
}

struct ASMainDisplayCard: Decodable{
    var cpc: Bool
    var news: Bool
    var invite: Bool
    var ticket: Bool
    var winner: Bool
    var benefit: Bool
    var cashUse: Bool
    var exchange: Bool
    var roulette: Bool
    var offerwall: Bool
}

struct ASAdvertise: Decodable{
    var network : ASAdverNet
    var placement: ASAdverPlace
}

public struct ASAdverNet: Decodable{
    var mobon : NetMobon
    var vungle : NetVungle
    var buzzvil : NetBuzzvil
    var manPlus : NetManPlus
    var igaworks : NetIgaworks
    var unityAds : NetUnityAds
    var mintegral : NetMintegral
}

struct ASAdverPlace: Decodable {
    var inApp : NetInApp
    var rvTicket : NetRvTicket
    var cashButton : NetCashButton
    var cashTicket : NetCashTicket
}

struct NetMobon: Decodable{
    var mediaKey : String
}

struct NetVungle: Decodable{
    var appID: String
}

struct NetBuzzvil : Decodable{
    var popUnitID : String
    var feedUnitID : String
    var nativeUnitID : String
}

struct NetManPlus : Decodable{
    var mediaCode : String
    var publisherCode: String
}

struct NetIgaworks: Decodable{
    var appKey: String
    var hashKey: String
}

struct NetUnityAds: Decodable{
    var gameID: String
}

struct NetMintegral: Decodable{
    var appID: String
    var appKey: String
}

// MARK: - placement

struct NetInApp: Decodable{
    var cpcReward: String
    var linearSSP: String
    var linearNative: String
}

struct NetRvTicket : Decodable{
    var linearSSP : String
    var interstitialOpenSSP : String
    var interstitialCloseSSP : String
    var interstitialOpenVideo : String
    var interstitialOpenNative : String
    var interstitialCloseNative : String
}

struct NetCashButton : Decodable{
    var popupSSP: String
    var popupNative: String
}

struct NetCashTicket: Decodable{
    var popupSSP: String
    var linearSSP: String
    var popupNative: String
    var interstitialOpenSSP: String
    var interstitialCloseSSP: String
    var interstitialOpenVideo: String
    var interstitialOpenNative: String
    var interstitialCloseNative: String
}
