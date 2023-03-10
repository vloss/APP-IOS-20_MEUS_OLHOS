//
//  ObjectsViewController.swift
//  MeusOlhos
//
//  Created by Eric Brito
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ObjectsViewController: UIViewController {
    
    @IBOutlet weak var viCamera: UIView!
    @IBOutlet weak var lbIdentifier: UILabel!
    @IBOutlet weak var lbConfidence: UILabel!
    
    lazy captureManager: CaptureManager = {
        let captureManager = CaptureManager()
        captureManager.videoBufferDelegate = self
        return captureManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func analyse(_ sender: UIButton) {
    }
}

extension ObjectsViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let model = try? VNCoreMLModel(for: VGG16().model) else { return }
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {return}
            for i in 0...5 {
                print(results[i].identifier, results[i].confidence)
            }
            print("=============================================")
            guard let firstObservation = results.first else {return}
            
            DispatchQueue.main.async {
                lbIdentifier.text = firstObservation.identifier
                
                let confidence = round(firstObservation.confidence*1000) / 10
                lbConfidence.text = "\(confidence)%"
            }
            
        }
    }
}
