//
//  UIViewControllerExtension.swift
//  Sipradi
//
//  Created by bibek timalsina on 5/25/17.
//  Copyright © 2017 Ekbana. All rights reserved.
//

import UIKit
import MBProgressHUD


// MARK: Alerts

extension UIViewController {
    
    func confirmationAlert(title: String, message: String, confirmTitle: String, style: UIAlertActionStyle = .destructive, confirmAction: @escaping () -> Void) {
        let deleteActionSheetController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: confirmTitle, style: style) {
            action -> Void in
            confirmAction()
        }
        
        let cancelAction = UIAlertAction(title: "text_cancel".localized(), style: .cancel) { action -> Void in
            
        }
        
        deleteActionSheetController.addAction(deleteAction)
        deleteActionSheetController.addAction(cancelAction)
        
        self.present(deleteActionSheetController, animated: true, completion: nil)
    }
    
    func alert(message: String?, title: String? = "text_error".localized(), okAction: (()->())? = nil) {
        let alertController = getAlert(message: message, title: title)
        alertController.addAction(title: "btn_okay".localized(), handler: okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alertWithOkCancel(message: String?, title: String? = "text_error".localized(), okTitle: String? = "btn_okay".localized(), style: UIAlertControllerStyle? = .alert, cancelTitle: String? = "text_cancel".localized(), OkStyle: UIAlertActionStyle = .default, cancelStyle: UIAlertActionStyle = .default, okAction: (()->())? = nil, cancelAction: (()->())? = nil) {
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

// MARK: HUD
extension UIViewController {
    
    private func setProgressHud() -> MBProgressHUD {
        let progressHud:  MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHud.tintColor = UIColor.darkGray
        progressHud.removeFromSuperViewOnHide = true
        objc_setAssociatedObject(self, &Associate.hud, progressHud, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return progressHud
    }
    
    var progressHud: MBProgressHUD {
        if let progressHud = objc_getAssociatedObject(self, &Associate.hud) as? MBProgressHUD {
            progressHud.isUserInteractionEnabled = true
            return progressHud
        }
        return setProgressHud()
    }
    
    var progressHudIsShowing: Bool {
        return self.progressHud.isHidden
    }
    
    func showProgressHud() {
        self.progressHud.show(animated: false)
    }
    
    func hideProgressHud() {
        self.progressHud.label.text = ""
        self.progressHud.completionBlock = {
            objc_setAssociatedObject(self, &Associate.hud, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        self.progressHud.hide(animated: false)
    }
}


@objc protocol Setup {
    @objc optional func setupTabItem()
}

//extension Setup where Self: UIViewController {
//    func setupTabItem() {
//        print("setup tab item")
//    }
//}

extension UIViewController: Setup {
    func setupTabItem() {
        
    }
}
