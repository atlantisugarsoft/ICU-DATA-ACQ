import 'package:flutter/material.dart';
import 'package:hospital_app/hospitalwidgets/settings.dart';
import 'package:hospital_app/providers/passwordprovider.dart';
import 'package:provider/provider.dart';

class PassWord extends StatefulWidget {
  const PassWord({super.key});

  @override
  State<PassWord> createState() => _PassWordState();
}

class _PassWordState extends State<PassWord> {
  String enteredPassword = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late PasswordProvider _passwordProvider;

  @override
  void initState() {
    super.initState();
    _passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
    _passwordProvider.retrievePassword();
    print('hello');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlantis-UgarSoft'),
      ),
      body: Center(
        child: AlertDialog(
          title: Text('Enter Password'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              obscureText: true,
              onChanged: (value) {
                enteredPassword = value;
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a password';
                }
                if (value != context.read<PasswordProvider>().storedPassword) {
                  return 'Invalid Password';
                }
                // Add additional validation logic here if needed
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                context.read<PasswordProvider>().retrievePassword();
                print(context.read<PasswordProvider>().storedPassword);
                if (_formKey.currentState!.validate()) {
                  if (enteredPassword ==
                      context.read<PasswordProvider>().storedPassword) {
                    //Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HospitalSettings()),
                    );

                    print('Correct');
                  } else {
                    // Incorrect password, show an error message
                    print('Incorect password');
                    // You can use a SnackBar or another AlertDialog to display the error.
                    // ScaffoldMessenger.of(context).showSnackBar(
                    // const SnackBar(
                    //  content: Text('Incorrect password'),
                    //),
                    //);
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
