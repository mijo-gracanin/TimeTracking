//
//  TimeInterval+Formatting.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 25.02.2023..
//

import Foundation

extension TimeInterval {
    func toTimerString() -> String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds / 60) % 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
        }
        return String(format: "%0.2d:%0.2d", minutes, seconds)
    }
}
