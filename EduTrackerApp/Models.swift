import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let fullName: String
    let year: Int
    let login: String
    let isAdmin: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case year
        case login
        case isAdmin = "is_admin"
    }
}

struct Course: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
    let startDate: String
    let endDate: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, description
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

struct Attendance: Identifiable, Codable {
    var id: String { "\(userId)-\(courseId)" }
    let userId: Int
    let courseId: Int
    let startDate: String
    let user: User?
    let course: Course?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case courseId = "course_id"
        case startDate = "start_date"
        case user, course
    }
}

struct AuthResponse: Codable {
    let token: String
}

struct CreateUserRequest: Codable {
    let fullName: String
    let year: Int
    let login: String
    let password: String
    let isAdmin: Bool
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case year, login, password
        case isAdmin = "is_admin"
    }
}

struct CreateCourseRequest: Codable {
    let title: String
    let description: String
    let startDate: String
    let endDate: String
    
    enum CodingKeys: String, CodingKey {
        case title, description
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

struct MarkAttendanceRequest: Codable {
    let userId: Int
    let courseId: Int
    let startDate: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case courseId = "course_id"
        case startDate = "start_date"
    }
}
