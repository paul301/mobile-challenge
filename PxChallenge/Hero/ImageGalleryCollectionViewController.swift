// The MIT License (MIT)
//
// Copyright (c) 2016 Luke Zhao <me@lkzhao.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Hero
import RxSwift
import Moya_ObjectMapper
import SDWebImage

class ImageGalleryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var photos : [Photo]?
    var disposeBag = DisposeBag()
    var photoSizes = [(photoSize:CGSize, photo:Photo)]()

    override func viewDidLoad() {
        super.viewDidLoad()

        pxProvider.request(.popularPhotos())
            .mapObject(PopularPage.self)
            .subscribe { [weak self] event in
                switch event {
                case .next(let page):
                    self?.photos = page.photos
                    self?.photoSizes = (ImageHelper.photoSizes(photos: page.photos, viewBounds: (self?.view.bounds)!))
                    self?.collectionView.reloadData()
                case .error(let error):
                    print(error)
                default:
                    break
                }
            }.disposed(by: disposeBag)
        
        collectionView.reloadData()
        collectionView.indicatorStyle = .white
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let newBounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if UIDevice.current.orientation.isLandscape {
            //Landscape
            photoSizes = ImageHelper.photoSizes(photos: photos!, viewBounds: newBounds)
            collectionView.reloadData()
        }
        else {
            //Portrait
            photoSizes = ImageHelper.photoSizes(photos: photos!, viewBounds: newBounds)
            collectionView.reloadData()
        }
    }
}


extension ImageGalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = (viewController(forStoryboardName: "ImageViewer") as? ImageViewController)!
        vc.selectedIndex = indexPath
        vc.photos = photos
        if let navigationController = navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photos = photos else { return 0 }
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let photos = photos else { return (collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as? ImageCell)! }
        
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
