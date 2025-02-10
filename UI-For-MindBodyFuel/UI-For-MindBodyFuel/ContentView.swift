import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Mind Body Fuel")
                .font(.largeTitle)
                .bold()
            Text("Elevate your body and mind—wellness in perfect harmony!")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
            
            NavigationLink(destination: CreateAccountView()) {
                Text("Let's do it")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct DashboardView: View {
    var body: some View {
        TabView {
            ProgressTrackingView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Progress")
                }
            WeightInputView()
                .tabItem {
                    Image(systemName: "scalemass")
                    Text("Weight")
                }
            HeightInputView()
                .tabItem {
                    Image(systemName: "ruler")
                    Text("Height")
                }
            SetWorkoutPlanView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Workout Plan")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct WeightInputView: View {
    @State private var weight: Double = 70.0
    @State private var unit: String = "kg"
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Enter Your Weight")
                .font(.headline)
            
            HStack {
                Text("\(Int(weight))")
                    .font(.largeTitle)
                Picker("Unit", selection: $unit) {
                    Text("kg").tag("kg")
                    Text("lbs").tag("lbs")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Slider(value: $weight, in: 30...200, step: 1)
                .padding()
            
            NavigationLink(destination: HeightInputView()) {
                Text("Next")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct ProgressTrackingView: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Progress Tracking")
                .font(.largeTitle)
            List {
                Section(header: Text("Daily Report")) {
                    Text("Calories: 1,350 kcal")
                    Text("Weight: 73.2 kgs")
                    Text("Workout: 35 min")
                    Text("Water: 2.3 L")
                    Text("Sleep: 7h 30m")
                }
            }
        }
        .padding()
    }
}

struct CreateAccountView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var agreeTerms: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                TextField("First name", text: $firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Last name", text: $lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Toggle("I agree to the Terms & Conditions", isOn: $agreeTerms)
                
                NavigationLink(destination: GenderSelectionView()) {
                    Text("Create Account")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!agreeTerms)
            }
            .padding()
        }
    }
}

struct GenderSelectionView: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("How do you identify?")
                .font(.headline)
            
            VStack {
                Button("Male") {}
                Button("Female") {}
                Button("Non-binary") {}
                Button("Other") {}
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            NavigationLink(destination: HeightInputView()) {
                Text("Continue")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct HeightInputView: View {
    @State private var height: Double = 170.0
    @State private var unit: String = "cm"
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Enter Your Height")
                .font(.headline)
            
            HStack {
                Text("\(Int(height))")
                    .font(.largeTitle)
                Picker("Unit", selection: $unit) {
                    Text("cm").tag("cm")
                    Text("ft").tag("ft")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Slider(value: $height, in: 100...250, step: 1)
                .padding()
            
            NavigationLink(destination: SetWorkoutPlanView()) {
                Text("Next")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var darkMode = false
    
    var body: some View {
        Form {
            Toggle("Enable Notifications", isOn: $notificationsEnabled)
            Toggle("Dark Mode", isOn: $darkMode)
        }
        .navigationTitle("Settings")
    }
}

struct SetWorkoutPlanView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("Set Your Workout Plan")
                    .font(.headline)
                
                List {
                    Text("Running - 30 minutes")
                    Text("Yoga - 20 minutes")
                    Text("Strength Training - 45 minutes")
                }
                .frame(height: 200)
                
                NavigationLink(destination: DashboardView()) {
                    Text("Finish")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateAccountView()
        }
    }
}
