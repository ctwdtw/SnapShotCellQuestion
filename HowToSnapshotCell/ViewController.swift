//
//  ViewController.swift
//  HowToSnapshotCell
//
//  Created by Paul Lee on 2021/3/11.
//

import UIKit

public class SwitchCell: UITableViewCell {
    public let switchBtn = UISwitch()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        switchBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        contentView.addSubview(switchBtn)
    }
}

public class ViewController: UIViewController, UITableViewDataSource {
    public let switchBtn = UISwitch()
    public let tableView = UITableView()
    public override func viewDidLoad() {
        //
        view.backgroundColor = .red
        
        //
        switchBtn.frame = CGRect(x: 0, y: 100, width: 50, height: 50)
        view.addSubview(switchBtn)
        
        //
        tableView.frame = CGRect(x: 0, y: 160, width: 200, height: 200)
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return SwitchCell()
    }
    
}
