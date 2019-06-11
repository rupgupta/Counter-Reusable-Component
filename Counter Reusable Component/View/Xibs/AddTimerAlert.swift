//
//  AddTimerAlert.swift
//  Counter Reusable Component
//
//  Created by Gupta, Rupali (US - Bengaluru) on 28/05/19.
//  Copyright © 2019 Gupta, Rupali (US - Bengaluru). All rights reserved.
//

import UIKit

/// Updates the choice selected by the user from Alert to ADD TIMER
protocol AddTimerUpdater: class {
    func shouldStartTimer(for seconds : Double)
    func didCancelNewTimer()
}
class AddTimerAlert: UIView {
    
    //MARK: - Outlets
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonStart: UIButton!
    
    //MARK: - Variables
    var hour = 0
    var minutes = 0
    var seconds = 0
    weak var delegate : AddTimerUpdater?
    
    //MARK: - Initial Setup Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setDelegates()
    }
    
    private func setDelegates() {
        self.pickerView.delegate = self
    }
    private func getSeconds() -> Double {
        
        return Double(self.seconds + (self.minutes*60) + (self.hour*3600))
    }
    
    //MARK: - Action Methods
    @IBAction func buttonStartTapped(_ sender: Any) {
        self.removeFromSuperview()
        self.delegate?.shouldStartTimer(for: self.getSeconds())
    }
    
    @IBAction func buttonCancelTapped(_ sender: Any) {
        self.removeFromSuperview()
        self.delegate?.didCancelNewTimer()
    }
}

//MARK: - Picker View Delegates & Datasources
extension AddTimerAlert:UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 25
        case 1,2:
            return 60
            
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width/3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row) hours"
        case 1:
            return "\(row) min"
        case 2:
            return "\(row) sec"
        default:
            return ""
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            hour = row
        case 1:
            minutes = row
        case 2:
            seconds = row
        default:
            break;
        }
    }
    
}
