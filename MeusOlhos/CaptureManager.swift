//
//  CaptureManager.swift
//  MeusOlhos
//
//  Created by Vinicius Loss on 09/03/23.
//  Copyright © 2023 Eric Brito. All rights reserved.
//

import Foundation
import AVKit

class CaptureManager {
    
    lazy var captureSession: AVCaptureSession = {
       let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        return captureSession
    }()
    
    weak var videoBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?
 
    init() {
        
    }
    
    func startCameraCapture() -> AVCaptureVideoPreviewLayer? {
        if askForPermission() {
            // objeto que vai ter acesso ao video
            guard let captureDevice = AVCaptureDevice.default(for: .video) else { return nil }
            
            do {
                // fonte de entreda de informações = video
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(input)
            } catch {
                print(error.localizedDescription)
                return nil
            }
            
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
            //captureSession.startRunning()
            
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(videoBufferDelegate, queue: DispatchQueue(label: "cameraQueue"))
            captureSession.addOutput(videoDataOutput)
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            return previewLayer
        } else {
            return nil
        }
    }
    
    // valida acesso a câmera do usuário
    func askForPermission() -> Bool {
        var hasPermission: Bool = true
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                hasPermission = true
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { (success) in
                    hasPermission = success
                }
            case .restricted, .denied:
                hasPermission = false
        }
        return hasPermission
    }
}
