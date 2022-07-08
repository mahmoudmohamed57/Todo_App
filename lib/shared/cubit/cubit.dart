import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/shared/cubit/states.dart';
import 'package:todo/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo/modules/new_tasks/new_tasks_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);
  int curIndex = 0;
  bool isBottomSheetSown = false;
  IconData fabIcon = Icons.edit;
  late Database database;
  List<Map> newTasks = [], doneTasks = [], archiveTasks = [];
  List<Widget> screens = [
    const NewTasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen(),
  ];
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void createDatabase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) {
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, date TEXT, time TEXT, status TEXT)')
          .then((value) {})
          .catchError((onError) {
        if (kDebugMode) {
          print('Error When Creating Table ${onError.toString()}');
        }
      });
    }, onOpen: (database) {
      getFromDatabase(database);
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  void insertToDatabase({
    required String title,
    required String date,
    required String time,
  }) async {
    await database.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
          .then((value) {
        emit(AppInsertDatabaseState());
        getFromDatabase(database);
      }).catchError((onError) {
        if (kDebugMode) {
          print('Error When Inserting New Record ${onError.toString()}');
        }
      });
    });
  }

  void getFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archiveTasks = [];
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archiveTasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  void updateDatabase({
    required String status,
    required int id,
  }) {
    database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      [status, id],
    ).then((value) {
      getFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteDatabase({
    required int id,
  }) {
    database.rawDelete(
      'DELETE FROM tasks WHERE id = ?',
      [id],
    ).then((value) {
      getFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  void changeIndex(int index) {
    curIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void changeBottomSheetState(bool isShow, IconData icon) {
    isBottomSheetSown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }
}
