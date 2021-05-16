import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_continuation/db/table/task.dart';

class CreateTaskPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return CreateTaskPageWidget();
  }
}

class CreateTaskPageWidget extends StatefulWidget {

  @override
  _CreateTaskPageWidgetState createState() => _CreateTaskPageWidgetState();
}

FormFieldValidator _requiredValidator(BuildContext context) => (val) => val.isEmpty ? '必須' : null;

class _CreateTaskPageWidgetState extends State<CreateTaskPageWidget> {

  final GlobalKey _taskKey = GlobalKey();
  final GlobalKey _daysKey = GlobalKey();
  var taskEditingController = TextEditingController(text: '');
  var daysEditingController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新規目標設定'),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
        child: Column(
            children: [
              Form(
                key: _taskKey,
                child: TextFormField(
                  decoration: InputDecoration(border: OutlineInputBorder(), labelText: '目標'),
                  controller: taskEditingController,
                  validator: _requiredValidator(context),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                ),
              ),
              Padding(padding: EdgeInsets.all(15)),
              Form(
                key: _daysKey,
                child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '継続日数',
                      counterText: ''
                    ),
                    controller: daysEditingController,
                    validator: _requiredValidator(context),
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ]
                ),
              ),
              Padding(padding: EdgeInsets.all(15)),
              ButtonTheme(
                height: 50,
                  child:  ElevatedButton(
                    onPressed: () async {
                      if (taskEditingController.text.isEmpty || daysEditingController.text.isEmpty) {
                        return;
                      }
                      var map = <String, Object>{
                        columnId: null,
                        columnTask: taskEditingController.text,
                        columnContinuousCount: 0,
                        columnTargetCount: int.parse(daysEditingController.text),
                        columnLastDate: null,
                        columnAchievement: false
                      };
                      var provider = TaskProvider();
                      await provider.open();
                      await provider.insert(Task.fromMap(map));
                      await provider.close();
                      Navigator.pop(context, true);
                      return;
                    },
                    child: const Text('設定',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  )
              ),
            ]
        ),
      ),
    );
  }
}