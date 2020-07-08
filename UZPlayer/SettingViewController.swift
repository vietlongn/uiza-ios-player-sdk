//
//  SettingViewController.swift
//  UZPlayerExample
//
//  Created by Nam Nguyen on 7/3/20.
//  Copyright © 2020 Nam Kennic. All rights reserved.
//

import UIKit
import AVFoundation

public class SettingViewController: UIViewController {
    private let withNavigationButton: Bool
    private var settingItems: [SettingItem]?
    private var defaultValue: Any? = nil
    private let text: String?
    private var tableView = UITableView()
    open weak var delegate: UZSettingViewDelegate?

    init(withNavigationButton: Bool, text: String? = nil, settingItems: [SettingItem]? = nil, defaultValue: Any? = nil) {
        self.withNavigationButton = withNavigationButton
        self.text = text
        self.settingItems = settingItems
        super.init(nibName: nil, bundle: nil)
        self.title = text
        self.defaultValue = defaultValue
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: "setting_row")
//        let contentView = UIView.makeView(withTitle: text)
//        view.backgroundColor = tableView?.backgroundColor
        view.addSubview(tableView)
        tableView.separatorColor = UIColor.clear
        tableView.estimatedRowHeight = 46.0
        let contentHeight: CGFloat = 46.0 + 46.0 * CGFloat(self.settingItems?.count ?? 0 + 1)
        tableView.isScrollEnabled = (tableView.contentSize.height >= contentHeight)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: contentHeight),
        ])

        preferredContentSize.height = contentHeight

//        if withNavigationButton {
//            let button = UIButton(type: .system)
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
//            button.setTitle("Next", for: .normal)
//            button.setTitleColor(.white, for: .normal)
//            button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
//            view.addSubview(button)
//
//            NSLayoutConstraint.activate([
//                button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                button.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
//            ])
//        }
    }
//    @objc private func handleButtonTap() {
//        let viewController = SettingViewController(withNavigationButton: false, contentHeight: contentHeight)
//        viewController.title = "Step 2"
//        navigationController?.pushViewController(viewController, animated: true)
//    }
}

