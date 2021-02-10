//
//  MainViewController.swift
//  IASKSampleAppStaticLibrary
//
//  Created by Ortwin Gentz on 07.05.20.
//

import UIKit

class MainViewController: UIViewController {

	var settingsViewController: IASKAppSettingsViewController?
	var tabSettingsViewController: IASKAppSettingsViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

		if let nc = tabBarController?.viewControllers?.last as? UINavigationController,
			let tabASVC = nc.topViewController as? IASKAppSettingsViewController
		{
			tabASVC.delegate = self
			tabSettingsViewController = tabASVC
		}
		updateHiddenKeys()
    
		NotificationCenter.default.addObserver(self, selector: #selector(settingDidChange(notification:)), name: Notification.Name.IASKSettingChanged, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
    
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		if let nc = segue.destination as? UINavigationController,
			let settingsVC = nc.topViewController as? IASKAppSettingsViewController
		{
			settingsVC.delegate = self
			settingsVC.showDoneButton = segue.identifier == "modal"
			settingsViewController = settingsVC
		} else if let settingsVC = segue.destination as? IASKAppSettingsViewController{
			settingsVC.delegate = self
			settingsViewController = settingsVC
		} else {
			print("unknown segue destination")
		}
		updateHiddenKeys()
	}
		
	@objc func settingDidChange(notification: Notification?) {
		updateHiddenKeys()
	}
	func updateHiddenKeys() {
		var hiddenKeys = Set<String>()
		if UserDefaults.standard.bool(forKey: "AutoConnect") {
			hiddenKeys.formUnion(["AutoConnectLogin", "AutoConnectPassword", "loginOptions"])
		}
		if !UserDefaults.standard.bool(forKey: "ShowAccounts") {
			hiddenKeys.insert("accounts")
		}
		settingsViewController?.setHiddenKeys(hiddenKeys, animated: true)
		tabSettingsViewController?.setHiddenKeys(hiddenKeys, animated: true)
	}
}

extension MainViewController: IASKSettingsDelegate {
	func settingsViewControllerDidEnd(_ settingsViewController: IASKAppSettingsViewController) {
		dismiss(animated: true, completion: nil)
	}
	
