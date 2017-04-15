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
    var columns = 3
    var photos : [Photo]?
    var disposeBag = DisposeBag()
    lazy var cellSize: CGSize = CGSize(width: self.view.bounds.width/CGFloat(self.columns),
                                    height: self.view.bounds.width/CGFloat(self.columns))
    
    


  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    pxProvider.request(.popularPhotos())
        .mapObject(PopularPage.self)
        .subscribe { [weak self] event in
            switch event {
            case .next(let page):
                self?.photos = page.photos
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

  @IBAction func switchLayout(_ sender: Any) {
    // just replace the root view controller with the same view controller
    // animation is automatic! Holy
    let next = (UIStoryboard(name: "ImageGallery", bundle: nil).instantiateViewController(withIdentifier: "imageGallery") as? ImageGalleryViewController)!
    next.columns = columns == 3 ? 5 : 3
    hero_replaceViewController(with: next)
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
    return cellSize
  }
}

extension ImageGalleryViewController: HeroViewControllerDelegate {
  func heroWillStartAnimatingTo(viewController: UIViewController) {
    if (viewController as? ImageGalleryViewController) != nil {
      collectionView.heroModifiers = [.cascade(delta:0.015, direction:.bottomToTop, delayMatchedViews:true)]
    } else if (viewController as? ImageViewController) != nil {
      let cell = collectionView.cellForItem(at: collectionView.indexPathsForSelectedItems!.first!)!
      collectionView.heroModifiers = [.cascade(delta: 0.015, direction: .radial(center: cell.center), delayMatchedViews: true)]
    } else {
      collectionView.heroModifiers = [.cascade(delta:0.015)]
    }
  }
  func heroWillStartAnimatingFrom(viewController: UIViewController) {
    view.heroModifiers = nil
    if (viewController as? ImageGalleryViewController) != nil {
      collectionView.heroModifiers = [.cascade(delta:0.015), .delay(0.25)]
    } else {
      collectionView.heroModifiers = [.cascade(delta:0.015)]
    }
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
