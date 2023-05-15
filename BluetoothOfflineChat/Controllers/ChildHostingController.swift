//
//  ChildHostingController.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 05/05/2023.
//

import Foundation
import UIKit
import SwiftUI

struct MainTabbedView: View {

    var body: some View {
        ZStack{

        }
    }
}

class ChildHostingController: UIHostingController<MainTabbedView> {
    
    required init?(coder: NSCoder) {
            super.init(coder: coder,rootView: MainTabbedView());
        }

        override func viewDidLoad() {
            super.viewDidLoad()
        }
}
