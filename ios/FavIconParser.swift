//
//  FavIconParser.swift
//  web
//
//  Created by Sergei Golishnikov on 01/06/2025.
//

import Foundation
import Fuzi

final class FavIconParserImpl {
  func favIcons(from htmlData: Data, relativeTo baseUrl: URL) -> [Favicon] {
    do {
      guard let html = String(data: htmlData, encoding: .utf8)
              ?? String(data: htmlData, encoding: .windowsCP1251),
            !html.isEmpty else {
        return []
      }
      
      let document = try HTMLDocument(string: html, encoding: .utf8)
      return document.head?.children(tag: "link")
        .filter { $0.attr("rel")?.lowercased().contains("icon") == true }
        .compactMap { [weak self] element -> Favicon? in
          return self?.favIcon(from: element, relativeTo: baseUrl)
        } ?? []
    } catch {
      return []
    }
  }
  
  // MARK: - Private
  
  private func favIcon(from element: XMLElement, relativeTo baseUrl: URL) -> Favicon? {
    let relAttribute = element.attr("rel")!
    let sizeAttribute = element.attr("sizes")
    guard var href = element.attr("href") else { return nil }
    let type: Favicon.FavIconType
    if href.contains(".ico") == true {
      type = .favIco
    } else {
      type = Favicon.FavIconType(value: relAttribute)
    }
    let sizeComponents = sizeAttribute?.components(separatedBy: "x")
    var size = CGSize.zero
    if let components = sizeComponents,
       components.count >= 2,
       let width = Int(components[0]),
       let height = Int(components[1]) {
      size = CGSize(width: width, height: height)
    }
    
    if href.starts(with: "//") { href = "https:\(href)"}
    guard let url = URL(string: href, relativeTo: baseUrl) else {
      return nil
    }
    
    return Favicon(url: url, size: size, type: type)
  }
}
