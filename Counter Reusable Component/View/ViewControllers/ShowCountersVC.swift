//
//  ViewController.swift
//  Counter Reusable Component
//
//  Created by Gupta, Rupali (US - Bengaluru) on 28/05/19.
//  Copyright © 2019 Gupta, Rupali (US - Bengaluru). All rights reserved.
//

import UIKit
/// To update the counters when app resigns active state & becomes active again:
/// App in Background state handling
protocol AppDelegateUpdater: class {
    func applicationWillResignActive()
    func applicationDidBecomeActive() 
}
class ShowCountersVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableviewCounter: UITableView!
    
    //MARK: - Variables
    
    /// model containing datasource for the timers
    var timers = [NewTimer]()

    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetUp()
    }
   
    //MARK: - Initial Set up Methods
    
    /// Sets up the view after view is loaded
    private func initialSetUp() {
        self.registerViews()
        self.setTableview()
        self.setDelegates()
    }
    
    /// Sets datasource, delegates & height of Tableview
    private func setTableview() {
        self.tableviewCounter.dataSource = self
        self.tableviewCounter.delegate = self
        
        self.tableviewCounter.estimatedRowHeight = 50.0
        self.tableviewCounter.rowHeight = 50.0
    }
    
    /// Registers the Xibs for tableview
    private func registerViews() {
        self.tableviewCounter.register(UINib(nibName: "CounterSectionView", bundle: nil), forHeaderFooterViewReuseIdentifier: "CounterSectionView")
        self.tableviewCounter.register(UINib(nibName: "CounterCell", bundle: nil), forCellReuseIdentifier: "CounterCell")
    }
    
    /// Sets the delegate for view controller
    private func setDelegates() {
        (UIApplication.shared.delegate as! AppDelegate).delegateTimeUpdater = self
    }
    //MARK: - View Update Methods
    
    /// Adds the alert asking for hours, min & sec for the timer
    private func addAlert() {
        if let alertView = Bundle.main.loadNibNamed("AddTimerAlert", owner: self, options: nil), let addAlertView = alertView[0] as? AddTimerAlert {
            addAlertView.frame = self.view.frame
            addAlertView.delegate = self
            self.view.addSubview(addAlertView)
        }
    }
    
    //MARK: - Timer Updater Methods
    
    private func startTimer(for seconds: Double) {
        let newTimer = NewTimer()
        newTimer.startTime = Date()
        newTimer.timerSeconds = seconds
        newTimer.totalSeconds = seconds
        newTimer.status = .notStarted
        self.timers.append(newTimer)
       
        let indexPath = IndexPath(row: self.timers.count-1, section: 0)
        tableviewCounter.beginUpdates()
        tableviewCounter.insertRows(at: [indexPath], with: .automatic)
        tableviewCounter.endUpdates()
    }
    
    
    //MARK: - Action Methods
    
    /// Action Method for Add Timer button in Tableview header
    ///
    /// - Parameter sender: Add Button
    @objc func buttonAddTimerTapped(sender: UIButton) {
        self.addAlert()
    }
}
//MARK: - Add Timer Alert Delegate

/// Updates the choice selected by the user from Alert to ADD TIMER
extension ShowCountersVC : AddTimerUpdater {
    
    /// Delegate method to notify to start the timer on time given by user
    ///
    /// - Parameter seconds: seconds to start timer for
    func shouldStartTimer(for seconds: Double) {
        self.startTimer(for: seconds)
    }
    
    /// Delegate method to notify to not apply any new timer
    func didCancelNewTimer() {
        // any update on UI etc to do in fututre
    }
}

//MARK: - Tableview Datasource & Delegate
extension ShowCountersVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CounterCell", for: indexPath) as? CounterCell else { fatalError("CounterCell could not be dequeued")
        }
        let model = self.timers[indexPath.row]
        cell.myRow = indexPath.row
        cell.initialSetUp(withData: model)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = Bundle.main.loadNibNamed("CounterSectionView", owner: self, options: nil)?[0], let counterSectionView = headerView as? CounterSectionView {
            
            counterSectionView.buttonAdd.addTarget(self, action: #selector(buttonAddTimerTapped), for: .touchUpInside)
            return counterSectionView
        }
        return nil
    }
    /// to save time when the timer cell is no longer displayed and will be reused by other cell
    ///
    /// - Parameters:
    ///   - tableView: tableViewCounter
    ///   - cell: CounterCell
    ///   - indexPath: indexPath
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.timers[indexPath.row].timeLeftAt = Date()
    }
}
//MARK: - App in Background case Handler Methods
extension ShowCountersVC : AppDelegateUpdater {
    func applicationWillResignActive() {
        UserDefaults.standard.set(Date(), forKey: "dateIsSet")
        
    }
    func applicationDidBecomeActive() {
        if let anyVal = UserDefaults.standard.value(forKey: "dateIsSet"), let date = anyVal as? Date {
            for count in 0..<self.timers.count {
                let element = self.timers[count]
                if element.status == .started || element.status == .startAgain || element.status == .inProgress {
                    element.timeLeftAt = date
                    if element.timer != nil, let cell = self.tableviewCounter.cellForRow(at: IndexPath(row: count, section: 0)) as? CounterCell, let status = element.status {
                        cell.timerStatus = status
                    }
                }
            }
        }
    }
}
