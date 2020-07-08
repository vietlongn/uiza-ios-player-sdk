//
//  ViewController.swift
//  UZPlayerExample
//
//  Created by Nam Kennic on 3/17/20.
//  Copyright © 2020 Uiza. All rights reserved.
//

import UIKit
//import UZPlayer

class ViewController: UIViewController {
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		UZPlayerSDK.initWith(enviroment: .development)
		UZPlayerSDK.showRestfulInfo = true
		
		askForURL()
	}
/// UserDefaults.standard.string(forKey: "last_url") ?? "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
	func askForURL() {
//		let prefilled = "https://1955897154.rsc.cdn77.org/live/8dee8601-931e-409a-b2e8-aa84761add1e/master.m3u8?cm=eyJlbnRpdHlfaWQiOiI4ZGVlODYwMS05MzFlLTQwOWEtYjJlOC1hYTg0NzYxYWRkMWUiLCJlbnRpdHlfc291cmNlIjoibGl2ZSIsImFwcF9pZCI6IjhhZTY3ZDlmM2EyNzQyODVhMTUwNmUzZjc3Njc5MmVhIn0="
		let prefilled = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
        
		let alertController = UIAlertController(title: "", message: "Please enter videoURL", preferredStyle: .alert)
		alertController.addTextField { (textField) in
			textField.font = UIFont(name: "Avenir", size: 14)
			textField.keyboardType = .URL
			textField.clearButtonMode = .whileEditing
			textField.text = prefilled
            textField.frame.size.height = 153
		}
		alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (action) in
			if let string = alertController.textFields?.first?.text, !string.isEmpty {
				UserDefaults.standard.set(string, forKey: "last_url")
				alertController.dismiss(animated: true, completion: nil)
				self?.presentFloatingPlayer(urlPath: string)
			}
			else {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					self?.askForURL()
				}
			}
		}))
		present(alertController, animated: true, completion: nil)
	}
	
	func presentFloatingPlayer(urlPath: String) {
		guard let url = URL(string: urlPath) else { return }
		let floatingPlayerViewController = UZFloatingPlayerViewController()
        let videoItem = UZVideoItem(name: nil, thumbnailURL: nil, linkPlay: UZVideoLinkPlay(definition: "", url: url), subtitleURLs: nil)
		floatingPlayerViewController.present(with: videoItem, playlist: nil).player.controlView.theme = UZTheme1()
        print("extIsTimeshift = \(videoItem.extIsTimeshift)")
        print("linkPlay = \(videoItem.linkPlay?.url.absoluteString ?? "")")
          print("extLinkPlay = \(videoItem.extLinkPlay?.url.absoluteString ?? "")")
		floatingPlayerViewController.onDismiss = { [weak self] in
			self?.askForURL()
		}
	}
	
	override open var prefersStatusBarHidden: Bool {
		return true
	}
	
	override open var shouldAutorotate: Bool {
		return false
	}
	
	override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return UIDevice.current.userInterfaceIdiom == .phone ? .portrait : UIApplication.shared.statusBarOrientation
	}
	
	override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIDevice.current.userInterfaceIdiom == .phone ? .portrait : .all
	}
	
}

