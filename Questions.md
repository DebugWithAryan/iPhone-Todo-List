# 🎯 Interview Questions & Concepts

This document covers all the key concepts, technologies, and patterns used in this ToDo List iOS project. These are common topics asked in iOS developer interviews.

---

## 📱 SwiftUI

### Q1: What is SwiftUI and how is it different from UIKit?
**Answer:** SwiftUI is Apple's modern, declarative UI framework introduced in iOS 13. Unlike UIKit which is imperative (you tell the system HOW to build the UI), SwiftUI is declarative (you tell the system WHAT the UI should look like). SwiftUI uses a state-driven approach where the UI automatically updates when data changes. It's cross-platform, supporting iOS, macOS, watchOS, and tvOS with shared code.

### Q2: Explain the concept of "View" in SwiftUI.
**Answer:** In SwiftUI, a View is a protocol that describes a piece of UI. Any struct conforming to the View protocol must implement a `body` property that returns `some View`. Views are lightweight value types (structs) rather than reference types (classes), making them efficient. When state changes, SwiftUI only re-renders the affected views.

### Q3: What are property wrappers in SwiftUI?
**Answer:** Property wrappers are a Swift feature that add behavior to properties. In SwiftUI:
- `@State`: Creates mutable state owned by the view
- `@Binding`: Creates a two-way connection to a @State property
- `@ObservedObject`: Observes an external ObservableObject
- `@StateObject`: Creates and owns an ObservableObject
- `@Published`: Announces changes to properties in ObservableObject
- `@Environment`: Reads values from the environment

### Q4: What is the difference between @State and @StateObject?
**Answer:** 
- `@State` is for simple value types (Int, String, Bool) owned by the view. SwiftUI manages its lifecycle.
- `@StateObject` is for reference types conforming to ObservableObject. It creates and owns the object, ensuring it persists across view updates. Use @StateObject when you want to create and own the object in the view.

In this project: `@StateObject private var viewModel = TodoViewModel()` in ContentView creates and owns the view model.

### Q5: Explain @ObservedObject vs @StateObject.
**Answer:**
- `@StateObject`: Creates and owns the object. Use when the view creates the object.
- `@ObservedObject`: References an object owned elsewhere. Use when passing objects between views.

In this project: ContentView uses `@StateObject` to create the viewModel, while AddTodoView and EditTodoView use `@ObservedObject` because they receive the viewModel from ContentView.

---

## 🏗 Architecture & Design Patterns

### Q6: What is MVVM and why is it used?
**Answer:** MVVM (Model-View-ViewModel) is an architectural pattern that separates concerns:
- **Model**: Data structures (Todo struct)
- **View**: UI components (SwiftUI views)
- **ViewModel**: Business logic, state management, and mediates between Model and View

Benefits: Better testability, separation of concerns, reusable business logic, and easier maintenance.

### Q7: How does MVVM work in this project?
**Answer:**
- **Model**: `Todo` struct represents the data
- **View**: `ContentView`, `AddTodoView`, `EditTodoView`, `TodoRowView`
- **ViewModel**: `TodoViewModel` manages state, handles business logic, and communicates with TodoService
- **Service Layer**: `TodoService` handles API communication

### Q8: What is the Service Layer pattern?
**Answer:** The Service Layer (or Repository pattern) abstracts data access logic from the business logic. TodoService encapsulates all API calls, making it easy to:
- Change backend implementation without affecting the ViewModel
- Mock the service for testing
- Reuse networking code across the app
- Handle API-specific logic in one place

### Q9: Explain the separation of concerns in this project.
**Answer:**
- **TodoService**: Only handles API communication
- **TodoViewModel**: Manages app state and business logic
- **Views**: Only handle UI rendering and user interactions
- **Model**: Defines data structure

Each component has a single responsibility, making the code maintainable and testable.

---

## 🌐 Networking

### Q10: What is URLSession and how is it used?
**Answer:** URLSession is Apple's API for making network requests. It provides methods for downloading/uploading data. In this project, we use `URLSession.shared.data(from:)` and `URLSession.shared.data(for:)` with async/await for making HTTP requests.

### Q11: Explain async/await in Swift.
**Answer:** Async/await is Swift's modern concurrency model introduced in Swift 5.5. It makes asynchronous code look and behave like synchronous code:
- `async`: Marks a function that can perform asynchronous work
- `await`: Suspends execution until the async operation completes
- Replaces callback hell and completion handlers with cleaner, linear code

