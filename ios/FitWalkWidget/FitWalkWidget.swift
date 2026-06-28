import WidgetKit
import SwiftUI

struct FitWalkEntry: TimelineEntry {
    let date: Date
    let steps: Int
    let goal: Int
    let progress: Double
}

struct Provider: TimelineProvider {
    let appGroup = "group.com.kaan.fitwalk"

    func placeholder(in context: Context) -> FitWalkEntry {
        FitWalkEntry(date: Date(), steps: 0, goal: 6000, progress: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (FitWalkEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FitWalkEntry>) -> Void) {
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [readEntry()], policy: .after(next)))
    }

    func readEntry() -> FitWalkEntry {
        let d = UserDefaults(suiteName: appGroup)
        return FitWalkEntry(
            date: Date(),
            steps: d?.integer(forKey: "steps") ?? 0,
            goal: d?.integer(forKey: "goal") ?? 6000,
            progress: d?.double(forKey: "progress") ?? 0
        )
    }
}

struct FitWalkWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bugün").font(.caption).foregroundColor(.secondary)
            Text("\(entry.steps)").font(.system(size: 28, weight: .bold))
            Text("/ \(entry.goal) adım").font(.caption2).foregroundColor(.secondary)
            ProgressView(value: entry.progress)
                .tint(Color(red: 0.055, green: 0.486, blue: 0.4))
        }
        .padding()
    }
}

@main
struct FitWalkWidget: Widget {
    let kind = "FitWalkWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                FitWalkWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                FitWalkWidgetEntryView(entry: entry).padding()
            }
        }
        .configurationDisplayName("FitWalk")
        .description("Bugünkü adımların ve hedefin.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
