import 'package:flutter/material.dart';
import 'package:task_continuation/db/table/task.dart';
import 'package:task_continuation/ui/page/task.dart';

import 'create_task.dart';

class TaskListPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return TaskListWidget();
  }
}

class TaskListWidget extends StatefulWidget {

  @override
  _TaskListWidgetState createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {

  List<Task> tasks = [];
  List<Task> achieves = [];
  int _currentIndex = 0;

  void _onItemTapped(int index) => setState(() => _currentIndex = index );

  @override
  void initState() {
    super.initState();
    reflectUpdate();
  }

  Future<void> reflectUpdate() async {
    var provider = TaskProvider();
    await provider.open();
    tasks = await provider.getNotAchievedTasks();
    achieves = await provider.getAchievedTasks();
    await provider.close();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('目標一覧'),
        centerTitle: true,
      ),
      body: [Container(
        margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
        child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 15.0),
            itemCount: tasks.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ListTile(
                      title: Text(tasks[index].task),
                      onTap: () {
                        // タスク詳細に遷移する
                        Navigator.push(context, MaterialPageRoute(builder:
                            (context) => TaskPage(task: tasks[index])))
                            .then((result) => reflectUpdate());
                      },
                    ),
                  ],
                ),
              );
            }
        ),
      ),
        Container(
          margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
          child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 15.0),
              itemCount: achieves.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      ListTile(
                        title: Text(achieves[index].task),
                        onTap: () {
                          // タスク詳細に遷移する
                          Navigator.push(context, MaterialPageRoute(builder:
                              (context) => TaskPage(task: achieves[index])))
                              .then((result) => reflectUpdate());
                        },
                      ),
                    ],
                  ),
                );
              }
          ),
        )
      ].elementAt(_currentIndex),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder:
              (context) => CreateTaskPage())).then((result) async => {
                reflectUpdate()
          });
        },
        child: Icon(Icons.add),
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: '目標'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: '達成済み'),
        ],
        currentIndex: _currentIndex,
        fixedColor: Colors.blueAccent,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}