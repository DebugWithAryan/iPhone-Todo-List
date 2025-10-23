//
//  ContentView.swift
//  To-Do List
//
//  Created by Aryan Jaiswal on 22/10/25.
//

import SwiftUI
import Foundation
import Combine

struct Todo: Codable, Identifiable {
    let id: Int?
    let title: String
    let description: String?
    let completed: Bool
    let createdAt: String?
    let updatedAt: String?
}

class TodoService {
    
    private let baseUrl = "https://todoapp-en1q.onrender.com/api/todos"
    
    func fetchTodo() async throws -> [Todo] {
        guard let url = URL(string: baseUrl) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let todos = try JSONDecoder().decode([Todo].self, from: data)
        return todos
    }
    
    func createTodo(_ todo: Todo) async throws -> Todo {
        guard let url = URL(string: baseUrl) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(todo)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Todo.self, from: data)
    }
    
    func updateTodo(_ todo: Todo) async throws -> Todo {
        guard let id = todo.id,
              let url = URL(string: "\(baseUrl)/\(id)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(todo)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Todo.self, from: data)
    }
    
    func deleteTodo(id: Int) async throws {
        guard let url = URL(string: "\(baseUrl)/\(id)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        _ = try await URLSession.shared.data(for: request)
    }
}

struct TodoRowView: View {
    let todo: Todo
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(todo.completed ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.headline)
                    .strikethrough(todo.completed)
                    .foregroundColor(todo.completed ? .gray : .primary)
                
                if let description = todo.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical,8)
    }
}

struct AddTodoView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TodoViewModel
    
    @State private var title = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Todo Details")) {
                    TextField("Title", text: $title)
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        Task {
                            await addTodo()
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func addTodo() async {
        let newTodo = Todo(
            id: nil,
            title: title,
            description: description.isEmpty ? nil : description,
            completed: false,
            createdAt: nil,
            updatedAt: nil
        )
        await viewModel.createTodo(newTodo)
        dismiss()
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TodoViewModel()
    
    @State private var showingAddTodo = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading todos...")
                } else if viewModel.todos.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 70))
                            .foregroundStyle(.gray)
                        
                        Text("No Task Yet")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text("Tap the + button to add your first todo")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                } else {
                    List {
                        ForEach(viewModel.todos) { todo in
                            TodoRowView(
                                todo: todo,
                                onToggle: {
                                    viewModel.toggleTodoCompletion(todo)
                                },
                                onDelete: {
                                    viewModel.deleteTodo(todo)
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("My Todos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTodo = true }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        Task { await viewModel.loadTodos() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingAddTodo) {
                AddTodoView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadTodos()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("Ok", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

#Preview {
    ContentView()
}
