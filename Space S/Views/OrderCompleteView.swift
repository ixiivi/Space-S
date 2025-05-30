//
//  OrderCompleteView.swift
//  Space S
//
//  Created by 김재현 on 5/28/25.
//

import SwiftUI

struct OrderCompleteView: View {
    @Binding var path: [Route]
    @Bindable var user: User

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()  // background color

            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)

                Text("Your order is complete")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .foregroundColor(.black)

                Spacer()
                
                Image("haha_yes")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 240)


                Spacer()

                Button(action: {
                    path.append(Route.selectDestination(user: self.user))
                }) {
                    Text("Explore Space S")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)

                Text("You will receive an email confirmation with your order details within 24 hours")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true) // 이 화면에서는 뒤로가기 버튼 숨김
        .onAppear {
            Logger.logInfo("OrderCompleteView appeared.")
        }
    }
}

// Preview
#if DEBUG
struct OrderCompleteView_Previews: PreviewProvider {
    @State static var previewPath: [Route] = []
    static var sampleUser: User = User(id: "previewUser", name: "Preview User", phoneNumber: "01012340000")
    static var previews: some View {
        NavigationStack { // Preview를 위해 NavigationStack으로 감쌈
            OrderCompleteView(path: $previewPath, user: sampleUser)
        }
    }
}
#endif
