//
//  ViewController.swift
//  PhotoKitCustomUIPractice
//
//  Created by 坂本龍哉 on 2021/09/11.
//

import UIKit
import Photos
import PhotosUI

final class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var fetchResult: PHFetchResult = PHFetchResult<PHAsset>()
    private let imageManager = PHCachingImageManager()
    private var thumbnailSize: CGSize!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPhotosAuthorization()
        setupCollectionView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        thumbnailSize = CGSize(width: view.frame.width / 3,
                               height: view.frame.width / 3)
        
    }

}

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CollectionViewCell.identifier,
                for: indexPath) as? CollectionViewCell
        else { fatalError("セルがありません") }
        let asset = fetchResult.object(at: indexPath.item)
        if asset.mediaSubtypes.contains(.photoLive) {
            cell.livePhotoBadgeImage = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        }
        
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset,
                                  targetSize: thumbnailSize,
                                  contentMode: .aspectFill,
                                  options: nil) { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumnailImage = image
            }
        }
        return cell
    }


}

extension ViewController: UICollectionViewDelegate {
}

// MARK: - Photos関係
extension ViewController {
    
    private func setupPhotos() {
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                         ascending: true)]
        fetchOptions.fetchLimit = .max
        fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    private func getPhotosAuthorization() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .authorized:
                print("authorized")
                self.setupPhotos()
            case .denied:
                DispatchQueue.main.async {
                    print("denied")
                    self.showPhotosAuthorizationDeniedAlert()
                }
            default:
                break
            }
        }
    }

}

// MARK: - その他
extension ViewController {
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.nib,
                                forCellWithReuseIdentifier: CollectionViewCell.identifier)
    }


    private func showPhotosAuthorizationDeniedAlert() {
        let alert = UIAlertController(title: "写真へのアクセスを許可しますか？",
                                      message: nil,
                                      preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "設定画面へ",
                                           style: .default) { (_) in
            guard let settngsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settngsURL,
                                      options: [:],
                                      completionHandler: nil)
        }
        let closeAction = UIAlertAction(title: "キャンセル",
                                        style: .cancel,
                                        handler: nil)
        [settingsAction, closeAction].forEach { alert.addAction($0) }
        present(alert,
                animated: true,
                completion: nil)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitem: item,
                                                       count: 3)
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

}
