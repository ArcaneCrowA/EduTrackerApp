import SwiftUI

struct StudentDashboard: View {
    @EnvironmentObject var apiService: APIService
    @State private var courses: [Course] = []
    @State private var attendances: [Attendance] = []
    
    var body: some View {
        TabView {
            availableCourses.tabItem { Label("Courses", systemImage: "book.fill") }
            myAttendance.tabItem { Label("My Attendance", systemImage: "checklist") }
        }
        .onAppear(perform: fetchData)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Logout", role: .destructive) {
                    apiService.logout()
                }
            }
        }
    }
    
    var availableCourses: some View {
        VStack {
            Text("Available Courses").font(.headline).padding()
            List(courses) { course in
                HStack {
                    VStack(alignment: .leading) {
                        Text(course.title).font(.headline)
                        Text(course.description).font(.subheadline).foregroundColor(.secondary)
                    }
                    Spacer()
                    Button("Attend") {
                        markAttendance(course: course)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    var myAttendance: some View {
        VStack {
            Text("My Attendance History").font(.headline).padding()
            List(attendances) { attendance in
                HStack {
                    VStack(alignment: .leading) {
                        Text(attendance.course?.title ?? "Course ID: \(attendance.courseId)")
                            .font(.headline)
                        Text(formatDate(attendance.startDate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if let user = attendance.user {
                        Text(user.fullName)
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    func fetchData() {
        guard let user = apiService.currentUser else { return }
        Task {
            do {
                let fetchedCourses: [Course] = try await apiService.request("/courses", method: "GET")
                let fetchedAttendances: [Attendance] = try await apiService.request("/attendances/users/\(user.id)", method: "GET")
                DispatchQueue.main.async {
                    self.courses = fetchedCourses
                    self.attendances = fetchedAttendances
                }
            } catch {
                print("Error fetching student data: \(error)")
            }
        }
    }
    
    func markAttendance(course: Course) {
        guard let user = apiService.currentUser else { return }
        let formatter = ISO8601DateFormatter()
        let request = MarkAttendanceRequest(userId: user.id, courseId: course.id, startDate: formatter.string(from: Date()))
        Task {
            do {
                let _: EmptyResponse = try await apiService.request("/attendances/mark", method: "POST", body: request)
                fetchData()
            } catch { print("Error marking attendance: \(error)") }
        }
    }
    
    func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoString) {
            let display = DateFormatter()
            display.dateStyle = .medium
            display.timeStyle = .short
            return display.string(from: date)
        }
        return isoString
    }
}
