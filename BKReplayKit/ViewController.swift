//
//  ViewController.swift
//  BKReplayKit
//
//  Created by bk on 2022/04/15.
//

import UIKit
import ReplayKit
import Photos

class ViewController: UIViewController,
                      RPScreenRecorderDelegate,
                      RPPreviewViewControllerDelegate {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var broadcastButton: UIButton!
    @IBOutlet weak var clipButton: UIButton!
    @IBOutlet weak var getClipButton: UIButton!
    @IBOutlet weak var cameraSwitch: UISwitch!
    @IBOutlet weak var micSwitch: UISwitch!
        
    @IBOutlet weak var rollingView: UIView!
    
    private var assetWriter = AssetWriter(fileName: "test.mp4")
    
    private var isActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.rollingView.rotate()
        
        // Initialize the screen recorder delegate.
        RPScreenRecorder.shared().delegate = self
        
        DispatchQueue.main.async {
            // Set the buttons' enabled states.
            self.recordButton.isEnabled = RPScreenRecorder.shared().isAvailable
            self.captureButton.isEnabled = RPScreenRecorder.shared().isAvailable
            self.broadcastButton.isEnabled = RPScreenRecorder.shared().isAvailable
            self.clipButton.isEnabled = RPScreenRecorder.shared().isAvailable
        }
    }
    
    // MARK: - Screen Recorder Microphone / Camera Property methods
    @IBAction func cameraSwitchTab(_ sender: Any) {
        if cameraSwitch.isOn == true {
            RPScreenRecorder.shared().isCameraEnabled = true
        } else {
            RPScreenRecorder.shared().isCameraEnabled = false
        }
    }
    
    @IBAction func microphoneSwitchTab(_ sender: Any) {
        if micSwitch.isOn == true {
            RPScreenRecorder.shared().isMicrophoneEnabled = true
        } else {
            RPScreenRecorder.shared().isMicrophoneEnabled = false
        }
    }
    
    // setupCameraView()
    
    // MARK: - In-App Recording
    @IBAction func recordButtonTab(_ sender: Any) {
        // Check the internal recording state.
        if isActive == false {
            // If a recording isn't currently underway, start it.
            startRecording()
        } else {
            // If a recording is active, the button stops it.
            stopRecording()
        }
    }
    
    func startRecording() {
        RPScreenRecorder.shared().startRecording { error in
            // If there is an error, print it and set the button title and state.
            if error == nil {
                // There isn't an error and recording starts successfully. Set the recording state.
                self.setRecordingState(active: true)
            } else {
                // Print the error.
                print("Error starting recording")
                
                // Set the recording state.
                self.setRecordingState(active: false)
            }
        }
    }
    
    func stopRecording() {
        RPScreenRecorder.shared().stopRecording { previewViewController, error in
            if error == nil {
                // There isn't an error and recording stops successfully. Present the view controller.
                print("Presenting Preview View Controller")
                
                guard previewViewController != nil else {
                    print("Preview controller is not available.")
                    return
                }
                previewViewController?.modalPresentationStyle = .overFullScreen
                previewViewController?.previewControllerDelegate = self
                self.present(previewViewController!, animated: true, completion: nil)
            } else {
                // There's an error stopping the recording, so print an error message.
                print("Error starting recording")
            }
            
            // Set the recording state.
            self.setRecordingState(active: false)
        }
    }
    
    func setRecordingState(active: Bool) {
        DispatchQueue.main.async {
            if active == true {
                // Set the button title.
                print("started recording")
                self.recordButton.setTitle("Stop Recording", for: UIControl.State.normal)
            } else {
                // Set the button title.
                print("stopped recording")
                self.recordButton.setTitle("Start Recording", for: UIControl.State.normal)
            }
            
            // Set the internal recording state.
            self.isActive = active
            
            // Set the other buttons' isEnabled properties.
            self.captureButton.isEnabled = !active
            self.broadcastButton.isEnabled = !active
            self.clipButton.isEnabled = !active
        }
    }
    // MARK: - RPPreviewViewController Delegate
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        // This delegate method tells the app when the user finishes with the
        // preview view controller sheet (when the user exits or cancels the sheet).
        // End the presentation of the preview view controller here.
        print("previewControllerDidFinish")
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - In-App Capture
    @IBAction func captureButtonTab(_ sender: Any) {
        // Check the internal recording state.
        if isActive == false {
            // If a recording isn't active, the button starts the capture session.
            startCapture()
        } else {
            // If a recording is active, the button stops the capture session.
            stopCapture()
        }
    }
    
    func startCapture() {
        RPScreenRecorder.shared().startCapture { sampleBuffer, sampleBufferType, error in
            // The sample calls this handler every time ReplayKit is ready to give you a video, audio or microphone sample.
            // You need to check several things here so that you can process these sample buffers correctly.
            // Check for an error and, if there is one, print it.
            if error != nil {
                print("Error receiving sample buffer for in app capture")
            } else {
                // There isn't an error. Check the sample buffer for its type.
                
                self.assetWriter.write(buffer: sampleBuffer, bufferType: sampleBufferType)
                
//                switch sampleBufferType {
//                case .video:
//                    self.processAppVideoSample(sampleBuffer: sampleBuffer)
//                case .audioApp:
//                    self.processAppAudioSample(sampleBuffer: sampleBuffer)
//                case .audioMic:
//                    self.processAppMicSample(sampleBuffer: sampleBuffer)
//                default:
//                    print("Unable to process sample buffer")
//                }
            }
        } completionHandler: { error in
            // The sample calls this handler when the capture session starts. It only calls it once.
            // Use this handler to set your started capture state and variables.
            if error == nil {
                // There's no error when attempting to start an in-app capture session. Update the capture state.
                self.setCaptureState(active: true)
                
            } else {
                // There's an error when attempting to start the in-app capture session. Print an error.
                print("Error starting in app capture session")
                
                // Update the capture state.
                self.setCaptureState(active: false)
            }
        }
    }
    
    //TODO::- AssetWriter 가져와서 넣기.
