import SwiftUI
import UIKit
import LinkPresentation

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    var subject: String? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        var activityItems: [Any] = []
        
        // If we have a subject, create an item source with metadata
        if let subject = subject, let text = items.first as? String {
            let itemSource = ShareActivityItemSource(text: text, subject: subject)
            activityItems.append(itemSource)
        } else {
            activityItems = items
        }
        
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

// Custom item source to provide subject/title
class ShareActivityItemSource: NSObject, UIActivityItemSource {
    let text: String
    let subject: String
    
    init(text: String, subject: String) {
        self.text = text
        self.subject = subject
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return text
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return text
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return subject
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = subject
        return metadata
    }
}
