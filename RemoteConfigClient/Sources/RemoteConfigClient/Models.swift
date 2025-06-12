//
//  EditorChoice.swift
//  RemoteConfigClient
//
//  Created by Thanh Hai Khong on 1/4/25.
//

import Foundation

public struct EditorChoice: Identifiable, Codable, Hashable, Sendable {
    public let id = UUID()
    public let appStorePath: String?
    public let caption: String?
    public let description: String?
    public let enabled: Bool
    public let artworkPath: String?
    public let miniIconPath: String?
    public let title: String?
    
    enum CodingKeys: String, CodingKey {
        case appStorePath = "appstore_url"
        case caption
        case description
        case enabled
        case artworkPath = "image_url"
        case miniIconPath = "appicon_url"
        case title
    }
}

extension EditorChoice {
    
    public var artworkURL: URL? {
        guard let urlString = artworkPath else { return nil }
        return URL(string: urlString)
    }
    
    public var miniIconURL: URL? {
        guard let urlString = miniIconPath else { return nil }
        return URL(string: urlString)
    }
    
    public var appStoreURL: URL? {
        guard let urlString = appStorePath else { return nil }
        return URL(string: urlString)
    }
}

extension EditorChoice {
    public static let offlineFiles: EditorChoice = EditorChoice(appStorePath: "https://apps.apple.com/app/id6478867245",
                                                                caption: "New App",
                                                                description: "Downloader • Player • Manager • Browser",
                                                                enabled: true,
                                                                artworkPath: "https://drive.google.com/uc?export=view&id=1pDE_TKWzrqlUhn7YmluYwAHaZZK82Qb-",
                                                                miniIconPath: "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/a8/bf/ed/a8bfed3f-47e0-2694-dc14-ec855cc5ba42/AppIcon-0-0-1x_U007epad-0-0-85-220.jpeg/540x540bb.jpg",
                                                                title: "Offline Files Download Manager")
    
    public static let contacts: EditorChoice = EditorChoice(appStorePath: "https://apps.apple.com/app/id6484267417",
                                                            caption: "New App",
                                                            description: "Transfer • Backup • Share Contacts",
                                                            enabled: true,
                                                            artworkPath: "https://drive.google.com/uc?export=view&id=1t0tEoa_xFqFSG8GBtD_MowQQS1RqeGrv",
                                                            miniIconPath: "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/e3/7e/f5/e37ef519-ff14-3940-2e51-d51548c7b863/AppIcon-0-0-1x_U007epad-0-0-85-220.png/540x540bb.jpg",
                                                            title: "Contacts Backup - Restore - Clean")
    
    
    public static let pixelAI: EditorChoice = EditorChoice(appStorePath: "https://apps.apple.com/app/id6450380621",
                                                           caption: "New App Update",
                                                           description: "AI Effect • AI Removal • AI Edit",
                                                           enabled: true,
                                                           artworkPath: "https://drive.google.com/uc?export=view&id=1MuvWFzgWd9ZLrvIZdLJvf-4eWPSIW4AF",
                                                           miniIconPath: "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/96/65/b5/9665b508-6ac2-b3e4-421a-374642f61494/AppIcon-0-0-1x_U007epad-0-0-85-220.png/540x540bb.jpg",
                                                           title: "PixeAI - AI Video - Photo Editor ")
   
    public static let randonauting: EditorChoice = EditorChoice(appStorePath: "https://apps.apple.com/app/id1616481958",
                                                                caption: "New App Update",
                                                                description: "Go on a Randonauting Advanture.",
                                                                enabled: true,
                                                                artworkPath: "https://drive.google.com/uc?export=view&id=10S1pkFzTpQX46HK6uj2Ses8vL3Zdx7Oe",
                                                                miniIconPath: "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/68/d3/26/68d326a6-3e93-eb47-b6f5-bdc8ac94b9e6/AppIcon-1x_U007emarketing-0-7-0-85-220.png/540x540bb.jpg",
                                                                title: "Randonauting Location Discover")
    
    public static let idPassport: EditorChoice = EditorChoice(appStorePath: "https://apple.co/41PdGCo",
                                                              caption: "New App Update",
                                                              description: "ID Passport • CV Resume Photo",
                                                              enabled: true,
                                                              artworkPath: "https://drive.google.com/uc?export=view&id=1Yqcy7Nm1R5pei1hfJbZIZ4AY8Dga2lDO",
                                                              miniIconPath: "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/3a/7a/8f/3a7a8f33-2f35-1da9-e1fa-3f584659e9a4/AppIcon-0-0-1x_U007epad-0-0-85-220.png/540x540bb.jpg",
                                                              title: "ID Passport - Photo Booth AI")
    
    public static let cartoonPhoto: EditorChoice = EditorChoice(appStorePath: "https://apps.apple.com/app/id1614396365",
                                                                caption: "New App Update",
                                                                description: "Cartoon Photo • AI Cartoon",
                                                                enabled: true,
                                                                artworkPath: "https://drive.google.com/uc?export=view&id=1I1L-xErsZXSoQzlbMw09IeVUusTYK1Xw",
                                                                miniIconPath: "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/2f/e6/a0/2fe6a048-8e46-229e-1ece-1c0fa0c08d05/AppIcon-1x_U007emarketing-0-7-0-85-220.png/540x540bb.jpg",
                                                                title: "Cartoon Photo - AI Cartoon")
    
    public static let compressPhoto: EditorChoice = EditorChoice(appStorePath: "https://apps.apple.com/app/id1615572010",
                                                                 caption: "New App Update",
                                                                 description: "Compress Photo • Save Space",
                                                                 enabled: true,
                                                                 artworkPath: "https://drive.google.com/uc?export=view&id=1piIi2WPzGCHQugVLvp9CCay3bxqBvUcn",
                                                                 miniIconPath: "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/6a/53/90/6a5390db-5e03-b563-d83b-e5ba0f63460d/AppIcon-1x_U007emarketing-0-7-0-85-220-0.png/540x540bb.jpg",
                                                                 title: "Compress Photo - Save Space")
    
    public static let compressVideo: EditorChoice = EditorChoice(appStorePath: "https://apps.apple.com/app/id1615883784",
                                                                 caption: "New App Update",
                                                                 description: "Compress Videos • Shrink Video",
                                                                 enabled: true,
                                                                 artworkPath: "https://drive.google.com/uc?export=view&id=1hS6jW6TThM848IfygDBUlW_yNNPdbc8f",
                                                                 miniIconPath: "https://is1-ssl.mzstatic.com/image/thumb/Purple116/v4/af/bc/f6/afbcf612-6331-7a1f-ffe7-de324e094741/AppIcon-1x_U007emarketing-0-7-0-85-220-0.png/540x540bb.jpg",
                                                                 title: "Compress Videos - Shrink Video")
    
    public static let all = [offlineFiles, contacts, pixelAI, randonauting, idPassport, cartoonPhoto, compressPhoto, compressVideo]
}
