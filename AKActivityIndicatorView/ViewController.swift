//
//  ViewController.swift
//  AKActivityIndicatorView
//
//  Created by wangcong on 2018/9/16.
//  Copyright © 2018年 wangcong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let tableView = UITableView(frame: CGRect.zero, style: .plain)
    let headerView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 260))
    let indicatorView = AKActivityIndicatorView(frame: CGRect.zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        headerView.image = UIImage(named: "header_bg")
        headerView.contentMode = .scaleAspectFill
        headerView.clipsToBounds = true
        view.addSubview(headerView)
        
//        indicatorView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        indicatorView.center = CGPoint(x: headerView.bounds.size.width / 2.0, y: headerView.bounds.size.height / 2.0)
//        indicatorView.transform = CGAffineTransform(scaleX: 2, y: 2)
        view.addSubview(indicatorView)


        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "identifier")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.frame = CGRect(x: 0, y: 260, width: view.bounds.size.width, height: view.bounds.size.height - 260)
        view.addSubview(tableView)
        
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath)
        cell.textLabel?.text = "第  \(indexPath.row)  行"
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.contentOffset.y > -50 && scrollView.contentOffset.y < 0 && !indicatorView.isAnimating {
            headerView.frame = CGRect(x: 0, y: scrollView.contentOffset.y, width: headerView.frame.size.width, height: 260 - scrollView.contentOffset.y)
            
            let delta = -scrollView.contentOffset.y / 50
            indicatorView.strokeEnd = min(delta, 1)
        }
        
        if scrollView.contentOffset.y < -51 {
            _startAnimation()
        }
    }
    
}

extension ViewController {
    
    func _startAnimation() {
        indicatorView.strokeEnd = 1.0
        indicatorView.startAnimation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) { [weak self] () in
            self?._stopAnimation()
        }
    }
    
    func _stopAnimation() {
        indicatorView.stopAnimation()
        indicatorView.strokeEnd = 0.0
    }
}
