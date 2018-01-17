//  Created by shishir sapkota on 1/17/18.
//  Copyright © 2018 ccr. All rights reserved.
//

import UIKit

// MARK: Alerts

extension UIViewController {

    func confirmationAlert(title: String, message: String, confirmTitle: String, style: UIAlertActionStyle = .destructive, confirmAction: @escaping () -> Void) {
        let deleteActionSheetController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: confirmTitle, style: style) {
            action -> Void in
            confirmAction()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        deleteActionSheetController.addAction(deleteAction)
        deleteActionSheetController.addAction(cancelAction)
        self.present(deleteActionSheetController, animated: true, completion: nil)
    }

    func alert(message: String?, title: String? = "error", okAction: (()->())? = nil) {
        let alertController = getAlert(message: message, title: title)
        alertController.addAction(title: "Ok", handler: okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func alertWithOkCancel(message: String?, title: String? = "error", okTitle: String? = "Ok", style: UIAlertControllerStyle? = .alert, cancelTitle: String? = "Cancel", OkStyle: UIAlertActionStyle = .default, cancelStyle: UIAlertActionStyle = .default, okAction: (()->())? = nil, cancelAction: (()->())? = nil) {
        let alertController = getAlert(message: message, title: title, style: style)
        alertController.addAction(title: okTitle,style: OkStyle, handler: okAction)
        alertController.addAction(title: cancelTitle, style: cancelStyle, handler: cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    private func getAlert(message: String?, title: String?, style: UIAlertControllerStyle? = .alert) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: style ?? .alert)
    }

    func present(_ alert: UIAlertController, asActionsheetInSourceView sourceView: Any) {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            alert.modalPresentationStyle = .popover
            if let presenter = alert.popoverPresentationController {
                if sourceView is UIBarButtonItem {
                    presenter.barButtonItem = sourceView as? UIBarButtonItem
                }else if sourceView is UIView {
                    let view = sourceView as! UIView
                    presenter.sourceView = view
                    presenter.sourceRect = view.bounds
                }
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
}


extension UIAlertController {
    func addAction(title: String?, style: UIAlertActionStyle = .default, handler: (()->())? = nil) {
        let action = UIAlertAction(title: title, style: style, handler: {_ in
            handler?()
        })
        self.addAction(action)
    }
}

struct Associate {
    static var hud: UInt8 = 0
    static var empty: UInt8 = 0
}
