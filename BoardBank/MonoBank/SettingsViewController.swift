//
//  SettingsViewController.swift
//  MonoBank
//
//  Created by Richard Neitzke on 04/01/2017.
//  Copyright © 2017 Richard Neitzke. All rights reserved.
//

import UIKit
import SafariServices

class SettingsViewController: UITableViewController, UITextFieldDelegate {
  
  @IBOutlet var currencyTextField: UITextField!
  @IBOutlet var defaultBalanceTextField: UITextField!
  @IBOutlet var quickAddTextField: UITextField!
  @IBOutlet var soundsEnabledSwitch: UISwitch!
  
  @IBOutlet var defaultBalanceCurrencyLabel: UILabel!
  @IBOutlet var quickAddCurrencyLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    soundsEnabledSwitch.isOn = BankManager.shared.soundsEnabled
    refreshText()
  }
  
  func refreshText() {
    currencyTextField.text = BankManager.shared.currencySymbol
    currencyTextField.placeholder = BankManager.shared.currencySymbol
    defaultBalanceCurrencyLabel.text = BankManager.shared.currencySymbol
    quickAddCurrencyLabel.text = BankManager.shared.currencySymbol
    
    defaultBalanceTextField.text = String(BankManager.shared.defaultBalance)
    defaultBalanceTextField.placeholder = String(BankManager.shared.defaultBalance)
    quickAddTextField.text = String(BankManager.shared.quickAddAmount)
    quickAddTextField.placeholder = String(BankManager.shared.quickAddAmount)
  }
  
  @IBAction func currencyTextFieldChanged(_ sender: UITextField) {
    let currencySymbol = sender.text!
    defaultBalanceCurrencyLabel.text = currencySymbol
    quickAddCurrencyLabel.text = currencySymbol
  }
  
  @IBAction func currencyTextFieldAction(_ sender: Any) {
    defaultBalanceTextField.becomeFirstResponder()
  }
  
  // MARK: - TableView
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    switch Section(rawValue: indexPath.section) {
    case .some(.tableViewSection):
      switch TableViewSection(rawValue: indexPath.row) {
      case .some(.saveSettings):
        // Save Settings
        if !currencyTextField.text!.isEmpty {
          BankManager.shared.currencySymbol = currencyTextField.text!
        }
        if let defaultBalance = Int(defaultBalanceTextField.text!) {
          BankManager.shared.defaultBalance = defaultBalance
        }
        if let quickAddAmount = Int(quickAddTextField.text!) {
          BankManager.shared.quickAddAmount = quickAddAmount
        }
        BankManager.shared.soundsEnabled = soundsEnabledSwitch.isOn
        BankManager.shared.save()
        refreshText()
        let mainViewController = navigationController!.viewControllers.first as! MainViewController
        mainViewController.playerCollectionView.reloadData()
        navigationController?.popViewController(animated: true)
      case .some(.newGame):
        // New Game
        let warningAlertController = UIAlertController(title: "Are you sure?", message: "By starting a new game you will lose all of your current game data.", preferredStyle: .alert)
        let resetAction = UIAlertAction(title: "New Game", style: .destructive, handler: { action in
          BankManager.shared.players = [Player]()
          BankManager.shared.save()
          let mainViewController = self.navigationController?.viewControllers.first as! MainViewController
          mainViewController.playerCollectionView.reloadData()
          mainViewController.playerNumberChanged()
          self.navigationController?.popViewController(animated: true)
        })
        warningAlertController.addAction(resetAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        warningAlertController.addAction(cancelAction)
        present(warningAlertController, animated: true)
      default:
        break
      }
    case .some(.information):
      switch Information(rawValue: indexPath.row) {
      case .some(.contact):
        // Contact
        let mailURL = URL(string: "mailto:richardneitzke.rn+MonoBank@gmail.com")!
        UIApplication.shared.openURL(mailURL)
      case .some(.iconSource):
        // Icons8
        let safariVC = SFSafariViewController(url: URL(string: "https://icons8.com")!)
        present(safariVC, animated: true, completion: nil)
      default:
        break
      }
    default:
      break
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension SettingsViewController {
  
  private enum Section: Int {
    case settings
    case tableViewSection
    case information
    
    init?(indexPath: IndexPath) {
      self.init(rawValue: indexPath.section)
    }
    
    static var numberOfSections: Int { return 3 }
  }
  
  private enum Settings: Int {
    case currency
    case defaultBalance
    case quickAddAmount
    case enableSounds
    
    init?(indexPath: IndexPath) {
      self.init(rawValue: indexPath.section)
    }
    
    static var numberOfSections: Int { return 4 }
  }
  
  private enum TableViewSection: Int {
    case saveSettings
    case newGame
    
    init?(indexPath: IndexPath) {
      self.init(rawValue: indexPath.section)
    }
    
    static var numberOfSections: Int { return 2 }
  }
  
  private enum Information: Int {
    case developer
    case contact
    case iconSource
    
    init?(indexPath: IndexPath) {
      self.init(rawValue: indexPath.section)
    }
    
    static var numberOfSections: Int { return 3 }
  }
  
}
