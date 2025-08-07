import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_widget.dart';

/// Job Listings Modal - NOW USES REAL API DATA FROM YOUR DATABASE
/// Calls your jobs.php API to display actual jobs instead of hardcoded samples
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
  // Filter state
  String? selectedLocation;
  String? selectedType;
  bool isLoading = true;
  List<Map<String, dynamic>> jobs = [];
  List<Map<String, dynamic>> filteredJobs = [];

  // API state
  bool hasError = false;
  String errorMessage = '';
  int totalJobs = 0;

  @override
  void initState() {
    super.initState();
    _loadJobsFromAPI(); // NOW CALLS REAL API
  }

  /// REAL API CALL - Fetch jobs from your database
  Future<void> _loadJobsFromAPI() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      print('🔧 Loading jobs from API with filters:');
      print('   Search: ${widget.searchKeyword}');
      print('   Location: ${widget.searchLocation}');
      print('   Category: ${widget.categoryFilter}');

      // Call your REAL API (jobs.php)
      final response = await ApiService.getLandingJobs(
        search: widget.searchKeyword,
        location: widget.searchLocation,
        category: widget.categoryFilter,
        limit: 50,
      );

      print('🔧 API Response: ${response['success']}');
      print('🔧 API Message: ${response['message']}');

      if (response['success'] == true) {
        final jobsData = response['data']['jobs'] as List<dynamic>;
        final pagination =
            response['data']['pagination'] as Map<String, dynamic>;

        setState(() {
          jobs = jobsData.cast<Map<String, dynamic>>();
          filteredJobs = List.from(jobs);
          totalJobs = pagination['total'] ?? 0;
          isLoading = false;
          hasError = false;
        });

        print('✅ Successfully loaded ${jobs.length} jobs from your database!');

        // Print first job for debugging
        if (jobs.isNotEmpty) {
          print(
              '📋 First job: ${jobs.first['title']} at ${jobs.first['company']}');
        }
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = response['message'] ?? 'Failed to load jobs from API';
        });
        print('❌ API Error: ${response['message']}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error connecting to your API: $e';
      });
      print('❌ Exception loading jobs from API: $e');
    }
  }

  /// Apply local filters to the API data
  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(jobs);

    // Filter by location
    if (selectedLocation != null && selectedLocation!.isNotEmpty) {
      filtered = filtered.where((job) {
        return job['location']
            .toString()
            .toLowerCase()
            .contains(selectedLocation!.toLowerCase());
      }).toList();
    }

    // Filter by job type
    if (selectedType != null && selectedType!.isNotEmpty) {
      filtered = filtered.where((job) {
        return job['type'].toString().toLowerCase() ==
            selectedType!.toLowerCase();
      }).toList();
    }

    setState(() {
      filteredJobs = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Modal Header
          _buildModalHeader(),

          // Job Filters
          _buildJobFilters(),

          // Jobs List - Shows REAL data or error/loading
          Expanded(
            child: _buildJobsList(),
          ),
        ],
      ),
    );
  }

  /// Modal Header with job count from API
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
          // Modal Title with REAL job count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.cardTitle,
                ),
                if (!isLoading && !hasError)
                  Text(
                    '${filteredJobs.length} jobs from your database',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                if (hasError)
                  Text(
                    'API Connection Failed',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.errorRed,
                    ),
                  ),
              ],
            ),
          ),

          // Refresh button to retry API call
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: AppColors.secondaryTeal,
            ),
            onPressed: _loadJobsFromAPI,
          ),

          // Close Button
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

  /// Job Filters - uses unique locations from API data
  Widget _buildJobFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Location Filter - populated from REAL job data
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              items: _getUniqueLocations(),
              onChanged: (value) {
                setState(() {
                  selectedLocation = value;
                });
                _applyFilters();
              },
            ),
          ),

          const SizedBox(width: 15),

          // Job Type Filter
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
                DropdownMenuItem(value: 'Freelance', child: Text('Freelance')),
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

  /// Get unique locations from REAL API data
  List<DropdownMenuItem<String>> _getUniqueLocations() {
    final locations = <String>{'All Locations'};

    for (final job in jobs) {
      final location = job['location']?.toString();
      if (location != null && location.isNotEmpty) {
        locations.add(location);
      }
    }

    return locations.map((location) {
      return DropdownMenuItem<String>(
        value: location == 'All Locations' ? null : location,
        child: Text(location),
      );
    }).toList();
  }

  /// Jobs List - shows REAL data, loading, or error state
  Widget _buildJobsList() {
    if (isLoading) {
      return const LoadingWidget(
        message: 'Loading jobs from your database...',
      );
    }

    if (hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.errorRed,
              ),
              const SizedBox(height: 20),
              Text(
                'Failed to Load Jobs',
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadJobsFromAPI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryTeal,
                ),
                child: const Text(
                  'Retry API Call',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Check: XAMPP running, correct IP address',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
                'No jobs found in database',
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: 10),
              Text(
                'Try different search criteria or add more jobs to your database.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Show REAL jobs from your database
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredJobs.length,
      itemBuilder: (context, index) {
        final job = filteredJobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: JobCard(
            jobTitle: job['title'] ?? 'Untitled Job',
            company: job['company'] ?? 'Company Name',
            location: job['location'] ?? 'Location Not Specified',
            jobType: job['type'] ?? 'Full-time',
            salary: job['salary'] ?? 'Competitive',
            description: job['description'] ?? 'No description available',
            postedTime: job['posted'] ?? 'Recently posted',
            onTap: () => _showJobDetails(job),
            onApply: () => _handleApply(job),
            onSave: () => _handleSave(job),
            // FIXED: Removed unsupported parameters
          ),
        );
      },
    );
  }

  /// Show Job Details with REAL data from your database
  void _showJobDetails(Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildJobDetailsModal(job),
    );
  }

  /// Job Details Modal showing REAL job information
  Widget _buildJobDetailsModal(Map<String, dynamic> job) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Job Details Header with REAL company info
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['title'] ?? 'Job Title',
                            style: AppTextStyles.cardTitle.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            job['company'] ?? 'Company',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Job meta information from YOUR DATABASE
                Wrap(
                  spacing: 15,
                  runSpacing: 10,
                  children: [
                    _buildJobMetaChip(Icons.location_on, job['location']),
                    _buildJobMetaChip(Icons.work, job['type']),
                    _buildJobMetaChip(Icons.attach_money, job['salary']),
                    _buildJobMetaChip(Icons.category, job['department']),
                    if (job['remote_available'] == true)
                      _buildJobMetaChip(Icons.home, 'Remote Available'),
                    if (job['flexible_schedule'] == true)
                      _buildJobMetaChip(Icons.schedule, 'Flexible Schedule'),
                  ],
                ),
              ],
            ),
          ),

          // Job Details Content from YOUR DATABASE
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Description from database
                  Text(
                    'Job Description',
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    job['description'] ?? 'No description available',
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: 20),

                  // Job Requirements from database
                  Text(
                    'Requirements',
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    job['requirements'] ??
                        'Requirements will be discussed during interview',
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: 20),

                  // Additional Details from database
                  if (job['department'] != null) ...[
                    Text(
                      'Department',
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      job['department'],
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (job['industry'] != null) ...[
                    Text(
                      'Industry',
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      job['industry'],
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Posted Time from database
                  Text(
                    'Posted: ${job['posted'] ?? 'Recently'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),

                  // Job Stats from database
                  if (job['views'] != null || job['applications'] != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Views: ${job['views'] ?? 0} | Applications: ${job['applications'] ?? 0}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.backgroundColor,
              border: Border(
                top: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleApply(job),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryTeal,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Apply Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleSave(job),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.secondaryTeal),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Save Job',
                      style: TextStyle(color: AppColors.secondaryTeal),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build job meta chip
  Widget _buildJobMetaChip(IconData icon, String? text) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Handle job application
  void _handleApply(Map<String, dynamic> job) {
    Navigator.of(context).pop(); // Close details modal
    Navigator.of(context).pop(); // Close job listings modal

    // Show success message with REAL job data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied to ${job['title']} at ${job['company']}!'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    // TODO: Navigate to candidate login or application flow
  }

  /// Handle save job
  void _handleSave(Map<String, dynamic> job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved ${job['title']} from your database!'),
        backgroundColor: AppColors.secondaryTeal,
      ),
    );

    // TODO: Implement save job functionality with real job ID
    print('Saving job ID: ${job['id']} to favorites');
  }
}
