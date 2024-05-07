//
//  LayoutGenerator.swift
//  Off Day
//
//  Created by zici on 2024/1/4.
//

import UIKit
import ZCCalendar

struct LayoutGenerater {
    static func dayLayout(for snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>, year: Int, customDaysDict: [Int : CustomDay]) {
        let firstDayOfWeek: WeekdayOrder = WeekdayOrder(rawValue: WeekStartType.current.rawValue) ?? WeekdayOrder.firstDayOfWeek        
        
        snapshot.appendSections([.topTag])
        snapshot.appendItems(rearrangeArray(startingFrom: firstDayOfWeek, in: WeekdayOrder.allCases).map({ .tag($0.getShortSymbol(), false) }), toSection: .topTag)
        
        for month in Month.allCases {
            snapshot.appendSections([.row(month.rawValue, month.getShortSymbol())])
            let firstDay = GregorianDay(year: year, month: month, day: 1)
            let firstWeekOrder = firstDay.weekdayOrder()
            let firstOffset = (firstWeekOrder.rawValue - (firstDayOfWeek.rawValue % 7) + 7) % 7
            if firstOffset >= 1 {
                snapshot.appendItems(Array(1...firstOffset).map({ index in
                    let uuid = "\(month)-\(index)"
                    return Item.invisible(uuid)
                }))
            }
            snapshot.appendItems(Array(1...ZCCalendar.manager.dayCount(at: month, year: year)).map({ day in
                let gregorianDay = GregorianDay(year: year, month: month, day: day)
                let julianDay = gregorianDay.julianDay
                let publicDay = DayInfoManager.shared.publicDay(at: julianDay)
                let customDay = customDaysDict[julianDay]
                
                let backgroundColor: UIColor
                let foregroundColor: UIColor
                
                if let dayType = publicDay?.type {
                    backgroundColor = dayType.color
                    foregroundColor = .white
                } else {
                    if WeekEndOffDayType.checkIsWeekOffDay(for: gregorianDay) {
                        backgroundColor = WeekEndColorType.getValue().getColor()
                        foregroundColor = .white
                    } else {
                        backgroundColor = AppColor.paper
                        foregroundColor = AppColor.text
                    }
                }
                
                return Item.block(BlockItem(index: julianDay, publicDay: publicDay, customDay: customDay, backgroundColor: backgroundColor, foregroundColor: foregroundColor, isToday: ZCCalendar.manager.isToday(gregorianDay: gregorianDay)))
            }))
        }
    }
}

extension LayoutGenerater {
    static func rearrangeArray(startingFrom value: WeekdayOrder, in array: [WeekdayOrder]) -> [WeekdayOrder] {
        guard let index = array.firstIndex(of: value) else {
            return array
        }
        let firstPart = array.suffix(from: index)
        let secondPart = array.prefix(index)
        return Array(firstPart + secondPart)
    }
}

extension WeekEndColorType {
    func getColor() -> UIColor {
        switch self {
        case .offDay:
            return AppColor.offDay
        case .blue:
            return AppColor.weekEnd
        }
    }
}
