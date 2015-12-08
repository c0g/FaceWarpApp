//
//  PixIAPHelper.swift
//  inappragedemo
//
//  Created by Ray Fix on 5/1/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import Foundation

// Use enum as a simple namespace.  (It has no cases so you can't instantiate it.)
public enum PixProducts {
  
  /// TODO:  Change this to whatever you set on iTunes connect
  private static let Prefix = "ch.phiresear.pixurgery."
  
  /// MARK: - Supported Product Identifiers
  public static let warppack1 = Prefix + "warppack1"
    
  // All of the products assembled into a set of product identifiers.
  private static let productIdentifiers: Set<ProductIdentifier> = [PixProducts.warppack1]
  
  /// Static instance of IAPHelper that for rage products.
  public static let store = IAPHelper(productIdentifiers: PixProducts.productIdentifiers)
}

/// Return the resourcename for the product identifier.
func resourceNameForProductIdentifier(productIdentifier: String) -> String? {
  return productIdentifier.componentsSeparatedByString(".").last
}