Example from project:
```swift
func loadTodos() async {
    todos = try await service.fetchTodo()
}
```

### Q12: What is @MainActor and why is it important?
**Answer:** `@MainActor` ensures that code runs on the main thread, which is required for UI updates in iOS. In this project, `TodoViewModel` is marked with `@MainActor` because it updates `@Published` properties that trigger UI changes. This prevents threading issues and ensures all UI updates happen on the main thread.

### Q13: How do you make different types of HTTP requests?
**Answer:** Using URLRequest:
- **GET**: Default method, just use the URL
- **POST**: Set `httpMethod = "POST"`, add body with `httpBody`
- **PUT**: Set `httpMethod = "PUT"`, add body
- **DELETE**: Set `httpMethod = "DELETE"`

Also set headers: `setValue("application/json", forHTTPHeaderField: "Content-Type")`

### Q14: What is RESTful API?
**Answer:** REST (Representational State Transfer) is an architectural style for APIs. RESTful APIs use HTTP methods:
- GET: Retrieve data
- POST: Create new data
- PUT/PATCH: Update existing data
- DELETE: Remove data

Resources are identified by URLs (e.g., `/api/todos/1`). This project consumes a RESTful API.

---

## 📦 Data & State Management

### Q15: What is Codable in Swift?
**Answer:** Codable is a type alias for `Encodable & Decodable`. It allows Swift types to be converted to/from external representations like JSON. JSONEncoder converts Swift objects to JSON, and JSONDecoder converts JSON to Swift objects. The Todo struct conforms to Codable for easy API serialization.

### Q16: Explain the @Published property wrapper.
**Answer:** `@Published` is used in ObservableObject classes to announce when a property changes. Any views observing the object (@ObservedObject or @StateObject) automatically re-render when @Published properties change. In TodoViewModel, `todos`, `isLoading`, `showError`, and `errorMessage` are @Published to update the UI automatically.

### Q17: What is ObservableObject?
**Answer:** ObservableObject is a protocol for reference types that emit change notifications. Classes conforming to it can use @Published properties. When @Published properties change, SwiftUI views observing the object are notified and re-render. TodoViewModel conforms to ObservableObject.

### Q18: How does SwiftUI handle state updates?
**Answer:** SwiftUI uses a unidirectional data flow:
1. User interacts with UI
2. Action updates @State or @Published property
3. SwiftUI detects the change
4. View's body is recomputed
5. UI updates to reflect new state

This ensures the UI always represents the current state.

---

## 🔄 Async Operations & Concurrency

### Q19: What is a Task in Swift Concurrency?
**Answer:** Task creates a new concurrent context to run async code from synchronous code. In this project, we use `Task { await viewModel.loadTodos() }` to call async methods from synchronous contexts like button actions or view lifecycle methods.

### Q20: Explain error handling with try/catch in async functions.
**Answer:** Async functions can throw errors, which we handle with do-try-catch:
```swift
do {
    let data = try await service.fetchTodo()
} catch {
    // Handle error
    errorMessage = error.localizedDescription
}
```
This is similar to synchronous error handling but works with async operations.

### Q21: What is the .task view modifier?
**Answer:** `.task` is a SwiftUI view modifier that runs an async task when a view appears. It automatically cancels the task if the view disappears. In this project, `.task { await viewModel.loadTodos() }` loads todos when ContentView appears.

---

## 🎨 UI Components & Modifiers

### Q22: What are sheets in SwiftUI?
**Answer:** Sheets are modal presentations that slide up from the bottom. Controlled by `@State` boolean or Identifiable binding:
- `.sheet(isPresented:)`: Shows/hides based on Bool
- `.sheet(item:)`: Shows when item is non-nil

This project uses both for AddTodoView and EditTodoView.

### Q23: Explain NavigationView and toolbar.
**Answer:** NavigationView provides navigation capabilities and a navigation bar. `.toolbar` modifier adds buttons to the navigation bar:
- `ToolbarItem(placement: .navigationBarTrailing)`: Right side buttons
- `ToolbarItem(placement: .navigationBarLeading)`: Left side buttons

