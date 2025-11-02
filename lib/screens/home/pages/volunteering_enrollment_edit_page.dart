import 'package:flutter/material.dart';
import 'package:project/utils/app_colors.dart';
import 'package:project/services/database_service.dart';
import 'package:project/models/volunteering_enrollment_model.dart';

class VolunteeringEnrollmentEditPage extends StatefulWidget {
  final VolunteeringEnrollmentModel? enrollment; // If null, it's add mode. If not null, it's edit mode.

  const VolunteeringEnrollmentEditPage({super.key, this.enrollment});

  @override
  State<VolunteeringEnrollmentEditPage> createState() => _VolunteeringEnrollmentEditPageState();
}

class _VolunteeringEnrollmentEditPageState extends State<VolunteeringEnrollmentEditPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;

  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _opportunityIdController = TextEditingController();
  final TextEditingController _opportunityTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.enrollment != null) {
      // Edit mode - populate fields
      _userIdController.text = widget.enrollment!.userId;
      _userNameController.text = widget.enrollment!.userName;
      _userEmailController.text = widget.enrollment!.userEmail;
      _opportunityIdController.text = widget.enrollment!.opportunityId;
      _opportunityTitleController.text = widget.enrollment!.opportunityTitle;
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _userNameController.dispose();
    _userEmailController.dispose();
    _opportunityIdController.dispose();
    _opportunityTitleController.dispose();
    super.dispose();
  }

  Future<void> _saveEnrollment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final enrollment = VolunteeringEnrollmentModel(
        id: widget.enrollment?.id ?? 'temp', // Temporary id for model, will be ignored in DB
        userId: _userIdController.text.trim(),
        userName: _userNameController.text.trim(),
        userEmail: _userEmailController.text.trim(),
        opportunityId: _opportunityIdController.text.trim(),
        opportunityTitle: _opportunityTitleController.text.trim(),
        enrolledAt: widget.enrollment?.enrolledAt,
        createdAt: widget.enrollment?.createdAt,
        updatedAt: DateTime.now(),
      );

      if (widget.enrollment == null) {
        // Add mode
        await _dbService.addVolunteeringEnrollment(enrollment);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Volunteering enrollment added successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // Edit mode
        await _dbService.updateVolunteeringEnrollment(enrollment);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Volunteering enrollment updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate refresh needed
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $errorMessage',
              style: const TextStyle(fontSize: 12),
              maxLines: 5,
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
        // Also print to console for debugging
        print('Volunteering enrollment save error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteEnrollment() async {
    if (widget.enrollment == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Enrollment'),
        content: Text('Are you sure you want to delete enrollment for "${widget.enrollment!.userName}" in "${widget.enrollment!.opportunityTitle}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _dbService.deleteVolunteeringEnrollment(widget.enrollment!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Volunteering enrollment deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate refresh needed
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error deleting enrollment: $errorMessage',
              style: const TextStyle(fontSize: 12),
              maxLines: 5,
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
        // Also print to console for debugging
        print('Volunteering enrollment delete error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        title: Text(
          widget.enrollment == null ? 'Add Enrollment' : 'Edit Enrollment',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.background,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _userIdController,
                  decoration: InputDecoration(
                    labelText: 'User ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter user ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    labelText: 'User Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter user name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _userEmailController,
                  decoration: InputDecoration(
                    labelText: 'User Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter user email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _opportunityIdController,
                  decoration: InputDecoration(
                    labelText: 'Opportunity ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.volunteer_activism),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter opportunity ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _opportunityTitleController,
                  decoration: InputDecoration(
                    labelText: 'Opportunity Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter opportunity title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveEnrollment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.enrollment == null ? 'Add Enrollment' : 'Update Enrollment',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                if (widget.enrollment != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _deleteEnrollment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Delete Enrollment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


