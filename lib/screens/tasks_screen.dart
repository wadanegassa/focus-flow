import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'task_details_screen.dart';
import 'add_edit_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: Consumer<TaskService>(
        builder: (context, taskService, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Filter Chips
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip(
                          'All',
                          taskService.filterStatus == null,
                          () => taskService.setFilterStatus(null),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Pending',
                          taskService.filterStatus == TaskStatus.pending,
                          () => taskService.setFilterStatus(TaskStatus.pending),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'In Progress',
                          taskService.filterStatus == TaskStatus.inProgress,
                          () => taskService.setFilterStatus(
                            TaskStatus.inProgress,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Completed',
                          taskService.filterStatus == TaskStatus.completed,
                          () =>
                              taskService.setFilterStatus(TaskStatus.completed),
                        ),
                      ],
                    ),
                  ),

                  // Task Stats
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            taskService.totalTasks.toString(),
                            Icons.task_alt,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Completed',
                            taskService.completedTasksCount.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Progress',
                            '${(taskService.completionPercentage * 100).toInt()}%',
                            Icons.trending_up,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tasks List
                  Expanded(
                    child: taskService.filteredTasks.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: taskService.filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = taskService.filteredTasks[index];
                              return _buildTaskCard(task, taskService);
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task, TaskService taskService) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: GestureDetector(
          onTap: () => taskService.toggleTaskStatus(task.id),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(task.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(task.status),
              color: _getStatusColor(task.status),
            ),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: task.status == TaskStatus.completed
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPriorityChip(task.priority),
                const SizedBox(width: 8),
                _buildCategoryChip(task.category),
                if (task.dueDate != null) ...[
                  const SizedBox(width: 8),
                  _buildDueDateChip(task.dueDate!),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditTaskScreen(task: task),
                  ),
                );
                break;
              case 'delete':
                _showDeleteDialog(task, taskService);
                break;
              case 'view':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailsScreen(task: task),
                  ),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailsScreen(task: task),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          color: _getPriorityColor(priority),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDueDateChip(DateTime dueDate) {
    final now = DateTime.now();
    final isOverdue = dueDate.isBefore(now) && !dueDate.isSameDay(now);
    final isToday = dueDate.isSameDay(now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue
            ? Colors.red.withOpacity(0.1)
            : isToday
            ? Colors.orange.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isToday
            ? 'Today'
            : isOverdue
            ? 'Overdue'
            : '${dueDate.day}/${dueDate.month}',
        style: TextStyle(
          color: isOverdue
              ? Colors.red
              : isToday
              ? Colors.orange
              : Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first task to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.play_circle_outline;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }

  void _showDeleteDialog(Task task, TaskService taskService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              taskService.deleteTask(task.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
