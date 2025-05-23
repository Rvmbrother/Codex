import SwiftUI

struct ContentView: View {
    var updateTitle: (String) -> Void

    @State private var tasks: [Task] = []
    @State private var taskFiles: [URL] = []
    @State private var selectedFile: URL?
    @State private var searchText = ""
    @State private var newTaskText = ""

    @State private var tick = Date()

    private let defaultDuration: TimeInterval = 60 * 25

    private var currentTask: Task? {
        tasks.filter { $0.isTask && !$0.isDone && ($0.scheduledTime ?? .distantFuture) <= tick }
            .sorted { ($0.scheduledTime ?? .distantFuture) < ($1.scheduledTime ?? .distantFuture) }
            .first
    }


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


                if let current = currentTask,
                   let start = current.scheduledTime {
                    let remaining = max(0, start.addingTimeInterval(defaultDuration).timeIntervalSince(tick))
                    Text("\u{23F1} " + timeString(from: remaining))
                        .font(.subheadline)
                        .monospacedDigit()
                }

                HStack {
                    TextField("New Task", text: $newTaskText)
                    Button("Add") {
                        let line = "[ ] " + newTaskText
                        let task = Task(id: tasks.count,
                                        line: line,
                                        isTask: true,
                                        isDone: false,
                                        indent: 0,
                                        scheduledTime: TaskParser.parseTime(from: line),
                                        duration: TaskParser.parseDuration(from: line))
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
                        row(for: task)
                    }
                    .onDelete(perform: deleteTasks)
                    .onMove(perform: move)
                }
                .searchable(text: $searchText)
                .listStyle(.inset)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear {
                loadTasks(from: file)
                updateTitle(file.deletingPathExtension().lastPathComponent)
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { date in
                tick = date
                if let running = currentTask,
                   running.actualStart == nil,
                   let index = tasks.firstIndex(where: { $0.id == running.id }) {
                    tasks[index].actualStart = date
                }
                for i in tasks.indices {
                    if let start = tasks[i].timerStart,
                       let dur = tasks[i].duration {
                        let passed = date.timeIntervalSince(start)
                        if tasks[i].elapsed + passed >= dur {
                            tasks[i].elapsed = dur
                            tasks[i].timerStart = nil
                        }
                    }
                }
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


    private func toggle(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isDone.toggle()
            tasks[index].line = tasks[index].line.replacingOccurrences(
                of: tasks[index].isDone ? "[ ]" : "[x]",
                with: tasks[index].isDone ? "[x]" : "[ ]"
            )
            if tasks[index].isDone {
                tasks[index].actualEnd = Date()
            } else {
                tasks[index].actualEnd = nil
            }
            if let url = selectedFile {
                TaskParser.save(tasks, to: url)
            }
        }
    }

    private func startPauseTimer(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        if let start = tasks[index].timerStart {
            tasks[index].elapsed += Date().timeIntervalSince(start)
            tasks[index].timerStart = nil
        } else {
            tasks[index].timerStart = Date()
        }
    }

    private func resetTimer(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].elapsed = 0
        tasks[index].timerStart = nil
    }

    @ViewBuilder
    private func row(for task: Task) -> some View {
        if task.isTask {
            HStack {
                Button(action: { toggle(task) }) {
                    Image(systemName: task.isDone ? "checkmark.square" : "square")
                }
                .buttonStyle(.plain)

                Text(task.text).strikethrough(task.isDone)
                Spacer()
                if let remaining = task.remainingTime {
                    Text(timeString(from: remaining))
                        .font(.footnote)
                        .monospacedDigit()
                    Button(action: { startPauseTimer(task) }) {
                        Image(systemName: task.timerStart == nil ? "play.circle" : "pause.circle")
                    }
                    .buttonStyle(.plain)
                    Button(action: { resetTimer(task) }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .buttonStyle(.plain)
                } else if let time = task.scheduledTime {
                    Text(time, style: .time)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
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

    private func timeString(from interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func move(from source: IndexSet, to destination: Int) {
        guard searchText.isEmpty else { return }
        tasks.move(fromOffsets: source, toOffset: destination)
        for index in tasks.indices {
            tasks[index].id = index
        }
        if let url = selectedFile {
            TaskParser.save(tasks, to: url)
        }
    }
}