### Q24: What is the Environment in SwiftUI?
**Answer:** Environment is a system for passing data down the view hierarchy without explicitly passing it through initializers. `@Environment(\.dismiss)` gives access to a dismiss action to close sheets or pop views. It's a way to access system-provided values.

### Q25: Explain List and ForEach in SwiftUI.
**Answer:** 
- `List`: A container that presents data in a scrollable, vertical list
- `ForEach`: Iterates over a collection to create views

Lists work with Identifiable types or can use explicit IDs. The Todo struct conforms to Identifiable, so ForEach can iterate it without explicit IDs.

### Q26: What are view modifiers?
**Answer:** View modifiers are methods that create new views with modified properties. They're chainable and return `some View`. Examples: `.font()`, `.foregroundColor()`, `.padding()`, `.disabled()`. The order matters as each creates a new view wrapping the previous one.

---

## 💾 Data Modeling

### Q27: Why is Todo a struct and not a class?
**Answer:** Structs are value types, meaning they're copied when passed around. This makes them thread-safe and prevents unwanted mutations. For simple data models like Todo, structs are preferred because they're lightweight, immutable by default, and work well with SwiftUI's value-based approach.

### Q28: What is Identifiable protocol?
**Answer:** Identifiable provides a stable identity for entities. It requires an `id` property. SwiftUI uses this for efficient List updates - when data changes, SwiftUI can identify which items changed based on IDs rather than comparing entire objects. Todo conforms to Identifiable with its `id: Int?` property.

### Q29: Why are some properties optional in Todo?
**Answer:**
- `id`: Nil when creating new todos (server assigns it)
- `description`: Optional user input
- `createdAt`, `updatedAt`: Server generates these

This matches the API contract and allows flexible todo creation.

---

## 🐛 Error Handling

### Q30: How does error handling work in this project?
**Answer:** Error handling uses:
1. Try-catch blocks in async methods
2. @Published properties for error state (`showError`, `errorMessage`)
3. SwiftUI `.alert()` modifier to display errors
4. Localized error descriptions for user-friendly messages

This separates error detection (service/viewmodel) from error display (view).

### Q31: What is URLError?
**Answer:** URLError is an error type for URL-related issues like bad URLs, no internet connection, timeouts, etc. In this project, we throw `URLError(.badURL)` when URL construction fails. URLSession methods also throw URLErrors for network issues.

---

## 🎭 View Lifecycle

### Q32: Explain view lifecycle in SwiftUI.
**Answer:** SwiftUI views don't have traditional lifecycle methods like UIKit. Instead:
- `.onAppear`: Called when view appears
- `.onDisappear`: Called when view disappears
- `.task`: Runs async code when view appears
- `.onChange`: Responds to value changes

Views are recreated when state changes, but SwiftUI optimizes this internally.

### Q33: What is the purpose of dismiss in SwiftUI?
**Answer:** `@Environment(\.dismiss)` provides a way to programmatically close sheets or pop views from navigation stacks. It's cleaner than using presentation bindings or environment values manually. Call `dismiss()` to trigger the dismissal.

---

## 🔧 Best Practices

### Q34: Why separate views into different structs?
**Answer:** Separating views improves:
- **Readability**: Each view has a clear purpose
- **Reusability**: TodoRowView can be reused
- **Performance**: SwiftUI only re-renders changed views
- **Maintainability**: Easier to modify individual components
- **Testing**: Can test views in isolation

### Q35: What is the purpose of .disabled() modifier?
**Answer:** `.disabled()` grays out and prevents interaction with views. In this project, it prevents submitting forms with empty titles: `.disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)`. This provides good UX by preventing invalid submissions.

### Q36: Why use Task instead of DispatchQueue?
**Answer:** Task is part of Swift's modern concurrency model and offers:
- Better integration with async/await
- Automatic cancellation support
- Structured concurrency
- Cleaner syntax than GCD
- Built-in error handling

DispatchQueue is the older approach and doesn't work well with async/await.

### Q37: What are the benefits of async/await over completion handlers?
**Answer:**
- Linear, readable code (no pyramid of doom)
- Built-in error handling with try-catch
- Better compiler support and type safety
- Automatic cancellation propagation
- Easier to debug
- Works with structured concurrency

