import 'package:pureflow/core/exceptions/app_exception.dart';
import 'package:pureflow/core/models/contract.dart';
import 'package:pureflow/core/providers/supabase_provider.dart';
import 'package:pureflow/core/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'contract_service.g.dart';

@riverpod
ContractService contractService(ContractServiceRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ContractService(supabase);
}

class ContractService {
  final SupabaseClient _supabase;

  ContractService(this._supabase);

  Future<Contract> createContract({
    required String subscriptionId,
    required String fileUrl,
  }) async {
    try {
      final response = await _supabase
          .from('contracts')
          .insert({
            'subscription_id': subscriptionId,
            'file_url': fileUrl,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Contract.fromJson(response);
    } on PostgrestException catch (e) {
      log.e('Failed to create contract', error: e);
      throw AppException('Failed to create contract: ${e.message}');
    } catch (e) {
      log.e('Unexpected error creating contract', error: e);
      throw AppException('An unexpected error occurred');
    }
  }

  Future<Contract> getContract(String contractId) async {
    try {
      final response = await _supabase
          .from('contracts')
          .select()
          .eq('id', contractId)
          .single();

      return Contract.fromJson(response);
    } on PostgrestException catch (e) {
      log.e('Failed to get contract', error: e);
      throw AppException('Failed to get contract: ${e.message}');
    } catch (e) {
      log.e('Unexpected error getting contract', error: e);
      throw AppException('An unexpected error occurred');
    }
  }

  Future<List<Contract>> getUserContracts(String userId) async {
    try {
      final response = await _supabase
          .from('contracts')
          .select('*, subscriptions!inner(*)')
          .eq('subscriptions.user_id', userId)
          .order('created_at', ascending: false);

      return response.map((data) => Contract.fromJson(data)).toList();
    } on PostgrestException catch (e) {
      log.e('Failed to get user contracts', error: e);
      throw AppException('Failed to get contracts: ${e.message}');
    } catch (e) {
      log.e('Unexpected error getting user contracts', error: e);
      throw AppException('An unexpected error occurred');
    }
  }

  Future<void> signContract(String contractId) async {
    try {
      await _supabase
          .from('contracts')
          .update({
            'status': 'signed',
            'signed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', contractId);
    } on PostgrestException catch (e) {
      log.e('Failed to sign contract', error: e);
      throw AppException('Failed to sign contract: ${e.message}');
    } catch (e) {
      log.e('Unexpected error signing contract', error: e);
      throw AppException('An unexpected error occurred');
    }
  }
} 