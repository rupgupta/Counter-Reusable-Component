//
//  Timer.swift
//  Counter Reusable Component
//
//  Created by Gupta, Rupali (US - Bengaluru) on 30/05/19.
//  Copyright © 2019 Gupta, Rupali (US - Bengaluru). All rights reserved.
//

import Foundation
enum TimerStatus : String {
    case inProgress = "In Progress"
    case completed = "Completed"
    case paused = "Paused"
    case started = "Started"
    case notStarted = "Not Started"
    case startAgain = "Start Again"
}
class NewTimer {
    
    var timerSeconds: Double?
    var totalSeconds :Double?
    var startTime: Date?
    var timeLeftAt: Date? 
    var status: TimerStatus?
    var timerAnimation : ProgressCircularAnimation?
    var timer: Timer?
    init() {
        
    }
}
