//
//  ContentView.swift
//  app_ios
//
//  Created by Vinh Tong on 23/5/25.
//

import SwiftUI

struct FView: UIViewControllerRepresentable {
    
    private var viewController: FViewController
    
    init() {
        self.viewController = FManager.shared.makeViewController()
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: ()) {
        guard let viewController = uiViewController as? FViewController else { return }
        viewController.dispose()
    }
}

struct ContentView: View {
    @State var path: [Int] = []
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 24) {
                Button(action: {
                    path = [0]
                }, label: {
                    Text("Push a page")
                })
                Button(action: {
                    path = (0..<10).map{ $0 }
                }, label: {
                    Text("Push 10 pages")
                })
                Button(action: {
                    path = (0..<100).map{ $0 }
                }, label: {
                    Text("Push 100 pages")
                })
            }
            .navigationDestination(for: Int.self) { value in
                FView()
                    .ignoresSafeArea()
                    .navigationTitle("[Flutter] Page \(value + 1)")
                    .toolbar {
                        ToolbarItem {
                            Button {
                                path = []
                            } label: {
                                Text("Reset")
                            }
                        }
                        ToolbarItem {
                            Button {
                                path.append(path.count)
                            } label: {
                                Text("Add")
                            }
                        }
                    }
            }
        }
        .task {
            FManager.shared.start()
        }
    }
}

#Preview {
    ContentView()
}
