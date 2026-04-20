import Foundation

enum HandymanType: String, CaseIterable, Codable {
    case construction
    case plumber
    case electrician
    case painter
    case carpenter
    case tiler

    var localizedName: String {
        switch self {
        case .construction: return L(.construction)
        case .plumber:      return L(.plumber)
        case .electrician:  return L(.electrician)
        case .painter:      return L(.painter)
        case .carpenter:    return L(.carpenter)
        case .tiler:        return L(.tiler)
        }
    }

    var jobsIcon: String {
        switch self {
        case .construction: return "hammer"
        case .plumber:      return "wrench.adjustable"
        case .electrician:  return "bolt"
        case .painter:      return "paintbrush"
        case .carpenter:    return "ruler"
        case .tiler:        return "square.grid.2x2"
        }
    }

    var materialsIcon: String {
        switch self {
        case .construction: return "shippingbox"
        case .plumber:      return "pipe.and.drop"
        case .electrician:  return "cable.connector"
        case .painter:      return "paintpalette"
        case .carpenter:    return "tree"
        case .tiler:        return "square.stack.3d.up"
        }
    }

    var settingsIcon: String {
        switch self {
        case .construction: return "wrench.and.screwdriver"
        case .plumber:      return "spigot"
        case .electrician:  return "powerplug"
        case .painter:      return "eyedropper"
        case .carpenter:    return "hammer"
        case .tiler:        return "square.on.square"
        }
    }
}
