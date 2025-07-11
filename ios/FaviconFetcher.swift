//
//  FaviconFetcher.swift
//  web
//
//  Created by Sergei Golishnikov on 01/06/2025.
//

import Foundation
import Fuzi
import UIKit

struct Favicon: CustomStringConvertible {
  enum FavIconType {
    case appleTouchIcon
    case appleTouchIconPrecomposed
    case icon
    case favIco
    case undefined

    init(value: String) {
      switch value {
      case "apple-touch-icon": self = .appleTouchIcon
      case "apple-touch-icon-precomposed": self = .appleTouchIconPrecomposed
      case "icon": self = .icon
      case "shortcut icon": self = .icon
      default: self = .undefined
      }
    }
  }

  let url: URL
  let size: CGSize
  let type: FavIconType

  public var description: String {
    return "size: \(size), type: \(type), link: \(url)"
  }

  func isAppleTouch() -> Bool {
    return type == .appleTouchIcon || type == .appleTouchIconPrecomposed
  }
}

class FaviconFetcherErrorType: Error {
  let description: String
  init(description: String) {
    self.description = description
  }
}



private extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

private let queue = DispatchQueue(label: "FaviconFetcher", attributes: DispatchQueue.Attributes.concurrent)
private let DefaultFaviconBackgroundColors = ["2e761a", "399320", "40a624", "57bd35", "70cf5b", "90e07f", "b1eea5", "881606", "aa1b08", "c21f09", "d92215", "ee4b36", "f67964", "ffa792", "025295", "0568ba", "0675d3", "0996f8", "2ea3ff", "61b4ff", "95cdff", "00736f", "01908b", "01a39d", "01bdad", "27d9d2", "58e7e6", "89f4f5", "c84510", "e35b0f", "f77100", "ff9216", "ffad2e", "ffc446", "ffdf81", "911a2e", "b7223b", "cf2743", "ea385e", "fa526e", "ff7a8d", "ffa7b3" ]
final class FaviconFetcher: NSObject, XMLParserDelegate {
  private static let header = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"
  static let userDefaults = UserDefaults(suiteName: "favicon")

  static func stableHash(_ str: String) -> UIColor {
    let unicodeScalars = str.unicodeScalars.map { $0.value }
    let hash = unicodeScalars.reduce(5381) {
      ($0 << 5) &+ $0 &+ Int($1)
    }

    let index = abs(hash) % (DefaultFaviconBackgroundColors.count - 1)
    let colorHex = DefaultFaviconBackgroundColors[index]
    guard let hex = Int(colorHex, radix: 16) else {
      return .clear
    }
    return UIColor(rgb: hex)
  }

  //An in-Memory data store that stores background colors domains. Stored using url.baseDomain.
  static var colors: [String: UIColor] = [:]

  static let multiRegionDomains = ["craigslist", "google", "amazon"]

  // Returns a color based on the url's hash
  static func getDefaultColor(_ link: String) -> UIColor {
    return stableHash(link)
  }

  static func getForURL(_ url: String?, callback: @escaping ([String]) -> Void) {
    guard let url else { return callback([]) }

    queue.async {
      self.parseHTMLForFavicons(url) { (icons, uri) in
        if !icons.isEmpty {
          debugPrint("cacheIcons", uri, icons)
          userDefaults?.set(icons[0], forKey: uri)
        }

        callback(icons)
      }
    }
  }

  // Loads and parses an html document and tries to find any known favicon-type tags for the page
  fileprivate static func parseHTMLForFavicons(_ url: String, callback: @escaping ([String], String) -> Void) {
    guard let uri = URIFixup.removeQueryAndFragment(from: URL(string: url)) else {
      return callback([], "")
    }

    if let icon = userDefaults?.string(forKey: uri.absoluteString) {
      debugPrint("fetchFromCache", uri, icon)
      return callback([icon], uri.absoluteString)
    }

    let session = URLSession.shared
    let request = NSMutableURLRequest(url: uri)
    request.setValue(header, forHTTPHeaderField: "User-Agent")

    debugPrint("parseHTMLForFavicons", uri)
    let task = session.dataTask(with: request as URLRequest, completionHandler: {
      (data, response, error) -> Void in
      if let data = data {
        let relativeURL = response?.url ?? uri
        let icons = FavIconParserImpl().favIcons(from: data, relativeTo: relativeURL)
        debugPrint("iconsFetched", uri)
        debugPrint("iconsFetched", icons)
        debugPrint("iconsFetched", "---------")

        var appleIcon = icons.sorted(by: {
          $0.size.width > $1.size.width && $0.size.height > $1.size.height
        }).filter({ $0.isAppleTouch() })
        if appleIcon.isEmpty && !icons.isEmpty {
          appleIcon = [icons[0]]
        }
        callback([appleIcon.first?.url.absoluteString].compactMap { $0 }, uri.absoluteString)
      }
    })
    task.resume()
  }
}
