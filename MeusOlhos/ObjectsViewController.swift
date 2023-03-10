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
        
    lazy var captureManager: CaptureManager = {
        let captureManager = CaptureManager()
        captureManager.videoBufferDelegate = self
        return captureManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbConfidence.text = ""
        lbIdentifier.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let previewLayer = captureManager.startCameraCapture() else {return}
        previewLayer.frame = viCamera.bounds
        viCamera.layer.addSublayer(previewLayer)
    }
    
    @IBAction func analyse(_ sender: UIButton) {
    }
}

extension ObjectsViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        guard let modelURL = Bundle.main.url(forResource: "YOLOv3Tiny", withExtension: "mlmodelc") else {
            print("ERROOOOO: YOLOv3Tiny")
            return
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let request = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                
                    
                    // Funciona
                    if let results = request.results {
                        for observation in results where observation is VNRecognizedObjectObservation {
                            
                            print("results: ", results)
                            
                            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                                continue
                            }

                            for label in objectObservation.labels {
                                print(label.identifier, " - ", label.confidence)
                            }

                            // Select only the label with the highest confidence.
                            let topLabelObservation = objectObservation.labels[0]

                            self.lbIdentifier.text = topLabelObservation.identifier
                            let confidence = round(topLabelObservation.confidence*1000) / 10
                            self.lbConfidence.text = "\(confidence)%"
                            
                            print("==============================================")
                        }
                    }
                })
            })
            
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer).perform([request])

        } catch let error as NSError {
            print("ERROOOOO: Model loading went wrong: \(error)")
        }
// ==============================================================================================
// Mostrado no curso, porém apresenta erro.
//        guard let model = try? VNCoreMLModel(for: VGG16().model) else { return }
//        let request = VNCoreMLRequest(model: model) { request, error in
//            guard let results = request.results as? [VNClassificationObservation] else {return}
//            for i in 0...5 {
//                print(results[i].identifier, results[i].confidence)
//            }
//            print("=============================================")
//            guard let firstObservation = results.first else {return}
//
//            DispatchQueue.main.async {
//                self.lbIdentifier.text = firstObservation.identifier
//
//                let confidence = round(firstObservation.confidence*1000) / 10
//                self.lbConfidence.text = "\(confidence)%"
//            }
//        }
        
//        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer).perform([request])
        
    }
}
