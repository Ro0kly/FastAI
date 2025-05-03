//
//  PaddingLabel.swift
//  FastAI
//
//  Created by Rookly on 01.05.2025.
//

import Foundation
import UIKit

final class PaddingLabel: UILabel {

   let topInset: CGFloat = 10
   let bottomInset: CGFloat = 10
   let leftInset: CGFloat = 10
   let rightInset: CGFloat = 10

   override func drawText(in rect: CGRect) {
      let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
       super.drawText(in: rect.inset(by: insets))
   }

   override var intrinsicContentSize: CGSize {
      get {
         var contentSize = super.intrinsicContentSize
         contentSize.height += topInset + bottomInset
         contentSize.width += leftInset + rightInset
         return contentSize
      }
   }
}
