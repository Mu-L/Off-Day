//
//  BaseCalendarManager.swift
//  Off Day
//
//  Created by zici on 8/5/24.
//

import Foundation
import ZCCalendar

enum BaseCalendarType: Int, Codable {
    case standard = 0
    case weeksCircle
    case daysCircle
}

struct StandardConfig: Codable {
    var weekdayOrders: [WeekdayOrder]
    
    static let `default` = Self.init(weekdayOrders: [.sat, .sun])
    
    var length: Int {
        return 7
    }
    
    var hasOff: Bool {
        return Set(weekdayOrders).count > 0
    }
    
    var hasWork: Bool {
        return Set(weekdayOrders).count < length
    }
}

enum WeekCount: Int, CaseIterable, Hashable, Equatable, Codable {
    case two = 2
    case three
    case four
    
    var title: String {
        switch self {
        case .two:
            return String(localized: "baseCalendar.weeks.2")
        case .three:
            return String(localized: "baseCalendar.weeks.3")
        case .four:
            return String(localized: "baseCalendar.weeks.4")
        }
    }
}

struct WeeksCircleConfig: Hashable, Codable {
    var offset: Int
    var weekCount: WeekCount
    var indexs: [Int]
    
    var length: Int {
        return weekCount.rawValue * 7
    }
    
    var hasOff: Bool {
        return indexs.count > 0
    }
    
    var hasWork: Bool {
        return indexs.count < length
    }
}

struct DaysCircleConfig: Hashable, Codable {
    var start: Int
    var workCount: Int
    var offCount: Int
    
    var length: Int {
        return workCount + offCount
    }
    
    var hasOff: Bool {
        return offCount > 0
    }
    
    var hasWork: Bool {
        return workCount > 0
    }
}

class BaseCalendarManager {
    static let shared = BaseCalendarManager()
    
    enum Config {
        case standard(StandardConfig)
        case weeksCircle(WeeksCircleConfig)
        case daysCircle(DaysCircleConfig)
        
        var type: BaseCalendarType {
            switch self {
            case .standard:
                return .standard
            case .weeksCircle:
                return .weeksCircle
            case .daysCircle:
                return .daysCircle
            }
        }
        
        static func generate(by config: BaseCalendarConfig) -> Self {
            switch config.type {
            case .standard:
                return .standard(StandardConfig(weekdayOrders: config.standardWeekdayOrders()))
            case .weeksCircle:
                return .weeksCircle(WeeksCircleConfig(offset: Int(config.weekOffset), weekCount: config.weekCount, indexs: config.weeksCircleIndexs()))
            case .daysCircle:
                return .daysCircle(DaysCircleConfig(start: Int(config.dayStart), workCount: Int(config.dayWorkCount), offCount: Int(config.dayOffCount)))
            }
        }
        
        var length: Int {
            switch self {
            case .standard(let standardConfig):
                return standardConfig.length
            case .weeksCircle(let weeksCircleConfig):
                return weeksCircleConfig.length
            case .daysCircle(let daysCircleConfig):
                return daysCircleConfig.length
            }
        }
        
        var hasOff: Bool {
            switch self {
            case .standard(let standardConfig):
                return standardConfig.hasOff
            case .weeksCircle(let weeksCircleConfig):
                return weeksCircleConfig.hasOff
            case .daysCircle(let daysCircleConfig):
                return daysCircleConfig.hasOff
            }
        }
        
        var hasWork: Bool {
            switch self {
            case .standard(let standardConfig):
                return standardConfig.hasWork
            case .weeksCircle(let weeksCircleConfig):
                return weeksCircleConfig.hasWork
            case .daysCircle(let daysCircleConfig):
                return daysCircleConfig.hasWork
            }
        }
    }
    
    private(set) var config: Config!

    init() {
        self.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .DatabaseUpdated, object: nil)
    }
    
    func save(config: Config) {
        guard var databaseConfig = BaseCalendarConfigManager.fetch() else {
            return
        }
        databaseConfig.type = config.type
        switch config {
        case .standard(let standardConfig):
            databaseConfig.standardOffday = standardConfig.weekdayOrders.map{ "\($0.rawValue)" }.joined(separator: "/")
        case .weeksCircle(let weeksCircleConfig):
            databaseConfig.weekCount = weeksCircleConfig.weekCount
            databaseConfig.weekOffset = Int64(weeksCircleConfig.offset)
            databaseConfig.weekIndexs = weeksCircleConfig.indexs.map{ "\($0)" }.joined(separator: "/")
        case .daysCircle(let daysCircleConfig):
            databaseConfig.dayStart = Int64(daysCircleConfig.start)
            databaseConfig.dayOffCount = Int64(daysCircleConfig.offCount)
            databaseConfig.dayWorkCount = Int64(daysCircleConfig.workCount)
        }
        self.config = Config.generate(by: databaseConfig)
        BaseCalendarConfigManager.update(config: databaseConfig)
    }
    
    func isOff(day: GregorianDay) -> Bool {
        switch config! {
        case .standard(let config):
            return config.weekdayOrders.contains(day.weekdayOrder())
        case .weeksCircle(let config):
            return config.indexs.contains(day.julianDay % (7 * config.weekCount.rawValue))
        case .daysCircle(let config):
            let cycle = config.workCount + config.offCount
            var offset = (day.julianDay - config.start) % cycle
            if offset < 0 {
                offset += cycle
            }
            return offset >= config.workCount
        }
    }
    
    public func fetchBaseDay(after startDay: Int, dayType: DayType) -> GregorianDay? {
        switch dayType {
        case .offDay:
            if !config.hasOff {
                return nil
            } else {
                for i in 1...config.length {
                    let condidateDay = GregorianDay(JDN: startDay + i)
                    if isOff(day: condidateDay) {
                        return condidateDay
                    }
                }
                return nil
            }
        case .workDay:
            if !config.hasWork {
                return nil
            } else {
                for i in 1...config.length {
                    let condidateDay = GregorianDay(JDN: startDay + i)
                    if !isOff(day: condidateDay) {
                        return condidateDay
                    }
                }
                return nil
            }
        }
    }
    
    @objc
    private func reloadData() {
        if let storedConfig = BaseCalendarConfigManager.fetch() {
            config = Config.generate(by: storedConfig)
        } else {
            let standardOffday: String
            switch WeekEndOffDayType.getValue() {
            case .two:
                standardOffday = "6/7"
            case .one:
                standardOffday = "7"
            case .zero:
                standardOffday = ""
            }
            let needSaveConfig = BaseCalendarConfig(type: .standard, standardOffday: standardOffday, weekOffset: 0, weekCount: .two, weekIndexs: "", dayStart: 0, dayWorkCount: 1, dayOffCount: 1)
            BaseCalendarConfigManager.add(config: needSaveConfig)
            
            config = Config.generate(by: needSaveConfig)
        }
    }
}

// Database
struct BaseCalendarConfigManager {
    static func fetch() -> BaseCalendarConfig? {
        var result: BaseCalendarConfig?
        do {
            try AppDatabase.shared.reader?.read{ db in
                result = try BaseCalendarConfig.fetchOne(db)
            }
        }
        catch {
            print(error)
        }
        return result
    }
    
    static func add(config: BaseCalendarConfig) {
        guard config.id == nil else {
            return
        }
        _ = AppDatabase.shared.add(baseCalendarConfig: config)
    }
    
    static func update(config: BaseCalendarConfig) {
        guard config.id != nil else {
            return
        }
        _ = AppDatabase.shared.update(baseCalendarConfig: config)
    }
}
