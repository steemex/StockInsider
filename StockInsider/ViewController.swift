//
//  ViewController.swift
//  StockInsider
//
//  Created by Andrey Sinyagin on 26/07/2018.
//  Copyright © 2018 Andrey Sinyagin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var stocks: [Stock]? = []
    var timer: Timer!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBAction func btnRefresh(_ sender: Any) {
        fetchStocks()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
        fetchStocks()
        scheduleRefresh()
    }
    func scheduleRefresh() {
        timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(fetchStocks), userInfo: nil, repeats: true)
    }
}
// Table
extension ViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MainCell
        cell.name.text = self.stocks?[indexPath.item].name
        cell.volume.text = self.stocks?[indexPath.item].volume
        cell.amount.text = self.stocks?[indexPath.item].amount
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stocks?.count ?? 0
    }
}
// Network
extension ViewController {
    @objc func fetchStocks() {
        let urlRequest = URLRequest(url: URL(string: "http://phisix-api3.appspot.com/stocks.json")!)
        activityIndicator.isHidden = false
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print(error as Any)
                return
            }
            self.stocks = [Stock]()
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                if let stocksFromJSON = json["stock"] as? [[String: AnyObject]] {
                    for stockFromJSON in stocksFromJSON {
                        let stock = Stock()
                        if let name = stockFromJSON["name"] as? String {
                            stock.name = name
                        }
                        if let volume = stockFromJSON["volume"] {
                            stock.volume = volume.stringValue
                        }
                        if let amount = stockFromJSON["price"]!["amount"]! as? Double {
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            formatter.maximumFractionDigits = 2
                            let formattedAmount = formatter.string(from: amount as NSNumber)!
                            stock.amount = String(describing: formattedAmount)
                        }
                        self.stocks?.append(stock)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.activityIndicator.isHidden = true
                }
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
}
// Layout
extension ViewController {
    
    
}









