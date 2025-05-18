+import SwiftUI

struct ContentView: View {
    var updateTitle: (String) -> Void

    @State private var tasks: [Task] = []
    @State private var taskFiles: [URL] = []
    @State private var selectedFile: URL?

    private var progress: (done: Int, total: Int) {
        let taskItems = tasks.filter { $0.isTask }
        let done = taskItems.filter { $0.isDone }.count
        return (done, taskItems.count)
    }

    private var tasksDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("tasks")
    }

    init(updateTitle: @escaping (String) -> Void) {
        self.updateTitle = updateTitle
    }



    var body: some View {
        if let file = selectedFile {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Button(action: {
                        selectedFile = nil
                        tasks.removeAll()
                        updateTitle("Codex")
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.plain)

                    Text(file.deletingPathExtension().lastPathComponent)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Divider()

                Text("\(progress.done)/\(progress.total) done")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                List {
                    ForEach($tasks) { $task in
                        if task.isTask {
                            HStack {
                                Button(action: {
                                    task.isDone.toggle()
                                    task.line = task.line.replacingOccurrences(
                                        of: task.isDone ? "[ ]" : "[x]",
                                        with: task.isDone ? "[x]" : "[ ]"
                                    )
                                    if let url = selectedFile {
                                        TaskParser.save(tasks, to: url)
                                    }
                                }) {
                                    Image(systemName: task.isDone ? "checkmark.square" : "square")
                                }
                                .buttonStyle(.plain)

                                Text(task.text).strikethrough(task.isDone)
                            }
                            .padding(.leading, CGFloat(task.indent) * 10)
                        } else {
                            Text(task.text)
                                .font(task.line.trimmingCharacters(in: .whitespaces).hasPrefix("#")
                                      ? .headline : .body)
                                .padding(.vertical,
                                         task.line.trimmingCharacters(in: .whitespaces).hasPrefix("#") ? 6 : 0)
                                .padding(.leading, CGFloat(task.indent) * 10)
                        }
                    }
                }
                .listStyle(.inset)
                .frame(width: 300, height: 400)
            }
            .onAppear {
                loadTasks(from: file)
                updateTitle(file.deletingPathExtension().lastPathComponent)
            }
        } else {

            VStack(alignment: .leading, spacing: 4) {
                Text("Task Lists")
                    .font(.headline)
                Divider()
                if taskFiles.isEmpty {
                    Text("No lists found")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List {
                        ForEach(taskFiles, id: \.self) { url in
                            Button(url.deletingPathExtension().lastPathComponent) {
                                selectedFile = url
                                updateTitle(url.deletingPathExtension().lastPathComponent)
                            }
                        }

                    }
                    .listStyle(.inset)
                }
            }
            .frame(width: 300, height: 400)
            .onAppear {
                loadTaskFiles()
                updateTitle("Codex")
            }
        }
        .frame(minWidth: 300, minHeight: 400)
    }

    private func loadTaskFiles() {
        if !FileManager.default.fileExists(atPath: tasksDirectory.path) {
            try? FileManager.default.createDirectory(at: tasksDirectory,
                                                     withIntermediateDirectories: true)
        }
        let files = (try? FileManager.default.contentsOfDirectory(at: tasksDirectory,
                                                                  includingPropertiesForKeys: nil)) ?? []
        taskFiles = files.filter { $0.pathExtension.lowercased() == "md" }
    }

    private func loadTasks(from url: URL) {
        if !FileManager.default.fileExists(atPath: url.path) {
            try? "".write(to: url, atomically: true, encoding: .utf8)
        }
        tasks = TaskParser.load(from: url)
    }
}