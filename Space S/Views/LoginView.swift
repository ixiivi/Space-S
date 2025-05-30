//
//  LoginView1.swift
//  Space S
//
//  Created by 김재현 on 5/28/25.
//

import SwiftUI
import SwiftData


struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var path: [Route]
    
    @State private var userIdInput: String = ""
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    
    @State private var isUserIdValid: Bool = true
    @State private var isNameValid: Bool = true
    @State private var isPhoneNumberValid: Bool = true
    @State private var showInvalidInputAlert: Bool = false
    @State private var errorMessageForAlert: String = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer().frame(height: UIScreen.main.bounds.height / 6)
                
                HStack(alignment: .bottom) {
                    Image("logo")
                        .resizable().scaledToFit().frame(width: 100, height: 100)
                        .clipShape(Circle()).overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    Spacer()
                    Text("Launch Now")
                        .foregroundColor(.white).font(.system(size: 28, weight: .bold)).baselineOffset(6)
                }.padding(.horizontal, 32)
                
                VStack(spacing: 20) {
                    TextField("Name", text: $name)
                        .foregroundColor(.white).padding()
                        .background(Color.black.opacity(0.8)).cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(isNameValid ? Color.white.opacity(0.2) : Color.red, lineWidth: 1))
                        .textContentType(.name).autocorrectionDisabled()
                    
                    TextField("ID", text: $userIdInput)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isUserIdValid ? Color.white.opacity(0.2) : Color.red, lineWidth: 1)
                        )
                        .autocapitalization(.none) // 자동 대문자화 방지
                        .disableAutocorrection(true) // 자동 수정 비활성화
                        .onChange(of: userIdInput) { oldValue, newValue in
                            // 입력값을 항상 소문자로 변환하여 @State 변수에 다시 할당
                            userIdInput = newValue.lowercased()
                        }
                    
                    TextField("Phone Number (e.g., 01012345678)", text: $phoneNumber)
                        .foregroundColor(.white).padding()
                        .background(Color.black.opacity(0.8)).cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(isPhoneNumberValid ? Color.white.opacity(0.2) : Color.red, lineWidth: 1))
                        .keyboardType(.phonePad).textContentType(.telephoneNumber)
                    
                    Button(action: registerNewUserAndProceed) { // 함수 이름 변경
                        Text("Get Started") // 버튼 텍스트
                            .font(.system(size: 18, weight: .bold)).frame(maxWidth: .infinity)
                            .padding().background(Color.blue)
                            .foregroundColor(.white).clipShape(Capsule())
                    }.padding(.top, 10)
                }.padding(.horizontal, 32)
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .alert("Input Error", isPresented: $showInvalidInputAlert) {
            Button("OK", role: .cancel) { }
        } message: { Text(errorMessageForAlert) }
    }
    
    private func validateInputs() -> Bool {
        isNameValid = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        isUserIdValid = !userIdInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let phoneRegex = "^[0-9]{10,11}$"
        let phonePredicate = NSPredicate(format:"SELF MATCHES %@", phoneRegex)
        isPhoneNumberValid = phonePredicate.evaluate(with: phoneNumber.replacingOccurrences(of: "-", with: ""))
        
        if !isNameValid {
            errorMessageForAlert = "Please enter your name."
            return false
        }
        if !isUserIdValid {
            errorMessageForAlert = "Please enter a valid ID (e.g., lowercase letters and numbers)."
            return false
        }
        if !isPhoneNumberValid {
            errorMessageForAlert = "Please enter a valid phone number (10-11 digits without hyphens)."
            return false
        }
        return true
    }
    
    // 항상 새로운 사용자를 생성하고 진행하는 함수
    private func registerNewUserAndProceed() {
        guard validateInputs() else {
            showInvalidInputAlert = true
            Logger.logError("Registration: Invalid input. Name: \(name), Phone: \(phoneNumber)")
            return
        }
        
        let normalizedPhoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
        
        do {
            let newUser = User(id: userIdInput, name: name, phoneNumber: normalizedPhoneNumber)
            modelContext.insert(newUser)
            try modelContext.save()
            
            // --- 사용자 정보 출력 시작 ---
            print("--- New User Information ---")
            print("ID: \(newUser.id)")
            print("Name: \(newUser.name)")
            print("Phone Number: \(newUser.phoneNumber)")
            print("Selected Bot Model: \(newUser.selectedBot ?? "N/A")")
            print("Sponsor: \(newUser.sponsor ?? "N/A")")
            print("Waiting Number: \(newUser.waitList)")
            //print("Created At: \(newUser.createdAt)")
            //print("Destination: \(newUser.destination ?? "N/A")")
            print("Is Fully Setup: \(newUser.isFullySetup)")
            print("---------------------------")
            // --- 사용자 정보 출력 끝 ---
            
            // 다음 화면으로 새로 생성된 User 객체 전달하며 네비게이션
            path.append(Route.buyBot(user: newUser))
            
        } catch {
            Logger.logError("Registration: Failed to create and save new user: \(error.localizedDescription)")
            errorMessageForAlert = "An error occurred while creating your profile. Please try again."
            showInvalidInputAlert = true
        }
    }
}

#Preview {
    @Previewable @State var previewPath: [Route] = []
    LoginView(path: $previewPath)
}