extension SettingViewController : UITableViewDelegate, UITableViewDataSource {
        
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingItems?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "setting_row", for: indexPath) as! SettingTableViewCell
        if let settingItem = self.settingItems?[indexPath.row] {
            cell.titleLabel.text = settingItem.title
            switch settingItem.type {
            case .bool:
                let toogle = UISwitch(frame: CGRect.zero)
                toogle.tag = settingItem.tag.rawValue
                toogle.isOn = settingItem.initValue as? Bool ?? false
                toogle.addTarget(self, action: #selector(onToggleAction(_:)), for: .valueChanged)
                cell.accessoryView = toogle
                break
            case .number:
                var checked : Bool = false
                if settingItem.tag == .speedRate {
                    let dv = (self.defaultValue as? Float) ?? UZSpeedRate.normal.rawValue
                    let iv =  (settingItem.initValue as? Float) ?? UZSpeedRate.normal.rawValue
                    checked = (dv == iv)
                } else if settingItem.tag == .audio || settingItem.tag == .captions {
                    if let dv = self.defaultValue as? AVMediaSelectionOption,
                        let iv = settingItem.initValue as? AVMediaSelectionOption {
                        checked = (dv == iv)
                    }
                }
                let checkIcon = UIImage(icon:  checked ? .fontAwesomeSolid(.dotCircle) : .fontAwesomeRegular(.circle), size: CGSize(width: 22, height: 22), textColor: checked ? UIColor.red : UIColor.gray, backgroundColor: .clear)
                            let accessorCheckView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
                            accessorCheckView.image = checkIcon
                            cell.accessoryView = accessorCheckView
                break
            case .array:
                let arrowIcon = UIImage(icon: .fontAwesomeSolid(.caretRight), size: CGSize(width: 22, height: 22), textColor: UIColor.gray, backgroundColor: .clear)
                let accessorView = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
                accessorView.image = arrowIcon
                cell.accessoryView = accessorView
                if settingItem.tag == .speedRate {
                    let dv = UZSpeedRate (rawValue: (settingItem.initValue as? Float) ?? UZSpeedRate.normal.rawValue) ?? UZSpeedRate.normal
                    cell.summaryLabel.text = dv.description
                } else if settingItem.tag == .audio || settingItem.tag == .captions {
                    if let dv = settingItem.initValue as? AVMediaSelectionOption {
                        cell.summaryLabel.text = dv.displayName
                    }
                }
                break
            default:
                break
            }
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let settingItem = self.settingItems?[indexPath.row] {
            let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
            switch settingItem.type {
            case .bool:
                let toggle = (currentCell.accessoryView as! UISwitch)
                toggle.isOn = !toggle.isOn
                self.delegate?.settingRow(didChanged: toggle)
                setNeedsFocusUpdate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // 500 milliseconds.
                     self.dismiss(animated: true, completion: nil)
                  }
                break
            case .number:
                if settingItem.tag == .speedRate {
                    self.delegate?.settingRow(didSelected: .speedRate, value: settingItem.initValue as! Float)
                } else if settingItem.tag == .audio || settingItem.tag == .captions {
                    self.delegate?.settingRow(didSelected: settingItem.tag, value: settingItem.initValue as! AVMediaSelectionOption)
                }
                setNeedsFocusUpdate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // 500 milliseconds.
                     self.dismiss(animated: true, completion: nil)
                  }
                break
            case .array:
                if settingItem.tag == .speedRate {
                    let settingRates = UZSpeedRate.allCases.map{ SettingItem(title: $0.description, tag: .speedRate, type: .number, initValue: $0.rawValue) }
                    let viewController = SettingViewController(withNavigationButton: false, text: currentCell.textLabel?.text ?? "", settingItems: settingRates, defaultValue: settingItem.initValue)
                    viewController.delegate = self.delegate
                    viewController.title = currentCell.textLabel?.text ?? ""
                    navigationController?.pushViewController(viewController, animated: true)
                } else if settingItem.tag == .audio || settingItem.tag == .captions {
                    if let audioOptions = settingItem.childItems {
                        let settingAudios = audioOptions.map{ SettingItem(title: $0.displayName, tag: settingItem.tag, type: .number, initValue: $0) }
                        let viewController = SettingViewController(withNavigationButton: false, text: settingItem.tag.description, settingItems: settingAudios, defaultValue: settingItem.initValue)
                                viewController.delegate = self.delegate
                                viewController.title = settingItem.tag.description
                                navigationController?.pushViewController(viewController, animated: true)
                    }
                }
             
                break
            default:
                self.delegate?.settingRow(didSelected: settingItem.tag, value: 1.0)
                break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let settingItem = self.settingItems?[indexPath.row] {
            let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
            switch settingItem.type {
            case .number:
                let checkIcon = UIImage(icon:   .fontAwesomeSolid(.dotCircle), size: CGSize(width: 22, height: 22), textColor: UIColor.red, backgroundColor: .clear)
                let accessorCheckView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
                accessorCheckView.image = checkIcon
                currentCell.accessoryView = accessorCheckView
                break
            default:
                break
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let settingItem = self.settingItems?[indexPath.row] {
            let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
            switch settingItem.type {
            case .number:
                let checkIcon = UIImage(icon: .fontAwesomeRegular(.circle), size: CGSize(width: 22, height: 22), textColor: UIColor.gray, backgroundColor: .clear)
                let accessorCheckView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
                accessorCheckView.image = checkIcon
                currentCell.accessoryView = accessorCheckView
                break
            default:
                break
            }
        }
    }
    
    @objc open func onToggleAction(_ sender: UISwitch) {
        self.delegate?.settingRow(didChanged: sender)
    }
}