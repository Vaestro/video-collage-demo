 /// Copyright (c) 2018 Razeware LLC
 ///
 /// Permission is hereby granted, free of charge, to any person obtaining a copy
 /// of this software and associated documentation files (the "Software"), to deal
 /// in the Software without restriction, including without limitation the rights
 /// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 /// copies of the Software, and to permit persons to whom the Software is
 /// furnished to do so, subject to the following conditions:
 ///
 /// The above copyright notice and this permission notice shall be included in
 /// all copies or substantial portions of the Software.
 ///
 /// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 /// distribute, sublicense, create a derivative work, and/or sell copies of the
 /// Software in any work that is designed, intended, or marketed for pedagogical or
 /// instructional purposes related to programming, coding, application development,
 /// or information technology.  Permission for such use, copying, modification,
 /// merger, publication, distribution, sublicensing, creation of derivative works,
 /// or sale is expressly withheld.
 ///
 /// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 /// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 /// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 /// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 /// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 /// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 /// THE SOFTWARE.
 
 import UIKit
 import MobileCoreServices
 import MediaPlayer
 import Photos
 
 class MergeVideoViewController: UIViewController {
  var numberOfVideos: Int = 1
  var firstAsset: AVAsset?
  var secondAsset: AVAsset?
  var audioAsset: AVAsset?
  var loadingAssetOne = false
  var assetOneView: UIView = UIView()
  var assetTwoView: UIView = UIView()
  var assetThreeView: UIView = UIView()
  
  
  var activityMonitor: UIActivityIndicatorView = UIActivityIndicatorView.init(frame: CGRect.init(x: 177.5, y: 318, width: 20, height: 20))
  convenience init(numberOfVideos: Int = 1) {
    self.init(nibName: nil, bundle: nil)
    self.numberOfVideos = numberOfVideos
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "export", style: .done, target: self, action: #selector(merge(_:)))
    
    view.backgroundColor = .white
    

    if numberOfVideos == 1 {
      view.addSubview(assetOneView)
      assetOneView.frame = CGRect.init(x: 10, y: 10, width: view.frame.width - 20, height: view.frame.height - 20)
      let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewOneTapped(tapGestureRecognizer:)))
      singleTapGestureRecognizer.numberOfTapsRequired = 1
      singleTapGestureRecognizer.delegate = self
      assetOneView.addGestureRecognizer(singleTapGestureRecognizer)
      assetOneView.backgroundColor = .gray
      
      let titleLabel = UILabel.init(frame: CGRect.init(x: 0.0, y: 0.0, width: assetOneView.frame.width, height: assetOneView.frame.height))
      titleLabel.text = "Tap to import video"
      titleLabel.textAlignment = .center
      titleLabel.textColor = .white
      assetOneView.addSubview(titleLabel)
      titleLabel.center = assetOneView.convert(assetOneView.center, to: assetOneView.superview)
      //      [assetOneView convertPoint:assetOneView.center
      //      fromView:assetOneView.superview];
      
    } else {
      view.addSubview(assetOneView)
      assetOneView.frame = CGRect.init(x: 10, y: 10, width: view.frame.width - 20, height: view.frame.height/2 - 20)
      let assetOneGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewOneTapped(tapGestureRecognizer:)))
      assetOneGestureRecognizer.numberOfTapsRequired = 1
      assetOneGestureRecognizer.delegate = self
      assetOneView.addGestureRecognizer(assetOneGestureRecognizer)
      assetOneView.backgroundColor = .gray
      
      let titleLabel = UILabel.init(frame: CGRect.init(x: 0.0, y: 0.0, width: assetOneView.frame.width, height: assetOneView.frame.height))
      titleLabel.text = "Tap to import video"
      titleLabel.textAlignment = .center
      titleLabel.textColor = .white
      assetOneView.addSubview(titleLabel)
      titleLabel.center = assetOneView.convert(assetOneView.center, to: assetOneView.superview)
     
      view.addSubview(assetTwoView)
      assetTwoView.frame = CGRect.init(x: 10, y: assetOneView.frame.height + 20, width: view.frame.width - 20, height: view.frame.height/2 - 20)
      let assetTwoGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTwoTapped(tapGestureRecognizer:)))
      assetTwoGestureRecognizer.numberOfTapsRequired = 1
      assetTwoGestureRecognizer.delegate = self
      assetTwoView.addGestureRecognizer(assetTwoGestureRecognizer)
      assetTwoView.backgroundColor = .gray
      
      let secondTitleLabel = UILabel.init(frame: CGRect.init(x: assetTwoView.frame.minX, y: assetTwoView.frame.minY, width: assetTwoView.frame.width, height: assetTwoView.frame.height))
      secondTitleLabel.text = "Tap to import video"
      secondTitleLabel.textAlignment = .center
      secondTitleLabel.textColor = .white
      assetTwoView.addSubview(secondTitleLabel)
      secondTitleLabel.center = assetTwoView.convert(assetTwoView.center, to: assetTwoView.superview)
    }
  }
  
  func savedPhotosAvailable() -> Bool {
    guard !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else { return true }
    
    let alert = UIAlertController(title: "Not Available", message: "No Saved Album found", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
    present(alert, animated: true, completion: nil)
    return false
  }
  
  func exportDidFinish(_ session: AVAssetExportSession) {
    
    // Cleanup assets
    activityMonitor.stopAnimating()
    firstAsset = nil
    secondAsset = nil
    audioAsset = nil
    
    guard session.status == AVAssetExportSessionStatus.completed,
      let outputURL = session.outputURL else { return }
    
    let saveVideoToPhotos = {
      PHPhotoLibrary.shared().performChanges({ PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL) }) { saved, error in
        let success = saved && (error == nil)
        let title = success ? "Success" : "Error"
        let message = success ? "Video saved" : "Failed to save video"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }
    }
    
    // Ensure permission to access Photo Library
    if PHPhotoLibrary.authorizationStatus() != .authorized {
      PHPhotoLibrary.requestAuthorization({ status in
        if status == .authorized {
          saveVideoToPhotos()
        }
      })
    } else {
      saveVideoToPhotos()
    }
  }
  
  @IBAction func loadAssetOne(_ sender: AnyObject) {
    if savedPhotosAvailable() {
      loadingAssetOne = true
      VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }
  }
  
  @IBAction func loadAssetTwo(_ sender: AnyObject) {
    if savedPhotosAvailable() {
      loadingAssetOne = false
      VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }
  }
  
  @IBAction func loadAudio(_ sender: AnyObject) {
    let mediaPickerController = MPMediaPickerController(mediaTypes: .any)
    mediaPickerController.delegate = self
    mediaPickerController.prompt = "Select Audio"
    present(mediaPickerController, animated: true, completion: nil)
  }
  
  @IBAction func merge(_ sender: AnyObject) {
    
    
    activityMonitor.startAnimating()
    
    // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
    let mixComposition = AVMutableComposition()
    
    
    let parentlayer = CALayer()
    mixComposition.naturalSize = CGRect.init(x: 0,y:  0, width: 375 ,height: 667).size
    parentlayer.frame = CGRect.init(x: 0,y:  0, width: 375 ,height:  667)
    var videoLayers:[CALayer] = []
    var layerInstructions:[AVMutableVideoCompositionLayerInstruction] = []
    var mainDuration:CMTimeRange =  CMTimeRangeMake(kCMTimeZero, kCMTimeZero)

    
    if let firstAsset = firstAsset {
      
      let vtrack = firstAsset.tracks(withMediaType: AVMediaType.video)
//      let atrack = firstAsset.tracks(withMediaType: AVMediaType.audio)
      let videoTrack:AVAssetTrack = vtrack[0]
      //      let audioTrack:AVAssetTrack = atrack[0]
      
      //      let videoTrack:AVMutableCompositionTrack =
      let vid_duration = videoTrack.timeRange.duration
      let vid_timerange = CMTimeRangeMake(kCMTimeZero, vid_duration)
      
      guard let compositionvideoTrack:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(1)) else {
        print("error creating composition")
        return
      }
      mainDuration = CMTimeRangeMake(kCMTimeZero,
                                     CMTimeAdd(mainDuration.duration,
                                               vid_duration))
      //      guard let compositionaudioTrack:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(1)) else {
      //        print("error creating composition")
      //        return
      //      }
      
      do {
        try compositionvideoTrack.insertTimeRange(vid_timerange, of: videoTrack, at: kCMTimeZero)
        //        try compositionaudioTrack.insertTimeRange(vid_timerange, of: audioTrack, at: kCMTimeZero)
        
      } catch {
        print("Failed to load first track")
        return
      }
      
      let frame = assetOneView.frame
      
      let firstInstruction = VideoHelper.videoCompositionInstruction(compositionvideoTrack, asset: firstAsset, scaleToFitFrame: frame)
      firstInstruction.setOpacity(0.0, at: firstAsset.duration)
      layerInstructions.append(firstInstruction)
      
      let videolayer = CALayer()
      videolayer.zPosition = 0
      
      videolayer.frame = frame
      
      parentlayer.addSublayer(videolayer)
      videoLayers.append(videolayer)
      
    }
    
    //handle second asset if it exists
    if let secondAsset = secondAsset {
      
      let vtrack = secondAsset.tracks(withMediaType: AVMediaType.video)
      //      let atrack = firstAsset.tracks(withMediaType: AVMediaType.audio)
      let videoTrack:AVAssetTrack = vtrack[0]
      //      let audioTrack:AVAssetTrack = atrack[0]
      
      //      let videoTrack:AVMutableCompositionTrack =
      let vid_duration = videoTrack.timeRange.duration
      let vid_timerange = CMTimeRangeMake(kCMTimeZero, vid_duration)
      
      guard let compositionvideoTrack:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(1)) else {
        print("error creating composition")
        return
      }

      //      guard let compositionaudioTrack:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(1)) else {
      //        print("error creating composition")
      //        return
      //      }
      
      do {
        try compositionvideoTrack.insertTimeRange(vid_timerange, of: videoTrack, at: kCMTimeZero)
        //        try compositionaudioTrack.insertTimeRange(vid_timerange, of: audioTrack, at: kCMTimeZero)
        
      } catch {
        print("Failed to load first track")
        return
      }
      
      let frame = assetTwoView.frame
      
      let instruction = VideoHelper.videoCompositionInstruction(compositionvideoTrack, asset: secondAsset, scaleToFitFrame: frame)
      instruction.setOpacity(0.0, at: secondAsset.duration)
      layerInstructions.append(instruction)
      
      let videolayer = CALayer()
      videolayer.zPosition = 1
      
      videolayer.frame = frame
      
      parentlayer.addSublayer(videolayer)
      videoLayers.append(videolayer)
      
    }
    
    guard layerInstructions.count > 0 else {
      let alert = UIAlertController(title: "No Assets", message: "No videos were loaded", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
      present(alert, animated: true, completion: nil)
      return
    }
    
    let mainInstruction = AVMutableVideoCompositionInstruction()
    mainInstruction.timeRange = mainDuration
    mainInstruction.layerInstructions = layerInstructions
    
    let mainComposition = AVMutableVideoComposition()
    mainComposition.instructions = [mainInstruction]
    mainComposition.frameDuration = CMTimeMake(1, 30)
    mainComposition.renderSize = CGSize.init(width: floor(375 / 16) * 16, height: floor(667 / 16) * 16)
    mainComposition.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayers: videoLayers, in: parentlayer)
    
    // 4 - Get path
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    let date = dateFormatter.string(from: Date())
    let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")
    
    // 5 - Create Exporter
    guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
    exporter.outputURL = url
    exporter.outputFileType = AVFileType.mov
    exporter.shouldOptimizeForNetworkUse = true
    exporter.videoComposition = mainComposition
    
    // 6 - Perform the Export
    exporter.exportAsynchronously(completionHandler: {
      switch exporter.status {
      case  AVAssetExportSessionStatus.failed:
        print("failed \(exporter.error?.localizedDescription ?? "creating asset failed")")
      case AVAssetExportSessionStatus.cancelled:
        print("cancelled \(exporter.error?.localizedDescription ?? "creating asset cancelled")")
      default:
        print("Movie complete")
        
        DispatchQueue.main.async {
          self.exportDidFinish(exporter)
        }
      }
    })
  }
  
 }
 
 extension MergeVideoViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    dismiss(animated: true, completion: nil)
    
    guard let mediaType = info[UIImagePickerControllerMediaType] as? String,
      mediaType == (kUTTypeMovie as String),
      let url = info[UIImagePickerControllerMediaURL] as? URL
      else { return }
    
    let avAsset = AVAsset(url: url)
    var message = ""
    if loadingAssetOne {
      message = "Video one loaded"
      firstAsset = avAsset
      assetOneView.backgroundColor = .green
    } else {
      message = "Video two loaded"
      secondAsset = avAsset
      assetTwoView.backgroundColor = .green

    }
    let alert = UIAlertController(title: "Asset Loaded", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
 }
 
 extension MergeVideoViewController: UIGestureRecognizerDelegate {
  
  @objc func viewOneTapped(tapGestureRecognizer: UITapGestureRecognizer) {
    self.loadAssetOne(self)
  }
  
  @objc func viewTwoTapped(tapGestureRecognizer: UITapGestureRecognizer) {
    self.loadAssetTwo(self)
  }
  
 }
 
 extension MergeVideoViewController: UINavigationControllerDelegate {
  
 }
 
 extension MergeVideoViewController: MPMediaPickerControllerDelegate {
  func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
    
    dismiss(animated: true) {
      let selectedSongs = mediaItemCollection.items
      guard let song = selectedSongs.first else { return }
      
      let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
      self.audioAsset = (url == nil) ? nil : AVAsset(url: url!)
      let title = (url == nil) ? "Asset Not Available" : "Asset Loaded"
      let message = (url == nil) ? "Audio Not Loaded" : "Audio Loaded"
      
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
    dismiss(animated: true, completion: nil)
  }
 }
