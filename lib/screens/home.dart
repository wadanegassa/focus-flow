import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task/widgets/drawer.dart';
import 'package:task/route.dart';
import 'package:task/services/task_service.dart';
import 'package:task/models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          children: [
            Text(
              'Good Morning 👋',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Ready to be productive?',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, Routes.tasks);
            },
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: Consumer<TaskService>(
        builder: (context, taskService, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Card
                    Container(
                      height: isTablet ? 180 : 150,
                      width: double.infinity,
                      margin: EdgeInsets.all(isTablet ? 20 : 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue, Colors.blue.shade600],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 25 : 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tasks Completed',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: isTablet ? 10 : 8),
                                  Text(
                                    '${taskService.completedTasksCount}/${taskService.totalTasks}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 32 : 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: isTablet ? 8 : 6),
                                  LinearProgressIndicator(
                                    value: taskService.completionPercentage,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.3,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                    minHeight: 6,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              height: isTablet ? 70 : 60,
                              width: isTablet ? 70 : 60,
                              child: Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: isTablet ? 35 : 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: isTablet ? 30 : 25),

                    // Quick Stats Section
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 25 : 20,
                      ),
                      child: Text(
                        'Quick Stats',
                        style: TextStyle(
                          fontSize: isTablet ? 22 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    SizedBox(height: isTablet ? 20 : 15),

                    // Stats Cards
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Completed',
                              value: '${taskService.completedTasksCount} tasks',
                              icon: Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: isTablet ? 20 : 16),
                          Expanded(
                            child: _buildStatCard(
                              title: 'In Progress',
                              value:
                                  '${taskService.inProgressTasksCount} tasks',
                              icon: Icons.hourglass_empty,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isTablet ? 30 : 25),

                    // Daily Motivation Card
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16,
                      ),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                height: isTablet ? 60 : 50,
                                width: isTablet ? 60 : 50,
                                child: Icon(
                                  Icons.flash_on_outlined,
                                  color: Colors.blue,
                                  size: isTablet ? 30 : 25,
                                ),
                              ),
                              SizedBox(width: isTablet ? 20 : 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daily Motivation',
                                      style: TextStyle(
                                        fontSize: isTablet ? 18 : 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: isTablet ? 8 : 6),
                                    Text(
                                      _getMotivationalQuote(),
                                      style: TextStyle(
                                        fontSize: isTablet ? 14 : 12,
                                        color: Colors.grey.shade600,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isTablet ? 30 : 25),

                    // Recent Tasks Section
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 25 : 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Tasks',
                            style: TextStyle(
                              fontSize: isTablet ? 22 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, Routes.tasks);
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isTablet ? 20 : 15),

                    // Task List
                    taskService.tasks.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            children: taskService.tasks
                                .take(3)
                                .map(
                                  (task) => _buildTaskCard(task, taskService),
                                )
                                .toList(),
                          ),

                    SizedBox(height: isTablet ? 30 : 25),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 8,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Navigate to different screens based on selected index
          switch (index) {
            case 0:
              // Already on home screen
              break;
            case 1:
              Navigator.pushNamed(context, Routes.tasks);
              break;
            case 2:
              Navigator.pushNamed(context, Routes.profile);
              break;
          }
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            activeIcon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            activeIcon: Icon(Icons.person_2),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              height: isTablet ? 50 : 40,
              width: isTablet ? 50 : 40,
              child: Icon(icon, color: color, size: isTablet ? 25 : 20),
            ),
            SizedBox(height: isTablet ? 12 : 10),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task, TaskService taskService) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 8 : 6,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 8 : 4,
          ),
          leading: GestureDetector(
            onTap: () => taskService.toggleTaskStatus(task.id),
            child: Container(
              decoration: BoxDecoration(
                color: _getStatusColor(task.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              height: isTablet ? 40 : 35,
              width: isTablet ? 40 : 35,
              child: Icon(
                _getStatusIcon(task.status),
                color: _getStatusColor(task.status),
                size: isTablet ? 20 : 18,
              ),
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              decoration: task.status == TaskStatus.completed
                  ? TextDecoration.lineThrough
                  : null,
              color: task.status == TaskStatus.completed
                  ? Colors.grey.shade600
                  : Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.category,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: Colors.grey.shade600,
                ),
              ),
              if (task.dueDate != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Due: ${_formatDate(task.dueDate!)}',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: _getDueDateColor(task.dueDate!),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: isTablet ? 18 : 16,
            color: Colors.grey.shade400,
          ),
          onTap: () {
            Navigator.pushNamed(context, Routes.tasks);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.task_alt_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No tasks yet',
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
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.tasks);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMotivationalQuote() {
    final quotes = [
      '"Discipline is the bridge between goals and accomplishment"',
      '"The way to get started is to quit talking and begin doing"',
      '"Don\'t be pushed around by the fears in your mind. Be led by the dreams in your heart"',
      '"Success is not final, failure is not fatal: it is the courage to continue that counts"',
      '"The future belongs to those who believe in the beauty of their dreams"',
    ];
    return quotes[DateTime.now().day % quotes.length];
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

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    if (dueDate.isBefore(now) && !dueDate.isSameDay(now)) {
      return Colors.red;
    } else if (dueDate.isSameDay(now)) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.isSameDay(now)) {
      return 'Today';
    } else if (date.isSameDay(now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else if (date.isSameDay(now.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