	func settingsViewController(_ settingsViewController: IASKAppSettingsViewController,
								validate specifier: IASKSpecifier,
								textField: IASKTextField,
								previousValue: String?,
								replacement: AutoreleasingUnsafeMutablePointer<NSString>?) -> IASKValidationResult {
		guard let key = specifier.key else { return .ok }
		if key.starts(with: "RegexValidation") {
			if textField.text == "" || textField.text?.range(of: #".+\@.+"#, options: .regularExpression) != nil {
				if #available(iOS 13.0, *) {
					textField.textColor = .label
				} else {
					textField.textColor = .darkText
				}
				return .ok
			}
			if key != "RegexValidation2" {
				let myReplacement: String = ((previousValue?.lengthOfBytes(using: .utf8) ?? 0) > 0 ? previousValue : textField.text) ?? ""
				replacement?.pointee = myReplacement as NSString
				return .failedWithShake
			}
			textField.textColor = .red
			return .failed
		}
		return .ok
	}
		
	func settingsViewController(_ settingsViewController: UITableViewController & IASKViewController, heightForHeaderInSection section: Int, specifier: IASKSpecifier) -> CGFloat {
		switch specifier.key {
		case "IASKLogo":
			return UIImage(named: "Icon.png")?.size.height ?? 0 + 25
		case "IASKCustomHeaderStyle":
			return 55
		default:
			return 0
		}
	}
	
	func settingsViewController(_ settingsViewController: UITableViewController & IASKViewController, viewForHeaderInSection section: Int, specifier: IASKSpecifier) -> UIView? {
		switch specifier.key {
		case "IASKLogo":
			let imageView = UIImageView(image: UIImage(named: "Icon.png"))
			imageView.contentMode = .center
			return imageView
		case "IASKCustomHeaderStyle":
			let label = UILabel()
			label.backgroundColor = .clear
			label.textAlignment = .center
			label.textColor = .red
			label.shadowColor = .white
			label.shadowOffset = CGSize(width: 0, height: 1)
			label.numberOfLines = 0
			label.font = .boldSystemFont(ofSize: 16)
			label.text = settingsViewController.settingsReader?.title(forSection: section)
			return label
		default:
			return nil
		}
	}
	
	func settingsViewController(_ settingsViewController: UITableViewController & IASKViewController, titleForHeaderInSection section: Int, specifier: IASKSpecifier) -> String? {
		switch specifier.key {
		case "CUSTOM_HEADER_FOOTER":
			return "Custom header title"
		default:
			return nil
		}
	}
	
	func settingsViewController(_ settingsViewController: UITableViewController & IASKViewController, heightForFooterInSection section: Int, specifier: IASKSpecifier) -> CGFloat {
		switch specifier.key {
		case "IASKLogo":
			return UIImage(named: "Icon.png")?.size.height ?? 0 + 25
		default:
			return 0
		}
	}
	
	func settingsViewController(_ settingsViewController: UITableViewController & IASKViewController, viewForFooterInSection section: Int, specifier: IASKSpecifier) -> UIView? {
		switch specifier.key {
		case "IASKLogo":
			let imageView = UIImageView(image: UIImage(named: "Icon.png"))
			imageView.contentMode = .center
			return imageView
		default:
			return nil
		}
	}
	
	func settingsViewController(_ settingsViewController: UITableViewController & IASKViewController, titleForFooterInSection section: Int, specifier: IASKSpecifier) -> String? {
		switch specifier.key {
		case "CUSTOM_HEADER_FOOTER":
			return "Custom footer title"
		default:
			return nil
		}
	}
	
	func settingsViewController(_ settingsViewController: UITableViewController & IASKViewController, heightFor specifier: IASKSpecifier) -> CGFloat {
		switch specifier.key {
		case "customCell":
			return 44 * 3
		default:
			return UITableView.automaticDimension
		}
	}
	
	func settingsViewController(_ settingsViewController: UITableViewController & IASKViewController, cellFor specifier: IASKSpecifier) -> UITableViewCell? {
		if specifier.parent?.key == "accounts" {
			let cell = settingsViewController.tableView.dequeueReusableCell(withIdentifier: "accountCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "accountCell")
			if let dict = settingsViewController.settingsStore.object(for: specifier) as? [String: AnyObject] {
				cell.textLabel?.text = dict["username"] as? String
				cell.detailTextLabel?.text = dict["email"] as? String
			}
			cell.accessoryType = .disclosureIndicator
			return cell
		}
		let cell = settingsViewController.tableView.dequeueReusableCell(withIdentifier: specifier.key!) as? CustomViewCell ?? Bundle.main.loadNibNamed("CustomViewCell", owner: self, options: nil)?.first as! CustomViewCell
		cell.textView.text = settingsViewController.settingsStore.object(for: specifier) as? String
		cell.textView.delegate = self
		cell.setNeedsLayout()
		return cell
	}
	
	func settingsViewController(_ settingsViewController: IASKAppSettingsViewController, valuesFor specifier: IASKSpecifier) -> [Any] {
		return specifier.key == "countryCode" ? Locale.isoRegionCodes : []
	}
	
	func settingsViewController(_ settingsViewController: IASKAppSettingsViewController, titlesFor specifier: IASKSpecifier) -> [Any] {
		if specifier.key == "countryCode" {
			return Locale.isoRegionCodes.map{Locale.current.localizedString(forRegionCode: $0) ?? ""}
		}
		return []
	}
	
	func settingsViewController(_ settingsViewController: IASKAppSettingsViewController, childPaneIsValidFor specifier: IASKSpecifier, contentDictionary: NSMutableDictionary) -> Bool {
		if specifier.parent?.key == "accounts" {
			guard let roleUser = contentDictionary["roleUser"] as? Bool,
				let roleEditor = contentDictionary["roleEditor"] as? Bool,
				let roleAdmin = contentDictionary["roleAdmin"] as? Bool else { return false}
			
			if !(roleUser || roleEditor || roleAdmin) {
				// select at least one role
				contentDictionary["roleUser"] = true
			}
			
			guard let username = contentDictionary["username"] as? String,
				let password = contentDictionary["password"] as? String else {return false}
			
			return username.lengthOfBytes(using: .utf8) > 1 && password.lengthOfBytes(using: .utf8) > 3 && (roleUser || roleEditor || roleAdmin)
		}
		return true
	}
}

extension MainViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		UserDefaults.standard.set(textView.text, forKey: "customCell")
		NotificationCenter.default.post(name: NSNotification.Name.IASKSettingChanged, object: self, userInfo: ["customCell": textView.text ?? ""])
	}
}
