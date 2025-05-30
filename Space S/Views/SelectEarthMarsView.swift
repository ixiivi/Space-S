import SwiftUI
import SwiftData

struct SelectEarthMarsView: View {
    @Binding var path: [Route]
    @Bindable var user: User
    
    init(path: Binding<[Route]>, user: User) {
        self._path = path
        self.user = user
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("CHOOSE YOUR PERSPECTIVE")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("View details for your Optimus \(user.selectedBot ?? "Bot")'s journey.")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // 지구 선택 버튼
                perspectiveButton(
                    perspectiveName: "Earth",
                    iconName: "network",
                    iconColor: .blue,
                    description: "Track production, launch, and interplanetary trajectory from Earth.",
                    action: {
                        Logger.logInfo("User '\(user.name)' chose Earth-side view for bot '\(user.selectedBot ?? "N/A")'.")
                        path.append(.earthSideView(user: self.user))
                    }
                )
                
                // 화성 선택 버튼
                perspectiveButton(
                    perspectiveName: "Mars",
                    iconName: "map.fill",
                    iconColor: .red,
                    description: "Monitor Mars landing conditions, deployment, and sponsored project progress.",
                    action: {
                        Logger.logInfo("User '\(user.name)' chose Mars-side view for bot '\(user.selectedBot ?? "N/A")'.")
                        path.append(.marsSideView(user: self.user))
                    }
                )
            }
            .padding(.vertical, 40)
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Journey Perspective")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Logger.logInfo("SelectEarthMarsView appeared for user: \(user.name), bot model: \(user.selectedBot ?? "N/A").")
        }
    }
    
    private func perspectiveButton(perspectiveName: String, iconName: String, iconColor: Color, description: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.system(size: 48))
                    .foregroundColor(iconColor)
                Text(perspectiveName + " Perspective")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(height: 50, alignment: .top)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(iconColor.opacity(0.7), lineWidth: 1.5)
            )
        }
        .padding(.horizontal, 32)
    }
}

// Preview (user.selectedBot 사용하도록 수정)
#if DEBUG
struct SelectEarthMarsView_Previews: PreviewProvider {
    @State static var previewPath: [Route] = []
    static var sampleUser: User = {
        // User init은 현재 프로젝트의 User 모델 정의를 따라야 합니다.
        // 제공해주신 User init: init(id: String, name: String, phoneNumber: String)
        let user = User(id: "previewSelectViewUser", name: "SelectView User", phoneNumber: "01077778888")
        user.selectedBot = "Gen6" // User 모델의 필드명에 맞게 설정
        return user
    }()

    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: User.self, configurations: config)
        container.mainContext.insert(sampleUser)

        return NavigationStack {
            SelectEarthMarsView(path: $previewPath, user: sampleUser)
                .modelContainer(container)
        }
    }
}
#endif