//    func processAppVideoSample(sampleBuffer: CMSampleBuffer) {
//        // An app can modify the video sample buffers as necessary.
//        // The sample simply prints a message to the console.
//        print("Received a video sample.")
//    }
//
//    func processAppAudioSample(sampleBuffer: CMSampleBuffer) {
//        // An app can modify the audio sample buffers as necessary.
//        // The sample simply prints a message to the console.
//        print("Received an audio sample.")
//    }
//
//    func processAppMicSample(sampleBuffer: CMSampleBuffer) {
//        // An app can modify the microphone audio sample buffers as necessary.
//        // The sample simply prints a message to the console.
//        print("Received a microphone audio sample.")
//    }
    
    func stopCapture() {
        RPScreenRecorder.shared().stopCapture { error in
            // The sample calls the handler when the stop capture finishes. Update the capture state.
            self.setCaptureState(active: false)
            
            self.assetWriter.finishWriting()
            
            // Check and print the error, if necessary.
            if error != nil {
                print("Encountered and error attempting to stop in app capture")
            }
        }
    }
    
    func setCaptureState(active: Bool) {
        DispatchQueue.main.async {
            if active == true {
                // Set the button title.
                self.captureButton.setTitle("Stop Capture", for: UIControl.State.normal)
            } else {
                // Set the button title.
                self.captureButton.setTitle("Start Capture", for: UIControl.State.normal)
            }
            
            // Set the internal recording state.
            self.isActive = active
            
            // Set the other buttons' isEnabled properties.
            self.recordButton.isEnabled = !active
            self.broadcastButton.isEnabled = !active
            self.clipButton.isEnabled = !active
        }
    }
    
    //TODO:: - 브로드캐스트 빼버림.
    // MARK: - In-App Broadcast
    @IBAction func broadcastButtonTapped(_ sender: Any) {
        // Check the internal recording state.
        if isActive == false {
            // If not active, present the broadcast picker.
            presentBroadcastPicker()
        } else {
            // If currently active, the button stops the broadcast session.
            stopBroadcast()
        }
    }
    
    func presentBroadcastPicker() {
        
        setBroadcastState(active: true)
        
//        RPBroadcastActivityViewController.load { broadcastAVC, error in  // broadcast service 를 제공하는 앱을 선택할 수 있는 화면 표출해주기 (share extension이랑 비슷한 흐름)
//
//            if error == nil {
//                if let broadcastAVC = broadcastAVC {
//                    broadcastAVC.delegate = self
//                    self.present(broadcastAVC, animated: true)
//                }
//            } else {
//                // There's an error when attempting to present the broadcast picker, so print the error.
//                print("Error attempting to present broadcast activity controller")
//            }
//        }
    }
    
    func stopBroadcast() {
        
        self.setBroadcastState(active: false)
        
//        broadcastController.finishBroadcast { error in
//            // Update the broadcast state.
//            self.setBroadcastState(active: false)
//
//            // Check and print the error, if necessary.
//            if error != nil {
//                print("Error attempting to stop in app broadcast")
//            }
//        }
    }
    
    func setBroadcastState(active: Bool) {
        DispatchQueue.main.async {
            if active == true {
                // Set the button title.
                self.broadcastButton.setTitle("Stop Broadcast", for: UIControl.State.normal)
            } else {
                // Set the button title.
                self.broadcastButton.setTitle("Start Broadcast", for: UIControl.State.normal)
            }
            
            // Set the internal recording state.
            self.isActive = active
            
            // Set the other buttons' isEnabled properties.
            self.recordButton.isEnabled = !active
            self.captureButton.isEnabled = !active
            self.clipButton.isEnabled = !active
        }
    }
    
    //TODO:: - 동작하는지 확인해보기.
    // MARK: - In-App Clip Recording
    @IBAction func clipButtonTab(_ sender: Any) {
        if #available(iOS 15.0, *) {
            // Check the internal recording state.
            if isActive == false {
                // If the recording isn't active, the button starts the clip buffering session.
                startClipBuffering()
            } else {
                // If a recording is active, the button stops the clip buffering session.
                stopClipBuffering()
            }
        }
    }
    
    @IBAction func generateClipPressed(_ sender: Any) {
        if self.isActive == true && self.getClipButton.isEnabled == true {
            exportClip()
        }
    }
    
    func startClipBuffering() {
        if #available(iOS 15.0, *) {
            RPScreenRecorder.shared().startClipBuffering { (error) in
                if error != nil {
                    print("Error attempting to start Clip Buffering")
                    
                    self.setClipState(active: false)
                    
                } else {
                    // There's no error when attempting to start a clip session. Update the clip state.
                    self.setClipState(active: true)
                }
            }
        }
        
    }
    
    func stopClipBuffering() {
        if #available(iOS 15.0, *) {
            RPScreenRecorder.shared().stopClipBuffering { (error) in
                if error != nil {
                    print("Error attempting to stop Clip Buffering")
                }
                // The sample calls this handler when stopClipBuffering finishes. Update the clip state.
                self.setClipState(active: false)
            }
        }
    }
    
    func setClipState(active: Bool) {
        DispatchQueue.main.async {
            if active == true {
                // Set the button title.
                self.clipButton.setTitle("Stop Clip", for: UIControl.State.normal)
            } else {
                // Set the button title.
                self.clipButton.setTitle("Start Clip", for: UIControl.State.normal)
            }
            
            // Set the internal recording state.
            self.isActive = active
            
            // Set the getClip button.
            self.getClipButton.isEnabled = active
            
            // Set the other buttons' isEnabled properties.
            self.recordButton.isEnabled = !active
            self.broadcastButton.isEnabled = !active
            self.captureButton.isEnabled = !active
        }
    }
    
    func exportClip() {
        let clipURL = getDirectory()
        let interval = TimeInterval(5)
    
        print("Generating clip at URL: ", clipURL)
        if #available(iOS 15.0, *) {
            RPScreenRecorder.shared().exportClip(to: clipURL, duration: interval) { error in
                if error != nil {
                    print("Error attempting to start Clip Buffering")
                } else {
                    // There isn't an error, so save the clip at the URL to Photos.
                    self.saveToPhotos(tempURL: clipURL)
                }
            }
        }
        
    }
    
    func getDirectory() -> URL {
        var tempPath = URL(fileURLWithPath: NSTemporaryDirectory())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        let stringDate = formatter.string(from: Date())
        print(stringDate)
        tempPath.appendPathComponent(String.localizedStringWithFormat("output-%@.mp4", stringDate))
        return tempPath
    }
        
    func saveToPhotos(tempURL: URL) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tempURL)
        } completionHandler: { success, error in
            if success == true {
                print("Saved to photos")
            } else {
                print("Error exporting clip to Photos")
            }
        }
    }
    
    
    // MARK: - RPBroadcastActivityViewController Delegate
    func broadcastActivityViewController(_ broadcastActivityViewController: RPBroadcastActivityViewController, didFinishWith broadcastController: RPBroadcastController?, error: NSError?) {
        //TODO::
    }

    // MARK: - RPBroadcastController Delegate
    func broadcastController(_ broadcastController: RPBroadcastController, didFinishWithError error: NSError?) {
        //TODO::
    }
    
    // MARK: - RPScreenRecorder Delegate
    func screenRecorderDidChangeAvailability(_ screenRecorder: RPScreenRecorder) {
        // This delegate call lets the developer know when the screen recorder's availability changes.
        DispatchQueue.main.async {
            self.recordButton.isEnabled = screenRecorder.isAvailable
            self.captureButton.isEnabled = screenRecorder.isAvailable
            self.broadcastButton.isEnabled = screenRecorder.isAvailable
            self.clipButton.isEnabled = screenRecorder.isAvailable
        }
    }
    
    func screenRecorder(_ screenRecorder: RPScreenRecorder, didStopRecordingWith previewViewController: RPPreviewViewController?, error: Error?) {
        // This delegate call lets you know if any of the ongoing recording or capture stops.
        // If there's a preview view controller to give back, present it here.
        print("delegate didstoprecording with previewViewController")
        DispatchQueue.main.async {
            // Reset the UI state.
            print("inside delegate call")
            self.isActive = false
            self.recordButton.setTitle("Start Recording", for: UIControl.State.normal)
            self.captureButton.setTitle("Start Capture", for: UIControl.State.normal)
            self.broadcastButton.setTitle("Start Broadcast", for: UIControl.State.normal)
            self.clipButton.setTitle("Start Clips", for: UIControl.State.normal)
            self.recordButton.isEnabled = true
            self.captureButton.isEnabled = true
            self.broadcastButton.isEnabled = true
            self.clipButton.isEnabled = true
            self.getClipButton.isHidden = true
            self.getClipButton.isEnabled = false
            
            guard previewViewController != nil else {
                print("Preview controller is not available.")
                return
            }
            previewViewController?.modalPresentationStyle = .overFullScreen
            previewViewController?.previewControllerDelegate = self
            self.present(previewViewController!, animated: true, completion: nil)
            
        }
    }

}

extension UIView{
    func rotate() {
        // SWIFT 3/4
//        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
//        rotation.toValue = NSNumber(double: M_PI * 2)
//        rotation.duration = 1
//        rotation.cumulative = true
//        rotation.repeatCount = FLT_MAX
//        self.layer.addAnimation(rotation, forKey: "rotationAnimation")
        
        // SWIFT 5
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}

