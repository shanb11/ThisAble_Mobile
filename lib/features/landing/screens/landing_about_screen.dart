import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../config/routes.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../widgets/landing_navbar.dart';
import '../widgets/landing_footer.dart';

/// Landing About Screen - Complete mobile version of landing_about.php
/// Mirrors your web about page structure exactly: hero + timeline + values + team + contact
class LandingAboutScreen extends StatefulWidget {
  const LandingAboutScreen({super.key});

  @override
  State<LandingAboutScreen> createState() => _LandingAboutScreenState();
}

class _LandingAboutScreenState extends State<LandingAboutScreen> {
  // Contact form controllers (matches your web contact form)
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _contactFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navigation Bar (matches your web about page navbar)
            LandingNavbar(
              onAboutPressed: () {}, // Current page
              onJobsPressed: () => AppRoutes.goToJobs(context),
            ),

            // About Hero Section (matches landing_about_team.php hero)
            _buildAboutHero(),

            // Timeline Section (matches your web timeline/journey)
            _buildTimelineSection(),

            // Mission & Values Section (matches your web values)
            _buildMissionValuesSection(),

            // Team Section (matches landing_about_team.php)
            _buildTeamSection(),

            // Contact Section (matches landing_about_contact.php)
            _buildContactSection(),

            // Footer (matches your web footer)
            const LandingFooter(),
          ],
        ),
      ),
    );
  }

  /// About Hero Section - matches your CSS .about-hero
  Widget _buildAboutHero() {
    return Container(
      width: double.infinity,
      color: AppColors.secondaryTeal, // matches background-color: #257180
      padding: const EdgeInsets.symmetric(
          vertical: 60, horizontal: 20), // matches padding: 60px 0
      child: Column(
        children: [
          // Hero Title (matches .about-hero h1)
          Text(
            'About ThisAble',
            style: AppTextStyles.aboutHeroTitle,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20), // matches margin-bottom: 20px

          // Hero Description (matches .about-hero p)
          Container(
            constraints:
                const BoxConstraints(maxWidth: 700), // matches max-width: 700px
            child: Text(
              'We are dedicated to creating inclusive job opportunities and connecting talented individuals with employers who value diversity and accessibility.',
              style: AppTextStyles.heroSubtitle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Timeline Section - matches your web timeline/journey section
  Widget _buildTimelineSection() {
    return Container(
      color: Colors.white, // matches background-color: #fff
      padding: const EdgeInsets.symmetric(
          vertical: 60, horizontal: 20), // matches padding: 60px 0
      child: Column(
        children: [
          // Section Title (matches .timeline-section h2)
          Text(
            'Our Journey',
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.secondaryTeal, // matches color: #257180
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40), // matches margin-bottom: 40px

          // Timeline Items
          _buildTimelineItem(
            icon: Icons.lightbulb_outline,
            title: 'The Idea',
            description:
                'Founded with the vision of creating equal opportunities for everyone in the job market.',
            isLeft: true,
          ),

          const SizedBox(height: 30),

          _buildTimelineItem(
            icon: Icons.rocket_launch_outlined,
            title: 'Launch',
            description:
                'Launched our platform connecting job seekers with inclusive employers.',
            isLeft: false,
          ),

          const SizedBox(height: 30),

          _buildTimelineItem(
            icon: Icons.trending_up_outlined,
            title: 'Growth',
            description:
                'Expanded to serve thousands of candidates and hundreds of employers.',
            isLeft: true,
          ),

          const SizedBox(height: 30),

          _buildTimelineItem(
            icon: Icons.public_outlined,
            title: 'Impact',
            description:
                'Making a real difference in creating inclusive workplaces worldwide.',
            isLeft: false,
          ),
        ],
      ),
    );
  }

  /// Timeline Item - matches your web .timeline-item structure
  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isLeft,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Row(
        children: [
          if (!isLeft) const Expanded(child: SizedBox()),

          // Timeline Icon (matches .timeline-icon)
          Container(
            width: 60, // matches width: 60px
            height: 60, // matches height: 60px
            decoration: const BoxDecoration(
              color:
                  AppColors.primaryOrange, // matches background-color: #FD8B51
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24, // matches font-size: 24px
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 20),

          // Timeline Content (matches .timeline-content)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20), // matches padding: 20px
              decoration: BoxDecoration(
                color: AppColors
                    .categoryBackground, // matches background-color: #f9f9f9
                borderRadius:
                    BorderRadius.circular(10), // matches border-radius: 10px
                border: const Border(
                  left: BorderSide(
                    color: AppColors
                        .secondaryTeal, // matches border-left: 5px solid #257180
                    width: 5,
                  ),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowLight, // matches box-shadow
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline Title (matches .timeline-content h3)
                  Text(
                    title,
                    style: AppTextStyles.timelineTitle,
                  ),

                  const SizedBox(height: 10), // matches margin-bottom: 10px

                  // Timeline Description (matches .timeline-content p)
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          if (isLeft) const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  /// Mission & Values Section - matches your web values section
  Widget _buildMissionValuesSection() {
    return Container(
      color: AppColors.backgroundColor, // matches background-color: #f9f9f9
      padding: const EdgeInsets.symmetric(
          vertical: 60, horizontal: 20), // matches padding: 60px 0
      child: Column(
        children: [
          // Section Title (matches .mission-values h2)
          Text(
            'Our Mission & Values',
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.secondaryTeal,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10), // matches margin-bottom: 40px

          // Values Grid (matches .values-grid)
          _buildValuesGrid(),
        ],
      ),
    );
  }

  /// Values Grid - matches your web values grid layout
  Widget _buildValuesGrid() {
    final values = [
      {
        'icon': Icons.accessibility_new_outlined,
        'title': 'Accessibility',
        'description':
            'Creating opportunities for everyone, regardless of ability.',
      },
      {
        'icon': Icons.diversity_3_outlined,
        'title': 'Diversity',
        'description':
            'Celebrating differences and promoting inclusive hiring.',
      },
      {
        'icon': Icons.handshake_outlined,
        'title': 'Integrity',
        'description':
            'Building trust through honest and transparent practices.',
      },
      {
        'icon': Icons.psychology_outlined,
        'title': 'Innovation',
        'description': 'Continuously improving our platform and services.',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 768 ? 2 : 1,
        crossAxisSpacing: 30, // matches gap: 30px
        mainAxisSpacing: 30,
        childAspectRatio: MediaQuery.of(context).size.width > 768 ? 1.2 : 1.5,
      ),
      itemCount: values.length,
      itemBuilder: (context, index) {
        final value = values[index];
        return _buildValueCard(
          icon: value['icon'] as IconData,
          title: value['title'] as String,
          description: value['description'] as String,
        );
      },
    );
  }

  /// Value Card - matches your web .value-card styling
  Widget _buildValueCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      // Matches .value-card styling
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: AppColors.primaryOrange, // matches ::before styling
            width: 5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
            10), // matches padding: 30px 20px (adjusted for mobile)
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Value Icon (matches .value-card .icon)
            Container(
              width: 60, // matches width: 70px
              height: 70, // matches height: 70px
              decoration: const BoxDecoration(
                color: AppColors
                    .categoryIconBackground, // matches background-color: #e6f3f0
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30, // matches font-size: 30px
                color: AppColors.secondaryTeal, // matches color: #257180
              ),
            ),

            const SizedBox(height: 20), // matches margin: 0 auto 20px

            // Value Title (matches .value-card h3)
            Text(
              title,
              style: AppTextStyles.valueCardTitle,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10), // matches margin-bottom: 10px

            // Value Description (matches .value-card p)
            Text(
              description,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Team Section - matches landing_about_team.php exactly
  Widget _buildTeamSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
          vertical: 60, horizontal: 20), // matches padding: 60px 0
      child: Column(
        children: [
          // Section Title (matches .team-section h2)
          Text(
            'Meet Our Team',
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.secondaryTeal,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10), // matches margin-bottom: 40px

          // Team Grid (matches .team-grid)
          _buildTeamGrid(),
        ],
      ),
    );
  }

  /// Team Grid - matches your web team member structure
  Widget _buildTeamGrid() {
    // Team data from your landing_about_team.php
    final teamMembers = [
      {'name': 'Mekaella Adrid', 'role': 'hihi'},
      {'name': 'Maria Cristina Banares', 'role': 'haha'},
      {'name': 'Shan Michael Baccay', 'role': 'hehe'},
      {'name': 'Jewel Paira', 'role': 'huhu'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 768 ? 2 : 1,
        crossAxisSpacing: 30, // matches gap: 30px
        mainAxisSpacing: 30,
        childAspectRatio: MediaQuery.of(context).size.width > 768 ? 0.8 : .5,
      ),
      itemCount: teamMembers.length,
      itemBuilder: (context, index) {
        final member = teamMembers[index];
        return _buildTeamMemberCard(
          name: member['name']!,
          role: member['role']!,
        );
      },
    );
  }

  /// Team Member Card - matches your web .team-member styling
  Widget _buildTeamMemberCard({
    required String name,
    required String role,
  }) {
    return Container(
      // Matches .team-member styling
      decoration: BoxDecoration(
        color:
            AppColors.categoryBackground, // matches background-color: #f9f9f9
        borderRadius: BorderRadius.circular(10), // matches border-radius: 10px
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Member Image Placeholder (matches .member-image)
          Container(
            height: 200, // matches height: 270px (adjusted for mobile)
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors
                  .categoryIconBackground, // matches background-color: #e6f3f0
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: const Icon(
              Icons.person, // matches your web <i class="fas fa-user"></i>
              size: 80, // matches font-size: 100px (adjusted for mobile)
              color: AppColors.secondaryTeal, // matches color: #257180
            ),
          ),

          // Member Info (matches .member-info)
          Container(
            padding: const EdgeInsets.all(20), // matches padding: 20px
            decoration: const BoxDecoration(
              color: Colors.white, // matches background-color: #fff
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                // Member Name (matches .member-info h3)
                Text(
                  name,
                  style: AppTextStyles.teamMemberName,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10), // matches margin-bottom: 10px

                // Member Role (matches .member-info p)
                Text(
                  role,
                  style: AppTextStyles.teamMemberRole,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20), // matches margin-bottom: 20px

                // Social Links (matches .social-links)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialLink(Icons.link, 'LinkedIn'),
                    const SizedBox(width: 15), // matches gap: 15px
                    _buildSocialLink(Icons.alternate_email, 'Twitter'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Social Link - matches your web .social-links a styling
  Widget _buildSocialLink(IconData icon, String label) {
    return Container(
      width: 40, // matches width: 40px
      height: 40, // matches height: 40px
      decoration: const BoxDecoration(
        color: AppColors.secondaryTeal, // matches background-color: #257180
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  /// Contact Section - matches landing_about_contact.php exactly
  Widget _buildContactSection() {
    return Container(
      color: AppColors.backgroundColor, // matches background-color: #f9f9f9
      padding: const EdgeInsets.symmetric(
          vertical: 60, horizontal: 20), // matches padding: 60px 0
      child: Column(
        children: [
          // Section Title (matches .contact-section h2)
          Text(
            'Get In Touch',
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.secondaryTeal,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40), // matches margin-bottom: 40px

          // Contact Content (matches .contact-container)
          _buildContactContent(),
        ],
      ),
    );
  }

  /// Contact Content - matches your web contact container layout
  Widget _buildContactContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 768;

    if (isLargeScreen) {
      // Desktop Layout (matches your web flex layout)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Info (matches .contact-info)
          Expanded(child: _buildContactInfo()),
          const SizedBox(width: 30),
          // Contact Form (matches .contact-form)
          Expanded(child: _buildContactForm()),
        ],
      );
    } else {
      // Mobile Layout
      return Column(
        children: [
          _buildContactInfo(),
          const SizedBox(height: 30),
          _buildContactForm(),
        ],
      );
    }
  }

  /// Contact Info - matches your web .contact-info structure
  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(
          20), // matches padding: 30px (adjusted for mobile)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Description
          Text(
            'Have questions about our platform or interested in partnering with us? We\'d love to hear from you! Fill out the form or contact us directly using the information below.',
            style: AppTextStyles.bodyMedium,
          ),

          const SizedBox(height: 20), // matches margin-top: 20px

          // Contact Details (matches .contact-details)
          _buildContactItem(
            icon: Icons.location_on_outlined,
            title: 'Address',
            content: '123 General Trias, Cavite',
          ),

          const SizedBox(height: 20),

          _buildContactItem(
            icon: Icons.phone_outlined,
            title: 'Phone',
            content: '(555) 123-4567',
          ),

          const SizedBox(height: 20),

          _buildContactItem(
            icon: Icons.email_outlined,
            title: 'Email',
            content: 'info@thisable.com',
          ),
        ],
      ),
    );
  }

  /// Contact Item - matches your web .contact-item structure
  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      children: [
        // Contact Icon (matches .contact-item i)
        Container(
          width: 50, // matches width: 50px
          height: 50, // matches height: 50px
          decoration: const BoxDecoration(
            color: AppColors.secondaryTeal, // matches background-color: #257180
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24, // matches font-size: 24px
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 20), // matches margin-right: 20px

        // Contact Details (matches .contact-item div)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Title (matches .contact-item div h4)
              Text(
                title,
                style: AppTextStyles.formLabel.copyWith(
                  color: AppColors.secondaryTeal,
                ),
              ),

              const SizedBox(height: 5), // matches margin-bottom: 5px

              // Contact Content (matches .contact-item div p)
              Text(
                content,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Contact Form - matches your web .contact-form structure exactly
  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(
          20), // matches padding: 30px (adjusted for mobile)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _contactFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Form Title
            Text(
              'Send us a Message',
              style: AppTextStyles.cardTitle,
            ),

            const SizedBox(height: 20),

            // Name Field (matches your web #name)
            CustomTextField(
              label: 'Your Name',
              controller: _nameController,
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Email Field (matches your web #email)
            EmailField(
              label: 'Email Address',
              controller: _emailController,
              required: true,
            ),

            const SizedBox(height: 20),

            // Subject Field (matches your web #subject)
            CustomTextField(
              label: 'Subject',
              controller: _subjectController,
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Subject is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Message Field (matches your web #message)
            TextAreaField(
              label: 'Message',
              controller: _messageController,
              required: true,
              maxLines: 5,
            ),

            const SizedBox(height: 30),

            // Submit Button (matches your web submit button)
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Send Message',
                onPressed: _handleContactSubmit,
                type: CustomButtonType.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle Contact Form Submission - matches your web contact form submission
  void _handleContactSubmit() {
    if (!_contactFormKey.currentState!.validate()) {
      return;
    }

    // Simulate form submission (matches your web alert)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Thank you for your message! We will get back to you shortly.'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    // Reset form (matches your web this.reset())
    _contactFormKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _messageController.clear();
  }
}
