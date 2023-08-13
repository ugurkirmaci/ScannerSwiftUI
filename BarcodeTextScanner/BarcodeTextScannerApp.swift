//
//  BarcodeTextScannerApp.swift
//  BarcodeTextScanner
//
//  Created by UğurKırmacı on 13.08.2023.
//

import SwiftUI

@main
struct BarcodeTextScannerApp: App {
    //Burda sadece appViewModeli baslattik
    @StateObject private var vm = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
            //uygulama baslatildiginda bu calisacak
                .task {
                    await vm.requestDataScannerAccessStatus()
                }
        }
    }
}
