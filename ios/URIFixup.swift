//
//  URIFixup.swift
//  web
//
//  Created by Sergei Golishnikov on 01/06/2025.
//

import Foundation

func getHost(link: String) -> String {
  return URIFixup.getURL(entry: link)!.host!
}

private let permanentURISchemes = ["aaa", "aaas", "about", "acap", "acct", "cap", "cid", "coap", "coaps", "crid", "data", "dav", "dict", "dns", "example", "file", "ftp", "geo", "go", "gopher", "h323", "http", "https", "iax", "icap", "im", "imap", "info", "ipp", "ipps", "iris", "iris.beep", "iris.lwz", "iris.xpc", "iris.xpcs", "jabber", "javascript", "ldap", "mailto", "mid", "msrp", "msrps", "mtqp", "mupdate", "news", "nfs", "ni", "nih", "nntp", "opaquelocktoken", "pkcs11", "pop", "pres", "reload", "rtsp", "rtsps", "rtspu", "service", "session", "shttp", "sieve", "sip", "sips", "sms", "snmp", "soap.beep", "soap.beeps", "stun", "stuns", "tag", "tel", "telnet", "tftp", "thismessage", "tip", "tn3270", "turn", "turns", "tv", "urn", "vemmi", "vnc", "ws", "wss", "xcon", "xcon-userid", "xmlrpc.beep", "xmlrpc.beeps", "xmpp", "z39.50r", "z39.50s"]

private let ignoredSchemes = ["data"]
private let supportedSchemes = permanentURISchemes.filter { !ignoredSchemes.contains($0) }

extension URL {
  /**
   Returns whether the URL's scheme is one of those listed on the official list of URI schemes.
   This only accepts permanent schemes: historical and provisional schemes are not accepted.
   */
  public var schemeIsValid: Bool {
    guard let scheme = scheme else { return false }
    return supportedSchemes.contains(scheme.lowercased())
  }
}

extension CharacterSet {
  public static let URLAllowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/?#[]@!$&'()*+,;=%")
  public static let SearchTermsAllowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789*-_.")
}

class URIFixup {
  static func removeQueryAndFragment(from url: URL?) -> URL? {
    guard  let url else { return nil }
    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    components?.query = nil
    components?.fragment = nil
    return components?.url
  }
  
  private static func validateURL(_ url: URL) -> URL? {
    // Validate the domain to make sure it doesn't have any invalid characters
    // IE: quotes, etc..
    if let host = url.host {
      guard let decodedASCIIURL = host.removingPercentEncoding else {
        return nil
      }
      
      if decodedASCIIURL.rangeOfCharacter(from: CharacterSet.URLAllowed.inverted) != nil {
        return nil
      }
    }
    
    return url
  }
  
  
  static func getURL(entry: String?) -> URL? {
    guard let entry = entry else { return nil }
    let trimmed = entry.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let escaped = trimmed.addingPercentEncoding(withAllowedCharacters: .URLAllowed) else {
      return nil
    }
    
    // Then check if the URL includes a scheme. This will handle
    // all valid requests starting with "http://", "about:", etc.
    // However, we ensure that the scheme is one that is listed in
    // the official URI scheme list, so that other such search phrases
    // like "filetype:" are recognised as searches rather than URLs.
    if let url = URL(string: escaped), url.schemeIsValid {
      return validateURL(url)
    }
    
    // If there's no scheme, we're going to prepend "http://". First,
    // make sure there's at least one "." in the host. This means
    // we'll allow single-word searches (e.g., "foo") at the expense
    // of breaking single-word hosts without a scheme (e.g., "localhost").
    if trimmed.range(of: ".") == nil {
      return nil
    }
    
    if trimmed.range(of: " ") != nil {
      return nil
    }
    
    // Partially canonicalize the URL and check if it has a "user"..
    // If it is, it should go to the search engine and not the DNS server..
    // This behaviour is mimicking SAFARI! It has the safest behaviour so far.
    //
    // 1. If the url contains just "user@domain.com", ALL browsers take you to the search engine.
    // 2. If it's an email with a PATH or QUERY such as "user@domain.com/whatever"
    //    where "/whatever" is the path or "user@domain.com?something=whatever"
    //    where "?something=whatever" is the query:
    //    - Firefox warns you that a site is trying to log you in automatically to the domain.
    //    - Chrome takes you to the domain (seems like a security flaw).
    //    - Safari passes on the entire url to the Search Engine just like it does
    //      without a path or query.
    if URL(string: trimmed)?.user != nil ||
        URL(string: escaped)?.user != nil ||
        URL(string: "http://\(trimmed)")?.user != nil ||
        URL(string: "http://\(escaped)")?.user != nil {
      return nil
    }
    
    // If there is a ".", prepend "http://" and try again. Since this
    // is strictly an "http://" URL, we also require a host.
    if let url = URL(string: "http://\(escaped)"), url.host != nil {
      return validateURL(url)
    }
    
    return nil
  }
  
  static func addWWWIfNeed(url: URL) -> String {
    let string = url.absoluteString
    if string.contains("www.") { return string }
    if string.starts(with: "http://") {
      return string.replacingOccurrences(of: "http://", with: "http://www.")
    }
    return string.replacingOccurrences(of: "https://", with: "https://www.")
  }
}
