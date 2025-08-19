//
//  FlypadLiveActivityWidgetLiveActivity.swift
//  FlypadLiveActivityWidget
//
//  Created by Azizbek Asadov on 04.07.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FlypadLiveActivityWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FlypadLiveActivityWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FlypadLiveActivityWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension FlypadLiveActivityWidgetAttributes {
    fileprivate static var preview: FlypadLiveActivityWidgetAttributes {
        FlypadLiveActivityWidgetAttributes(name: "World")
    }
}

extension FlypadLiveActivityWidgetAttributes.ContentState {
    fileprivate static var smiley: FlypadLiveActivityWidgetAttributes.ContentState {
        FlypadLiveActivityWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FlypadLiveActivityWidgetAttributes.ContentState {
         FlypadLiveActivityWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FlypadLiveActivityWidgetAttributes.preview) {
   FlypadLiveActivityWidgetLiveActivity()
} contentStates: {
    FlypadLiveActivityWidgetAttributes.ContentState.smiley
    FlypadLiveActivityWidgetAttributes.ContentState.starEyes
}
