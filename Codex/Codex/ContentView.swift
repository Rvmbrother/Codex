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
                if task.isTask {
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
                    .padding(.leading, CGFloat(task.indent) * 10)
                } else {
                    Text(task.text)
                        .font(task.line.trimmingCharacters(in: .whitespaces).hasPrefix("#") ? .headline : .body)
                        .padding(.vertical, task.line.trimmingCharacters(in: .whitespaces).hasPrefix("#") ? 6 : 0)
                        .padding(.leading, CGFloat(task.indent) * 10)
                }
            }
        }
        .frame(width: 300, height: 400)

        .listStyle(.inset)


        .onAppear(perform: loadTasks)
    }

    private func loadTasks() {
        if !FileManager.default.fileExists(atPath: tasksURL.path) {
            try? "".write(to: tasksURL, atomically: true, encoding: .utf8)
        }
        tasks = TaskParser.load(from: tasksURL)
    }
}


