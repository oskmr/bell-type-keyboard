//
//  ContactFormView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/08/28.
//

import SwiftUI
import PhotosUI

/// ContactFormView renders a native contact form for support inquiries.
///
/// Example:
/// ```swift
/// ContactFormView()
/// ```
struct ContactFormView: View {
    private static let categories = [
        "不具合の報告",
        "機能の要望・改善案",
        "課金・プランについて",
        "その他"
    ]

    private static let maxScreenshots = 3

    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategory: String?
    @State private var content: String = ""
    @State private var replyEmail: String = ""
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var screenshots: [UIImage] = []
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private var isValid: Bool {
        selectedCategory != nil && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                categorySection
                contentSection
                emailSection
                screenshotSection
                submitButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("お問い合わせ")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Color(.systemGray5)))
                }
            }
        }
        .alert("お問い合わせ", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onChange(of: pickerItems) { _, newItems in
            loadScreenshots(from: newItems)
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カテゴリ")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                ForEach(Self.categories, id: \.self) { category in
                    categoryRow(category)
                }
            }
        }
    }

    private func categoryRow(_ category: String) -> some View {
        let isSelected = selectedCategory == category

        return Button(action: { selectedCategory = category }) {
            HStack {
                Text(category)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: isSelected ? "checkmark.seal.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .green : Color(.systemGray4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("お問い合わせ内容")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)

            ZStack(alignment: .topLeading) {
                if content.isEmpty {
                    Text("お困りの内容やご要望をご記入ください")
                        .font(.system(size: 16))
                        .foregroundColor(Color(.placeholderText))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }

                TextEditor(text: $content)
                    .font(.system(size: 16))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .scrollContentBackground(.hidden)
            }
            .frame(minHeight: 180)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
    }

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("返信用メールアドレス（任意）")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)

            TextField("例) example@fracaso.app", text: $replyEmail)
                .font(.system(size: 16))
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.secondarySystemGroupedBackground))
                )

            Text("返信をご希望の場合はご入力ください")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }

    private var screenshotSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("スクリーンショット（任意・最大\(Self.maxScreenshots)枚）")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                ForEach(Array(screenshots.enumerated()), id: \.offset) { index, image in
                    screenshotThumbnail(image, index: index)
                }

                if screenshots.count < Self.maxScreenshots {
                    PhotosPicker(
                        selection: $pickerItems,
                        maxSelectionCount: Self.maxScreenshots - screenshots.count,
                        matching: .images
                    ) {
                        VStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .medium))
                            Text("追加")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.secondary)
                        .frame(width: 80, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                        )
                    }
                }
            }
        }
    }

    private func screenshotThumbnail(_ image: UIImage, index: Int) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(alignment: .topTrailing) {
                Button(action: { removeScreenshot(at: index) }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
                .offset(x: 6, y: -6)
            }
    }

    private var submitButton: some View {
        Button(action: submit) {
            HStack(spacing: 8) {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                }
                Text("送信する")
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(isValid ? Color.green : Color.green.opacity(0.4))
            )
        }
        .disabled(!isValid || isSubmitting)
        .padding(.top, 4)
    }

    private func removeScreenshot(at index: Int) {
        screenshots.remove(at: index)
    }

    private func loadScreenshots(from items: [PhotosPickerItem]) {
        Task {
            var loaded: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    loaded.append(image)
                }
            }
            await MainActor.run {
                screenshots = loaded
            }
        }
    }

    private func submit() {
        // TODO: 送信先(Notion連携等)が決まり次第、実際の送信処理に差し替える。
        alertMessage = "送信機能は準備中です"
        showAlert = true
    }
}

#Preview {
    NavigationStack {
        ContactFormView()
    }
}
