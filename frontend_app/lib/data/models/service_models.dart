class ServiceCategoryModel {
  final String id;
  final String name;
  final String kind;
  final String iconKey;
  final String color;
  final bool isActive;

  const ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.kind,
    required this.iconKey,
    required this.color,
    required this.isActive,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawIsActive = json['isActive'];
    final rawStatus = json['status']?.toString().toUpperCase();

    return ServiceCategoryModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      kind: json['kind']?.toString().toUpperCase() ?? 'OTHER',
      iconKey: json['iconKey']?.toString() ?? 'category',
      color: json['color']?.toString() ?? '#EA4C89',
      isActive:
          rawIsActive == true ||
          rawIsActive?.toString().toLowerCase() == 'true' ||
          rawStatus == 'ACTIVE' ||
          rawIsActive == null,
    );
  }
}

class PatientServiceModel {
  final String id;
  final String categoryId;
  final ServiceCategoryModel? category;
  final String title;
  final String description;
  final String location;
  final String date;
  final String? endDate;
  final String time;
  final String? departureTime;
  final String? meetingPlace;
  final int capacity;
  final int seatsTaken;
  final int remainingSeats;
  final String status;

  const PatientServiceModel({
    required this.id,
    required this.categoryId,
    this.category,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    this.endDate,
    required this.time,
    this.departureTime,
    this.meetingPlace,
    required this.capacity,
    required this.seatsTaken,
    required this.remainingSeats,
    required this.status,
  });

  factory PatientServiceModel.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'] ?? json['serviceCategory'];
    final category = categoryJson is Map<String, dynamic>
        ? ServiceCategoryModel.fromJson(categoryJson)
        : null;
    final capacity = int.tryParse(json['capacity']?.toString() ?? '') ?? 0;
    final seatsTaken = int.tryParse(json['seatsTaken']?.toString() ?? '') ?? 0;

    return PatientServiceModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      categoryId:
          (json['categoryId'] ??
                  json['serviceCategoryId'] ??
                  json['category_id'] ??
                  json['service_category_id'] ??
                  category?.id ??
                  '')
              .toString(),
      category: category,
      title: (json['name'] ?? json['title'] ?? '').toString(),
      description: json['description']?.toString() ?? '',
      location: (json['locationBranch'] ?? json['location'] ?? '').toString(),
      date: (json['startDate'] ?? json['date'] ?? '').toString(),
      endDate: json['endDate']?.toString(),
      time: (json['startTime'] ?? json['time'] ?? '').toString(),
      departureTime: json['departureTime']?.toString(),
      meetingPlace: json['meetingPlace']?.toString(),
      capacity: capacity,
      seatsTaken: seatsTaken,
      remainingSeats:
          int.tryParse(json['remainingSeats']?.toString() ?? '') ??
          (capacity - seatsTaken),
      status: json['status']?.toString() ?? 'ACTIVE',
    );
  }
}

class ServiceRequestModel {
  final String id;
  final String status;
  final String requestDate;
  final String patientName;
  final String medicalNumber;
  final PatientServiceModel? service;

  const ServiceRequestModel({
    required this.id,
    required this.status,
    required this.requestDate,
    required this.patientName,
    required this.medicalNumber,
    this.service,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    final serviceJson = json['service'];
    final patientJson = json['patient'] ?? json['user'];

    return ServiceRequestModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      requestDate:
          (json['requestDate'] ?? json['createdAt'] ?? json['created_at'] ?? '')
              .toString(),
      patientName: patientJson is Map<String, dynamic>
          ? (patientJson['name'] ??
                    patientJson['fullName'] ??
                    patientJson['displayName'] ??
                    '')
                .toString()
          : (json['patientName'] ?? '').toString(),
      medicalNumber: patientJson is Map<String, dynamic>
          ? (patientJson['medicalNumber'] ??
                    patientJson['crn'] ??
                    patientJson['medicalRecordNumber'] ??
                    '')
                .toString()
          : (json['medicalNumber'] ?? json['crn'] ?? '').toString(),
      service: serviceJson is Map<String, dynamic>
          ? PatientServiceModel.fromJson(serviceJson)
          : null,
    );
  }
}
