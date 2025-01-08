import 'dart:developer';

import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:todo_app/application/user_provider.dart';
import 'package:todo_app/infrastructure/models/todo.dart';
import 'package:todo_app/infrastructure/services/todo.dart';
import 'package:todo_app/presentation/elements/app_button.dart';
import 'package:todo_app/presentation/elements/custom_appbar.dart';

import '../../../../configurations/frontend_configs.dart';
import '../../../elements/todo_tile.dart';

class SearchByDatesBody extends StatefulWidget {
  const SearchByDatesBody({super.key});

  @override
  State<SearchByDatesBody> createState() => _SearchByDatesBodyState();
}

class _SearchByDatesBodyState extends State<SearchByDatesBody> {
  DateTime? _startDate;
  DateTime? _endDate;

  List<TodoModel>? _searchedTodos = [];

  _searchByDates() async{
    setState(() {
      _searchedTodos=null;
    });
    String startDate = _startDate.toString().split(' ')[0];
    log(('Start: $startDate'));
    _endDate ??= _startDate;
    String endDate = _endDate.toString().split(' ')[0];
    log(('End: $endDate'));

    await TodoServices().searchTodosByDates(Provider.of<UserProvider>(context, listen: false).getUser!.token!, startDate, endDate).then((val){
      if(val!=null){
       setState(() {
         _searchedTodos = val;
       });
      }else{
        floatingSnackBar(message: 'An unexpected error occurred while searching. Please try again later.', context: context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FrontendConfigs.whiteColor,
      appBar: customAppBar(
        title: 'Search by dates',
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            // Date Picker Widget
            SfDateRangePicker(
              selectionColor: FrontendConfigs.kAppPrimaryColor,
              headerHeight: 60,
              selectionMode: DateRangePickerSelectionMode.range,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                setState(() {
                  // Extract the start and end dates from the range
                  if (args.value is PickerDateRange) {
                    _startDate = args.value.startDate;
                    _endDate = args.value.endDate;
                    log('_startDate: $_startDate');
                    log('_endDate: $_endDate');
                  }
                });
              },
            ),
            const Divider(height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  AppButton(
                      onPressed: () {
                        if(_startDate!=null) {
                          _searchByDates();
                        }else{
                          floatingSnackBar(message: 'Please select a start date.', context: context);
                        }
                      },
                      child: const Text('Search')),
                  _searchedTodos == null
                      ? const SizedBox(
                          height: 200,
                          child: Center(
                              child: CircularProgressIndicator(
                            color: FrontendConfigs.kAppPrimaryColor,
                          )))
                      : Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _searchedTodos!.length,
                            itemBuilder: (context, index) {
                              final todo = _searchedTodos![index];
                              return TodoTile(
                                todo: todo,
                              );
                            }),
                      )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
