//
//  ContentView.swift
//  MindBodyFuel-Proto2
//
//  Created by Satya Narayanaa Hariharan  on 2/3/25.
//

import SwiftUI
import RealityKit
import Foundation
import HealthKit
import UserNotifications
import NIO
import SpotifyWebAPI
import RealmSwift
import MongoSwift



// MARK: - HealthKit Manager
class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    func requestAuthorization() {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.workoutType()
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchWorkoutData(completion: @escaping ([HKWorkout]?) -> Void) {
        let workoutType = HKObjectType.workoutType()
        let query = HKSampleQuery(sampleType: workoutType, predicate: nil, limit: 10, sortDescriptors: nil) { _, results, _ in
            if let workouts = results as? [HKWorkout] {
                completion(workouts)
            } else {
                completion(nil)
            }
        }
        healthStore.execute(query)
    }
}

// MARK: - MongoDB & Realm Managers
class MongoDBManager {
    static let shared = MongoDBManager()
    var client: MongoClient?

    init() {
        do {
            let connectionString = "mongodb+srv://satyahari3011:<db_password>@mindbodyfuel.962op.mongodb.net/?retryWrites=true&w=majority&appName=MindBodyFuel"
            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            client = try MongoClient(connectionString, using: eventLoopGroup)
        } catch {
            print("Failed to initialize MongoDB client: \(error)")
        }
    }
    
    func getUserData(userId: String, completion: @escaping (BSONDocument?) -> Void) {
        guard let client = client else { return }

        let database = client.db("MindBodyFuel")
        let collection = database.collection("users", withType: BSONDocument.self)
        let query: BSONDocument = ["userId": .string(userId)]

        collection.findOne(filter: query) { (result: Result<BSONDocument?, Error>) in
            switch result {
            case .success(let document):
                completion(document)
            case .failure(let error):
                print("Error fetching user data: \(error)")
                completion(nil)
            }
        }
    }

    func saveWorkoutData(userId: String, workoutData: BSONDocument) {
        guard let client = client else { return }

        let database = client.db("MindBodyFuel")
        let collection = database.collection("workouts")

        collection.insertOne(workoutData) { (result: Result<BSONObjectID, Error>) in
            switch result {
            case .success(let objectId):
                print("Workout saved with ID: \(objectId)")
            case .failure(let error):
                print("Error saving workout: \(error)")
            }
        }
    }
}

class RealmManager: ObservableObject {
    private(set) var realm: Realm?
    
    init() {
        do {
            realm = try Realm()
        } catch {
            print("Error initializing Realm: \(error)")
        }
    }
    
    func addWorkout(_ workout: Workout) {
        do {
            try realm?.write {
                realm?.add(workout)
            }
        } catch {
            print("Error adding workout: \(error)")
        }
    }
}

// MARK: - Spotify Manager
class SpotifyManager: ObservableObject {
    let spotify = SpotifyAPI(authorizationManager: AuthorizationCodeFlowManager(clientId: "YOUR_CLIENT_ID", clientSecret: "YOUR_CLIENT_SECRET"))
    
    func playSong(uri: String) {
        spotify.playerPlay(uri: uri) { result in
            switch result {
            case .success:
                print("Playing song: \(uri)")
            case .failure(let error):
                print("Failed to play song: \(error)")
            }
        }
    }
    
    func pausePlayback() {
        spotify.playerPause() { result in
            if case .failure(let error) = result {
                print("Failed to pause playback: \(error)")
            }
        }
    }
}

// MARK: - Models
class User: Object, Identifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var email: String = ""
    @Persisted var password: String = ""
}

class Workout: Object, Identifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var category: String = ""
    @Persisted var duration: Int = 0
    @Persisted var completed: Bool = false
}

