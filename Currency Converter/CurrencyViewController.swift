//
//  CurrencyViewController.swift
//  Currency Converter
//
//  Created by Sankalp Kanungo on 13/11/17.
//  Copyright © 2017 TNS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftChart
import Foundation

class CurrencyViewController: UIViewController, UITextFieldDelegate, ChartDelegate {
    
    @IBOutlet weak var convertTo = UILabel()
    @IBOutlet weak var txtFld = UITextField()
    @IBOutlet weak var myrLabel = UILabel()
    
    @IBOutlet weak var chart = Chart()
    var selectedChart = 0
    var strRate = 0.0
    var strConvertTo = NSString()
    var priceArray = [Float]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        print(self.priceArray)
        
        self.chart?.delegate = self
        let series = ChartSeries(self.priceArray)
        series.color = ChartColors.greenColor()
        self.chart?.add(series)
        self.txtFld?.delegate = self as UITextFieldDelegate
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
        
        let url =  NSString(format: "https://api.fixer.io/2017-11-13?base=MYR&symbols=%@", strConvertTo) as String
        
        
        Alamofire.request(url
            , method: .get, parameters:nil, encoding: URLEncoding.httpBody).responseJSON { response in
                
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Response: \(String(describing: json))")
                    
                    if let json: NSDictionary = response.result.value as? NSDictionary  {
                        print("JSON: \(json)")
                        
                        let currencyData = json.value(forKey:"rates") as! NSDictionary
                        self.strRate = Double(Array(currencyData.allValues)[0] as! Float)
                        self.convertTo?.text =  NSString(format: "%@ = %.2f", self.strConvertTo, self.strRate) as String
                    }else {
                        let alert = UIAlertController(title: "Failed", message: "Failed to load data.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Chart delegate
    
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        for (seriesIndex, dataIndex) in indexes.enumerated() {
            if let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex) {
                print("Touched series: \(seriesIndex): data index: \(dataIndex!); series value: \(value); x-axis value: \(x) (from left: \(left))")
                self.convertTo?.text =  NSString(format: "%@ = %.2f", self.strConvertTo, value) as String
            }
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
    }
    
    //MARK :- TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.txtFld?.becomeFirstResponder()
        
        myrLabel?.text = "\(calculateInterest())"
        
        self.txtFld?.resignFirstResponder()
        
        return true
    }
    
    //MARK :- Calculation
    
    func calculateInterest() -> Double {
        let amount: Double = (txtFld!.text! as NSString).doubleValue
        let rate:Double = strRate
        return amount * rate
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
