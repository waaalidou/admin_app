import 'package:flutter/material.dart';
import 'package:project/utils/app_colors.dart';
import 'package:project/services/database_service.dart';
import 'package:project/models/volunteering_opportunity_model.dart';

class VolunteeringOpportunityEditPage extends StatefulWidget {
  final VolunteeringOpportunityModel? opportunity; // If null, it's add mode. If not null, it's edit mode.

  const VolunteeringOpportunityEditPage({super.key, this.opportunity});

  @override
  State<VolunteeringOpportunityEditPage> createState() => _VolunteeringOpportunityEditPageState();
}

class _VolunteeringOpportunityEditPageState extends State<VolunteeringOpportunityEditPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _iconNameController = TextEditingController();
  final TextEditingController _enrolledCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.opportunity != null) {
      // Edit mode - populate fields
      _titleController.text = widget.opportunity!.title;
      _descriptionController.text = widget.opportunity!.description;
      _locationController.text = widget.opportunity!.location;
      _iconNameController.text = widget.opportunity!.iconName;
      _enrolledCountController.text = widget.opportunity!.enrolledCount.toString();
    } else {
      // Add mode - set defaults
      _iconNameController.text = 'volunteer_activism';
      _enrolledCountController.text = '0';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _iconNameController.dispose();
    _enrolledCountController.dispose();
    super.dispose();
  }

  Future<void> _saveOpportunity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final opportunity = VolunteeringOpportunityModel(
        id: widget.opportunity?.id ?? 'temp', // Temporary id for model, will be ignored in DB
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        iconName: _iconNameController.text.trim(),
        color: widget.opportunity?.color ?? '#4CAF50', // Keep existing color or use default
        enrolledCount: int.tryParse(_enrolledCountController.text) ?? 0,
        createdAt: widget.opportunity?.createdAt,
        updatedAt: DateTime.now(),
      );

      if (widget.opportunity == null) {
        // Add mode
        await _dbService.addVolunteeringOpportunity(opportunity);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Volunteering opportunity added successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // Edit mode
        await _dbService.updateVolunteeringOpportunity(opportunity);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Volunteering opportunity updated successfully'),
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
        print('Volunteering opportunity save error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteOpportunity() async {
    if (widget.opportunity == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Volunteering Opportunity'),
        content: Text('Are you sure you want to delete "${widget.opportunity!.title}"? This action cannot be undone.'),
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
      await _dbService.deleteVolunteeringOpportunity(widget.opportunity!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Volunteering opportunity deleted successfully'),
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
              'Error deleting volunteering opportunity: $errorMessage',
              style: const TextStyle(fontSize: 12),
              maxLines: 5,
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
        // Also print to console for debugging
        print('Volunteering opportunity delete error: $e');
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
          widget.opportunity == null ? 'Add Opportunity' : 'Edit Opportunity',
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
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _iconNameController,
                  decoration: InputDecoration(
                    labelText: 'Icon Name',
                    hintText: 'e.g., volunteer_activism, group',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.emoji_events),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter icon name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _enrolledCountController,
                  decoration: InputDecoration(
                    labelText: 'Enrolled Count',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.people),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter enrolled count';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveOpportunity,
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
                          widget.opportunity == null ? 'Add Opportunity' : 'Update Opportunity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                if (widget.opportunity != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _deleteOpportunity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Delete Opportunity',
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

