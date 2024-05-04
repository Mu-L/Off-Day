//
//  PublicDayViewController.swift
//  Off Day
//
//  Created by zici on 3/5/24.
//

import UIKit
import SnapKit

class PublicDayViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
        
    enum Section: Hashable {
        case special
        case cn
        case jp
        
        var header: String? {
            return nil
        }
        
        var footer: String? {
            return nil
        }
    }
    
    enum Item: Hashable {
        case empty
        case plan(DayInfoManager.PublicDayPlan)
        
        var title: String {
            switch self {
            case .empty:
                return String(localized: "publicDay.item.special.empty")
            case .plan(let plan):
                return plan.title
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = String(localized: "controller.publicDay.title")
        view.backgroundColor = .background
        updateNavigationBarStyle()
        
        configureHierarchy()
        configureDataSource()
        reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) { [weak self] in
            self?.updateSelection()
        }
    }
    
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            configuration.separatorConfiguration = UIListSeparatorConfiguration(listAppearance: .insetGrouped)
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .background
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    func configureDataSource() {
        let listCellRegistration = createListCellRegistration()
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    func createListCellRegistration() -> UICollectionView.CellRegistration<PublicPlanCell, Item> {
        return UICollectionView.CellRegistration<PublicPlanCell, Item> { [weak self] (cell, indexPath, item) in
            guard let self = self else { return }
            switch item {
            case .empty:
                var content = UIListContentConfiguration.valueCell()
                content.text = item.title
                var layoutMargins = content.directionalLayoutMargins
                layoutMargins.leading = 10.0
                content.directionalLayoutMargins = layoutMargins
                cell.contentConfiguration = content
                cell.detail = nil
            default:
                var content = UIListContentConfiguration.valueCell()
                content.text = item.title
                var layoutMargins = content.directionalLayoutMargins
                layoutMargins.leading = 10.0
                content.directionalLayoutMargins = layoutMargins
                cell.contentConfiguration = content
                cell.detail = nil//self.detailAccessoryForListCellItem(item)
            }
        }
    }
    
    func detailAccessoryForListCellItem(_ item: Item) -> UICellAccessory {
        return UICellAccessory.detail(options: UICellAccessory.DetailOptions(tintColor: .offDay), actionHandler: { [weak self] in
            self?.goToDetail(for: item)
        })
    }
    
    func goToDetail(for item: Item) {
        print(item)
    }
    
    @objc
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.special])
        snapshot.appendItems([.empty], toSection: .special)
        
        snapshot.appendSections([.cn])
        snapshot.appendItems([.plan(.cn), .plan(.cn_xj), .plan(.cn_xz), .plan(.cn_gx), .plan(.cn_nx)], toSection: .cn)
        
        snapshot.appendSections([.jp])
        snapshot.appendItems([.plan(.jp)], toSection: .jp)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func updateSelection() {
        if let plan = DayInfoManager.shared.plan, let index = dataSource.indexPath(for: .plan(plan)) {
            collectionView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
        } else {
            if let index = dataSource.indexPath(for: .empty) {
                collectionView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
            }
        }
    }
}

extension PublicDayViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            switch item {
            case .empty:
                DayInfoManager.shared.plan = nil
            case .plan(let publicDayPlan):
                DayInfoManager.shared.plan = publicDayPlan
            }
        }
    }
}

class PublicPlanCell: UICollectionViewListCell {
    var detail: UICellAccessory?
    
    var customBackgroundView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .secondarySystemGroupedBackground
        
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        detail = nil
    }
    
    private func setupViewsIfNeeded() {
        guard customBackgroundView.superview == nil else { return }
        
        contentView.addSubview(customBackgroundView)
        contentView.sendSubviewToBack(customBackgroundView)
        customBackgroundView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        setupViewsIfNeeded()

        if state.isSelected {
            let checkmark = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)))
            accessories = [detail, .customView(configuration: .init(customView: checkmark, placement: .leading(), reservedLayoutWidth: .custom(12), tintColor: .offDay))].compactMap{ $0 }
        } else {
            accessories = [detail, (.customView(configuration: .init(customView: UIView(), placement: .leading(), reservedLayoutWidth: .custom(12), tintColor: .offDay)))].compactMap{ $0 }
        }
        if state.isHighlighted {
            if state.isSelected {
                customBackgroundView.alpha = 1.0
                customBackgroundView.backgroundColor = .systemGray4
            } else {
                customBackgroundView.alpha = 0.0
                customBackgroundView.backgroundColor = .secondarySystemGroupedBackground
            }
        } else {
            customBackgroundView.alpha = 1.0
            customBackgroundView.backgroundColor = .secondarySystemGroupedBackground
        }
        
        backgroundConfiguration = PublicPlanCellBackgroundConfiguration.configuration(for: state)
    }
}

struct PublicPlanCellBackgroundConfiguration {
    static func configuration(for state: UICellConfigurationState) -> UIBackgroundConfiguration {
        var background = UIBackgroundConfiguration.listGroupedCell()
        if state.isSelected {
            background.backgroundColor = .clear
        }
        return background
    }
}
