import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerView: View {
    let onPick: (URL) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var pickedURL: URL?

    var body: some View {
        NavigationStack {
            VStack(spacing: SaltTheme.spacingXL) {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(SaltColors.accent)

                VStack(spacing: SaltTheme.spacingM) {
                    Text("Import Music")
                        .saltTitle1()

                    Text("Select a folder containing your music files")
                        .saltSecondary()
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: SaltTheme.spacingS) {
                    Text("Supported formats:")
                        .font(SaltTypography.caption1)
                        .foregroundColor(SaltColors.textTertiary)

                    Text("MP3, M4A, AAC, FLAC, WAV, AIFF, OGG")
                        .font(SaltTypography.caption1)
                        .foregroundColor(SaltColors.textSecondary)
                }

                Button(action: {
                    let types: [UTType] = [.audio, .mp3, .mpeg4Audio, .flac, .aiff, .wav]
                    let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: false)
                    picker.delegate = DocumentPickerDelegate(onPick: { url in
                        pickedURL = url
                        onPick(url)
                        dismiss()
                    })
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        rootVC.present(picker, animated: true)
                    }
                }) {
                    HStack {
                        Image(systemName: "folder")
                        Text("Select Folder")
                    }
                    .font(SaltTypography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SaltTheme.spacingM)
                    .background(SaltGradient.accent)
                    .clipShape(Capsule())
                }
                .padding(.horizontal, SaltTheme.spacingXL)
            }
            .padding(SaltTheme.spacingXL)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SaltColors.background)
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(SaltColors.textSecondary)
                }
            }
        }
    }
}

class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    let onPick: (URL) -> Void

    init(onPick: @escaping (URL) -> Void) {
        self.onPick = onPick
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        onPick(url)
    }

    func documentPickerWasDismissed(_ controller: UIDocumentPickerViewController) {
    }
}

#Preview {
    DocumentPickerView { _ in }
}
