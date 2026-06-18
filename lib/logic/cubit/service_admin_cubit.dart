import 'package:bahya_app/data/models/service_models.dart';
import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:bahya_app/logic/state/service_admin_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiceAdminCubit extends Cubit<ServiceAdminState> {
  ServiceAdminCubit(this.repo) : super(const ServiceAdminState());

  final AppRepository repo;

  Future<void> loadPatientHomeData() async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final categories = await repo.getServiceCategories(isActive: true);

      final services = await repo.getServices(status: 'ACTIVE', pageSize: 100);

      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          categories: categories,
          services: services,
          selectedCategory:
              state.selectedCategory ??
              (categories.isNotEmpty ? categories.first : null),
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoading: false,
          categories: const [],
          services: const [],
          error: 'حدث خطأ أثناء تحميل الخدمات.',
        ),
      );
    }
  }

 Future<void> loadDashboard() async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final categories = await repo.getServiceCategories(isActive: true);
      final services = await repo.getServices(pageSize: 100);

      final pendingRequests = await repo.getServiceRequests(
        status: 'PENDING',
        pageSize: 100,
      );

      final allRequests = await repo.getServiceRequests(pageSize: 100);

      final summary = _buildSummary(allRequests);

      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          categories: categories,
          services: services,
          requests: pendingRequests,
          summary: summary,
          selectedCategory:
              state.selectedCategory ??
              (categories.isNotEmpty ? categories.first : null),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoading: false,
          error: 'حدث خطأ أثناء تحميل بيانات الخدمات.',
        ),
      );
    }
  }

  Map<String, dynamic> _buildSummary(List<ServiceRequestModel> requests) {
    int count(String status) {
      return requests
          .where((r) => r.status.trim().toUpperCase() == status)
          .length;
    }

    return {
      'total': requests.length,
      'pending': count('PENDING'),
      'approved': count('APPROVED'),
      'rejected': count('REJECTED'),
    };
  }

  Future<void> approveRequest(String requestId) async {
    if (isClosed) return;
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      await repo.approveServiceRequest(requestId);

      if (isClosed) return;

      emit(state.copyWith(isSaving: false));
      await loadDashboard();
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isSaving: false, error: 'حدث خطأ أثناء قبول الطلب.'));
    }
  }

  Future<void> rejectRequest(String requestId) async {
    if (isClosed) return;
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      await repo.rejectServiceRequest(requestId);

      if (isClosed) return;

      emit(state.copyWith(isSaving: false));
      await loadDashboard();
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isSaving: false, error: 'حدث خطأ أثناء رفض الطلب.'));
    }
  }
Future<void> loadPatientRequestsDetails() async {
    if (isClosed) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final requests = await repo.getServiceRequests(pageSize: 100);
      final services = await repo.getServices(pageSize: 100);

      final hydratedRequests = requests.map((request) {
        final requestServiceId = request.service?.id ?? '';

        final matchedService = services
            .where((service) {
              return service.id == requestServiceId;
            })
            .cast<PatientServiceModel?>()
            .firstOrNull;

        if (matchedService == null) return request;

        return request.copyWith(service: matchedService);
      }).toList();

      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          requests: hydratedRequests,
          services: services,
        ),
      );
    } catch (_) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          requests: const [],
          error: 'حدث خطأ أثناء تحميل طلبات المريضات.',
        ),
      );
    }
  }
  void selectCategory(ServiceCategoryModel? category) {
    if (isClosed) return;
    emit(state.copyWith(selectedCategory: category, clearError: true));
  }

  Future<void> createCategory({
    required String name,
    required String iconKey,
    required String color,
    required String kind,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      final category = await repo.createServiceCategory(
        kind: kind,
        name: name,
        iconKey: iconKey,
        color: color,
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          isSaving: false,
          categories: [category, ...state.categories],
          selectedCategory: category,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isSaving: false,
          error: e.toString().contains('Category name is already taken')
              ? 'اسم الكاتيجوري موجود بالفعل.'
              : 'حدث خطأ أثناء حفظ الكاتيجوري.',
        ),
      );
    }
  }

  Future<void> createService(Map<String, dynamic> data) async {
    if (isClosed) return;
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      final service = await repo.createService(data);

      if (isClosed) return;

      emit(
        state.copyWith(isSaving: false, services: [service, ...state.services]),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isSaving: false, error: 'حدث خطأ أثناء حفظ الخدمة.'));
    }
  }

  Future<void> updateService({
    required String serviceId,
    required Map<String, dynamic> data,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      final updatedService = await repo.updateService(
        serviceId: serviceId,
        data: data,
      );

      if (isClosed) return;

      final updatedServices = state.services.map((service) {
        return service.id == serviceId ? updatedService : service;
      }).toList();

      emit(state.copyWith(isSaving: false, services: updatedServices));
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(isSaving: false, error: 'حدث خطأ أثناء تعديل الخدمة.'),
      );
    }
  }

  
}
