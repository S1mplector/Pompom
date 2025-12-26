import Foundation
import AppKit

struct ExportData: Codable {
    let exportDate: Date
    let appVersion: String
    let statistics: SessionStatistics
    let tasks: [PomodoroTask]
    let settings: TimerSettings
}

final class DataExportService {
    static let shared = DataExportService()
    
    private init() {}
    
    func exportData(
        statistics: SessionStatistics,
        tasks: [PomodoroTask],
        settings: TimerSettings
    ) {
        let exportData = ExportData(
            exportDate: Date(),
            appVersion: Bundle.main.fullVersion,
            statistics: statistics,
            tasks: tasks,
            settings: settings
        )
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "pompom-backup-\(formattedDate()).json"
        savePanel.title = "Export Pompom Data"
        savePanel.message = "Choose where to save your Pompom backup"
        
        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else { return }
            
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                encoder.dateEncodingStrategy = .iso8601
                
                let data = try encoder.encode(exportData)
                try data.write(to: url)
                
                self.showSuccessAlert(url: url)
            } catch {
                self.showErrorAlert(error: error)
            }
        }
    }
    
    func importData(completion: @escaping (ExportData?) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.title = "Import Pompom Data"
        openPanel.message = "Select a Pompom backup file to restore"
        
        openPanel.begin { response in
            guard response == .OK, let url = openPanel.url else {
                completion(nil)
                return
            }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let exportData = try decoder.decode(ExportData.self, from: data)
                
                self.showImportConfirmation { confirmed in
                    if confirmed {
                        completion(exportData)
                    } else {
                        completion(nil)
                    }
                }
            } catch {
                self.showErrorAlert(error: error)
                completion(nil)
            }
        }
    }
    
    func exportToCSV(statistics: SessionStatistics, tasks: [PomodoroTask]) {
        var csv = "Type,Title,Estimated,Completed,Priority,Status,Created,Notes\n"
        
        for task in tasks {
            let status = task.isCompleted ? "Completed" : "Pending"
            let title = task.title.replacingOccurrences(of: ",", with: ";")
            let notes = task.notes.replacingOccurrences(of: ",", with: ";").replacingOccurrences(of: "\n", with: " ")
            
            csv += "Task,\(title),\(task.estimatedPomodoros),\(task.completedPomodoros),\(task.priority.title),\(status),\(formattedDate(task.createdAt)),\(notes)\n"
        }
        
        csv += "\nStatistics\n"
        csv += "Total Work Sessions,\(statistics.totalWorkSessions)\n"
        csv += "Total Work Minutes,\(statistics.totalWorkMinutes)\n"
        csv += "Total Break Minutes,\(statistics.totalBreakMinutes)\n"
        csv += "Current Streak,\(statistics.currentStreak)\n"
        csv += "Longest Streak,\(statistics.longestStreak)\n"
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.commaSeparatedText]
        savePanel.nameFieldStringValue = "pompom-export-\(formattedDate()).csv"
        savePanel.title = "Export to CSV"
        
        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else { return }
            
            do {
                try csv.write(to: url, atomically: true, encoding: .utf8)
                self.showSuccessAlert(url: url)
            } catch {
                self.showErrorAlert(error: error)
            }
        }
    }
    
    private func formattedDate(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func showSuccessAlert(url: URL) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Export Successful"
            alert.informativeText = "Your data has been exported to:\n\(url.lastPathComponent)"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Show in Finder")
            
            let response = alert.runModal()
            if response == .alertSecondButtonReturn {
                NSWorkspace.shared.activateFileViewerSelecting([url])
            }
        }
    }
    
    private func showErrorAlert(error: Error) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Export Failed"
            alert.informativeText = "An error occurred: \(error.localizedDescription)"
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    private func showImportConfirmation(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Import Data"
            alert.informativeText = "This will replace your current data. Are you sure you want to continue?"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Import")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            completion(response == .alertFirstButtonReturn)
        }
    }
}
