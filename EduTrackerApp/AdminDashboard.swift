import SwiftUI

struct AdminDashboard: View {
    @EnvironmentObject var apiService: APIService
    @State private var users: [User] = []
    @State private var courses: [Course] = []
    @State private var selectedTab = 0
    
    // New User state
    @State private var newUserFullName = ""
    @State private var newUserYear = 1
    @State private var newUserLogin = ""
    @State private var newUserPassword = ""
    @State private var newUserIsAdmin = false
    
    // New Course state
    @State private var newCourseTitle = ""
    @State private var newCourseDescription = ""
    @State private var newCourseStartDate = Date()
    @State private var newCourseEndDate = Date().addingTimeInterval(3600 * 24 * 90)
    
    var body: some View {
        TabView(selection: $selectedTab) {
            usersList.tabItem { Label("Users", systemImage: "person.3") }.tag(0)
            coursesList.tabItem { Label("Courses", systemImage: "book") }.tag(1)
            attendanceView.tabItem { Label("Attendance", systemImage: "calendar.badge.clock") }.tag(2)
        }
        .onAppear(perform: fetchData)
    }
    
    var usersList: some View {
        VStack {
            List(users) { user in
                HStack {
                    VStack(alignment: .leading) {
                        Text(user.fullName).font(.headline)
                        Text(user.login).font(.subheadline).foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(user.isAdmin ? "Admin" : "Student")
                        .padding(4)
                        .background(user.isAdmin ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            Divider()
            VStack(spacing: 12) {
                Text("Register New User").font(.headline)
                HStack {
                    TextField("Full Name", text: $newUserFullName)
                    TextField("Login", text: $newUserLogin)
                }
                HStack {
                    TextField("Password", text: $newUserPassword)
                    Stepper("Year: \(newUserYear)", value: $newUserYear, in: 1...6)
                    Toggle("Admin", isOn: $newUserIsAdmin)
                }
                Button("Create User", action: createUser).buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
        }
    }
    
    var coursesList: some View {
        VStack {
            List(courses) { course in
                VStack(alignment: .leading) {
                    Text(course.title).font(.headline)
                    Text(course.description).font(.subheadline).lineLimit(1)
                }
            }
            Divider()
            VStack(spacing: 12) {
                Text("Create New Course").font(.headline)
                TextField("Title", text: $newCourseTitle)
                TextField("Description", text: $newCourseDescription)
                HStack {
                    DatePicker("Start", selection: $newCourseStartDate, displayedComponents: .date)
                    DatePicker("End", selection: $newCourseEndDate, displayedComponents: .date)
                }
                Button("Create Course", action: createCourse).buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
        }
    }
    
    var attendanceView: some View {
        VStack {
            Text("Attendance Management").font(.headline).padding()
            Text("Select a course to mark attendance for users.")
            List(courses) { course in
                NavigationLink(destination: MarkAttendanceView(course: course, users: users)) {
                    Text(course.title)
                }
            }
        }
    }
    
    func fetchData() {
        Task {
            do {
                let fetchedUsers: [User] = try await apiService.request("/users", method: "GET")
                let fetchedCourses: [Course] = try await apiService.request("/courses", method: "GET")
                DispatchQueue.main.async {
                    self.users = fetchedUsers
                    self.courses = fetchedCourses
                }
            } catch {
                print("Error fetching admin data: \(error)")
            }
        }
    }
    
    func createUser() {
        let request = CreateUserRequest(fullName: newUserFullName, year: newUserYear, login: newUserLogin, password: newUserPassword, isAdmin: newUserIsAdmin)
        Task {
            do {
                let _: EmptyResponse = try await apiService.request("/users", method: "POST", body: request)
                fetchData()
                DispatchQueue.main.async {
                    newUserFullName = ""; newUserLogin = ""; newUserPassword = ""
                }
            } catch { print("Error creating user: \(error)") }
        }
    }
    
    func createCourse() {
        let formatter = ISO8601DateFormatter()
        let request = CreateCourseRequest(title: newCourseTitle, description: newCourseDescription, startDate: formatter.string(from: newCourseStartDate), endDate: formatter.string(from: newCourseEndDate))
        Task {
            do {
                let _: EmptyResponse = try await apiService.request("/courses", method: "POST", body: request)
                fetchData()
                DispatchQueue.main.async {
                    newCourseTitle = ""; newCourseDescription = ""
                }
            } catch { print("Error creating course: \(error)") }
        }
    }
}

struct MarkAttendanceView: View {
    let course: Course
    let users: [User]
    @EnvironmentObject var apiService: APIService
    @State private var successMessage = ""
    
    var body: some View {
        VStack {
            Text("Mark Attendance for \(course.title)").font(.title2).padding()
            if !successMessage.isEmpty {
                Text(successMessage).foregroundColor(.green).padding()
            }
            List(users) { user in
                HStack {
                    Text(user.fullName)
                    Spacer()
                    Button("Present") {
                        markPresent(user: user)
                    }
                }
            }
        }
    }
    
    func markPresent(user: User) {
        let formatter = ISO8601DateFormatter()
        let request = MarkAttendanceRequest(userId: user.id, courseId: course.id, startDate: formatter.string(from: Date()))
        Task {
            do {
                let _: EmptyResponse = try await apiService.request("/attendances/mark", method: "POST", body: request)
                DispatchQueue.main.async {
                    successMessage = "Marked \(user.fullName) present!"
                }
            } catch { print("Error marking attendance: \(error)") }
        }
    }
}
