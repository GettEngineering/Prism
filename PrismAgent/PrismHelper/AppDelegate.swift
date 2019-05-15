//
//  AppDelegate.swift
//  PrismHelper
//
//  Created by Shai Mishali on 13/05/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        defer { NSApp.terminate(nil) }

        guard !NSWorkspace.shared.runningApplications.contains(where: { $0.bundleIdentifier == "com.gett.PrismAgent" }) else {
            print("Agent already running, exiting")
            return
        }

        NSWorkspace.shared.launchApplication(withBundleIdentifier: "com.gett.PrismAgent",
                                             options: .init(),
                                             additionalEventParamDescriptor: nil,
                                             launchIdentifier: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

