import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:pureflow/core/models/subscription.dart';
import 'package:pureflow/features/contracts/providers/contract_provider.dart';
import 'package:pureflow/shared/widgets/error_text.dart';

class ContractSignScreen extends HookConsumerWidget {
  final String contractId;
  final String pdfUrl;
  
  const ContractSignScreen({
    super.key, 
    required this.contractId,
    required this.pdfUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final signatureKey = useMemoized(() => GlobalKey<SfSignaturePadState>());
    final hasSignature = useState(false);
    final errorMsg = useState<String?>(null);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Contract'),
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: SfPdfViewer.network(
                    pdfUrl,
                    onDocumentLoadFailed: (details) {
                      errorMsg.value = 'Failed to load document: ${details.error}';
                    },
                  ),
                ),
                if (errorMsg.value != null)
                  ErrorText(errorMsg.value!),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Please sign below to confirm your agreement',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Container(
                  height: 200,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SfSignaturePad(
                    key: signatureKey,
                    minimumStrokeWidth: 1,
                    maximumStrokeWidth: 3,
                    strokeColor: Colors.black,
                    backgroundColor: Colors.white,
                    onDrawStart: () {
                      hasSignature.value = true;
                      return true;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          signatureKey.currentState?.clear();
                          hasSignature.value = false;
                        },
                        child: const Text('Clear'),
                      ),
                      ElevatedButton(
                        onPressed: !hasSignature.value
                            ? null
                            : () async {
                                try {
                                  isLoading.value = true;
                                  errorMsg.value = null;
                                  
                                  // Get signature image
                                  final signatureData = await _getSignatureData(signatureKey);
                                  if (signatureData == null) {
                                    errorMsg.value = 'Failed to process signature';
                                    isLoading.value = false;
                                    return;
                                  }
                                  
                                  // Upload signature and sign contract
                                  await ref.read(contractProviderProvider.notifier)
                                      .signContract(contractId);
                                      
                                  if (context.mounted) {
                                    // Navigate to dashboard or confirmation screen
                                    context.go('/dashboard');
                                  }
                                } catch (e) {
                                  errorMsg.value = e.toString();
                                  isLoading.value = false;
                                }
                              },
                        child: const Text('Sign & Submit'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
  
  Future<String?> _getSignatureData(GlobalKey<SfSignaturePadState> key) async {
    try {
      final signatureData = await key.currentState?.toImage();
      if (signatureData == null) return null;
      
      final bytes = await signatureData.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return null;
      
      final encoded = base64Encode(bytes.buffer.asUint8List());
      return encoded;
    } catch (e) {
      return null;
    }
  }
} 