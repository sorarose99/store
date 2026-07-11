import 'package:flutter/material.dart';

class SendGiftPage extends StatefulWidget {
  final Map<String, dynamic>? initialGiftDetails;

  const SendGiftPage({super.key, this.initialGiftDetails});

  @override
  _SendGiftPageState createState() => _SendGiftPageState();
}

class _SendGiftPageState extends State<SendGiftPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _wrapGift = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialGiftDetails != null) {
      _nameController.text = widget.initialGiftDetails!['recipientName'] ?? '';
      _phoneController.text = widget.initialGiftDetails!['recipientPhone'] ?? '';
      _messageController.text = widget.initialGiftDetails!['message'] ?? '';
      _wrapGift = widget.initialGiftDetails!['wrap'] ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الهدية')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'اسم المستلم')),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'رقم الجوال')),
            TextField(controller: _messageController, decoration: const InputDecoration(labelText: 'رسالة الهدية')),
            CheckboxListTile(
              title: const Text('تغليف الهدية (+15.0 ر.س)'),
              value: _wrapGift,
              onChanged: (val) => setState(() => _wrapGift = val ?? false),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'recipientName': _nameController.text,
                  'recipientPhone': _phoneController.text,
                  'message': _messageController.text,
                  'wrap': _wrapGift,
                });
              },
              child: const Text('حفظ'),
            )
          ],
        ),
      ),
    );
  }
}
