import Foundation

enum JobStatus: String, CaseIterable, Codable {
    case draft
    case scheduled
    case completed
    case archived

    var localizedName: String {
        switch self {
        case .draft:     return L(.statusDraft)
        case .scheduled: return L(.statusScheduled)
        case .completed: return L(.statusCompleted)
        case .archived:  return L(.statusArchived)
        }
    }

    var icon: String {
        switch self {
        case .draft:     return "doc"
        case .scheduled: return "calendar.badge.clock"
        case .completed: return "checkmark.circle.fill"
        case .archived:  return "archivebox"
        }
    }
}
