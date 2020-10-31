//
//  RCTContextMenuView.swift
//  nativeUIModulesTest
//
//  Created by Dominic Go on 7/14/20.
//

import Foundation
import UIKit


@available(iOS 13, *)
class RCTContextMenuView: UIView {
  
  var isContextMenuVisible = false;
  var didPressMenuItem     = false;
  
  // ---------------------------------------------
  // MARK: RCTContextMenuView - RN Event Callbacks
  // ---------------------------------------------
  
  @objc var onMenuWillShow  : RCTBubblingEventBlock?;
  @objc var onMenuWillHide  : RCTBubblingEventBlock?;
  @objc var onMenuWillCancel: RCTBubblingEventBlock?;
  
  @objc var onMenuDidShow  : RCTBubblingEventBlock?;
  @objc var onMenuDidHide  : RCTBubblingEventBlock?;
  @objc var onMenuDidCancel: RCTBubblingEventBlock?;
  
  @objc var onPressMenuItem   : RCTBubblingEventBlock?;
  @objc var onPressMenuPreview: RCTBubblingEventBlock?;
  
  // -----------------------------------
  // MARK: RCTContextMenuView - RN Props
  // -----------------------------------
    
  private var _menuConfig: RCTMenuItem?;
  @objc var menuConfig: NSDictionary? {
    didSet {
      guard
        let menuConfig = self.menuConfig,
        menuConfig.count > 0 else { return };
      
      #if DEBUG
      print("menuConfig didSet"
        + " - RCTMenuItem init"
        + " - menuConfig count: \(menuConfig.count)"
      );
      #endif
      
      self._menuConfig = RCTMenuItem(dictionary: menuConfig);
    }
  };
  
  // -------------------------------
  // MARK: RCTContextMenuView - Init
  // -------------------------------
  
  init(bridge: RCTBridge) {
    super.init(frame: CGRect());
    
    let interaction = UIContextMenuInteraction(delegate: self);
    self.addInteraction(interaction);
  };
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented");
  };
  
  override func reactSetFrame(_ frame: CGRect) {
    super.reactSetFrame(frame);
  };
};

// -----------------------------------------------------------
// MARK: RCTContextMenuView - UIContextMenuInteractionDelegate
// -----------------------------------------------------------

@available(iOS 13, *)
extension RCTContextMenuView: UIContextMenuInteractionDelegate {
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
    guard  let menuConfig = self._menuConfig else {
      #if DEBUG
      print("RCTContextMenuView, UIContextMenuInteractionDelegate"
        + " - contextMenuInteraction: config"
        + " - guard check failed, menuConfig: nil"
      );
      #endif
      return nil;
    };
    
    return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
      return menuConfig.createMenu { (dict, action) in
        self.didPressMenuItem = true;
        self.onPressMenuItem?(dict);
      };
    });
  };
  
  // context menu display begins
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willDisplayMenuFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
    #if DEBUG
    print("RCTContextMenuView, UIContextMenuInteractionDelegate"
      + " - contextMenuInteraction: will show"
    );
    #endif

    self.isContextMenuVisible = true;
    
    self.onMenuWillShow?([:]);
    animator?.addCompletion {
      self.onMenuDidShow?([:]);
    };
  };
  
  // context menu display ends
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
    #if DEBUG
    print("RCTContextMenuView, UIContextMenuInteractionDelegate"
      + " - contextMenuInteraction: will hide"
    );
    #endif
    
    guard self.isContextMenuVisible else { return };
    
    self.onMenuWillHide?([:]);
    if !self.didPressMenuItem {
      self.onMenuWillCancel?([:]);
    };
    
    animator?.addCompletion {
      if !self.didPressMenuItem {
        self.onMenuDidCancel?([:]);
      };
      
      self.onMenuDidHide?([:]);
      self.didPressMenuItem = false;
    };
    
    self.isContextMenuVisible = false;
  };
  
  // context menu preview tapped
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
    #if DEBUG
    print("RCTContextMenuView, UIContextMenuInteractionDelegate"
      + " - contextMenuInteraction: preview tapped"
    );
    #endif
    self.isContextMenuVisible = false;
    self.onPressMenuPreview?([:]);
  };
};