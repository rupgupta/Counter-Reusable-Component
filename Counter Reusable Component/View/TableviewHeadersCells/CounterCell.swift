//
//  CounterCell.swift
//  Counter Reusable Component
//
//  Created by Gupta, Rupali (US - Bengaluru) on 28/05/19.
//  Copyright © 2019 Gupta, Rupali (US - Bengaluru). All rights reserved.
//

import UIKit
class CounterCell: UITableViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var labelCounter: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonPauseResume: UIButton!
    
    //MARK: - Variables
    var myRow = -1
    var timerModel:NewTimer?
    
    /// Property Observes & changes the UI as according to the state changed
    var timerStatus : TimerStatus = .notStarted {
        didSet {
            self.timerModel?.status = timerStatus
            switch timerStatus {
                
            case .notStarted:
                self.refreshProgressView()
                self.updateData()
                
            case .started, .startAgain:
                self.timerModel?.timeLeftAt = nil
                self.refreshProgressView()
                self.startTimer()
                self.setAnimation()
                self.updateData()
                
            case .inProgress:
                self.startTimer()
                self.updateElapsedSeconds()
                self.setAnimation()
                self.updateData()
                
            case .completed:
                self.setAnimation()
                self.refreshTimer()
                self.updateData()
                
            case .paused:
                self.timerModel?.timeLeftAt = nil
                self.timerModel?.timer?.invalidate()
                self.timerModel?.timer = nil
                self.updateData()
                self.setAnimation()
            }
        }
    }
    
    //MARK: - Initial Setup Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setButtonAppearence()
    }
    
    /// remove the existing timers before dequeuing the cell
    override func prepareForReuse() {
        super.prepareForReuse()
        if let existingTimer = self.timerModel {
            existingTimer.timer?.invalidate()
            existingTimer.timer = nil
        }
    }
    
    private func setButtonAppearence() {
        self.buttonPauseResume.layer.cornerRadius = 5.0
        self.buttonPauseResume.backgroundColor = UIColor(displayP3Red: 63.0/255.0, green: 82.0/255.0, blue: 115.0/255.0, alpha: 1.0)
        self.buttonPauseResume.setTitleColor(UIColor.white, for: .normal)
    }
    //MARK: - Action Methods
    
    /// Action Method to change the state of the timer to run in this particular cell
    ///
    /// - Parameter sender: buttonPauseResume
    @IBAction func buttonPauseResumeTapped(_ sender: UIButton) {
        switch self.timerStatus {
        case  .notStarted:
            self.timerStatus = .started
            
        case .inProgress, .started, .startAgain:
            self.timerStatus = .paused
            
        case .completed:
            self.timerStatus = .startAgain
            
        case .paused:
            self.timerStatus = .inProgress
        }
    }
    
    //MARK: - Data updater Methods
    
    /// Sets up the datasource for the cell & calls the
    /// timerStatus to update cell as per present state
    /// - Parameter withData: model info
    func initialSetUp(withData:NewTimer) {
        self.timerModel = withData
        if let status = withData.status {
            self.timerStatus = status
        }
    }
    
    /// Converts the seconds into hrs, min & sec string
    ///
    /// - Parameter seconds: seconds to be changed in time format
    /// - Returns: formatted time in hrs, min & sec
    private func getConvertedTime(seconds : Int) -> String {
        return "\(seconds / 3600) hr  \((seconds % 3600)/60) min  \((seconds % 3600) % 60) sec"
    }
    
    /// refreshes the progress view by removing all the sublayers from view before starting the animations
    private func refreshProgressView() {
        self.progressView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    /// refresh the timer once the timer is completed & reaches the complete timerStatus
    private func refreshTimer() {
        self.timerModel?.timeLeftAt = nil
        self.timerModel?.timerSeconds = self.timerModel?.totalSeconds
        self.timerModel?.timer?.invalidate()
    }
    
    /// updates the seconds left for timer if this cell was scrolled and now again scrolled to display
    private func updateElapsedSeconds() {
        
        guard let timeLeftAt = self.timerModel?.timeLeftAt else { return }
        self.timerModel?.timeLeftAt = nil
        let components = Calendar.current.dateComponents([.hour,.minute,.second], from: timeLeftAt, to: Date())
        
        guard let hr = components.hour, let min = components.minute, let sec = components.second  else { return }
        let elapsedTime = hr*3600 + min*60 + sec
        if let seconds = self.timerModel?.timerSeconds {
            let sec = seconds - Double(elapsedTime)
            if sec > 0 {
                self.timerModel?.timerSeconds = sec
            } else {
                self.timerModel?.timerSeconds = 0
            }
        }
    }
    
    /// updates the UI Elements of cell
    private func updateData() {
        
        self.labelCounter.text = getConvertedTime(seconds: Int(self.timerModel?.timerSeconds ?? 0.0))
        self.labelStatus.text = self.timerModel?.status?.rawValue
        self.labelTitle.text = "\(self.myRow + 1 )."

        switch self.timerStatus {
        case .notStarted:
            self.buttonPauseResume.setTitle("Start", for: .normal)
            
        case .started, .startAgain :
            self.buttonPauseResume.setTitle("Pause", for: .normal)
            
        case .inProgress:
            self.buttonPauseResume.setTitle("Pause", for: .normal)
            
        case .completed:
            self.buttonPauseResume.setTitle("Start", for: .normal)
            
        case .paused:
            self.buttonPauseResume.setTitle("Resume", for: .normal)
        }
    }
    
    //MARK: - Timer Updater Methods
    
    /// starts a new timer on an interval of 1 second
    private func startTimer()   {
        if self.timerModel?.timer != nil {
            self.timerModel?.timer?.invalidate()
            self.timerModel?.timer = nil
        }
        self.timerModel?.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerUpdater), userInfo: nil, repeats: true)
    }
    
    /// Action Method to update the timerSeconds in model in every 1 second
    @objc private func timerUpdater() {
        if let model = self.timerModel, let sec = model.timerSeconds {
            self.timerModel?.status = .inProgress
            model.timerSeconds = sec - 1.0
            if let totSec = model.totalSeconds, let seconds = model.timerSeconds, totSec - seconds == 1, self.timerStatus != .inProgress {
                self.timerStatus = .inProgress
            }
            if let seconds = model.timerSeconds, seconds <= 0.0 {
                self.timerStatus = .completed
            }
            self.updateData()
            self.timerModel?.timerAnimation?.animate()
        }
    }
    
    //MARK: - Animation Updater Methods
    
    /// sets the animation with progress view
    private func setAnimation() {
        self.refreshProgressView()
        self.timerModel?.timerAnimation = ProgressCircularAnimation()
        self.timerModel?.timerAnimation?.initialSetUp(forSeconds: CGFloat(self.timerModel?.totalSeconds ?? 0.0), forView: self.progressView, arcWidth: self.progressView.frame.width/4)
            self.addInitialLapse()
    }
    
    /// updates the lapsed animation on progress view if this cell was scrolled and now again scrolled to display
    private func addInitialLapse() {
        guard let secondsLeft = self.timerModel?.timerSeconds, let totalTime = self.timerModel?.totalSeconds else {
            return
        }
        if self.timerStatus == .completed {
            self.timerModel?.timerAnimation?.addCompleteProgressView()
        }
        let secondsReached = totalTime - secondsLeft
        if secondsReached > 0 {
            self.timerModel?.timerAnimation?.addProgressWithoutAnimation(secondsReached: CGFloat(secondsReached))
        }
    }
}


