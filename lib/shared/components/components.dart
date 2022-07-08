import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo/shared/cubit/cubit.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  required String label,
  required String message,
  required IconData prefix,
  IconData? suffix,
  Function(String)? onSubmit,
  Function(String)? onChanged,
  Function()? onTap,
  bool showPassword = false,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      onFieldSubmitted: onSubmit,
      onChanged: onChanged,
      onTap: onTap,
      obscureText: showPassword,
      validator: (value) {
        if (value!.isEmpty) {
          return message;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefix),
        suffixIcon: suffix != null ? Icon(suffix) : null,
        border: const OutlineInputBorder(),
      ),
    );

Widget buildTaskItem(Map model, BuildContext context) => Dismissible(
      key: Key(model['id'].toString()),
      onDismissed: (direction) {
        AppCubit.get(context).deleteDatabase(
          id: model['id'],
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40.0,
              child: Text(
                '${model['time']}',
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['title']}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${model['date']}',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateDatabase(
                  status: 'done',
                  id: model['id'],
                );
              },
              icon: const Icon(
                Icons.check_box,
                color: Colors.lightGreenAccent,
              ),
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateDatabase(
                  status: 'archive',
                  id: model['id'],
                );
              },
              icon: const Icon(
                Icons.archive,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );

Widget taskBuilder({
  required List<Map> tasks,
}) =>
    ConditionalBuilder(
      condition: tasks.isNotEmpty,
      builder: (context) => ListView.separated(
        itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
        separatorBuilder: (context, index) => Container(
          height: 1,
          width: double.infinity,
          color: Colors.grey[300],
        ),
        itemCount: tasks.length,
      ),
      fallback: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.menu,
              size: 100.0,
              color: Colors.grey,
            ),
            Text(
              'No Tasks Yet, Please Add Some Tasks',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
