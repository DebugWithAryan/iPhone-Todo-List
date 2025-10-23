//
//  TodoViewModel.swift
//  To-Do List
//
//  Created by Aryan Jaiswal on 22/10/25.
//

import Foundation
import Combine


@MainActor
class TodoViewModel: ObservableObject {
    @Published var todos: [Todo] = []
    
    @Published var isLoading = false
    
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let service = TodoService()
    
    func loadTodos() async {
        isLoading = true
        do{
            todos = try await service.fetchTodo()
            isLoading = false
        }
        catch{
            isLoading = false
            showError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func createTodo(_ todo: Todo) async {
        do{
            let createdTodo = try await service.createTodo(todo)
            todos.append(createdTodo)
        }
        catch{
            errorMessage = "Failed to create todo"
            showError = true
        }
    }
    
    func toggleTodoCompletion(_ todo: Todo) {
        Task {
            do {
                let updatedTodo = Todo(
                    id: todo.id,
                    title: todo.title,
                    description: todo.description,
                    completed: !todo.completed,
                    createdAt: todo.createdAt,
                    updatedAt: todo.updatedAt
                )
                let updated = try await service.updateTodo(updatedTodo)
                if let index = todos.firstIndex(where: { $0.id == updated.id }) {
                    todos[index] = updated
                }
            } catch {
                errorMessage = "Failed to update todo"
                showError = true
            }
        }
    }
    
    func deleteTodo(_ todo: Todo){
        guard let id = todo.id else {return}
        
        Task{
            do {
                try await service.deleteTodo(id: id)
                todos.removeAll{
                    $0.id == id
                }
            }catch{
                errorMessage = "Failed to delete todo"
                showError = true
            }
        }
    }
    
}

    
    
