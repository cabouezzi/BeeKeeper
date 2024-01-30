//
//  InspectionView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/29/24.
//

import UIKit
import SceneKit

class InspectionView: UIView {
    let structureView: SCNView
    let releaseButton: UIButton
    let scrollView: UIScrollView
    let structure: Structure
    
    private var reference: SCNNode?
    private lazy var fontSize: CGFloat = frame.size.height / 30
    private lazy var inset: CGFloat = fontSize
    
    init(structure: Structure, frame: CGRect) {
        self.structure = structure
        
        let scrollFraction = 0.5
        structureView = SCNView(frame: frame)
        structureView.scene = SCNScene(named: "ModelBase.scn")
        structureView.scene?.background.contents = UIColor.brown
        structureView.frame.size.width *= 1 - scrollFraction
        
        reference = structureView.scene?.rootNode.childNode(withName: "BeeReference", recursively: true)
        reference?.isHidden = true
        
        releaseButton = UIButton(frame: frame)
        releaseButton.isHidden = true
        
        scrollView = UIScrollView(frame: frame)
        scrollView.frame.size.width *= scrollFraction
        scrollView.frame.origin.x = structureView.frame.maxX
        scrollView.contentSize = scrollView.frame.size
        scrollView.contentSize.height = scrollView.frame.size.height
        
        super.init(frame: frame)
        addSubview(structureView)
        
        releaseButton.backgroundColor = .red
        releaseButton.setTitle("Release Bees", for: .normal)
        
        scrollView.addSubview(releaseButton)
        
        scrollView.backgroundColor = .clear
        scrollView.isDirectionalLockEnabled = true
        scrollView.canCancelContentTouches = true
        addSubview(scrollView)
        
        let info = setBasicInfo()
        let container = setContainerInfo()
        let incubator = setIncubatorInfo()
        
        addConstraints([
            container.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: inset),
            info.topAnchor.constraint(equalTo: container.bottomAnchor, constant: inset),
            incubator.topAnchor.constraint(equalTo: info.bottomAnchor, constant: inset),
        ])
        
        setModel(structure)
        backgroundColor = .baige
        
