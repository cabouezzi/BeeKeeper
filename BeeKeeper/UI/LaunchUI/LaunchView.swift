//
//  LaunchView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/21/24.
//

import UIKit

class LaunchView: UIView {
    let background: UIImageView
    let logo: UIImageView
    let progress: UIProgressView
    let label: UILabel
    private var loadingTask: Task<Void, Never>?
    
    override init(frame: CGRect) {
        background = UIImageView(frame: frame)
        background.image = UIImage(named: "background-hexagons")
        background.contentMode = .scaleAspectFill
        
        logo = UIImageView(frame: frame)
        logo.image = UIImage(named: "logo")
        logo.contentMode = .scaleAspectFit
        
        progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .lightGray
        progress.progressTintColor = .orange
        progress.layer.cornerRadius = 10
        progress.layer.borderWidth = 1
        progress.layer.borderColor = UIColor.white.cgColor
        progress.clipsToBounds = true
        
        label = UILabel()
        label.text = "Loading"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.textAlignment = .center
        label.setShadow()
        super.init(frame: frame)
        addSubview(background)
        addSubview(logo)
        addSubview(progress)
        addSubview(label)
        
        logo.translatesAutoresizingMaskIntoConstraints = false
        progress.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            logo.centerXAnchor.constraint(equalTo: centerXAnchor),
            logo.bottomAnchor.constraint(equalTo: centerYAnchor),
            logo.heightAnchor.constraint(equalToConstant: frame.height / 4),
            logo.widthAnchor.constraint(equalTo: logo.heightAnchor),
            
            progress.centerXAnchor.constraint(equalTo: centerXAnchor),
            progress.topAnchor.constraint(equalTo: logo.bottomAnchor),
            progress.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            progress.heightAnchor.constraint(equalToConstant: 50),
            
            label.leftAnchor.constraint(equalTo: progress.leftAnchor),
            label.rightAnchor.constraint(equalTo: progress.rightAnchor),
            label.topAnchor.constraint(equalTo: progress.topAnchor),
            label.bottomAnchor.constraint(equalTo: progress.bottomAnchor),
        ])
        
        progress.setProgress(0, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            loadingTask?.cancel()
            loadingTask = nil
        } else if loadingTask == nil {
            loadingTask = Task { @MainActor [weak self] in
                var index = 0
                while !Task.isCancelled {
                    guard self != nil else { return }
                    index = (index + 1) % 4
                    self?.label.text = "Loading" + String(repeating: ".", count: index)
                    do {
                        try await Task.sleep(for: .seconds(1))
                    } catch {
                        return
                    }
                }
            }
        }
    }

    func showError(_ message: String) {
        loadingTask?.cancel()
        loadingTask = nil
        label.text = message
    }

    deinit {
        loadingTask?.cancel()
    }
}
