import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_widget.dart';

/// Job Listings Modal - Mobile version of modals/landing/landing_job_listings_modal.php
/// Matches your web modal structure and functionality exactly
class JobListingsModal extends StatefulWidget {
  final String? searchKeyword;
  final String? searchLocation;
  final String? categoryFilter;
  final String title;

  const JobListingsModal({
    super.key,
    this.searchKeyword,
    this.searchLocation,
    this.categoryFilter,
    required this.title,
  });

  @override
  State<JobListingsModal> createState() => _JobListingsModalState();
}

class _JobListingsModalState extends State<JobListingsModal> {
  // Filter state (matches your web modal filters)
  String? selectedLocation;
  String? selectedType;
  bool isLoading = true;
  List<Map<String, dynamic>> jobs = [];
  List<Map<String, dynamic>> filteredJobs = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  /// Load jobs data (simulates your web API call)
  Future<void> _loadJobs() async {
    setState(() {
      isLoading = true;
    });

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Sample job data (matches your web jobsData structure)
    final allJobs = [
      {
        'id': 1,
        'title': 'Elementary School Teacher',
        'company': 'Bright Future Academy',
        'location': 'New York',
        'type': 'Full-time',
        'category': 'education',
        'salary': '\$45,000 - \$60,000',
        'description':
            'Looking for a passionate elementary school teacher to educate and inspire young minds. Must have a teaching certificate and experience working with children.',
        'posted': '3 days ago',
      },
      {
        'id': 2,
        'title': 'Administrative Assistant',
        'company': 'Global Solutions Inc.',
        'location': 'Chicago',
        'type': 'Full-time',
        'category': 'office',
        'salary': '\$35,000 - \$45,000',
        'description':
            'Seeking an organized administrative assistant to support our executive team. Responsibilities include scheduling, document management, and customer service.',
        'posted': '1 week ago',
      },
      {
        'id': 3,
        'title': 'Customer Service Representative',
        'company': 'Tech Support Central',
        'location': 'Remote',
        'type': 'Part-time',
        'category': 'customer',
        'salary': '\$18 - \$22 per hour',
        'description':
            'Join our remote customer service team providing technical support to customers. Strong communication skills and problem-solving abilities required.',
        'posted': '2 days ago',
      },
      {
        'id': 4,
        'title': 'Business Analyst',
        'company': 'Finance Corp',
        'location': 'San Francisco',
        'type': 'Full-time',
        'category': 'business',
        'salary': '\$70,000 - \$90,000',
        'description':
            'Seeking a business analyst to help improve our operational processes. Must have experience with data analysis and business process optimization.',
        'posted': '1 month ago',
      },
      {
        'id': 5,
        'title': 'Registered Nurse',
        'company': 'Community Health Center',
        'location': 'Miami',
        'type': 'Full-time',
        'category': 'healthcare',
        'salary': '\$65,000 - \$85,000',
        'description':
            'Join our healthcare team as a registered nurse. Must have valid nursing license and experience in direct patient care.',
        'posted': '2 weeks ago',
      },
      {
        'id': 6,
        'title': 'Bookkeeper',
        'company': 'Small Business Solutions',
        'location': 'Atlanta',
        'type': 'Part-time',
        'category': 'finance',
        'salary': '\$25 - \$30 per hour',
        'description':
            'Part-time bookkeeper needed for local accounting firm. Responsibilities include maintaining financial records, processing invoices, and reconciling accounts.',
        'posted': '5 days ago',
      },
    ];

    // Filter jobs based on search criteria and category (matches your web filtering logic)
    List<Map<String, dynamic>> results = allJobs;

    // Filter by category
    if (widget.categoryFilter != null) {
      results = results
          .where((job) => job['category'] == widget.categoryFilter)
          .toList();
    }

    // Filter by search keyword
    if (widget.searchKeyword != null && widget.searchKeyword!.isNotEmpty) {
      final keyword = widget.searchKeyword!.toLowerCase();
      results = results.where((job) {
        return job['title'].toString().toLowerCase().contains(keyword) ||
            job['company'].toString().toLowerCase().contains(keyword) ||
            job['description'].toString().toLowerCase().contains(keyword);
      }).toList();
    }

    // Filter by search location
    if (widget.searchLocation != null && widget.searchLocation!.isNotEmpty) {
      final location = widget.searchLocation!.toLowerCase();
      results = results.where((job) {
        return job['location'].toString().toLowerCase().contains(location);
      }).toList();
    }

    setState(() {
      jobs = results;
      filteredJobs = results;
      isLoading = false;
    });
  }

