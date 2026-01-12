import SwiftUI

struct SocialLoginButtons: View {
    let onSignIn: (String) -> Void // provider name
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Button(action: { onSignIn("google") }) {
                HStack(spacing: Spacing.md) {
                    Image("google_logo") // Assuming we have it or use SF Symbol
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    
                    Text("Войти через Google")
                        .font(.muscleUpBodyMedium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(CornerRadius.md)
            }
            
            Button(action: { onSignIn("apple") }) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 24))
                    
                    Text("Войти через Apple")
                        .font(.muscleUpBodyMedium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.black)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(Color.muscleUpCardBorder, lineWidth: 1)
                )
                .cornerRadius(CornerRadius.md)
            }
        }
    }
}
