//
//  AccountActivityCell.swift
//  Near
//
//  Created by Bhushan Mahajan on 30/09/21.
//

import UIKit

class AccountActivityCell: UITableViewCell {
    
    //MARK: - Properties/Variables
    
    static let identifier = "cell"
    
    var actionKindLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.grey()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        return label
    }()

    //MARK: - Init Functions
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configuration Functions
    
    func configureCell() {
        contentView.backgroundColor = UIColor.grey()
        contentView.addSubview(actionKindLabel)
        actionKindLabel.anchor(top: contentView.topAnchor, paddingTop: 0, left: contentView.leftAnchor, paddingLeft: 32, right: contentView.rightAnchor, paddingRight: 32, height: 40)
    }
}