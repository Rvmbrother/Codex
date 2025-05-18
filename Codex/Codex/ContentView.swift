import SwiftUI

struct ContentView: View {
    @State private var tasks: [Task] = []

    private var tasksURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("tasks.md")
    }

    var body: some View {
        List {
            ForEach($tasks) { $task in
                HStack {
                    Button(action: {
                        task.isDone.toggle()
                        if task.isDone {
                            task.line = task.line.replacingOccurrences(of: "[ ]", with: "[x]")
                        } else {
                            task.line = task.line.replacingOccurrences(of: "[x]", with: "[ ]")
                        }
                        TaskParser.save(tasks, to: tasksURL)
                    }) {
                        Image(systemName: task.isDone ? "checkmark.square" : "square")
                    }
                    .buttonStyle(.plain)

                    Text(task.text)
                        .strikethrough(task.isDone)
                }
            }
        }
        .frame(width: 220, height: 200)
        .onAppear(perform: loadTasks)
    }

    private func loadTasks() {
        if !FileManager.default.fileExists(atPath: tasksURL.path) {
            try? "".write(to: tasksURL, atomically: true, encoding: .utf8)
        }
        tasks = TaskParser.load(from: tasksURL)
    }
}