### Q38: Why use guard let instead of if let for optionals?
**Answer:** `guard let` is used for early exits, making the code cleaner when checking preconditions. It enforces that the rest of the function only executes when conditions are met. In TodoService, we use `guard let url = URL(string: baseUrl)` to ensure valid URLs before proceeding.

---

## 🎯 iOS-Specific Concepts

### Q39: What is the difference between @State and regular variables?
**Answer:** Regular variables don't trigger UI updates when changed. @State is a property wrapper that tells SwiftUI to watch for changes and re-render views when the value updates. It's essential for interactive UIs.

### Q40: Why use buttonStyle(PlainButtonStyle())?
**Answer:** By default, buttons in Lists have blue tint and highlight behavior. PlainButtonStyle() removes these, allowing custom styling. In TodoRowView, we want custom button appearances (checkmark, pencil, trash icons) without default List button styling.

### Q41: What is the purpose of lineLimit modifier?
**Answer:** `lineLimit()` restricts text to a specific number of lines. In this project:
- `.lineLimit(2)` on description shows max 2 lines with ellipsis
- `.lineLimit(3...6)` on TextField allows 3-6 lines of expandable text

This improves UI layout and readability.

### Q42: Explain Form in SwiftUI.
**Answer:** Form is a container for grouping input controls with platform-appropriate styling. It automatically applies iOS-style grouped table view appearance with sections, separators, and padding. Used in AddTodoView and EditTodoView for data entry.

---

## 🚀 Advanced Topics

### Q43: How would you implement offline support?
**Answer:** Add local persistence:
1. Use Core Data or UserDefaults to cache todos
2. Check network availability
3. Load from cache when offline
4. Sync with API when online
5. Handle conflicts (last-write-wins or more sophisticated merge strategies)

### Q44: How would you add authentication?
**Answer:**
1. Add auth tokens to TodoService
2. Store tokens securely (Keychain)
3. Add login/register screens
4. Include token in API request headers
5. Handle 401 responses (refresh token or re-login)
6. Add user session management to ViewModel

### Q45: How would you implement pull-to-refresh?
**Answer:** Use `.refreshable()` modifier on List:
```swift
List { ... }
.refreshable {
    await viewModel.loadTodos()
}
```
SwiftUI handles the pull gesture and UI automatically.

### Q46: How would you test this application?
**Answer:**
- **Unit Tests**: Test ViewModel logic, TodoService with mock URLSession
- **UI Tests**: Test user flows using XCTest UI testing
- **Integration Tests**: Test API integration
- **Mock Service**: Create MockTodoService for testing without network calls

### Q47: How would you improve performance?
**Answer:**
1. Implement pagination for large todo lists
2. Add caching to avoid unnecessary API calls
3. Use lazy loading for images if added
4. Optimize List rendering with `.id()` modifiers
5. Add request debouncing for search features
6. Implement background fetch for data updates

### Q48: What accessibility features could be added?
**Answer:**
1. Add `.accessibilityLabel()` to icons and buttons
2. Support Dynamic Type for text scaling
3. Add VoiceOver support with descriptive labels
4. Ensure sufficient color contrast
5. Support keyboard navigation
6. Add `.accessibilityHint()` for complex interactions

---

## 💡 Common Interview Scenarios

### Q49: How would you handle network failures gracefully?
**Answer:** This project already implements error handling, but improvements:
1. Retry logic with exponential backoff
2. Show specific error types (network, server, parsing)
3. Offline mode with local cache
4. Network reachability monitoring
5. User-friendly error messages with actions

### Q50: Explain the complete flow of creating a todo.
**Answer:**
1. User taps + button
2. `showingAddTodo` becomes true
3. AddTodoView sheet appears
4. User enters title/description
5. User taps Add button
6. `addTodo()` creates Todo struct
7. ViewModel's `createTodo()` is called
8. Service makes POST request to API
9. API returns created todo with ID
10. Todo is appended to `todos` array
11. SwiftUI detects @Published change
12. List automatically updates
13. Sheet dismisses

---

This document covers the fundamental to advanced concepts used in this project. Understanding these will prepare you for iOS development interviews!

**Tips for Interviews:**
- Always explain the "why" behind design decisions
- Mention trade-offs and alternatives
- Show understanding of best practices
- Be ready to write code on a whiteboard
- Know when to use each pattern/technology
- Understand the entire data flow in the app