  /// Apply filters (matches your web filter functionality)
  void _applyFilters() {
    List<Map<String, dynamic>> filtered = jobs;

    // Filter by location
    if (selectedLocation != null && selectedLocation!.isNotEmpty) {
      filtered =
          filtered.where((job) => job['location'] == selectedLocation).toList();
    }

    // Filter by type
    if (selectedType != null && selectedType!.isNotEmpty) {
      filtered = filtered.where((job) => job['type'] == selectedType).toList();
    }

    setState(() {
      filteredJobs = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9, // 90% of screen height
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Modal Header (matches your web modal header)
          _buildModalHeader(),

          // Job Filters (matches your web .job-filters)
          _buildJobFilters(),

          // Jobs List (matches your web .jobs-list)
          Expanded(
            child: _buildJobsList(),
          ),
        ],
      ),
    );
  }

  /// Modal Header - matches your web modal close button and title
  Widget _buildModalHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Modal Title (matches your web #modal-title)
          Expanded(
            child: Text(
              widget.title,
              style: AppTextStyles.cardTitle,
            ),
          ),

          // Close Button (matches your web .close)
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppColors.textLight,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Job Filters - matches your web .job-filters structure
  Widget _buildJobFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Location Filter (matches #filter-location)
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 9, vertical: 10),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Locations')),
                DropdownMenuItem(value: 'Remote', child: Text('Remote')),
                DropdownMenuItem(value: 'New York', child: Text('New York')),
                DropdownMenuItem(
                    value: 'San Francisco', child: Text('San Francisco')),
                DropdownMenuItem(value: 'Chicago', child: Text('Chicago')),
                DropdownMenuItem(value: 'Miami', child: Text('Miami')),
                DropdownMenuItem(value: 'Atlanta', child: Text('Atlanta')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedLocation = value;
                });
                _applyFilters();
              },
            ),
          ),

          const SizedBox(width: 15), // matches gap: 15px

          // Type Filter (matches #filter-type)
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Job Type',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Types')),
                DropdownMenuItem(value: 'Full-time', child: Text('Full-time')),
                DropdownMenuItem(value: 'Part-time', child: Text('Part-time')),
                DropdownMenuItem(value: 'Contract', child: Text('Contract')),
                DropdownMenuItem(
                    value: 'Internship', child: Text('Internship')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
                _applyFilters();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Jobs List - matches your web #jobs-container .jobs-list
  Widget _buildJobsList() {
    if (isLoading) {
      return const LoadingWidget(
        message: 'Loading jobs...',
      );
    }

    if (filteredJobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.work_off_outlined,
                size: 80,
                color: AppColors.textLight,
              ),
              const SizedBox(height: 20),
              Text(
                'No jobs found',
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: 10),
              Text(
                'Try adjusting your search criteria or filters.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredJobs.length,
      itemBuilder: (context, index) {
        final job = filteredJobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: JobCard(
            jobTitle: job['title'],
            company: job['company'],
            location: job['location'],
            jobType: job['type'],
            salary: job['salary'],
            description: job['description'],
            postedTime: job['posted'],
            onTap: () => _showJobDetails(job),
            onApply: () => _handleApply(job),
            onSave: () => _handleSave(job),
          ),
        );
      },
    );
  }

  /// Show Job Details (matches your web job detail modal functionality)
  void _showJobDetails(Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildJobDetailsModal(job),
    );
  }

  /// Job Details Modal (expanded job information)
  Widget _buildJobDetailsModal(Map<String, dynamic> job) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Job Details Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.secondaryTeal,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job['title'],
                        style: AppTextStyles.heroTitle.copyWith(fontSize: 24),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Text(
                  job['company'],
                  style: AppTextStyles.heroSubtitle.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Job Details Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Meta Information
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildJobDetailChip(
                          Icons.location_on_outlined, job['location']),
                      _buildJobDetailChip(Icons.access_time, job['type']),
                      _buildJobDetailChip(Icons.attach_money, job['salary']),
                      _buildJobDetailChip(
                          Icons.calendar_today_outlined, job['posted']),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Job Description
                  Text(
                    'Job Description',
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    job['description'],
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleApply(job),
                          child: const Text('Apply Now'),
                        ),
                      ),
                      const SizedBox(width: 15),
                      OutlinedButton(
                        onPressed: () => _handleSave(job),
                        child: const Text('Save Job'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Job Detail Chip (reusable component)
  Widget _buildJobDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.jobDetailBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(text, style: AppTextStyles.jobDetail),
        ],
      ),
    );
  }

  /// Handle Apply (matches your web apply functionality)
  void _handleApply(Map<String, dynamic> job) {
    Navigator.of(context).pop(); // Close job details
    Navigator.of(context).pop(); // Close job listings

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied to ${job['title']} at ${job['company']}! 🎉'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  /// Handle Save Job (matches your web save functionality)
  void _handleSave(Map<String, dynamic> job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved ${job['title']} to your favorites! 📌'),
        backgroundColor: AppColors.primaryOrange,
      ),
    );
  }
}
