//
//  CheckDayIntent.swift
//  Off Day
//
//  Created by zici on 1/5/24.
//

import AppIntents
import ZCCalendar

struct CheckDayClashIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.clash.title"
    
    static var description: IntentDescription = IntentDescription("If the result is true, it is a clash day.", categoryName: "Check Clash Day")
    
    @Parameter(title: "Date", description: "Date", kind: .date, requestValueDialog: IntentDialog("Which day?"))
    var date: Date
    
    @Parameter(title: "Including Custom Mark", description: "Including Custom Mark", default: false)
    var enableUserMark: Bool
    
    static var parameterSummary: some ParameterSummary {
        Summary("Is \(\.$date) a Clash Day?") {
            \.$enableUserMark
        }
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        var isOffDay = false
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        if let year = components.year, let month = components.month, let day = components.day, let month = Month(rawValue: month) {
            let target = GregorianDay(year: year, month: month, day: day)
            isOffDay = target.isClashDay(including: enableUserMark)
        }
        return .result(value: isOffDay)
    }

    static var openAppWhenRun: Bool = false
}

struct CheckTodayClashIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.clash.today.title"
    
    static var description: IntentDescription = IntentDescription("If the result is true, it is a clash day.", categoryName: "Check Clash Day")
    
    @Parameter(title: "Including Custom Mark", description: "Including Custom Mark", default: false)
    var enableUserMark: Bool
    
    static var parameterSummary: some ParameterSummary {
        Summary("Is Today a Clash Day?") {
            \.$enableUserMark
        }
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        var isOffDay = false
        let components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        if let year = components.year, let month = components.month, let day = components.day, let month = Month(rawValue: month) {
            let target = GregorianDay(year: year, month: month, day: day)
            isOffDay = target.isClashDay(including: enableUserMark)
        }
        return .result(value: isOffDay)
    }

    static var openAppWhenRun: Bool = false
}

struct CheckTomorrowClashIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.clash.tomorrow.title"
    
    static var description: IntentDescription = IntentDescription("If the result is true, it is a clash day.", categoryName: "Check Clash Day")
    
    @Parameter(title: "Including Custom Mark", description: "Including Custom Mark", default: false)
    var enableUserMark: Bool
    
    static var parameterSummary: some ParameterSummary {
        Summary("Is Tomorrow a Clash Day?") {
            \.$enableUserMark
        }
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        var isOffDay = false
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let components = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        if let year = components.year, let month = components.month, let day = components.day, let month = Month(rawValue: month) {
            let target = GregorianDay(year: year, month: month, day: day)
            isOffDay = target.isClashDay(including: enableUserMark)
        }
        return .result(value: isOffDay)
    }

    static var openAppWhenRun: Bool = false
}

extension GregorianDay {
    fileprivate func isClashDay(including customMarkEnabled: Bool) -> Bool {
        let basicOffValue = BasicCalendarManager.shared.isOff(day: self)
        let publicOffValue: Bool
        if let publicDay = DayInfoManager.shared.publicDay(at: julianDay) {
            publicOffValue = publicDay.type == .offDay
        } else {
            publicOffValue = false
        }
        if customMarkEnabled {
            let customOffValue: Bool
            if let customDay = CustomDayManager.shared.fetchCustomDay(by: julianDay) {
                customOffValue = customDay.dayType == .offDay
            } else {
                customOffValue = false
            }
            return !((basicOffValue == publicOffValue) && (customOffValue == basicOffValue))
        } else {
            return basicOffValue != publicOffValue
        }
    }
}
