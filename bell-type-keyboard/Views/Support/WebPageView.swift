//
//  WebPageView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/08/28.
//

import SwiftUI
import WebKit

/// WebPageView loads a URL in an embedded web view with a navigation title.
///
/// Example:
/// ```swift
/// WebPageView(title: "利用規約", urlString: "https://example.com")
/// ```
struct WebPageView: View {
    let title: String
    let urlString: String

    @State private var isLoading = true

    var body: some View {
        ZStack {
            if let url = URL(string: urlString) {
                WebViewRepresentable(url: url, isLoading: $isLoading)
            } else {
                Text("URLを読み込めませんでした")
                    .foregroundColor(.secondary)
            }

            if isLoading {
                ProgressView()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct WebViewRepresentable: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool

        init(isLoading: Binding<Bool>) {
            _isLoading = isLoading
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        WebPageView(title: "利用規約", urlString: "https://sun-pink-516.notion.site/1c54c4b711e98020a28ff182d9d4fd6c")
    }
}