// MARK: - Notification & Authentication Managers
class NotificationManager {
    static let shared = NotificationManager()
    
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleGoalReminder(goal: String) {
        let content = UNMutableNotificationContent()
        content.title = "Fitness Goal Reminder"
        content.body = "Don't forget to \(goal) today!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    
    func login(email: String, password: String) {
        if email == "test@example.com" && password == "password" {
            isAuthenticated = true
        }
    }
    
    func logout() {
        isAuthenticated = false
    }
}

// MARK: - Welcome view
struct WelcomeView: View {
    var body: some View {
        VStack {
            Image("app_icon") // Placeholder for app icon
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding()
            
            Text("Welcome to Mind Body Fuel")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("Elevate your body and mind—wellness in perfect harmony!")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                // Navigate to signup
            }) {
                Text("Let’s do it")
                    .font(.headline)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

// MARK: - Signup Page
struct SignupView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var agreedToTerms = false
    
    var body: some View {
        VStack {
            TextField("First name", text: $firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Last name", text: $lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Toggle("I agree to the Terms & Conditions", isOn: $agreedToTerms)
                .padding()
            
            Button(action: {
                // Handle sign-up logic
            }) {
                Text("Create Account")
                    .frame(width: 200, height: 50)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Text("Or register with")
                .font(.footnote)
                .padding()
            
            HStack {
                Button("Google") {
                    // Google Sign-In Logic
                }
                .frame(width: 100, height: 40)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Apple") {
                    // Apple Sign-In Logic
                }
                .frame(width: 100, height: 40)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}

// MARK: - Dashboard
struct DashboardView: View {
    var body: some View {
        VStack {
            Text("Welcome, Jhony Barstrow")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text("Set your workout plan")
                .font(.headline)
                .padding()
            
            HStack {
                VStack {
                    Text("Running")
                    Text("18500 Steps")
                }
                VStack {
                    Text("Workout")
                    Text("40 Minutes")
                }
            }
            .padding()
            
            Text("Relax")
                .font(.headline)
                .padding()
            
            HStack {
                Button("5 Mins") {}
                Button("10 Mins") {}
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            Button("Start Timer") {
                // Start relaxation timer
            }
            .frame(width: 200, height: 50)
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

// MARK: - Main View
struct ContentView : View {
    @ObservedObject var realmManager = RealmManager()
    @ObservedObject var authManager = AuthManager()
    @ObservedObject var spotifyManager = SpotifyManager()
    @State private var stepCount: Int = 0
    @State private var workouts: [HKWorkout] = []
    @State private var goal: String = ""

    var body: some View {
        NavigationView {
            VStack {
                if authManager.isAuthenticated {
                    Text("FastNFitness").font(.largeTitle).padding()
                    Text("Step Count: \(stepCount)").font(.title2).padding()
                        .onAppear { fetchStepCount() }
                    
                    Button("Play Song") {
                        spotifyManager.playSong(uri: "spotify:track:6rqhFgbbKwnb9MLmUQDhG6")
                    }
                    .padding().background(Color.green).foregroundColor(.white).cornerRadius(10)
                    
                    Button("Pause") {
                        spotifyManager.pausePlayback()
                    }
                    .padding().background(Color.red).foregroundColor(.white).cornerRadius(10)
                    
                    Button("Authorize HealthKit") {
                        HealthKitManager.shared.requestAuthorization()
                    }
                    .padding().background(Color.blue).foregroundColor(.white).cornerRadius(10)
                    
                    Button("Fetch Workouts") {
                        fetchWorkoutData()
                    }
                    .padding().background(Color.orange).foregroundColor(.white).cornerRadius(10)
                }
            }
        }
        RealityView { content in

            // Create a cube model
            let model = Entity()
            let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
            let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
            model.components.set(ModelComponent(mesh: mesh, materials: [material]))
            model.position = [0, 0.05, 0]

            // Create horizontal plane anchor for the content
            let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
            anchor.addChild(model)

            // Add the horizontal plane anchor to the scene
            content.add(anchor)

            content.camera = .spatialTracking

        }
        .edgesIgnoringSafeArea(.all)
    }

}

#Preview {
    ContentView()
}
@main
struct FitnessApp: App {
    var body: some Scene {
        WindowGroup {
            WelcomeView()
            ContentView()
        }
    }
}
