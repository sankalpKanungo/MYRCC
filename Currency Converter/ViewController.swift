//
//  ViewController.swift
//  Currency Converter
//
//  Created by Sankalp Kanungo on 13/11/17.
//  Copyright © 2017 TNS. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView : UITableView!
    var refreshControl: UIRefreshControl!
    var currencyList = NSDictionary()
    var searchActive : Bool = false
    var filtered:[String] = []
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        let image = UIImage(named: "header")
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : Any]
        let attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 28)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.navigationController?.navigationBar.setBackgroundImage(image,for: .default)
        
        // Pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action:  #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        scheduledTimerWithTimeInterval()
        Alamofire.request("https://api.fixer.io/latest?base=MYR"
            , method: .get, parameters:nil, encoding: URLEncoding.httpBody).responseJSON { response in
                
                if let data = response.data {
                    _ = String(data: data, encoding: String.Encoding.utf8)
                    
                    if let json: NSDictionary = response.result.value as? NSDictionary  {
                        self.currencyList = json.value(forKey:"rates") as! NSDictionary
                        self.tableView.reloadData()
                        
                    }else {
                        let alert = UIAlertController(title: "Failed", message: "Failed to load data.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }
        }
    }
    
    func scheduledTimerWithTimeInterval(){
        
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    func updateCounting(){
        NSLog("counting..")
        self.viewDidAppear(true)
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        self.viewDidAppear(true)
        self.refreshControl?.endRefreshing()
    }
    
    //*****MARK :- SEARCHBARDELEGATES
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() //hide keyboard
        
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let data = Array(self.currencyList.allKeys)
        filtered = data.filter({ (text) -> Bool in
            let tmp: NSString = text as! NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        }) as! [String]
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
        
    }
    
    //*****MARK :- TABLEVIEWDELEGATES
    // MARK: - TableView Delegate Method
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive && filtered.count != 0) {
            return filtered.count
        }
        return currencyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "CellCurrencyList") as UITableViewCell!
        let countryLbl =  cell.viewWithTag(101) as? UILabel
        let rateLbl =  cell.viewWithTag(102) as? UILabel
        
        if(searchActive && filtered.count != 0){
            let name : NSString = filtered[indexPath.row] as NSString
            countryLbl!.text = name as String
            let rate = self.currencyList.value(forKey: name as String) as? Double
            rateLbl!.text = NSString(format: "%.2f", rate!) as String
        } else {
            
            
            let country = Array(self.currencyList.allKeys)[indexPath.row]
            countryLbl?.text = country as? String
            
            let rates : Float = Array(self.currencyList.allValues)[indexPath.row] as! Float
            
            rateLbl?.text = NSString(format: "%.2f", rates) as String
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc =  self.storyboard?.instantiateViewController(withIdentifier: "CurrencyViewController") as! CurrencyViewController
        if(searchActive && filtered.count != 0){
            
            vc.strConvertTo = filtered[indexPath.row] as NSString
        } else {
            vc.strConvertTo = Array(self.currencyList.allKeys)[indexPath.row] as! NSString
        }
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        var days = [Int]()
        var dateAry = [String]()
        for _ in 1 ... 7 {
            let day = cal.component(.day, from: date)
            days.append(day)
            date = cal.date(byAdding: .day, value: -1, to: date)!
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let convertedDateString = dateFormatter.string(from: date)
            let dateField : String!
            dateField = convertedDateString as String
            
            print(convertedDateString)
            print(dateField)
            
            dateAry.append(convertedDateString)
            print(dateAry)
        }
        print(days)
        
        
        var i = 0
        while i < days.count {
            
            let date = dateAry[i]
            let url = NSString(format: "https://api.fixer.io/%@?base=MYR", date) as String
            
            Alamofire.request(url, method: .get, parameters:nil, encoding: URLEncoding.httpBody).responseJSON { response in
                
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Response: \(String(describing: json))")
                    print(response.result.value as Any)
                    
                    if let json: NSDictionary = response.result.value as? NSDictionary  {
                        let currencyList : NSDictionary = json.value(forKey:"rates") as! NSDictionary
                        let price = currencyList.object(forKey:vc.strConvertTo as String)!
                        vc.priceArray.append(price as! Float)
                        print(vc.priceArray)
                        if vc.priceArray.count == 7 {
                            self.searchActive = false
                            self.navigationController?.pushViewController(vc, animated: false)
                            //Cancel requests
                            Alamofire.SessionManager.default.session.getAllTasks { (tasks) in
                                
                                tasks.forEach({$0.cancel()})
                            }
                            
                            
                            self.timer.invalidate()
                        }
                    }else {
                        let alert = UIAlertController(title: "Login", message: "Failed", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }
            }
            i += 1
        }
        
        print(vc.priceArray)
        
    }
    
}

