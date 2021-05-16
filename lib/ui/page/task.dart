import 'package:flutter/material.dart';
import 'package:task_continuation/db/table/task.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:task_continuation/util/date_format.dart';

class TaskPage extends StatelessWidget {

  final Task task;

  TaskPage({@required this.task}) : super();

  @override
  Widget build(BuildContext context) {
    return TaskPageWidget(task: task);
  }
}

class TaskPageWidget extends StatefulWidget {

  final Task task;
  TaskPageWidget({@required this.task}) : super();
  
  @override
  _TaskPageWidgetState createState() => _TaskPageWidgetState(task: task);
}

class _TaskPageWidgetState extends State<TaskPageWidget> {

  final Task task;

  _TaskPageWidgetState({@required this.task}) : super();

  @override
  void initState() {
    super.initState();
    if (!task.achievement && task.continuousCount > 0) {
      var limit = task.lastDate.add(Duration(days: 2));
      if (DateTime.now().compareTo(limit) >= 0) {
        task.continuousCount = 0;
        reflectUpdate();
      }
    }
  }

  Future<void> deleteTask() async {
    var provider = TaskProvider();
    await provider.open();
    await provider.delete(task.id);
    await provider.close();
  }

  Future<void> reflectUpdate() async {
    var provider = TaskProvider();
    await provider.open();
    await provider.update(task);
    await provider.close();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var percent = task.continuousCount / task.targetCount;
    var todayDone = task.lastDate != null &&
        task.lastDate.formatToString() == DateTime.now().formatToString();
    return Scaffold(
      appBar: AppBar(
        title: Text('目標詳細'),
        centerTitle: true,
        actions: <Widget>[
          Visibility(
            visible: !task.achievement,
            child: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => setState(() {
                showDialog(context: context, builder: (_) {
                  return AlertDialog(
                    content: Text('この目標を削除しますか？'),
                      actions: <Widget>[
                        // ボタン領域
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await deleteTask();
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('削除する'),
                        ),
                      ]
                  );
                });
              })),
        ),],
      ),
      body: Center(child: Container(
          margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
          child: Column(
            children: [
              Text(
                  '目標',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25
                  )
              ),
              Padding(padding: EdgeInsets.all(10)),
              Text(task.task,
                  style: TextStyle(
                    fontSize: 25,
                  )),
              Padding(padding: EdgeInsets.all(10)),
              Visibility(
                  visible: todayDone,
                  child: Text('Done!'),
              ),
              Padding(padding: EdgeInsets.all(10)),
              CircularPercentIndicator(
                radius: 200.0,
                lineWidth: 7.0,
                percent: percent,
                center: Text('${task.continuousCount} / ${task.targetCount}'),
                progressColor: Colors.green,
              )
              ,
              Padding(padding: EdgeInsets.all(20)),
              Visibility(
                visible: !task.achievement && !todayDone,
                child: ButtonTheme(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        task.continuousCount += 1;
                        task.lastDate = DateTime.now();
                        task.achievement = task.continuousCount == task.targetCount;
                        await reflectUpdate();
                        return;
                      },
                      child: const Text('達成',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    )
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}