import 'package:bahya_app/data/models/service_models.dart';
import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:bahya_app/logic/state/patient_services_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientServicesCubit extends Cubit<PatientServicesState> {
  PatientServicesCubit(this.repo) : super(const PatientServicesState());

  final AppRepository repo;

  Future<void> loadMyRequests() async {
    if (isClosed) return;

    emit(state.copyWith(isLoading: true, hasLoaded: false, clearError: true));

    try {
      final requests = await repo.getMyServiceRequests();

      final hydratedRequests = await Future.wait(
        requests.map((request) async {
          final service = request.service;

          if (service == null || service.id.trim().isEmpty) {
            return request;
          }

          final hasFullCategory =
              service.category != null &&
              service.category!.iconKey.trim().isNotEmpty &&
              service.category!.color.trim().isNotEmpty;

          if (hasFullCategory) {
            return request;
          }

          try {
            final fullService = await repo.getServiceDetails(service.id);
            return request.copyWith(service: fullService);
          } catch (_) {
            return request;
          }
        }),
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          hasLoaded: true,
          requests: hydratedRequests,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      debugPrint('[PatientServices] my requests error: $e');

      emit(
        state.copyWith(
          isLoading: false,
          hasLoaded: true,
          error: 'حدث خطأ أثناء تحميل طلباتك.',
        ),
      );
    }
  }

Future<void> loadServices({required String categoryId, String? q}) async {
    if (isClosed) return;

    final selectedCategoryId = categoryId.trim();

    if (selectedCategoryId.isEmpty) {
      emit(
        state.copyWith(
          isLoading: false,
          hasLoaded: true,
          services: const [],
          categories: const [],
          requests: const [],
          error: 'لا توجد خدمات متاحة حالياً',
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, hasLoaded: false, clearError: true));

    try {
      final categories = await repo.getServiceCategories(isActive: true);
      if (isClosed) return;

      final allServices = await repo.getServices(
        status: 'ACTIVE',
        q: q,
        page: 1,
        pageSize: 100,
      );
      if (isClosed) return;

      final myRequests = await repo.getMyServiceRequests();
      if (isClosed) return;

      final requestedServiceIds = myRequests
          .where((request) {
            final status = request.status.trim().toUpperCase();
            return status != 'CANCELLED' && status != 'REJECTED';
          })
          .map((request) => request.service?.id.trim() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      final filteredServices = allServices.where((service) {
        final serviceCategoryId = service.categoryId.trim();
        final nestedCategoryId = service.category?.id.trim() ?? '';
        final status = service.status.trim().toUpperCase();

        return status == 'ACTIVE' &&
            (serviceCategoryId == selectedCategoryId ||
                nestedCategoryId == selectedCategoryId);
      }).toList();

      final sortedServices = [...filteredServices]
        ..sort((a, b) {
          final aRequested = requestedServiceIds.contains(a.id.trim());
          final bRequested = requestedServiceIds.contains(b.id.trim());

          if (aRequested == bRequested) return 0;
          return aRequested ? 1 : -1;
        });

      emit(
        state.copyWith(
          isLoading: false,
          hasLoaded: true,
          categories: categories,
          services: sortedServices,
          requests: myRequests,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      debugPrint('[PatientServices] loadServices error => $e');

      emit(
        state.copyWith(
          isLoading: false,
          hasLoaded: true,
          services: const [],
          requests: const [],
          error: 'حدث خطأ أثناء تحميل الخدمات.',
        ),
      );
    }
  }

  Future<void> requestService(
    String serviceId, {
    required String categoryId,
  }) async {
    if (isClosed) return;

    final alreadyRequested = state.requests.any((request) {
      return request.service?.id == serviceId &&
          request.status.toUpperCase() != 'CANCELLED' &&
          request.status.toUpperCase() != 'REJECTED';
    });

    if (alreadyRequested) {
      emit(state.copyWith(error: 'لقد قمت بطلب هذه الخدمة بالفعل.'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await repo.requestService(serviceId);
      if (isClosed) return;

      await loadServices(categoryId: categoryId);
    } catch (e) {
      if (isClosed) return;

      debugPrint('[PatientServices] requestService error => $e');

      emit(
        state.copyWith(
          isSubmitting: false,
          error: 'حدث خطأ أثناء إرسال طلب الانضمام.',
        ),
      );
    }
  }

  Future<void> cancelRequest(String requestId) async {
    if (isClosed) return;

    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await repo.cancelServiceRequest(requestId);
      if (isClosed) return;

      await loadMyRequests();
    } catch (e) {
      if (isClosed) return;

      debugPrint('[PatientServices] cancel request error: $e');

      emit(
        state.copyWith(
          isSubmitting: false,
          error: 'حدث خطأ أثناء إلغاء الطلب.',
        ),
      );
    }
  }
}
