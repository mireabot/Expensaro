//
//  Currency.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 1/9/24.
//

import Foundation

struct Currency: Hashable {
  let name: String
  let code: String
  let symbol: String
}

extension Locale {
  func localizedCurrencySymbol(forCurrencyCode currencyCode: String) -> String? {
    guard let languageCode = language.languageCode?.identifier, let regionCode = region?.identifier else { return nil }
    
    let components: [String: String] = [
      NSLocale.Key.languageCode.rawValue: languageCode,
      NSLocale.Key.countryCode.rawValue: regionCode,
      NSLocale.Key.currencyCode.rawValue: currencyCode
    ]
    
    let identifier = Locale.identifier(fromComponents: components)
    
    return Locale(identifier: identifier).currencySymbol
  }
}

extension Currency {
  static var currencyCodes: [String] = ["AED", "AFN", "ALL", "AMD", "ANG", "AOA", "ARS", "AUD", "AWG", "AZN", "BAM", "BBD", "BDT", "BGN", "BHD", "BIF", "BMD", "BND", "BOB", "BRL", "BSD", "BTN", "BWP", "BYN", "BZD", "CAD", "CDF", "CHF", "CLP", "CNY", "COP", "CRC", "CUP", "CVE", "CZK", "DJF", "DKK", "DOP", "DZD", "EGP", "ERN", "ETB", "EUR", "FJD", "FKP", "GBP", "GEL", "GHS", "GIP", "GMD", "GNF", "GTQ", "GYD", "HKD", "HNL", "HRK", "HTG", "HUF", "IDR", "ILS", "INR", "IQD", "IRR", "ISK", "JMD", "JOD", "JPY", "KES", "KGS", "KHR", "KMF", "KPW", "KRW", "KWD", "KYD", "KZT", "LAK", "LBP", "LKR", "LRD", "LYD", "MAD", "MDL", "MGA", "MKD", "MMK", "MNT", "MOP", "MRU", "MUR", "MVR", "MWK", "MXN", "MYR", "MZN", "NAD", "NGN", "NIO", "NOK", "NPR", "NZD", "OMR", "PAB", "PEN", "PGK", "PHP", "PKR", "PLN", "PYG", "QAR", "RON", "RSD", "RUB", "RWF", "SAR", "SBD", "SCR", "SDG", "SEK", "SGD", "SHP", "SLL", "SOS", "SRD", "SSP", "STN", "SYP", "SZL", "THB", "TJS", "TMT", "TND", "TOP", "TRY", "TTD", "TWD", "TZS", "UAH", "UGX", "USD", "UYU", "UZS", "VES", "VND", "VUV", "WST", "XAF", "XCD", "XOF", "XPF", "YER", "ZAR", "ZMW"]
  
  static var allCurrencies: [Currency] {
    let currencies: [Currency] = currencyCodes.compactMap {
      let name = Locale.current.localizedString(forCurrencyCode: $0) ?? ""
      let symbol = Locale.current.localizedCurrencySymbol(forCurrencyCode: $0) ?? ""
      return Currency(name: name, code: $0, symbol: symbol)
    }
    return currencies
  }
}
