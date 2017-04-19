//
//  ImageGalleryViewController.swift
//  PxChallenge
//
//  Created by Paul Floussov on 2017-04-10.
//  Copyright © 2017 Paul Floussov. All rights reserved.
//

import UIKit
import Hero
import RxSwift
import Moya_ObjectMapper
import SDWebImage
import UIScrollView_InfiniteScroll

class ImageGalleryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var photos = [Photo]()
    var disposeBag = DisposeBag()
    var photoSizes = [(photoSize:CGSize, photo:Photo)]()
    var page = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        page = 0
        fetchNextPage() // initial fetch

        collectionView.indicatorStyle = .white
        
        // adding infinate scroll
        collectionView.addInfiniteScroll { [weak self] (collectionView) -> Void in
            self?.fetchNextPage()
        }
    }

    func fetchNextPage() {
        page += 1
        pxProvider.request(.popularPhotos(page: page))
            .mapObject(PopularPage.self)
            .subscribe { [weak self] event in
                switch event {
                case .next(let page):
                    self?.collectionView.performBatchUpdates({ () -> Void in
                        self?.addPhotosToView(newPhotos: page.photos)
                    }, completion: { (finished) -> Void in
                        self?.collectionView.finishInfiniteScroll()
                    });
                case .error(let error):
                    print(error)
                default:
                    break
                }
            }.disposed(by: disposeBag)
    }

    func addPhotosToView(newPhotos: [Photo]) {
        guard newPhotos.count > 0 else { return }
        
        let initalCount = photos.count
        
        photos.append(contentsOf: newPhotos)
        photoSizes = (ImageHelper.photoSizes(photos: photos, viewBounds: self.view.bounds))
        
        var indexPaths = [IndexPath]()
        for index in initalCount..<initalCount + newPhotos.count {
            indexPaths.append( IndexPath(row: index , section: 0))
        }
        collectionView.insertItems(at: indexPaths)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let newBounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if UIDevice.current.orientation.isLandscape {
            photoSizes = ImageHelper.photoSizes(photos: photos, viewBounds: newBounds)
            collectionView.reloadData()
        }
        else {
            photoSizes = ImageHelper.photoSizes(photos: photos, viewBounds: newBounds)
            collectionView.reloadData()
        }
    }
}


extension ImageGalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let navigationController = navigationController else { return }
        
        let vc = (UIStoryboard(name: "ImageViewer", bundle: nil).instantiateInitialViewController()! as? ImageViewController)!
        vc.selectedIndex = indexPath
        vc.photos = photos
        navigationController.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard photos.count > 0 else { return 0 }
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard photos.count > 0 else { return (collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as? ImageCell)! }
        
        let imageCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as? ImageCell)!
        imageCell.imageView.sd_setImage(with: URL(string: photos[indexPath.row].images.first(where: {$0.size == 21})!.url))
        imageCell.imageView.heroID = "image_\(indexPath.item)"
        imageCell.imageView.heroModifiers = [.fade, .scale(0.8)]
        imageCell.imageView.isOpaque = true
        return imageCell
    }
    
}


extension ImageGalleryViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return photoSizes[indexPath.row].photoSize
    }
    
}


extension ImageGalleryViewController: HeroViewControllerDelegate {
    
    func heroWillStartAnimatingTo(viewController: UIViewController) {
        let cell = collectionView.cellForItem(at: collectionView.indexPathsForSelectedItems!.first!)!
        collectionView.heroModifiers = [.cascade(delta: 0.008, direction: .radial(center: cell.center), delayMatchedViews: true)]
    }
    
    func heroWillStartAnimatingFrom(viewController: UIViewController) {
        view.heroModifiers = nil
        collectionView.heroModifiers = [.cascade(delta:0.015)]
        if let vc = viewController as? ImageViewController,
            let originalCellIndex = vc.selectedIndex,
            let currentCellIndex = vc.collectionView?.indexPathsForVisibleItems[0],
            let targetAttribute = collectionView.layoutAttributesForItem(at: currentCellIndex) {
            collectionView.heroModifiers = [.cascade(delta:0.015, direction:.inverseRadial(center:targetAttribute.center))]
            if !collectionView.indexPathsForVisibleItems.contains(currentCellIndex) {
                // make the cell visible
                collectionView.scrollToItem(at: currentCellIndex,
                                            at: originalCellIndex < currentCellIndex ? .bottom : .top,
                                            animated: false)
            }
        }
    }
    
}
