//
//  HudView.swift
//  MyLocation
//
//  Created by Zexi Chen on 8/12/16.
//  Copyright © 2016 ChenZexi. All rights reserved.
//

import UIKit
import Dispatch

class HudView: UIView {
	var text = ""
	var textView:UILabel?

	class func hudInView(view: UIView, animated: Bool) -> HudView {
		let hudView = HudView(frame: view.bounds)
		hudView.opaque = false

		view.addSubview(hudView)
		view.userInteractionEnabled = false

//		hudView.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
		hudView.showAnimatede(animated)
		return hudView
	}

	override func drawRect(rect: CGRect) {
		let boxWidth: CGFloat = 96
		let boxHeight: CGFloat = 96

		let boxRect = CGRect(
			x: round((bounds.size.width - boxWidth)/2),
			y: round((bounds.size.height - boxHeight)/2),
			width: boxWidth,
			height: boxHeight)

		let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
		UIColor(white: 0.3, alpha: 0.8).setFill() // 注意设置颜色的方式
		roundedRect.fill()

		//加入image assets
		if let image = UIImage(named: "Checkmark") {
			let imagePoint = CGPoint(
				x: center.x - round(image.size.width/2),
				y: center.y	- round(image.size.height/2 + boxHeight/8)
			)
			image.drawAtPoint(imagePoint)
		}

		//文字描述
		let attribs = [ NSFontAttributeName: UIFont.systemFontOfSize(16),
		                NSForegroundColorAttributeName: UIColor.whiteColor()]

		let textSize = text.sizeWithAttributes(attribs)

		let textPoint = CGPoint(
			x: center.x - round(textSize.width/2),
			y: center.y	- round(textSize.height/2) + boxHeight / 4
		)

		text.drawAtPoint(textPoint, withAttributes: attribs)
	}

	func showAnimatede(animated: Bool) {
		if animated {
			alpha = 0
			transform = CGAffineTransformMakeScale(1.3, 1.3)
			UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
				self.alpha = 1
				self.transform = CGAffineTransformIdentity
				}, completion: nil)
		}
	}

}
