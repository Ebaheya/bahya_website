part of 'reports_widgets.dart';

class ReportMobileCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onTap;

  const ReportMobileCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = report["status"].toString();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: responsiveHeight(context, 0.014, min: 10, max: 14),
      ),
      padding: EdgeInsets.all(responsiveSize(context, 0.012, min: 14, max: 18)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.012, min: 14, max: 18),
        ),
        border: Border.all(color: const Color(0xFFFFC6DD)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(
              text: report["title"].toString(),
              size: responsiveSize(context, 0.01, min: 15, max: 18),
              color: textColor,
              bold: true,
              isEnglish: true,
              isCenter: false,
              maxLines: 2,
            ),
            SizedBox(height: responsiveHeight(context, 0.01, min: 8, max: 10)),
            customText(
              text: "${report["reporter"]} • ${report["role"]}",
              size: responsiveSize(context, 0.008, min: 12, max: 14),
              color: Colors.grey,
              isEnglish: true,
              isCenter: false,
              maxLines: 1,
            ),
            SizedBox(
              height: responsiveHeight(context, 0.014, min: 10, max: 14),
            ),
            Row(
              children: [
                ReportStatusBadge(status: status),
                const Spacer(),
                ReportActionButton(title: "Resolve", onTap: onTap),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReportStatusBadge extends StatelessWidget {
  final String status;

  const ReportStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status.toUpperCase()) {
      case "PENDING":
      case "Pending":
        color = Colors.purple;
        break;
      case "INVESTIGATING":
      case "Investigating":
        color = Colors.blue;
        break;
      case "RESOLVED":
      case "Resolved":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.008, min: 9, max: 12),
        vertical: responsiveHeight(context, 0.006, min: 4, max: 6),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: customText(
        text: status,
        size: responsiveSize(context, 0.008, min: 12, max: 14),
        isEnglish: true,
        color: color,
      ),
    );
  }
}

class ReportActionButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const ReportActionButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.01, min: 10, max: 14),
          vertical: responsiveHeight(context, 0.007, min: 5, max: 7),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(20),
        ),
        child: customText(
          text: title,
          size: responsiveSize(context, 0.008, min: 12, max: 14),
          isEnglish: true,
          color: Colors.white,
        ),
      ),
    );
  }
}

class DialogActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const DialogActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: responsiveHeight(context, 0.055, min: 42, max: 48),
        decoration: BoxDecoration(
          gradient: isPrimary ? LinearGradient(colors: gradientColors) : null,
          color: isPrimary ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary ? Colors.transparent : const Color(0xFFFFC6DD),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: responsiveSize(context, 0.01, min: 16, max: 18),
              color: isPrimary ? Colors.white : const Color(0xFFE83E8C),
            ),
            SizedBox(width: responsiveSize(context, 0.006, min: 6, max: 10)),
            customText(
              text: title,
              size: responsiveSize(context, 0.008, min: 12, max: 15),
              color: isPrimary ? Colors.white : const Color(0xFFE83E8C),
              bold: true,
              isEnglish: true,
            ),
          ],
        ),
      ),
    );
  }
}

final reports = [
  {
    "role": "Doctor",
    "reporter": "Sarah Johnson",
    "email": "sarah.johnson@email.com",
    "title": "Content Report",
    "body":
        "The patient reported that some content contains inappropriate language and needs to be reviewed by the admin team.",
    "date": "2024-04-26",
    "status": "Pending",
  },
  {
    "role": "Patient",
    "reporter": "James Martinez",
    "email": "james.martinez@email.com",
    "title": "Technical Issue",
    "body":
        "Chat page is not loading correctly after login. The user tried refreshing the page but the issue still appears.",
    "date": "2024-04-26",
    "status": "Completed",
  },
  {
    "role": "Volunteer",
    "reporter": "Emma Williams",
    "email": "emma.williams@email.com",
    "title": "User Behavior",
    "body":
        "There is a harassment concern reported during interaction with another user. Needs investigation.",
    "date": "2024-04-25",
    "status": "Pending",
  },
  {
    "role": "Admin",
    "reporter": "John Davis",
    "email": "john.davis@email.com",
    "title": "Bug Report",
    "body":
        "Payment confirmation button is not responding. The user cannot complete the request flow.",
    "date": "2024-04-25",
    "status": "Investigating",
  },
];
