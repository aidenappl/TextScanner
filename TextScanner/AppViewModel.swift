//
//  AppViewModel.swift
//  TextScanner
//
//  Created by Aiden Appleby on 2/10/23.
//

import AVKit
import Foundation
import SwiftUI
import VisionKit

enum ScanType {
    case barcode, text
}

enum DataScannerAccessStatusType {
    case notDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}

@MainActor
final class AppViewModel: ObservableObject {
    
    @Published var dataScannerAccessStatus: DataScannerAccessStatusType = .notDetermined
    @Published var recognizedItems: [RecognizedItem] = []
    @Published var scanType: ScanType = .barcode
    @Published var textContentType: DataScannerViewController.TextContentType?
    @Published var recognizesMultipleItems: Bool = true
    
   var recognizedDataType: DataScannerViewController.RecognizedDataType {
       get {scanType == .barcode ? .barcode() :
           .text(textContentType: textContentType)}
       set {}
    }
    
    private var isScannerAvailable: Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    func requestDataScannerAccessStats() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
            case .authorized:
                dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            
            case .restricted, .denied:
                dataScannerAccessStatus = .cameraAccessNotGranted
                
            case .notDetermined:
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                if granted {
                    dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
                } else {
                    dataScannerAccessStatus = .cameraAccessNotGranted
                }
                
            default: break
            
        }
    }
    
}
