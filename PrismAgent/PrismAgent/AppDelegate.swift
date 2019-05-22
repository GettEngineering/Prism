//
//  AppDelegate.swift
//  PrismAgent
//
//  Created by Shai Mishali on 12/05/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Cocoa
import os
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private var state = State.idle {
        didSet {
            applyState()
        }
    }

    private var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private var activity: NSProgressIndicator = {
        let activity = NSProgressIndicator(frame: .zero)
        activity.style = .spinning
        activity.startAnimation(nil)
        activity.isHidden = true

        return activity
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        constructMenu()
        copyLaunchAgent()
    }

    private func copyLaunchAgent() {
        if !SMLoginItemSetEnabled("com.gett.PrismHelper" as CFString, true) {
            os_log("Failed enabled Login Item", log: log, type: .error)
        } else {
            os_log("Added Prism Login Item", log: log, type: .info)
        }
    }

    private func showError(message: String) {
        state = .idle
        let alert = NSAlert()
        alert.messageText = "Something went wrong..."
        alert.informativeText = message
        alert.icon = NSImage(named: NSImage.Name("palette"))
        alert.addButton(withTitle: "Dismiss")
        alert.runModal()
    }

    @objc private func generate(_ sender: NSMenuItem) {
        state = .loading

        guard let platform = Platform(keyEquivalent: sender.keyEquivalent) else {
            preconditionFailure("Platform can only be iOS or Android. Something is wrong.")
        }

        let request = platform.workflowRequest
        os_log("Running %{public}s with JSON body: %{public}s",
               log: log, type: .info,
               request.description,
               String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "{}")

        URLSession.shared.dataTask(with: platform.workflowRequest) { [weak self] data, response, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    os_log("Failed HTTP Request: %{public}s", log: log, type: .error, error.localizedDescription)
                    self.showError(message: "HTTP Request failed: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    os_log("Got back `nil` Data", log: log, type: .error)
                    self.showError(message: "Failed retrieving response data")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(WorkflowResponse.self, from: data)

                    os_log("Launched build %{public}d: %{public}s", log: log, type: .info, response.buildNumber, "\(response)")

                    self.state = .idle

                    let alert = NSAlert()
                    alert.messageText = "Generating \(platform.rawValue) Style Guide!"
                    alert.informativeText = "A Style Guide including text styles and colors is currently being generated for your \(platform.rawValue) app. Tap the \"See Build\" button below for additional information."
                    alert.addButton(withTitle: "Dismiss")
                    alert.addButton(withTitle: "See Build")
                    alert.icon = NSImage(named: NSImage.Name("palette"))

                    if alert.runModal() == alertGoToBuild {
                        NSWorkspace.shared.open(response.buildURL)
                    }
                } catch let err {
                    self.showError(message: "Failed decoding response: \(err.localizedDescription)")
                }
            }
        }.resume()
    }

    private func applyState() {
        switch state {
        case .loading:
            activity.isHidden = false
            statusItem.button?.image = nil
            statusItem.button?.cell?.isHighlighted = false
            statusItem.button?.isEnabled = false
        case .idle:
            activity.isHidden = true
            statusItem.button?.image = NSImage(named: NSImage.Name("prism"))
            statusItem.button?.cell?.isHighlighted = false
            statusItem.button?.isEnabled = true
        }
    }

    private func constructMenu() {
        guard let button = statusItem.button else { return }

        button.image = NSImage(named: NSImage.Name("prism"))
        activity.frame = CGRect(x: button.frame.origin.x,
                                y: button.frame.origin.y,
                                width: button.frame.size.height,
                                height: button.frame.size.height)
        button.addSubview(activity)

        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Generate iOS Style Guide", action: #selector(AppDelegate.generate(_:)), keyEquivalent: "I"))
        menu.addItem(NSMenuItem(title: "Generate Android Style Guide", action: #selector(AppDelegate.generate(_:)), keyEquivalent: "A"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "Q"))

        statusItem.menu = menu
    }
}

enum State {
    case idle
    case loading
}

enum Platform: String {
    case iOS = "iOS"
    case android = "Android"

    init?(keyEquivalent: String) {
        switch keyEquivalent {
        case "A":
            self = .android
        case "I":
            self = .iOS
        default:
            return nil
        }
    }

    fileprivate var workflowRequest: URLRequest {
        switch self {
        case .iOS:
            let url = URL(string: "https://app.bitrise.io/app/2ad094b6f5a78e41/build/start.json")!
            var request = URLRequest(url: url)

            let body = [
                "hook_info": [
                    "type": "bitrise",
                    "build_trigger_token": "qBtkPcyhlGbV-GLfg8cqPw"
                ],
                "build_params": [
                    "branch": "master",
                    "workflow_id": "dsm"
                ],
                "triggered_by": "prism"
            ] as [String: Any]

            guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
                fatalError("Couldn't generate workflow request for iOS")
            }

            request.allHTTPHeaderFields = ["Content-Type": "application/json"]
            request.httpBody = bodyData
            request.httpMethod = "POST"

            return request
        case .android:
            let url = URL(string: "https://app.bitrise.io/app/6fcc76912dba7b17/build/start.json")!
            var request = URLRequest(url: url)

            let body = [
                "hook_info": [
                    "type": "bitrise",
                    "build_trigger_token": "7YcSvtxAht2dcSp8Wb3vog"
                ],
                "build_params": [
                    "branch": "develop",
                    "workflow_id": "designsystem"
                ],
                "triggered_by": "prism"
            ] as [String: Any]

            guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
                fatalError("Couldn't generate workflow request for Android")
            }

            request.allHTTPHeaderFields = ["Content-Type": "application/json"]
            request.httpBody = bodyData
            request.httpMethod = "POST"

            return request
        }
    }
}

private let alertGoToBuild = NSApplication.ModalResponse(rawValue: 1001)
private let log = OSLog(subsystem: "com.gett.PrismAgent", category: "general")
