//
//  MoreViewController.swift
//  Off Day
//
//  Created by zici on 1/5/24.
//

import UIKit
import SnapKit
import SafariServices

class MoreViewController: UIViewController {
    static let supportEmail = "offday@zi.ci"

    private var tableView: UITableView!
    private var dataSource: DataSource!
        
    enum Section: Hashable {
        case general
        case appjun
        case about
        
        var header: String? {
            switch self {
            case .general:
                return String(localized: "more.section.general")
            case .appjun:
                return String(localized: "more.section.appjun")
            case .about:
                return String(localized: "more.section.about")
            }
        }
        
        var footer: String? {
            return nil
        }
    }
    
    enum Item: Hashable {
        enum GeneralItem: Hashable {
            case language
            case publicPlan(DayInfoManager.PublicPlan?)
            
            var title: String {
                switch self {
                case .language:
                    return String(localized: "more.item.settings.language")
                case .publicPlan:
                    return String(localized: "more.item.settings.publicPlan")
                }
            }
            
            var value: String? {
                switch self {
                case .language:
                    return String(localized: "more.item.settings.language.value")
                case .publicPlan(let plan):
                    if let plan = plan {
                        return plan.title
                    } else {
                        return String(localized: "more.item.settings.publicPlan.noSet")
                    }
                }
            }
        }
        
        enum AboutItem {
            case specifications
            case share
            case review
            case eula
            case privacyPolicy
            case email
            
            var title: String {
                switch self {
                case .specifications:
                    return String(localized: "more.item.about.specifications")
                case .share:
                    return String(localized: "more.item.about.share")
                case .review:
                    return String(localized: "more.item.about.review")
                case .eula:
                    return String(localized: "more.item.about.eula")
                case .privacyPolicy:
                    return String(localized: "more.item.about.privacyPolicy")
                case .email:
                    return String(localized: "more.item.about.email")
                }
            }
            
            var value: String? {
                switch self {
                case .email:
                    return MoreViewController.supportEmail
                default:
                    return nil
                }
            }
        }
        
        enum AppJunItem: Hashable {
            case otherApps(App)
            case bilibili
            case xiaohongshu
            
            var title: String {
                switch self {
                case .otherApps:
                    return ""
                case .bilibili:
                    return String(localized: "more.item.appjun.bilibili")
                case .xiaohongshu:
                    return String(localized: "more.item.appjun.xiaohongshu")
                }
            }
            
            var value: String? {
                switch self {
                case .otherApps:
                    return nil
                case .bilibili, .xiaohongshu:
                    return "@App君"
                }
            }
        }
        
        case settings(GeneralItem)
        case appjun(AppJunItem)
        case about(AboutItem)
        
        var title: String {
            switch self {
            case .settings(let item):
                return item.title
            case .appjun(let item):
                return item.title
            case .about(let item):
                return item.title
            }
        }
    }
    
    class DataSource: UITableViewDiffableDataSource<Section, Item> {
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            let sectionKind = sectionIdentifier(for: section)
            return sectionKind?.header
        }
        
        override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
            let sectionKind = sectionIdentifier(for: section)
            return sectionKind?.footer
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        title = String(localized: "controller.more.title")
        tabBarItem = UITabBarItem(title: String(localized: "controller.more.title"), image: UIImage(systemName: "ellipsis"), tag: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("MoreViewController is deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColor.background
        updateNavigationBarStyle()
        
        configureHierarchy()
        configureDataSource()
        reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .SettingsUpdate, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func configureHierarchy() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = AppColor.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.register(AppCell.self, forCellReuseIdentifier: NSStringFromClass(AppCell.self))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50.0
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func configureDataSource() {
        dataSource = DataSource(tableView: tableView) { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else { return nil }
            guard let identifier = dataSource.itemIdentifier(for: indexPath) else { return nil }
            switch identifier {
            case .settings(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                var content = UIListContentConfiguration.valueCell()
                content.text = identifier.title
                content.textProperties.color = .label
                content.secondaryText = item.value
                cell.contentConfiguration = content
                return cell
            case .appjun(let item):
                switch item {
                case .otherApps(let app):
                    let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(AppCell.self), for: indexPath)
                    if let cell = cell as? AppCell {
                        cell.update(app)
                    }
                    cell.accessoryType = .disclosureIndicator
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    cell.accessoryType = .disclosureIndicator
                    var content = UIListContentConfiguration.valueCell()
                    content.text = identifier.title
                    content.textProperties.color = .label
                    content.secondaryText = item.value
                    cell.contentConfiguration = content
                    return cell
                }

            case .about(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                var content = UIListContentConfiguration.valueCell()
                content.text = identifier.title
                content.textProperties.color = .label
                content.secondaryText = item.value
                cell.contentConfiguration = content
                return cell
            }
        }
    }
    
    @objc
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.general])
        snapshot.appendItems([.settings(.language), .settings(.publicPlan(DayInfoManager.shared.publicPlan))], toSection: .general)
        
        snapshot.appendSections([.appjun])
        var appItems: [Item] = [.appjun(.otherApps(.lemon)), .appjun(.otherApps(.moontake)), .appjun(.otherApps(.coconut)), .appjun(.otherApps(.pigeon))]
        if Language.type() == .zh {
            appItems.append(.appjun(.otherApps(.festivals)))
        }
        appItems.append(contentsOf: [.appjun(.bilibili), .appjun(.xiaohongshu)])
        snapshot.appendItems(appItems, toSection: .appjun)
        
        snapshot.appendSections([.about])
        snapshot.appendItems([.about(.specifications), .about(.eula), .about(.privacyPolicy), .about(.email)], toSection: .about)
//        snapshot.appendItems([.about(.specifications), .about(.eula), .about(.share), .about(.review), .about(.privacyPolicy), .about(.email)], toSection: .about)

        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension MoreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = dataSource.itemIdentifier(for: indexPath) {
            switch item {
            case .settings(let item):
                switch item {
                case .language:
                    jumpToSettings()
                case .publicPlan:
                    showPublicPlanPicker()
                }
            case .appjun(let item):
                switch item {
                case .otherApps(let app):
                    openStorePage(for: app)
                case .bilibili:
                    openBilibiliWebpage()
                case .xiaohongshu:
                    openXiaohongshuWebpage()
                }
            case .about(let item):
                switch item {
                case .specifications:
                    enterSpecifications()
                case .share:
                    shareApp()
                case .review:
                    openAppStoreForReview()
                case .eula:
                    openEULA()
                case .privacyPolicy:
                    openPrivacyPolicy()
                case .email:
                    sendEmailToCustomerSupport()
                }
            }
        }
    }
}