        let backButton = UIButton(frame: CGRect(x: 25, y: 25, width: frame.height / 15, height: frame.height / 15))
        backButton.setImage(UIImage(named: "backButton"), for: .normal)
        backButton.addAction { [weak self] in
            self?.removeFromSuperview()
        }
        addSubview(backButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setModel(_ structure: Structure?) {
        guard let structure = structure, let _ = reference, let geometry = structure.geometry else { return }
        let model = SCNNode(geometry: geometry)
        structureView.scene?.rootNode.addChildNode(model)
    }
    
    @discardableResult
    private func setContainerInfo() -> UIView {
        guard let container = structure as? Container else {
            let view = UIView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(view)
            return view
        }
        let section = UIView()
        section.translatesAutoresizingMaskIntoConstraints = false
        
        let containingTitle = UILabel()
        containingTitle.font = .preferredFont(forTextStyle: .largeTitle).withSize(fontSize)
        containingTitle.text = "Containing"
        containingTitle.sizeToFit()
        containingTitle.setShadow()
        
        let containingLabel = UILabel()
        containingLabel.font = .preferredFont(forTextStyle: .title1).withSize(fontSize)
        containingLabel.attributedText = container.containing.attributedString(font: containingLabel.font, roundDecimals: true)
        if containingLabel.attributedText?.length == 0 {
            containingLabel.text = "Empty"
        }
        containingLabel.sizeToFit()
        containingLabel.setShadow()
        
        let maximumTitle = UILabel()
        maximumTitle.font = .preferredFont(forTextStyle: .largeTitle).withSize(fontSize)
        maximumTitle.text = "Capacity"
        maximumTitle.sizeToFit()
        maximumTitle.setShadow()
        
        let maximumLabel = UILabel()
        maximumLabel.font = .preferredFont(forTextStyle: .title1).withSize(fontSize)
        maximumLabel.attributedText = container.maximum.attributedString(font: maximumLabel.font, roundDecimals: true)
        maximumLabel.sizeToFit()
        maximumLabel.setShadow()
        
        func updateLabels() {
            containingLabel.attributedText = container.containing.attributedString(font: containingLabel.font, roundDecimals: true)
            if containingLabel.attributedText?.length == 0 {
                containingLabel.text = "Empty"
            }
            maximumLabel.attributedText = container.maximum.attributedString(font: maximumLabel.font, roundDecimals: true)
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard self != nil else {
                timer.invalidate()
                return
            }
            updateLabels()
        }
        
        for subview in [containingTitle, containingLabel, maximumTitle, maximumLabel] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            section.addSubview(subview)
        }
        
        scrollView.addSubview(section)
        
        addConstraints([
            containingTitle.topAnchor.constraint(equalTo: section.topAnchor, constant: inset),
            containingTitle.leftAnchor.constraint(equalTo: section.leftAnchor, constant: inset),
            containingTitle.rightAnchor.constraint(equalTo: section.centerXAnchor),
            
            containingLabel.topAnchor.constraint(equalTo: containingTitle.bottomAnchor),
            containingLabel.widthAnchor.constraint(equalTo: containingTitle.widthAnchor),
            containingLabel.centerXAnchor.constraint(equalTo: containingTitle.centerXAnchor),
            
            maximumTitle.topAnchor.constraint(equalTo: section.topAnchor, constant: inset),
            maximumTitle.leftAnchor.constraint(equalTo: section.centerXAnchor),
            maximumTitle.rightAnchor.constraint(equalTo: section.rightAnchor, constant: -inset),
            
            maximumLabel.topAnchor.constraint(equalTo: maximumTitle.bottomAnchor),
            maximumLabel.widthAnchor.constraint(equalTo: maximumTitle.widthAnchor),
            maximumLabel.centerXAnchor.constraint(equalTo: maximumTitle.centerXAnchor),
            
            section.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -inset),
            section.topAnchor.constraint(greaterThanOrEqualTo: maximumTitle.topAnchor, constant: inset),
            section.bottomAnchor.constraint(greaterThanOrEqualTo: maximumLabel.bottomAnchor, constant: inset),
            section.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
        ])
        
        section.backgroundColor = .black.withAlphaComponent(0.3)
        section.layer.cornerRadius = 10
        
