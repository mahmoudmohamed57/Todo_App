import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:todo/shared/cubit/cubit.dart';
import 'package:todo/shared/cubit/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/shared/components/components.dart';

var scaffoldKey = GlobalKey<ScaffoldState>();
var formKey = GlobalKey<FormState>();
var titleController = TextEditingController();
var timeController = TextEditingController();
var dateController = TextEditingController();

class HomeLayout extends StatelessWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
            timeController.text = '';
            titleController.text = '';
            dateController.text = '';
          }
        },
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.curIndex],
              ),
              centerTitle: true,
            ),
            body: cubit.screens[cubit.curIndex],
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetSown) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertToDatabase(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text,
                    );
                  }
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) => Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                  controller: titleController,
                                  type: TextInputType.text,
                                  message: 'title must not be empty',
                                  label: 'Task Title',
                                  prefix: Icons.title,
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                defaultFormField(
                                  controller: timeController,
                                  type: TextInputType.datetime,
                                  message: 'time must not be empty',
                                  label: 'Task Time',
                                  prefix: Icons.watch_later_outlined,
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then((value) {
                                      timeController.text =
                                          value!.format(context).toString();
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                defaultFormField(
                                  controller: dateController,
                                  type: TextInputType.datetime,
                                  message: 'date must not be empty',
                                  label: 'Task Date',
                                  prefix: Icons.calendar_today,
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2022-12-30'),
                                    ).then((value) {
                                      dateController.text = DateFormat.yMMMd()
                                          .format(value!)
                                          .toString();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        elevation: 20.0,
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(
                      false,
                      Icons.edit,
                    );
                  });
                  cubit.changeBottomSheetState(
                    true,
                    Icons.add,
                  );
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: cubit.curIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'New_Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline),
                  label: 'Done Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined),
                  label: 'Archived Tasks',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
