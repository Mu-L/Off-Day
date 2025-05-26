//
//  TutorialsViewController.swift
//  Off Day
//
//  Created by zici on 1/5/24.
//

import UIKit
import SnapKit

struct HelpURL {
    static let shortcutsNormalURL = URL(string: String(localized: "url.shortcuts.normal"))
    static let shortcutsSleepURL = URL(string: String(localized: "url.shortcuts.sleep"))
    static let shortcutsHelpURL = URL(string: String(localized: "url.help.shortcuts"))
    static let automationHelpURL = URL(string: String(localized: "url.help.automation"))
    static let helpCenterURL = URL(string: String(localized: "url.help.center"))
}

class TutorialsViewController: UIViewController {
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24.0
        stackView.distribution = .fill
        stackView.alignment = .leading
        
        return stackView
    }()
    
    private var topLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.textColor = AppColor.offDay
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        
        label.text = String(localized: "tutorials.hint.top")
        
        return label
    }()
    
    private var secondLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize, weight: .black)
        label.textAlignment = .center
        label.textColor = AppColor.offDay
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        
        label.text = String(localized: "tutorials.hint.second")
        
        return label
    }()
    
    private var publicPlanButton: UIButton = {
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.image = UIImage(systemName: "1.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18.0))
        configuration.title = String(localized: "tutorials.publicPlan.title")
        configuration.subtitle = String(localized: "tutorials.publicPlan.subtitle")
        configuration.imagePadding = 8.0
        configuration.titlePadding = 4.0
        configuration.cornerStyle = .large
        configuration.buttonSize = .large
        
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ incoming in
            var outgoing = incoming
            outgoing.font = UIFont.preferredFont(forTextStyle: .headline)

            return outgoing
        })
        
        let button = UIButton(configuration: configuration)
        button.tintColor = AppColor.offDay
        
        return button
    }()
    
    private var addShortcutsButton: UIButton = {
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.image = UIImage(systemName: "2.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18.0))
        configuration.title = String(localized: "tutorials.shortcuts.title")
        configuration.subtitle = String(localized: "tutorials.shortcuts.subtitle")
        configuration.imagePadding = 8.0
        configuration.titlePadding = 4.0
        configuration.cornerStyle = .large
        configuration.buttonSize = .large
        
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ incoming in
            var outgoing = incoming
            outgoing.font = UIFont.preferredFont(forTextStyle: .headline)

            return outgoing
        })
        
        let button = UIButton(configuration: configuration)
        button.tintColor = AppColor.offDay
        button.showsMenuAsPrimaryAction = true
        
        return button
    }()
    
    private var automationButton: UIButton = {
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.image = UIImage(systemName: "3.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18.0))
        configuration.title = String(localized: "tutorials.automation.title")
        configuration.subtitle = String(localized: "tutorials.automation.subtitle")
        configuration.imagePadding = 8.0
        configuration.titlePadding = 4.0
        configuration.cornerStyle = .large
        configuration.buttonSize = .large
        
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ incoming in
            var outgoing = incoming
            outgoing.font = UIFont.preferredFont(forTextStyle: .headline)

            return outgoing
        })
        
        let button = UIButton(configuration: configuration)
        button.tintColor = AppColor.offDay
        
        return button
    }()
    
    private var tutorialsButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        let button = UIButton(configuration: configuration)
        button.tintColor = AppColor.offDay
        
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: UIFont.systemFont(ofSize: 14)
        ]
        let string = NSAttributedString(string: String(localized: "tutorials.shortcuts.help.title"),attributes: attributes)
        button.setAttributedTitle(string, for: .normal)
        
        return button
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        title = String(localized: "controller.tutorials.title")
        tabBarItem = UITabBarItem(title: String(localized: "controller.tutorials.title"), image: UIImage(systemName: "sparkles"), tag: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("TutorialsViewController is deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColor.background
        updateNavigationBarStyle()
        
        let helpButton = UIBarButtonItem(title: String(localized: "more.section.help"), style: .plain, target: self, action: nil)
        let helpAction = UIAction(title: String(localized: "more.item.help"), subtitle: String(localized: "more.section.help.hint"), image: UIImage(systemName: "questionmark.circle")) { [weak self] _ in
            self?.enterHelpCenter()
        }
        let contactDivider = UIMenu(title: String(localized: "more.section.contact"), subtitle: String(localized: "more.section.contact.hint"), children: MoreViewController.Item.ContactItem.allCases.map({ item in
            return UIAction(title: item.title, subtitle: item.value, image: item.image) { [weak self] _ in
                self?.handle(contactItem: item)
            }
        }))
        helpButton.menu = UIMenu(title: "", children: [helpAction, contactDivider])
        navigationItem.rightBarButtonItem = helpButton
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(50)
            make.height.width.greaterThanOrEqualTo(0)
            make.width.lessThanOrEqualTo(view).offset(-80)
        }
        
        stackView.addArrangedSubview(publicPlanButton)
        stackView.addArrangedSubview(addShortcutsButton)
        stackView.setCustomSpacing(4, after: addShortcutsButton)
        stackView.addArrangedSubview(tutorialsButton)
        stackView.addArrangedSubview(automationButton)
        
        view.addSubview(secondLabel)
        secondLabel.snp.makeConstraints { make in
            make.bottom.equalTo(stackView.snp.top).offset(-60)
            make.leading.trailing.equalTo(view).inset(32)
        }
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.bottom.equalTo(secondLabel.snp.top).offset(-10)
            make.leading.trailing.equalTo(view).inset(32)
        }
        
        let normalAction = UIAction(title: String(localized: "tutorials.normal.title"), image: UIImage(systemName: "alarm")) { [weak self] _ in
            guard let self = self else { return }
            self.addNormalShortcuts()
        }
        let sleepAction = UIAction(title: String(localized: "tutorials.sleep.title"), image: UIImage(systemName: "moon.fill")) { [weak self] _ in
            guard let self = self else { return }
            self.addSleepShortcuts()
        }
        if #available(iOS 17.0, *) {
            addShortcutsButton.menu = UIMenu(title: "", children: [normalAction, sleepAction])
        } else {
            addShortcutsButton.menu = UIMenu(title: "", children: [normalAction])
        }
        
        publicPlanButton.configurationUpdateHandler = { button in
            button.configuration?.subtitle = (PublicPlanManager.shared.dataSource == nil) ? String(localized: "tutorials.shortcuts.subtitle") : PublicPlanManager.shared.dataSource?.name
        }

        publicPlanButton.addTarget(self, action: #selector(showPublicPlanPicker), for: .touchUpInside)
        tutorialsButton.addTarget(self, action: #selector(openShortcutsHelp), for: .touchUpInside)
        automationButton.addTarget(self, action: #selector(openAutomationHelp), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .SettingsUpdate, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc
    func showPublicPlanPicker() {
        let calendarSectionViewController = PublicPlanViewController()
        let nav = NavigationController(rootViewController: calendarSectionViewController)
        
        navigationController?.present(nav, animated: true)
    }
    
    @objc
    func enterHelpCenter() {
        if let url = HelpURL.helpCenterURL {
            openSF(with: url)
        }
    }
    
    func addNormalShortcuts() {
        if let shortcutsURL = HelpURL.shortcutsNormalURL {
            UIApplication.shared.open(shortcutsURL, options: [:], completionHandler: nil)
        }
    }
    
    func addSleepShortcuts() {
        if let shortcutsURL = HelpURL.shortcutsSleepURL {
            UIApplication.shared.open(shortcutsURL, options: [:], completionHandler: nil)
        }
    }
    
    @objc
    func openShortcutsHelp() {
        if let url = HelpURL.shortcutsHelpURL {
            openSF(with: url)
        }
    }
    
    @objc
    func openAutomationHelp() {
        if let url = HelpURL.automationHelpURL {
            openSF(with: url)
        }
    }
    
    @objc
    func reloadData() {
        publicPlanButton.setNeedsUpdateConfiguration()
    }
}
