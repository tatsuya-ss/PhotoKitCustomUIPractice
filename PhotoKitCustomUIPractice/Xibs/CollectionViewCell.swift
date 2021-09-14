//
//  CollectionViewCell.swift
//  PhotoKitCustomUIPractice
//
//  Created by 坂本龍哉 on 2021/09/11.
//

import UIKit

final class CollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var photoImageView: UIImageView!
    
    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }
    
    var representedAssetIdentifier: String!

    var thumnailImage: UIImage! {
        didSet {
            photoImageView.image = thumnailImage
        }
    }
    var livePhotoBadgeImage: UIImage! {
        didSet {
            photoImageView.image = livePhotoBadgeImage
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }

}
