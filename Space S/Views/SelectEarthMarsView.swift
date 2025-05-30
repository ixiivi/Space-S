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
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 32) {

                Text("Welcome, \(user.name)!                          Choose Your Perspective")
                    .font(.system(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)

                Text("View details for your Optimus \(user.selectedBot ?? "Bot")'s journey.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                perspectiveButton(
                    perspectiveName: "Earth",
                    iconName: "network",
                    iconColor: .blue,
                    description: "Track production, launch, and interplanetary trajectory from Earth."
                ) {
                    Logger.logInfo("User '\(user.name)' chose Earth-side view.")
                    path.append(.earthSideView(user: self.user))
                }

                perspectiveButton(
                    perspectiveName: "Mars",
                    iconName: "map.fill",
                    iconColor: .red,
                    description: "Monitor Mars landing conditions, deployment, and sponsored project progress."
                ) {
                    Logger.logInfo("User '\(user.name)' chose Mars-side view.")
                    path.append(.marsSideView(user: self.user))
                }
            }
            .padding(.vertical, 40)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Journey Perspective")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Logger.logInfo("SelectEarthMarsView appeared for user: \(user.name)")
        }
    }

    private func perspectiveButton(
        perspectiveName: String,
        iconName: String,
        iconColor: Color,
        description: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 40))
                    .foregroundColor(iconColor)

                Text("\(perspectiveName) Perspective")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .padding(.horizontal, 24)
    }
}
