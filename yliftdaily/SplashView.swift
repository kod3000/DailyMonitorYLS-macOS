//
//  SplashView.swift
//  YLift Daily
//
//  Created by username on 6/30/24.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        GeometryReader { geometry in
            Image("splash") 
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .overlay(
                    VStack {
                        Spacer()
//                        Text("Y Lift Daily Monitor")
//                            .font(.largeTitle)
//                            .foregroundColor(.white)
//                            .padding()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.bottom, 50)
                    }
                )
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
