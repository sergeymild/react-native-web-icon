import UIKit
import SDWebImage

private func getHostFromUrl(_ url: String) -> String {
    guard let parsedUrl = URL(string: url), let scheme = parsedUrl.scheme, let host = parsedUrl.host else {
        print("Invalid URL: \(url)")
        return ""
    }
    return "\(scheme)://\(host)"
}

private func getUrl(_ url: String) -> String {
    let host = getHostFromUrl(url)
    return "https://t3.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&size=128&fallback_opts=TYPE,SIZE,URL&url=\(host)"
}

@objc(WebIconViewManager)
class WebIconViewManager: RCTViewManager {
  override func view() -> UIView! {
    let view = WebIcon()
    return view
  }
}


class WebIcon: UIImageView {

  @objc
  func setUrl(_ url: String) {
    FaviconFetcher.getForURL(url) { [weak self] icons in
      var icon = icons.first
      if icon == nil || icon?.hasSuffix(".ico") == true {
        icon =  getUrl(url)
      }
      guard let url = URL(string: icon ?? "") else { return }
      self?.sd_setImage(with: url)
    }
  }
}
