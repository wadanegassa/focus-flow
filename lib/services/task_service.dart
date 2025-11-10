import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';

class TaskService extends ChangeNotifier {
  final List<Task> _tasks = [];
  TaskStatus? _filterStatus;
  String _searchQuery = '';
  static const String _tasksKey = 'tasks';

  List<Task> get tasks => _tasks;
  TaskStatus? get filterStatus => _filterStatus;
  String get searchQuery => _searchQuery;

  List<Task> get filteredTasks {
    List<Task> filtered = _tasks;

    // Filter by status
    if (_filterStatus != null) {
      filtered = filtered
          .where((task) => task.status == _filterStatus)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (task) =>
                task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                task.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                task.category.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // Sort by priority and due date
    filtered.sort((a, b) {
      // First sort by priority (urgent first)
      int priorityComparison = b.priority.value.compareTo(a.priority.value);
      if (priorityComparison != 0) return priorityComparison;

      // Then sort by due date (earliest first)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }

      // Finally sort by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  List<Task> get pendingTasks =>
      _tasks.where((task) => task.status == TaskStatus.pending).toList();
  List<Task> get inProgressTasks =>
      _tasks.where((task) => task.status == TaskStatus.inProgress).toList();
  List<Task> get completedTasks =>
      _tasks.where((task) => task.status == TaskStatus.completed).toList();

  int get totalTasks => _tasks.length;
  int get completedTasksCount => completedTasks.length;
  int get pendingTasksCount => pendingTasks.length;
  int get inProgressTasksCount => inProgressTasks.length;

  double get completionPercentage {
    if (_tasks.isEmpty) return 0.0;
    return completedTasksCount / _tasks.length;
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];
    _tasks.clear();
    for (final taskJson in tasksJson) {
      final taskMap = json.decode(taskJson) as Map<String, dynamic>;
      _tasks.add(Task.fromJson(taskMap));
    }
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((task) => json.encode(task.toJson())).toList();
    await prefs.setStringList(_tasksKey, tasksJson);
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    _saveTasks();
    notifyListeners();
  }

  void toggleTaskStatus(String taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      TaskStatus newStatus;
      switch (task.status) {
        case TaskStatus.pending:
          newStatus = TaskStatus.inProgress;
          break;
        case TaskStatus.inProgress:
          newStatus = TaskStatus.completed;
          break;
        case TaskStatus.completed:
          newStatus = TaskStatus.pending;
          break;
        case TaskStatus.cancelled:
          newStatus = TaskStatus.pending;
          break;
      }
      _tasks[index] = task.copyWith(status: newStatus);
      _saveTasks();
      notifyListeners();
    }
  }

  void setFilterStatus(TaskStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
