import SwiftUI

struct ContentView: View {
    var updateTitle: (String) -> Void

    @State private var tasks: [Task] = []
    @State private var taskFiles: [URL] = []
    @State private var selectedFile: URL?
    @State private var searchText = ""
    @State private var newTaskText = ""
    @State private var hoveredTaskId: Int?

    @Environment(\.scenePhase) private var scenePhase

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
        if let customPath = UserDefaults.standard.string(forKey: "customTasksPath") {
            return URL(fileURLWithPath: customPath)
        }
        
        // Try Documents/TasksFolder first
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let documentsTasksURL = documentsURL.appendingPathComponent("TasksFolder")
        
        // Check if we can access Documents/TasksFolder
        if FileManager.default.isReadableFile(atPath: documentsTasksURL.path) {
            return documentsTasksURL
        }
        
        // Fallback to the project's tasks folder
        let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        return currentDirectory.appendingPathComponent("tasks")
    }

    init(updateTitle: @escaping (String) -> Void) {
        self.updateTitle = updateTitle
    }



    var body: some View {
        Group {
        if let file = selectedFile {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFile = nil
                                tasks.removeAll()
                                updateTitle("Codex")
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Lists")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(Color(NSColor.secondaryLabelColor))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)

                        Text(file.deletingPathExtension().lastPathComponent)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(NSColor.labelColor))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Progress and timer section
                    HStack(spacing: 16) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green.opacity(0.8))
                                .frame(width: 8, height: 8)
                            Text("\(progress.done)/\(progress.total) done")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(NSColor.secondaryLabelColor))
                        }
                        
                        if let current = currentTask,
                           let start = current.scheduledTime {
                            let remaining = max(0, start.addingTimeInterval(defaultDuration).timeIntervalSince(tick))
                            HStack(spacing: 6) {
                                Image(systemName: "timer")
                                    .font(.system(size: 11))
                                    .foregroundColor(.orange.opacity(0.8))
                                Text(timeString(from: remaining))
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundColor(.orange.opacity(0.8))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.15))
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(NSColor.windowBackgroundColor))
                
                Divider()
                    .foregroundColor(Color(NSColor.separatorColor).opacity(0.5))
                
                // New task input
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.blue.opacity(0.8))
                    
                    TextField("Add new task...", text: $newTaskText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14))
                        .onSubmit {
                            addNewTask()
                        }
                    
                    Button(action: addNewTask) {
                        Text("Add")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(newTaskText.isEmpty ? Color.gray.opacity(0.3) : Color.blue.opacity(0.8))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .disabled(newTaskText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.3))

                // Search bar
                if !tasks.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 13))
                            .foregroundColor(Color(NSColor.tertiaryLabelColor))
                        
                        TextField("Search tasks...", text: $searchText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }

                // Task list
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(tasks.filter { searchText.isEmpty || $0.text.localizedCaseInsensitiveContains(searchText) }) { task in
                            taskRow(for: task)
                                .onHover { hovering in
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        hoveredTaskId = hovering ? task.id : nil
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .background(Color(NSColor.windowBackgroundColor))
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
            // File list view
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.blue.opacity(0.8))
                        Text("Task Lists")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }
                
                Divider()
                    .foregroundColor(Color(NSColor.separatorColor).opacity(0.5))
                
                if taskFiles.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(Color(NSColor.tertiaryLabelColor))
                        Text("No task lists found")
                            .font(.system(size: 14))
                            .foregroundColor(Color(NSColor.secondaryLabelColor))
                        Text("Create .md files in ~/Documents/TasksFolder")
                            .font(.system(size: 12))
                            .foregroundColor(Color(NSColor.tertiaryLabelColor))
                        
                        Button(action: selectTasksFolder) {
                            HStack(spacing: 6) {
                                Image(systemName: "folder.badge.plus")
                                Text("Select Tasks Folder")
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(taskFiles, id: \.self) { url in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedFile = url
                                        updateTitle(url.deletingPathExtension().lastPathComponent)
                                    }
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "doc.text.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color.blue.opacity(0.7))
                                        
                                        Text(url.deletingPathExtension().lastPathComponent)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(NSColor.labelColor))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(NSColor.tertiaryLabelColor))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 12)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(NSColor.windowBackgroundColor))
            .onAppear {
                loadTaskFiles()
                updateTitle("Codex")
            }
        }
        }
        .frame(minWidth: 320, minHeight: 440)
        .background(Color(NSColor.windowBackgroundColor))
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active, let file = selectedFile {
                loadTasks(from: file)
            }
        }
    }

    private func addNewTask() {
        guard !newTaskText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let line = "[ ] " + newTaskText
        let task = Task(id: tasks.count,
                        line: line,
                        isTask: true,
                        isDone: false,
                        indent: 0,
                        scheduledTime: TaskParser.parseTime(from: line),
                        duration: TaskParser.parseDuration(from: line))
        withAnimation(.easeInOut(duration: 0.2)) {
            tasks.append(task)
        }
        if let url = selectedFile {
            TaskParser.save(tasks, to: url)
        }
        newTaskText = ""
    }

    private func loadTaskFiles() {
        // Request access to Documents folder
        let tasksFolderURL = tasksDirectory
        
        // Debug: print the path we're trying to access
        print("Looking for tasks in: \(tasksFolderURL.path)")
        
        // Create the TasksFolder if it doesn't exist
        if !FileManager.default.fileExists(atPath: tasksFolderURL.path) {
            do {
                try FileManager.default.createDirectory(at: tasksFolderURL,
                                                       withIntermediateDirectories: true)
                print("Created TasksFolder at: \(tasksFolderURL.path)")
            } catch {
                print("Failed to create TasksFolder: \(error)")
                return
            }
        }
        
        // Try to read the directory contents
        do {
            let files = try FileManager.default.contentsOfDirectory(at: tasksFolderURL,
                                                                   includingPropertiesForKeys: nil)
            print("Found \(files.count) files in TasksFolder")
            taskFiles = files.filter { $0.pathExtension.lowercased() == "md" }
            print("Found \(taskFiles.count) .md files")
            for file in taskFiles {
                print("- \(file.lastPathComponent)")
            }
        } catch {
            print("Error reading TasksFolder: \(error)")
            taskFiles = []
        }
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
            withAnimation(.easeInOut(duration: 0.2)) {
                // Check current state BEFORE toggling
                let wasChecked = tasks[index].isDone
                
                // Toggle the state
                tasks[index].isDone.toggle()
                
                // Update the line text based on what it WAS, not what it IS now
                if wasChecked {
                    // Was checked, now unchecking: [x] -> [ ]
                    tasks[index].line = tasks[index].line.replacingOccurrences(of: "[x]", with: "[ ]")
                    tasks[index].actualEnd = nil
                } else {
                    // Was unchecked, now checking: [ ] -> [x]
                    tasks[index].line = tasks[index].line.replacingOccurrences(of: "[ ]", with: "[x]")
                    tasks[index].actualEnd = Date()
                }
            }
            if let url = selectedFile {
                TaskParser.save(tasks, to: url)
            }
        }
    }

    private func startPauseTimer(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            if let start = tasks[index].timerStart {
                // Pause timer
                tasks[index].elapsed += Date().timeIntervalSince(start)
                tasks[index].timerStart = nil
            } else {
                // Start timer
                tasks[index].timerStart = Date()
                if tasks[index].actualStart == nil {
                    tasks[index].actualStart = Date()
                }
            }
        }
        
        // Save to file
        if let url = selectedFile {
            TaskParser.save(tasks, to: url)
        }
    }

    private func resetTimer(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            tasks[index].elapsed = 0
            tasks[index].timerStart = nil
            tasks[index].actualStart = nil
        }
        
        // Save to file
        if let url = selectedFile {
            TaskParser.save(tasks, to: url)
        }
    }

    @ViewBuilder
    private func taskRow(for task: Task) -> some View {
        if task.isTask {
            HStack(spacing: 12) {
                // Checkbox with animation
                Button(action: { 
                    toggle(task) 
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(task.isDone ? Color.green.opacity(0.8) : Color(NSColor.tertiaryLabelColor), lineWidth: 2)
                            .frame(width: 20, height: 20)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(task.isDone ? Color.green.opacity(0.8) : Color.clear)
                            )
                        
                        if task.isDone {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.text)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(task.isDone ? Color(NSColor.tertiaryLabelColor) : Color(NSColor.labelColor))
                        .strikethrough(task.isDone, color: Color(NSColor.tertiaryLabelColor))
                    
                    if let time = task.scheduledTime, !task.isDone {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10))
                            Text(time, style: .time)
                                .font(.system(size: 11))
                        }
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                    }
                }
                
                Spacer()

                // Timer controls for tasks with duration
                if let duration = task.duration, !task.isDone {
                    HStack(spacing: 8) {
                        // Timer display
                        VStack(alignment: .trailing, spacing: 2) {
                            let elapsed = task.elapsed + (task.timerStart != nil ? Date().timeIntervalSince(task.timerStart!) : 0)
                            let remaining = max(0, duration - elapsed)
                            
                            Text(timeString(from: remaining))
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundColor(remaining > 0 ? Color.blue.opacity(0.8) : Color.red.opacity(0.8))
                            
                            // Progress bar
                            ProgressView(value: min(elapsed / duration, 1.0))
                                .progressViewStyle(LinearProgressViewStyle())
                                .frame(width: 60, height: 4)
                                .scaleEffect(x: 1, y: 0.5)
                        }
                        
                        // Timer controls
                        VStack(spacing: 4) {
                            Button(action: { startPauseTimer(task) }) {
                                Image(systemName: task.timerStart != nil ? "pause.fill" : "play.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(task.timerStart != nil ? Color.orange.opacity(0.8) : Color.green.opacity(0.8))
                                    .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: { resetTimer(task) }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(NSColor.secondaryLabelColor))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                } else if let duration = task.duration {
                    // Completed task - show duration badge
                    Text(formatDuration(duration))
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(NSColor.tertiaryLabelColor))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(hoveredTaskId == task.id ? Color(NSColor.controlBackgroundColor).opacity(0.5) : Color.clear)
            )
            .padding(.leading, CGFloat(task.indent) * 20)
        } else {
            Text(task.text)
                .font(task.line.trimmingCharacters(in: .whitespaces).hasPrefix("#")
                      ? .system(size: 16, weight: .semibold) : .system(size: 14))
                .foregroundColor(task.line.trimmingCharacters(in: .whitespaces).hasPrefix("#")
                      ? Color(NSColor.labelColor) : Color(NSColor.secondaryLabelColor))
                .padding(.vertical,
                         task.line.trimmingCharacters(in: .whitespaces).hasPrefix("#") ? 12 : 4)
                .padding(.horizontal, 16)
                .padding(.leading, CGFloat(task.indent) * 20)
        }
    }

    private func timeString(from interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        var parts: [String] = []
        if days > 0 { parts.append("\(days)d") }
        if hours > 0 { parts.append("\(hours)h") }
        if minutes > 0 { parts.append("\(minutes)m") }
        return parts.joined(separator: " ")
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

    private func selectTasksFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Tasks Folder"
        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents")
        
        if panel.runModal() == .OK, let selectedURL = panel.url {
            // Store the selected folder path
            UserDefaults.standard.set(selectedURL.path, forKey: "customTasksPath")
            
            // Update the tasks directory and reload
            loadTaskFiles()
        }
    }
}

