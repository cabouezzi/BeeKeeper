//
//  EvolutionGeneDataView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/27/24.
//

import UIKit

struct GeneData {
    let gene: Gene
    let details: String
    let cost: Resources
}

class EvolutionGeneDataView: UIScrollView {
    private var data: GeneData?
    private var iconView: UIImageView
    private var titleLabel: UILabel
    private var detailsLabel: UILabel
    private var costLabel: UILabel
    
    override init(frame: CGRect) {
        let size = min(frame.size.width, frame.size.height)
        let inset = size * 0.1
        
        let iconRect = CGRect(x: 0, y: 0, width: size, height: size).insetBy(dx: inset, dy: inset)
        iconView = UIImageView(frame: iconRect)
        iconView.backgroundColor = .clear
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = .clear
        
        let detailsRect = CGRect(x: 0, y: iconRect.maxY, width: frame.width, height: inset * 2).insetBy(dx: inset, dy: inset)
        detailsLabel = UILabel(frame: detailsRect)
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.backgroundColor = .clear
        
        let costRect = CGRect(x: 0, y: detailsRect.maxY, width: frame.width, height: frame.width).insetBy(dx: inset, dy: inset)
        costLabel = UILabel(frame: costRect)
        costLabel.translatesAutoresizingMaskIntoConstraints = false
        costLabel.backgroundColor = .clear
        
        super.init(frame: frame)
        
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(detailsLabel)
        addSubview(costLabel)
        
        let content = subviews.reduce(CGRect.zero, { $0.union($1.frame) })
        contentSize = content.size
        
        layer.cornerRadius = 10
        backgroundColor = .darkGray
        
        addConstraints([
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: inset),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: inset),
            detailsLabel.widthAnchor.constraint(equalTo: iconView.widthAnchor),
            detailsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            costLabel.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: inset),
            costLabel.widthAnchor.constraint(equalTo: detailsLabel.widthAnchor),
            costLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setGeneData(_ data: GeneData) {
        let image = UIImage(cgImage: data.gene.texture.cgImage())
        iconView.contentMode = .scaleAspectFit
        iconView.image = image
        
        titleLabel.text = data.gene.rawValue
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        
        detailsLabel.text = data.details
        detailsLabel.font = .preferredFont(forTextStyle: .body)
        detailsLabel.textAlignment = .left
        detailsLabel.contentMode = .topLeft
        detailsLabel.numberOfLines = 0
        
        costLabel.font = .preferredFont(forTextStyle: .headline)
        costLabel.attributedText = data.cost.attributedString(font: costLabel.font, delimiter: "   ", verbose: false)
        costLabel.contentMode = .topLeft
        costLabel.lineBreakMode = .byWordWrapping
        costLabel.numberOfLines = 0
        costLabel.textAlignment = .left
    }
}
