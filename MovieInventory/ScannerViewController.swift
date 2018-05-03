//
//  ScannerViewController.swift
//  MovieInventory
//
//  Created by Paul Heintz on 4/18/18.
//  Copyright © 2018 Paul Heintz. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class ScannerViewController: UIViewController, UITextFieldDelegate, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var previewFrame: UIView!
    @IBOutlet weak var barcodeLbl: UILabel!
    @IBOutlet weak var movieLbl: UILabel!
    @IBOutlet weak var movieTitle: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var codeLabel: UILabel! = {
        let codeLabel = UILabel()
        codeLabel.backgroundColor = .white
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        return codeLabel
    }()
    let codeFrame: UIView = {
        let codeFrame = UIView()
        codeFrame.layer.borderColor = UIColor.green.cgColor
        codeFrame.layer.borderWidth = 2
        codeFrame.frame = CGRect.zero
        codeFrame.translatesAutoresizingMaskIntoConstraints = false
        return codeFrame
    }()
    var captureDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    var theTitle: String?
    var movie: Movie?
    
    override func viewDidLayoutSubviews() {
        videoPreviewLayer?.frame = previewFrame.layer.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieTitle.delegate = self
        movieLbl.isHidden = true
        movieTitle.text = theTitle
        movieTitle.isHidden = true
        barcodeLbl.isHidden = true
        addBtn.isHidden = true
        saveButton.isEnabled = false
        
        // Setup capture device
        captureDevice = AVCaptureDevice.default(for: .video)
        
        // Check if capture device returns a value and unwrap it
        if let captureDevice = captureDevice {
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                
                captureSession = AVCaptureSession()
                guard let captureSession = captureSession else { return }
                captureSession.addInput(input)
                
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession.addOutput(captureMetadataOutput)
                
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: .main)
                captureMetadataOutput.metadataObjectTypes = [.code128, .qr, .ean13, .ean8, .code39, .upce]
                
                captureSession.startRunning()
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer?.videoGravity = .resizeAspectFill
                previewFrame.layer.addSublayer(videoPreviewLayer!)
                
            } catch {
                print("Error Device Input")
            }
        }
        view.addSubview(codeLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            codeFrame.frame = CGRect.zero
            codeLabel.text = "No Data"
            return
        }
        
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        guard let stringCodeValue = metadataObject.stringValue else { return }
        
        view.addSubview(codeFrame)
        
        guard let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject) else { return }
        codeFrame.frame = barcodeObject.bounds
        codeLabel.text = stringCodeValue
        
        // Play beep sound
        let customSoundId: SystemSoundID = 1052
        
        AudioServicesAddSystemSoundCompletion(customSoundId, nil, nil, { (customSoundId, _) -> Void in
            AudioServicesDisposeSystemSoundID(customSoundId)
        }, nil)
        
        AudioServicesPlaySystemSound(customSoundId)
        
        
        // Stop capturing and hence stop executing metadataOutput function over and over again
        captureSession?.stopRunning()
        
        let url = "\(BarcodeAPI.movieDetailsURL)&barcode=\(stringCodeValue)"
        fetchMovieDetails(apiURL: url)
        //fetchMovieDetails(apiURL: "\(BarcodeAPI.movieDetailsURL)")
        
        movieLbl.isHidden = false
        movieTitle.text = theTitle
        movieTitle.isHidden = false
        barcodeLbl.isHidden = false
        saveButton.isEnabled = true
        
    }
    
    func fetchMovieDetails(apiURL: String) {
        print("apiURL: \(apiURL)")
        let url = URLComponents(string: apiURL)
        let request = URLRequest(url: (url?.url!)!)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let results = json["result"] as? [[String: Any]] {
                    for result in results {
                        if let details = result["details"] as? AnyObject {
                            DispatchQueue.main.async {
                                self.movieTitle.text = (details["long_description"] as! String)
                            }
                            self.theTitle = (details["long_description"] as! String)
                            print("From JSON: \(self.theTitle ?? "")")
                            //self.movies.append(title)
                        }
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
        }
        task.resume()
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        movieTitle.text = textField.text
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            print("A save button was not pressed, cancelling")
            return
        }
        
        let barcode = codeLabel.text ?? ""
        let title = movieTitle.text ?? ""
        
        // Set the movie to be passed to MovieTableViewController after the unwind segue.
        movie = Movie(barcode: barcode, title: title)
    }
}

