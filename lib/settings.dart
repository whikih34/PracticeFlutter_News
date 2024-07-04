import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key});

  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  double _sliderValue = 0;
  bool checked = false;
  bool switchValue = false;
  String email = '';

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding:  const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Scrollbar(
            child: Align(
              alignment: Alignment.topCenter,
              child: Card(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ...[
                          TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.person),
                              hintText: 'Enter your ID',
                              labelText: 'ID',
                            ),
                            onChanged: (value) { print(value); },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              icon: Icon(Icons.lock),
                              hintText: 'Enter your Password',
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscureText,
                            onChanged: (value) { print(value); },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              icon: Icon(Icons.email),
                              hintText: 'Enter your Email',
                              labelText: 'Email',
                            ),
                            maxLength: 300,
                            maxLines: 5,
                            onChanged: (value) {
                              email = value;
                            },
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Slide Bar', style: Theme.of(context).textTheme.titleMedium,),
                                ],
                              ),
                              Text('${_sliderValue.toInt()}'),
                              Slider(
                                min: 0,
                                max: 500,
                                divisions: 500,
                                value: _sliderValue,
                                onChanged: (value) {
                                  // Text 필드를 상태 변경
                                  setState(() {
                                    _sliderValue = value;  // 현재 슬라이더 값 변경
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: checked,
                                onChanged: (value) {
                                  setState(() {
                                    checked = value!;
                                  });
                                },
                              ),
                              Text((checked) ? '체크됨' : '체크안됨'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Switch(
                                value: switchValue,
                                onChanged: (value) {
                                  setState(() {
                                    switchValue = value;
                                  });
                                }
                              ),
                              Text((switchValue) ? '켜짐' : '꺼짐'),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}