extension MoreViewController {
    func jumpToSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    func showPublicPlanPicker() {
        let calendarSectionViewController = PublicDayViewController()
        let nav = UINavigationController(rootViewController: calendarSectionViewController)
        
        navigationController?.present(nav, animated: true)
    }
    
    func enterSpecifications() {
        let specificationViewController = SpecificationsViewController()
        specificationViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(specificationViewController, animated: true)
    }
    
    func sendEmailToCustomerSupport() {
        let recipient = MoreViewController.supportEmail
        
        guard let emailUrlString = "mailto:\(recipient)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let emailUrl = URL(string: emailUrlString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(emailUrl) {
            UIApplication.shared.open(emailUrl, options: [:], completionHandler: nil)
        } else {
            // 打开邮件应用失败，进行适当的处理或提醒用户
        }
    }
    
    func openEULA() {
        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
            openSF(with: url)
        }
    }
    
    func openPrivacyPolicy() {
        if let url = URL(string: "https://zizicici.medium.com/privacy-policy-for-off-day-app-6f7f26f68c7c") {
            openSF(with: url)
        }
    }
    
    func openBilibiliWebpage() {
        if let url = URL(string: "https://space.bilibili.com/4969209") {
            openSF(with: url)
        }
    }
    
    func openXiaohongshuWebpage() {
        if let url = URL(string: "https://www.xiaohongshu.com/user/profile/63f05fc5000000001001e524") {
            openSF(with: url)
        }
    }
    
    func openYoutubeWebpage() {
        if let url = URL(string: "https://www.youtube.com/@app_jun") {
            openSF(with: url)
        }
    }
    
    func openStorePage(for app: App) {
        guard let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/" + app.storeId) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(appStoreURL) {
            UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
        }
    }
    
    func openAppStoreForReview() {
        guard let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id6474681491?action=write-review") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(appStoreURL) {
            UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
        }
    }
    
    func shareApp() {
        if let url = URL(string: "https://apps.apple.com/app/id6474681491") {
            let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            present(controller, animated: true)
        }
    }
}

extension MoreViewController {
    func showOverlayViewController() {
        let overlayVC = OverlayViewController()
        
        // 让当前视图控制器的内容可见但不可交互
        overlayVC.modalPresentationStyle = .overCurrentContext
        overlayVC.modalTransitionStyle = .crossDissolve
        
        // 显示覆盖全屏的遮罩层
        navigationController?.present(overlayVC, animated: true, completion: nil)
    }

    func hideOverlayViewController() {
        // 隐藏覆盖全屏的遮罩层
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

class OverlayViewController: UIViewController {
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置背景颜色和透明度
        view.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        
        // 添加指示器到视图并居中
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // 开始旋转
        activityIndicator.startAnimating()
    }
}

struct Language {
    enum LanguageType {
        case zh
        case en
        case ja
    }
    
    static func type() -> LanguageType {
        switch String(localized: "more.item.settings.language.value") {
        case "简体中文", "繁体中文", "繁体中文（香港）":
            return .zh
        case "日本語":
            return .ja
        default:
            return .en
        }
    }
}