        return section
    }
    
    @discardableResult
    private func setBasicInfo() -> UIView {
        let section = UIView()
        section.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        
        func column(title: String, label: String) -> UIView {
            let container = UIView()
            
            let columnTitle = UILabel()
            columnTitle.translatesAutoresizingMaskIntoConstraints = false
            columnTitle.font = .preferredFont(forTextStyle: .largeTitle).withSize(fontSize)
            columnTitle.adjustsFontSizeToFitWidth = true
            columnTitle.text = title
            columnTitle.sizeToFit()
            columnTitle.setShadow()
            let columnLabel = UILabel()
            columnLabel.translatesAutoresizingMaskIntoConstraints = false
            columnLabel.font = .preferredFont(forTextStyle: .title1).withSize(fontSize)
            columnTitle.adjustsFontSizeToFitWidth = true
            columnLabel.text = label
            columnLabel.sizeToFit()
            columnLabel.setShadow()
            
            container.addSubview(columnTitle)
            container.addSubview(columnLabel)
            
            container.addConstraints([
                columnLabel.topAnchor.constraint(equalTo: columnTitle.bottomAnchor),
                container.widthAnchor.constraint(greaterThanOrEqualTo: columnTitle.widthAnchor),
                container.widthAnchor.constraint(greaterThanOrEqualTo: columnLabel.widthAnchor),
                container.topAnchor.constraint(equalTo: columnTitle.topAnchor),
                container.bottomAnchor.constraint(equalTo: columnLabel.bottomAnchor),
            ])
            return container
        }
        
        stack.addArrangedSubview(column(title: "Name", label: structure.name ?? "Structure"))
        stack.addArrangedSubview(column(title: "Area", label: structure.area.width.description + " x " + structure.area.height.description))
        stack.addArrangedSubview(column(title: "Maximum Bees", label: structure.maximumAssignedBees.description))
        
        section.addSubview(stack)
        scrollView.addSubview(section)
        
        addConstraints([
            stack.topAnchor.constraint(equalTo: section.topAnchor, constant: inset),
            stack.leftAnchor.constraint(equalTo: section.leftAnchor, constant: inset),
            stack.rightAnchor.constraint(equalTo: section.rightAnchor, constant: -inset),
            
            section.topAnchor.constraint(greaterThanOrEqualTo: stack.topAnchor, constant: inset),
            section.bottomAnchor.constraint(greaterThanOrEqualTo: stack.bottomAnchor, constant: inset),
            section.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -inset),
            section.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            section.bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: inset),
        ])
        
        section.backgroundColor = .black.withAlphaComponent(0.3)
        section.layer.cornerRadius = 10
        
        return section
    }
    
    @discardableResult
    private func setIncubatorInfo() -> UIView {
        guard let incubator = structure as? Incubator else {
            let view = UIView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(view)
            return view
        }
        
        let section = UIView()
        section.translatesAutoresizingMaskIntoConstraints = false
        
        let statusTitle = UILabel()
        statusTitle.translatesAutoresizingMaskIntoConstraints = false
        statusTitle.font = .preferredFont(forTextStyle: .largeTitle).withSize(fontSize)
        statusTitle.adjustsFontSizeToFitWidth = true
        statusTitle.text = "Status"
        statusTitle.sizeToFit()
        statusTitle.setShadow()
        
        let statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .preferredFont(forTextStyle: .largeTitle).withSize(fontSize)
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.sizeToFit()
        statusLabel.setShadow()
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline).withSize(fontSize)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.setShadow()
        button.sizeToFit()
        button.backgroundColor = .orange
        button.layer.cornerRadius = 10
        
        func update() {
            switch incubator.state {
            case .idle:
                statusLabel.text = "No incubation in progress"
                button.setTitle("Incubate", for: .normal)
            case .incubating:
                guard let period = incubator.currentPeriod else { break }
                statusLabel.text = "Time Left: " + Date.now.distance(to: period.finishTime).formattedString()
                button.setTitle("Speed Up?", for: .normal)
            case .finished:
                statusLabel.text = "Done"
                button.setTitle("Hatch", for: .normal)
            }
        }
        update()
        button.addAction { [unowned self, unowned incubator] in
            switch incubator.state {
            case .idle:
                try? incubator.startIncubating(100)
            case .incubating:
                try? incubator.forceFinish()
            case .finished:
                do {
                    try incubator.hatch()
                    removeFromSuperview()
                } catch{}
            }
            update()
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard self != nil else {
                timer.invalidate()
                return
            }
            update()
        }
        
        for subview in [statusTitle, statusLabel, button] {
            section.addSubview(subview)
        }
        scrollView.addSubview(section)
        
        addConstraints([
            statusTitle.widthAnchor.constraint(equalTo: section.widthAnchor, constant: -inset),
            statusTitle.centerXAnchor.constraint(equalTo: section.centerXAnchor),
            statusTitle.topAnchor.constraint(equalTo: section.topAnchor, constant: inset),
            statusLabel.widthAnchor.constraint(equalTo: statusTitle.widthAnchor, constant: -inset),
            statusLabel.centerXAnchor.constraint(equalTo: statusTitle.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: statusTitle.bottomAnchor, constant: inset),
            button.widthAnchor.constraint(equalTo: statusLabel.widthAnchor),
            button.centerXAnchor.constraint(equalTo: statusLabel.centerXAnchor),
            button.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: inset),
            button.heightAnchor.constraint(equalTo: statusTitle.heightAnchor, multiplier: 2),
            section.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -inset),
            section.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            section.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: inset)
        ])
        
        section.backgroundColor = .black.withAlphaComponent(0.3)
        section.layer.cornerRadius = 10
        
        return section
    }
}
