//
//  DataScannerView.swift
//  BarcodeTextScanner
//
//  Created by UğurKırmacı on 13.08.2023.
//

import Foundation
import SwiftUI
import VisionKit



struct DataScannerView: UIViewControllerRepresentable {
    
    @Binding var recognizedItems: [RecognizedItem]
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    let recognizesMultipleItems: Bool
    
    //mac ui gorunum icin
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(recognizedDataTypes: [recognizedDataType],
            qualityLevel: .balanced,
            recognizesMultipleItems: recognizesMultipleItems,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        return vc
    }
    //veri tarayici view controller gececek
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        //yeni tagleri gecis yapmasi ve guncellemesi icin
        
        try? uiViewController.startScanning()//kamerayi taramaya basliyacak
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems)
    }
    
    //icerik icin entegre etmeye burdan alcaz
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning() //cleanup
    }
    
    
    //goruntu denetleyicisini calistirmak icin bir class olusturucaz
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        @Binding var recognizedItems: [RecognizedItem]
        //init edicez
        init(recognizedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recognizedItems
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print("didTapOn \(item)")
        }
        //ekle
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            recognizedItems.append(contentsOf: addedItems)
            print("didAddItems \(addedItems)")
        }
        //data impilimente edicez
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            //tableri filitreme burdan olacak
            self.recognizedItems = recognizedItems.filter { item in
                !removedItems.contains(where: {$0.id == item.id }) //id ye esit olduguda kaldirma ogesini almayan ogeleri filitreliyecegiz
            }
            print("didRemovedItems \(removedItems)")
        }
        
        //error
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("became unaviable with error \(error.localizedDescription)")
        }
        
    }
    
    
    
}
