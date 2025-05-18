import SwiftUI

struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var taskFiles: [URL] = []
    @State private var selectedFile: URL?

    private var tasksDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("tasks")
    }


    var body: some View {
        if let file = selectedFile {
            VStack(alignment: .leading) {
                Button("Back") {
                    selectedFile = nil
                    tasks.removeAll()
                }
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
                                    if let url = selectedFile {
                                        TaskParser.save(tasks, to: url)
                                    }
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
                .listStyle(.inset)
                .frame(width: 300, height: 400)
            }
            .onAppear { loadTasks(from: file) }
        } else {
            List {
                ForEach(taskFiles, id: \.self) { url in
                    Button(url.deletingPathExtension().lastPathComponent) {
                        selectedFile = url
                    }
                }
            }
            .listStyle(.inset)
            .frame(width: 300, height: 400)
            .onAppear(perform: loadTaskFiles)
        }
    }

    private func loadTaskFiles() {
        if !FileManager.default.fileExists(atPath: tasksDirectory.path) {
            try? FileManager.default.createDirectory(at: tasksDirectory, withIntermediateDirectories: true)
        }
        let files = (try? FileManager.default.contentsOfDirectory(at: tasksDirectory, includingPropertiesForKeys: nil)) ?? []
        taskFiles = files.filter { $0.pathExtension.lowercased() == "md" }
    }

    private func loadTasks(from url: URL) {
        if !FileManager.default.fileExists(atPath: url.path) {
            try? "".write(to: url, atomically: true, encoding: .utf8)
        }
        tasks = TaskParser.load(from: url)
    }
}


