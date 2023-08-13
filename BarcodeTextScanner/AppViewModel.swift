//
//  AppViewModel.swift
//  BarcodeTextScanner
//
//  Created by UğurKırmacı on 13.08.2023.
//

import AVKit
import Foundation
import SwiftUI
import VisionKit


enum ScanType: String {
    case barcode, text
}


enum DataScannerAccessStatusType {
    case notDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}

//Eszamanli yonetebilkmek icin uygulama gorunteleme modelini kullanicaz. Bu bizim ana aktorumuz olucak
@MainActor
final class AppViewModel: ObservableObject {
    
    //veri tarayici erisim durumunu eszamansiz olarak talep etmek
    @Published var dataScannerAccessStatus: DataScannerAccessStatusType = .notDetermined
    @Published var recognizedItems: [RecognizedItem] = []
    @Published var scanType: ScanType = .barcode
    @Published var textContentType: DataScannerViewController.TextContentType?
    @Published var recognizesMultipleItems = true
    
    var recognizedDataType: DataScannerViewController.RecognizedDataType {
        scanType == .barcode ? .barcode() : .text(textContentType: textContentType)
    }
    
    var headerText: String {
        if recognizedItems.isEmpty {
            return "Scanning \(scanType.rawValue)"
        } else {
            return "Recognized \(recognizedItems.count) item(s)"// ogegi taniyarak geri donecek itemslara
        }
    }
    
    var dataScannerViewId: Int {
        var hasher = Hasher()
        hasher.combine(scanType)
        hasher.combine(recognizesMultipleItems)
        if let textContentType {
            hasher.combine(textContentType)
        }
        return hasher.finalize()
    }
    
    private var isScannerAvailable: Bool {
        //iki ozellik dogru oldugunda isScannerAvailable
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    //VisonKit frameworkunu kullaniyoruz.
    func requestDataScannerAccessStatus() async {
        //kamera donanimina sahip olup olmadigimiz kontrol edicez,
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }
        
        //kamera erisim izni icin
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        
        case .authorized:
            dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
        
        case .restricted, .denied:
            dataScannerAccessStatus = .cameraAccessNotGranted
        
        case .notDetermined:
            //Bool'in bir degere donusturen asycn bir fonksiyon
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
