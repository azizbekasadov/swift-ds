//
//  GenderSelectionView.swift
//  SalamNamaz
//
//  Created by Azizbek Asadov on 25.07.2025.
//


struct GenderSelectionView: View {
    @State private var selectedGender: GenderType? = .male

    var body: some View {
        VStack(spacing: 24) {
            // Title
            VStack(spacing: 8) {
                Text("Gender illustrations")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Select the gender illustrations that will be used to learn the prayer")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)

            // Gender selection cards
            HStack(spacing: 24) {
                GenderCardView(
                    imageName: "male_illustration",
                    isSelected: selectedGender == .male
                ) {
                    selectedGender = .male
                }

                GenderCardView(
                    imageName: "female_illustration",
                    isSelected: selectedGender == .female
                ) {
                    selectedGender = .female
                }
            }

            Spacer()

            // Select button
            Button(action: {
                // handle selection confirmation
                print("Selected gender: \(selectedGender?.rawValue ?? "none")")
            }) {
                Text("Select")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.black.ignoresSafeArea())
    }
}

enum GenderType: String {
    case male, female
}

struct GenderCardView: View {
    let imageName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 250)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.green : Color.clear, lineWidth: 4)
                )
        }
    }
}