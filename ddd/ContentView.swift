//
//  ContentView.swift
//  ddd
//
//  Created by Finny Jakey on 2023/10/05.
//

import SwiftUI

struct ContentView: View {
    init(){
        UINavigationBar.appearance().barTintColor = .systemBackground
        UINavigationBar.appearance().shadowImage = UIImage()
        UITableViewHeaderFooterView.appearance().backgroundView = UIView()
    }
    
    var body: some View {
        NavigationStack {
            DayListView()
                .navigationTitle("DDD")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
