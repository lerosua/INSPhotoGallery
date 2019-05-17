//
//  CTGalleryOverlayView.swift
//  ComoTravel
//
//  Created by WOO Yu Kit on 5/7/2016.
//  Copyright © 2016 Como. All rights reserved.
//

import UIKit
import INSNibLoading
import INSPhotoGalleryFramework
import AVFoundation

class CTGalleryOverlayView: INSNibLoadedView {
    weak var photosViewController: INSPhotosViewController?
    
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var videoPlayBtn: UIButton!
    @IBOutlet weak var videofullBtn: UIButton!
    @IBOutlet weak var lblVideoTime: UILabel!
    @IBOutlet weak var videoProgress: UIProgressView!
    @IBOutlet weak var videoControl: UIView!
    

    // Pass the touches down to other views
//    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
//        if let hitView = super.hitTest(point, withEvent: event), hitView != self {
//            return hitView
//        }
//        return nil
//    }
    @IBAction  @objc  func nextBtnClick(sender: UIButton) {
        if let photosViewController = self.photosViewController{
            let index = photosViewController.dataSource.indexOfPhoto(photosViewController.currentPhoto!)
            if index ?? 0 < photosViewController.dataSource.numberOfPhotos-1{
                photosViewController.changeToPhoto(photosViewController.dataSource.photoAtIndex(index!+1)!, animated: true)
            }
        }
    }
    @IBAction  @objc  func prevBtnClick(sender: UIButton) {
        if let photosViewController = self.photosViewController{
            let index = photosViewController.dataSource.indexOfPhoto(photosViewController.currentPhoto!)
            if index ?? 0 > 0{
                photosViewController.changeToPhoto(photosViewController.dataSource.photoAtIndex(index!-1)!, animated: true)
            }
        }
    }
    @IBAction  @objc  func closeBtnClick(sender: UIButton) {
        photosViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction @objc func videoPlayBtnClick(sender: UIButton){
        if let _ = photosViewController!.currentPhoto?.videoURL{
            if let player = photosViewController!.currentPhotoViewController?.videoPlayer{
                if (player.rate != 0 && player.error == nil) {
                    player.pause()
                    videoPlayBtn.setImage(UIImage(named: "btnVideoPlay"), for: .normal)
                }
                else{
                    player.play()
                    videoPlayBtn.setImage(UIImage(named: "btnVideoPause"), for: .normal)
                }
            }
        }
    }
    @IBAction  @objc  func videoFullBtnClick(sender: UIButton){
        if let playerLayer = photosViewController!.currentPhotoViewController?.videoPlayerLayer{
            if playerLayer.videoGravity == AVLayerVideoGravity.resizeAspect{
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videofullBtn.setImage(UIImage(named: "btnVideoExit"), for: .normal)
            }
            else{
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                videofullBtn.setImage(UIImage(named: "btnVideoFullscreen"), for: .normal)
            }
        }
    }
    
}

extension CTGalleryOverlayView: INSPhotosOverlayViewable {
    func view() -> UIView {
        setupView()
        return self
    }
    func populateWithPhoto(_ photo: INSPhotoViewable) {
        setupView()
    }
    func setHidden(_ hidden: Bool, animated: Bool) {
        if self.isHidden == hidden {
            return
        }
        
        if animated {
            self.isHidden = false
            self.alpha = hidden ? 1.0 : 0.0
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut, .allowAnimatedContent, .allowUserInteraction], animations: { () -> Void in
                self.alpha = hidden ? 0.0 : 1.0
                }, completion: { result in
                    self.alpha = 1.0
                    self.isHidden = hidden
            })
        } else {
            self.isHidden = hidden
        }
    }
    func setupView(){
        if let photosViewController = photosViewController {
            let index = photosViewController.dataSource.indexOfPhoto(photosViewController.currentPhoto!)!+1
            lblTitle.text = "\(index) / \(photosViewController.dataSource.numberOfPhotos)"
            leftArrow.isHidden = false
            rightArrow.isHidden = false
            if index == 1{
                leftArrow.isHidden = true
            }
            else if index==photosViewController.dataSource.numberOfPhotos{
                rightArrow.isHidden = true
            }
            if let _ = photosViewController.currentPhoto?.videoURL{
                if let player = photosViewController.currentPhotoViewController?.videoPlayer{
                    if (player.rate != 0 && player.error == nil) {
                        videoPlayBtn.setImage(UIImage(named: "btnVideoPause"), for: .normal)
                    }
                    else{
                        videoPlayBtn.setImage(UIImage(named: "btnVideoPlay"), for: .normal)
                    }
                    
                    if let playerLayer = photosViewController.currentPhotoViewController?.videoPlayerLayer{
                        if playerLayer.videoGravity == AVLayerVideoGravity.resizeAspect{
                            videofullBtn.setImage(UIImage(named: "btnVideoFullscreen"), for: .normal)
                        }
                        else{
                            videofullBtn.setImage(UIImage(named: "btnVideoExit"), for: .normal)
                        }
                    }
                    if let observer = photosViewController.currentPhotoViewController?.videoPlayerObserver{
                        player.removeTimeObserver(observer)
                    }
                    photosViewController.currentPhotoViewController?.videoPlayerObserver =
                        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using:{_ in
                            self.updateTimeFrame(player: player)
                        }) as AnyObject
                    self.updateTimeFrame(player: player)
                    videoControl.isHidden = false
                }
            }
            else{
                videoControl.isHidden = true
            }
        }
    }
    func updateTimeFrame(player:AVPlayer) {
        let currentSeconds = CMTimeGetSeconds(player.currentTime())
        
        let hours:Int = Int(currentSeconds / 3600)
        let minutes:Int = Int(currentSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(currentSeconds.truncatingRemainder(dividingBy:  60))
        
        if hours > 0 {
            self.lblVideoTime.text = String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            self.lblVideoTime.text = String(format: "%02i:%02i", minutes, seconds)
        }
        let totalSeconds = CMTimeGetSeconds((player.currentItem?.duration)!)
        self.videoProgress.progress = Float(currentSeconds / totalSeconds)
    }
}
