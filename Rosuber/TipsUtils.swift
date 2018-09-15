//
//  TipsUtils.swift
//  Rosuber
//
//  Created by FengYizhi on 2018/5/14.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit

class TipsUtils: NSObject {
    
    static func getRandomTips() -> String {
        let tips = ["Rosuber is a rideshare app designated for Rose-Hulman students.",
                    "Update your phone number in Profile page so that others can text you.",
                    "You can upload your profile image in Profile page.",
                    "View all the trips you did and will participate in My Trips page.",
                    "There might be an available trip for you before you create one.",
                    "Create a new trip in Find Trips page",
                    "Have questions for us? Contact us in About page.",
                    "You can contact the driver and/or passenger(s) in a trip in Trip Detail page.",
                    "Contact your trip member(s) when you join or leave the trip."]
        
        let randomIndex = Int(arc4random_uniform(UInt32(tips.count)))
        return tips[randomIndex]
    }
    
}
