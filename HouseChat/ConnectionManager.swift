//
//  ConnectionManager.swift
//  HouseChat
//
//  Created by Linus Skucas on 12/3/20.
//

import Foundation
import MultipeerConnectivity


class ConnectionManager: NSObject, ObservableObject, MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate {
    
    static let serviceType = "housechat"
    
    @Published var messages: [Message] = []
    @Published var connected = false
    @Published var frens: [MCPeerID] = []
    
    let myFrenId = MCPeerID(displayName: UIDevice.current.name)
    private var hosting = false
    private var session: MCSession?
    private var advertiserAssistant: MCNearbyServiceAdvertiser?
    
    func hostChat() {
        hosting = true
        self.frens.removeAll()
        self.messages.removeAll()
        connected = true
        session = MCSession(peer: myFrenId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        advertiserAssistant = MCNearbyServiceAdvertiser(peer: myFrenId, discoveryInfo: nil, serviceType: ConnectionManager.serviceType)
        advertiserAssistant?.delegate = self
        advertiserAssistant?.startAdvertisingPeer()
    }
    
    func joinChat() {
        frens.removeAll()
        messages.removeAll()
        session = MCSession(peer: myFrenId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        
        guard let window = UIApplication.shared.windows.first,
              let session = session else { return }
        let mcBrowserViewController = MCBrowserViewController(serviceType: Self.serviceType, session: session)
        mcBrowserViewController.delegate = self
        window.rootViewController?.present(mcBrowserViewController, animated: true)
    }
    
    func leaveChat() {
        hosting = false
        connected = false
        advertiserAssistant?.stopAdvertisingPeer()
        messages.removeAll()
        session = nil
        advertiserAssistant = nil
    }
    
    func sendMessage(_ message: String) {
        let newMessage = Message(displayName: myFrenId.displayName, message: message)
        messages.append(newMessage)
        
        guard let session = session,
              let data = message.data(using: .utf8),
              !session.connectedPeers.isEmpty else { return }
        
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            messages.append(Message(displayName: "System", message: "Failed to send last message."))
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            DispatchQueue.main.async {
                if let index = self.frens.firstIndex(of: peerID) {
                    self.frens.remove(at: index)
                }
                if self.frens.isEmpty && !self.hosting {
                    self.connected = false
                }
            }
        case .connecting:
            print("\(peerID.displayName) is connecting ✨")
        case .connected:
            if !frens.contains(peerID) {
                DispatchQueue.main.async {
                    self.frens.insert(peerID, at: 0)
                }
            }
        @unknown default:
            print("idk what happened")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {  // TODO
        guard let newMessage = String(data: data, encoding: .utf8) else { return }
        let message = Message(displayName: peerID.displayName, message: newMessage)
        DispatchQueue.main.async {
            self.messages.append(message)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true) {
            self.connected = true
        }
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        session?.disconnect()
        browserViewController.dismiss(animated: true)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}
