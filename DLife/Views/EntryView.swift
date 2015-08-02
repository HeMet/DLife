//
//  EntryView.swift
//  DLife
//
//  Created by Евгений Губин on 15.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit
import Cartography
import MVVMKit
import WebImage

@IBDesignable
class EntryView: UIView, ViewForViewModel {
    let placeholder_image = "placeholder_image"
    let designer_image = "designer_image"
    
    var imgPicture: UIImageView = UIImageView()
    var lblDescription: UILabel = UILabel()
    var lblRating: UILabel = UILabel()
    var lblRatingValue: UILabel = UILabel()
    var btnFavorite: UIButton = UIButton()
    
    var viewModel: EntryViewModel! {
        didSet {
            #if TARGET_INTERFACE_BUILDER
            bindToViewModel()
            #endif
        }
    }
    
    var instantGifLoading = false
    
    var loadingOverlay : LoadingOverlayLayer = LoadingOverlayLayer()
    
    @IBInspectable var picture: UIImage? {
        didSet {
            viewModel.entry.previewURL = designer_image
            bindToViewModel()
        }
    }
    
    @IBInspectable var title: String = "Description" {
        didSet {
            viewModel.entry.description = title
            bindToViewModel()
        }
    }
    
    @IBInspectable var ratingValue: Int = 0 {
        didSet {
            viewModel.entry.votes = ratingValue
            bindToViewModel()
        }
    }

    @IBInspectable var overlay: Bool {
        get {
            return !loadingOverlay.hidden
        }
        set {
            loadingOverlay.hidden = !newValue
        }
    }
    
    @IBInspectable var loadingPercentage: CGFloat {
        get {
            return loadingOverlay.percentage
        }
        set {
            loadingOverlay.percentage = newValue
        }
    }
    
    @IBInspectable var isFavorite: Bool {
        get {
            return btnFavorite.selected
        }
        set {
            btnFavorite.selected = newValue
        }
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setTranslatesAutoresizingMaskIntoConstraints(false)
        setup()
    }
    
    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    func setup() {
        setupHierarchy()
        setupLayout()
        setDefaultValues()
    }
    
    func setDefaultValues() {
        lblRating.text = "Rating:"
        
        loadingOverlay.hidden = true
        
        let dvm = DLEntry()
        dvm.id = -1
        dvm.description = "Descriptions"
        dvm.votes = 9000
        dvm.previewURL = placeholder_image
        dvm.imgSize = (50, 50)
        
        viewModel = EntryViewModel(entry: dvm)
    }
    
    func setupHierarchy() {
        addSubview(lblDescription)
        addSubview(imgPicture)
        addSubview(lblRating)
        addSubview(lblRatingValue)
        addSubview(btnFavorite)
        
        imgPicture.layer.addSublayer(loadingOverlay)
        
        let tr = UITapGestureRecognizer(target: self, action: Selector("handlePictureTap:"))
        imgPicture.addGestureRecognizer(tr)
        imgPicture.userInteractionEnabled = true
        
        lblDescription.numberOfLines = 0
        
        btnFavorite.setImage(UIImage(named: "favorites_normal"), forState: .Normal)
        btnFavorite.setImage(UIImage(named: "favorites_checked"), forState: .Selected)
        btnFavorite.addTarget(self, action: Selector("handleFavoriteTap"), forControlEvents: .TouchUpInside)
    }
    
    func setupLayout() {
        constrain(lblDescription) { desc in
            desc.left == desc.superview!.left + 8
            desc.right == desc.superview!.right - 8
            desc.top == desc.superview!.top + 8
        }
        
        constrain(lblDescription, imgPicture, lblRatingValue) { desc, pic, rating in
            pic.top == desc.bottom + 16
            pic.centerX == pic.superview!.centerX
            
            rating.top == pic.bottom + 12
        }
        
        constrain(lblRating, lblRatingValue, btnFavorite) { rating, value, favorite in
            value.right == value.superview!.right - 8
            value.bottom == value.superview!.bottom - 12
            
            rating.right == value.left - 8
            rating.baseline == value.baseline
            
            favorite.right == rating.left - 8
            favorite.centerY == rating.centerY
            favorite.left >= favorite.superview!.left + 8
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        loadingOverlay.frame = imgPicture.layer.bounds
    }
    
    func bindToViewModel() {
        lblDescription.text = viewModel.entry.description
        lblRatingValue.text = "\(viewModel.entry.votes)"
        updatePicture()
        
        #if !TARGET_INTERFACE_BUILDER
        btnFavorite.selected = viewModel.isFavorite
        viewModel.onFavoriteChanged = { [unowned self] in
            self.btnFavorite.selected = self.viewModel.isFavorite
        }
        #endif
    }
    
    func handlePictureTap(recognizer: UITapGestureRecognizer) {
        loadGif(imgPicture.image!)
    }
    
    func handleFavoriteTap() {
        viewModel.toggleFavorite()
    }
    
    func loadPreview() {
        let ph = placeholderImage(viewModel.entry.imgSize.0, viewModel.entry.imgSize.1)
        imgPicture.sd_setImageWithURL(NSURL(string: viewModel.entry.previewURL), placeholderImage: ph) { img, _, _, _ in
            if (self.instantGifLoading) {
                // Workaround: in some cases (first load in our case) completition block is not called
                NSTimer.schedule(delay: 0.1) { _ in
                    self.loadGif(img)
                }
            }
        }
    }
    
    func loadGif(preview: UIImage) {
        if !self.viewModel.entry.gifURL.isEmpty {
            loadingOverlay.hidden = false
            
            imgPicture.sd_setImageWithURL(NSURL(string: self.viewModel.entry.gifURL),
                placeholderImage: preview,
                options: SDWebImageOptions(0),
                progress: { receivedSize, expectedSize in
                    self.loadingPercentage = CGFloat(receivedSize * 100 / expectedSize)
                }) { _ in
                self.loadingOverlay.hidden = true
            }
        }
    }
    
    func updatePicture() {
        switch viewModel.entry.previewURL {
        case placeholder_image:
            imgPicture.image = placeholderImage(viewModel.entry.imgSize.0, viewModel.entry.imgSize.1, transparent: false)
        case designer_image:
            imgPicture.image = picture
        default:
            loadPreview()
        }
    }
    
    func placeholderImage(width: Float, _ height: Float, transparent: Bool = true) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        UIGraphicsBeginImageContext(CGSize(width: rect.width, height: rect.height))
        
        if (!transparent) {
            let ctx = UIGraphicsGetCurrentContext()
            UIColor.blackColor().set()
            CGContextFillRect(ctx, rect)
        }
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}
