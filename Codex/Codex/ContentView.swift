import SwiftUI

struct ContentView: View {
    var updateTitle: (String) -> Void

    @State private var tasks: [Task] = []
    @State private var taskFiles: [URL] = []
    @State private var selectedFile: URL?
    @State private var searchText = ""
    @State private var newTaskText = ""

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

                HStack {
                    TextField("New Task", text: $newTaskText)
                    Button("Add") {
                        let line = "[ ] " + newTaskText
                        let task = Task(id: tasks.count,
                                        line: line,
                                        isTask: true,
                                        isDone: false,
                                        indent: 0)
                        tasks.append(task)
                        if let url = selectedFile {
                            TaskParser.save(tasks, to: url)
                        }
                        newTaskText = ""
                    }
                    .disabled(newTaskText.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                List {
                    ForEach(tasks.filter { searchText.isEmpty || $0.text.localizedCaseInsensitiveContains(searchText) }) { task in
                        if task.isTask {
                            HStack {
                                Button(action: {
                                    if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                        tasks[index].isDone.toggle()
                                        tasks[index].line = tasks[index].line.replacingOccurrences(
                                            of: tasks[index].isDone ? "[ ]" : "[x]",
                                            with: tasks[index].isDone ? "[x]" : "[ ]"
                                        )
                                        if let url = selectedFile {
                                            TaskParser.save(tasks, to: url)
                                        }
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
                    .onDelete(perform: deleteTasks)
                }
                .searchable(text: $searchText)
                .listStyle(.inset)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    private func deleteTasks(at offsets: IndexSet) {
        let filtered = tasks.filter { searchText.isEmpty || $0.text.localizedCaseInsensitiveContains(searchText) }
        let ids = offsets.map { filtered[$0].id }
        tasks.removeAll { ids.contains($0.id) }
        if let url = selectedFile {
            TaskParser.save(tasks, to: url)
        }
    }

    private func loadTasks(from url: URL) {
        if !FileManager.default.fileExists(atPath: url.path) {
            try? "".write(to: url, atomically: true, encoding: .utf8)
        }
        tasks = TaskParser.load(from: url)
    }
}
