import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/navigation.dart';
import '../viewmodels/inbox_viewmodel.dart';
import '../viewmodels/navigation_viewmodel.dart';
import '../views/screens/task_dashboard_screen.dart';
import '../views/screens/task_details_screen.dart';
import 'project_service.dart';
import 'task_service.dart';

class NotificationNavigationHelper {
  /// Handles contextual redirection when a notification is tapped.
  static Future<void> handleNotificationTap({
    required String type,
    required Map<String, dynamic> payload,
    WidgetRef? ref,
    Ref? containerRef,
    int retryCount = 0,
  }) async {
    final context = navigatorKey.currentContext;
    if (context == null || navigatorKey.currentState == null) {
      if (retryCount < 10) {
        Future.delayed(const Duration(milliseconds: 500), () {
          handleNotificationTap(
            type: type,
            payload: payload,
            ref: ref,
            containerRef: containerRef,
            retryCount: retryCount + 1,
          );
        });
      } else {
        developer.log('Navigator not ready after 5s. Tap ignored.');
      }
      return;
    }

    // Try to extract notification ID to mark it read
    final notificationId = payload['notification_id']?.toString() ??
        payload['notificationId']?.toString() ??
        payload['id']?.toString();

    if (notificationId != null) {
      try {
        if (ref != null) {
          ref.read(inboxViewModelProvider.notifier).markAsRead(notificationId);
        } else if (containerRef != null) {
          containerRef
              .read(inboxViewModelProvider.notifier)
              .markAsRead(notificationId);
        }
      } catch (e) {
        developer.log('Error marking clicked notification as read: $e');
      }
    }

    // Handle routing depending on notification type
    if (type == 'project:invite' || type == 'project:added') {
      // Pop detail screens to return to root
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
      if (ref != null) {
        ref.read(navigationProvider.notifier).setIndex(2);
      } else if (containerRef != null) {
        containerRef.read(navigationProvider.notifier).setIndex(2);
      }
    } else if (type == 'task:assigned' ||
        type == 'comment:added' ||
        type == 'task:updated' ||
        type == 'comment:mention') {
      final projectId = payload['project_id']?.toString() ??
          payload['projectId']?.toString();
      final taskId = payload['task_id']?.toString() ??
          payload['taskId']?.toString();

      if (projectId == null || taskId == null) {
        return;
      }

      // Show loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFF87941)),
        ),
      );

      try {
        final projectService = ProjectService();
        final taskService = TaskService();

        // 1. Fetch Project Details
        final project = await projectService.getProject(projectId);

        // 2. Fetch Task Details
        final task = await taskService.getTask(taskId);

        // Dismiss loader
        navigatorKey.currentState?.pop();

        // Navigate to project dashboard
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => TaskDashboardScreen(project: project),
          ),
        );

        // Navigate to task details
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => TaskDetailsScreen(
              task: task,
              projectId: project.id,
            ),
          ),
        );
      } catch (e) {
        // Dismiss loader
        navigatorKey.currentState?.pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible d\'ouvrir la tâche : le projet ou la '
              'tâche n\'existe plus.',
              style: TextStyle(color: Color(0xFFFDFCFC)),
            ),
            backgroundColor: Color(0xFFF87941),
          ),
        );
      }
    }
  }
}
