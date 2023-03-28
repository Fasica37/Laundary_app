import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';

import 'contacts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late TextEditingController _controllerMessage = TextEditingController();
  String? _message, body;
  String _canSendSMSMessage = 'Check is not run.';
  final CollectionReference<Map<String, dynamic>> _customersDoc =
      FirebaseFirestore.instance.collection('Customers');

  bool isLoading = false;

  Future<bool> _canSendSMS() async {
    bool _result = await canSendSMS();
    setState(() => _canSendSMSMessage =
        _result ? 'This unit can send SMS' : 'This unit cannot send SMS');
    return _result;
  }

  Future<void> _checkPermission(List<String> recipients) async {
    Permission permission = Permission.sms;
    var status = await permission.status;
    if (status != PermissionStatus.granted) {
      final status = await permission.request();
      if (status == PermissionStatus.granted) {
        _sendSMS(recipients);
      }
    } else {
      _sendSMS(recipients);
    }
  }

  Future<void> _sendSMS(List<String> recipients) async {
    try {
      setState(() {
        isLoading = true;
      });
      String _result = await sendSMS(
        message: _controllerMessage.text,
        recipients: recipients,
        sendDirect: true,
      );

      setState(() {
        _message = _result;
        isLoading = false;
        _controllerMessage.clear();
      });
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }

  void _send(List<String> recipients) {
    if (recipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'At Least 1 Person or Message Required',
          textAlign: TextAlign.center,
        ),
      ));
    } else {
      _checkPermission(recipients);
    }
  }

  Widget _phoneTile(Map<String, dynamic> customer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Text(
                        customer['Name'],
                        textScaleFactor: 1,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                      ),
                      child: Text(
                        customer['Phone'],
                        textScaleFactor: 1,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await _customersDoc.doc(customer['id']).delete();
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Laundary'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.contacts,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(Contacts.route);
            },
          ),
        ],
      ),
      body: FirestoreQueryBuilder<Map<String, dynamic>>(
        query: _customersDoc,
        builder: (context, snapshot, _) {
          if (snapshot.isFetching || isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          }
          List<String> recipients = [];
          for (int i = 0; i < snapshot.docs.length; i++) {
            recipients.add(snapshot.docs[i].data()['Phone']);
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.message),
                      title: TextField(
                        decoration:
                            const InputDecoration(labelText: 'Add Message'),
                        controller: _controllerMessage,
                        onChanged: (String value) => setState(() {}),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Can send SMS'),
                      subtitle: Text(_canSendSMSMessage),
                      trailing: IconButton(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          _canSendSMS();
                        },
                      ),
                    ),
                    // SwitchListTile(
                    //     title: const Text('Send Direct'),
                    //     subtitle: const Text(
                    //         'Should we skip the additional dialog? (Android only)'),
                    //     value: sendDirect,
                    //     onChanged: (bool newValue) {
                    //       setState(() {
                    //         sendDirect = newValue;
                    //       });
                    //     }),
                    Container(
                      padding: const EdgeInsets.only(top: 30),
                      width: 250,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                              (states) =>
                                  Theme.of(context).colorScheme.secondary),
                          padding: MaterialStateProperty.resolveWith(
                            (states) => const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                        onPressed: () {
                          _send(recipients);
                        },
                        child: const Text(
                          'SEND',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ),
                    // Visibility(
                    //   visible: _message != null,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: <Widget>[
                    //       Expanded(
                    //         child: Padding(
                    //           padding: const EdgeInsets.all(12),
                    //           child: Text(
                    //             _message ?? 'No Data',
                    //             maxLines: null,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
              const Divider(
                height: 10,
                thickness: 2,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Contact List',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: Colors.blue,
                  ),
                ),
              ),
              if (snapshot.docs.isEmpty)
                const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text('No contacts added'),
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: List<Widget>.generate(snapshot.docs.length,
                          (int index) {
                        return _phoneTile(snapshot.docs[index].data());
                      }),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
