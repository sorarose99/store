import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../checkout/domain/entities/checkout_entities.dart';
import '../blocs/address_bloc.dart';
import '../blocs/address_event.dart';
import '../blocs/address_state.dart';
import 'add_address_page.dart';

class DeliveryAddressesPage extends StatefulWidget {
  const DeliveryAddressesPage({super.key});

  @override
  State<DeliveryAddressesPage> createState() => _DeliveryAddressesPageState();
}

class _DeliveryAddressesPageState extends State<DeliveryAddressesPage> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(LoadAddresses());
  }

  void _navigateToAddAddress([SavedAddressEntity? address]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddAddressPage(addressToEdit: address),
      ),
    );
  }

  void _deleteAddress(String id) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف العنوان', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('هل أنت متأكد من رغبتك في حذف هذا العنوان؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textGrey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<AddressBloc>().add(DeleteAddress(id));
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'عناوين التوصيل',
            style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocConsumer<AddressBloc, AddressState>(
          listener: (context, state) {
            if (state is AddressActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is AddressActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is AddressLoading || state is AddressInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            List<SavedAddressEntity> addresses = [];
            if (state is AddressLoaded) {
              addresses = state.addresses;
            } else if (state is AddressActionLoading || state is AddressActionSuccess || state is AddressActionError) {
              // If we are in an action state, we should ideally keep the old list,
              // but standard bloc pattern might lose it unless we cache it or it's part of the state.
              // For now, if we are in ActionLoading we can show a loader.
              if (state is AddressActionLoading) {
                return const Center(child: CircularProgressIndicator());
              }
            }

            if (addresses.isEmpty && state is AddressLoaded) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final addr = addresses[index];
                      return _buildAddressCard(addr);
                    },
                  ),
                ),
                _buildAddButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.location_on_outlined, size: 60, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد عناوين توصيل',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'لم تقم بإضافة أي عنوان توصيل بعد. يرجى إضافة عنوانك لتسهيل عملية الشحن وتوصيل طلباتك.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.5),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _navigateToAddAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text(
                  'إضافة عنوان جديد',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(SavedAddressEntity address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault ? AppColors.primary : const Color(0xFFEEEEEE),
          width: address.isDefault ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    address.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                  ),
                ],
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'الافتراضي',
                    style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${address.fullName}\n${address.detailedAddress.isNotEmpty ? address.detailedAddress : address.city}',
            style: const TextStyle(fontSize: 13, color: AppColors.textMid, height: 1.5),
          ),
          if (address.phone.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: AppColors.textGrey),
                const SizedBox(width: 6),
                Text(
                  address.phone,
                  style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFEEEEEE), height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _navigateToAddAddress(address),
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                label: const Text('تعديل', style: TextStyle(fontSize: 13, color: AppColors.primary)),
              ),
              TextButton.icon(
                onPressed: () => _deleteAddress(address.id),
                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                label: const Text('حذف', style: TextStyle(fontSize: 13, color: Colors.red)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _navigateToAddAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: const Text(
            'إضافة عنوان جديد',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
