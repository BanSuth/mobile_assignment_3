import 'dart:convert';
//import 'dart:js_util';
//import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assign_3/calorieCalc.dart';
import 'package:mobile_assign_3/foodItem.dart';
import 'package:mobile_assign_3/calcEntry.dart'; //getting all the required packages
import 'package:flutter/material.dart';
import 'package:mobile_assign_3/homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_assign_3/DatabaseHelper.dart';

class calcDisplayHomePage extends StatefulWidget {
  const calcDisplayHomePage({super.key}); //starting the home page

  @override
  _calcDisplayHomePageState createState() => _calcDisplayHomePageState();
}

class _calcDisplayHomePageState extends State<calcDisplayHomePage> {
  //List<foodItem> items = [];

  List<calcEntry> filtered = [];
  List<calcEntry> items = []; //defining variables for the lists used in the program.
  late List<dynamic> calcList;

  late DatabaseHelper db; //getting DB
  TextEditingController dateController = TextEditingController(); //creating a controller for the date input



  @override
  void initState() { //called on start
    super.initState();
    db = DatabaseHelper.instance; //getting the db
    addEntries();
    _loadCalcs(); //getting and loading all the calculations
  }

  Future addEntries() async {
    await Future.delayed(const Duration(milliseconds: 100));
    List<dynamic> test = await db.queryAllRows();

    if (test.isNotEmpty) {
      return;
    }


    db.insert(foodItem(name: "Apple", calories: 59));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Banana", calories: 151));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Grapes", calories: 100));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Asparagus", calories: 27));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Broccoli", calories: 45));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Carrots", calories: 50));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Beef", calories: 142));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Chicken", calories: 136));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Tofu", calories: 86));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Egg", calories: 78));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Bread", calories: 75));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Butter", calories: 102));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "salad", calories: 481));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Cheeseburger", calories: 285));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Pizza", calories: 285));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Watermelon", calories: 50));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Pineapple", calories: 82));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Eggplant", calories: 35));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Shrimp", calories: 56));
    await Future.delayed(const Duration(milliseconds: 100));
    db.insert(foodItem(name: "Rice", calories: 206));
  }

    Future<void> _loadCalcs() async { //function to get the calculations from the DB

    calcList = await db.getCalcs(); //querying the db and getting the list of all the calculations made.
    //print(calcList);

    if(calcList != null){
      setState(() {
        items = calcList.map((calc) => calcEntry.fromMap(calc)).toList();
      });
    }

  }

  Future<void> filterEntry() async {  //function to filter the list of calculations based on the user selection .

    final text = dateController.text; //get the date from the data controller
    if(text.isEmpty){ //ensure it is not empty
      return;
    }

    var filteredList = calcList.where((val) => val["date"] == text); //search through the calculations and check the "date" field, and get the places it matches

    setState(() {
      filtered = filteredList.map((note) => calcEntry.fromMap(note)).toList(); //create a list based on filtered results
    });


  }
  Future<void> _saveEntry(calcEntry input) async { //function to save a calc entry into db.

    await db.insertCalc(input); //insert into DB, the user calculation. Uses a model class to make things easier

    await _loadCalcs(); //call load calcs again to update the entry list.

  }

  Future<void> _deleteEntry(calcEntry input) async { //function to delete an entry from db

    await db.deleteCalc(input.id!); //delete an entry using its "ID"

    await _loadCalcs(); //call load calcs again to update the entry list.

    await filterEntry(); //call load calcs again to update the filtered items.
  }

  Future<void> _updateEntry(calcEntry input) async { //function to update an entry from the db
    await db.updateCalc(input); //update calc, update information by passing model class (id remains the same, so everything else that changed will be updated).
    await _loadCalcs(); //call load calcs again to update the entry list.
  }

  Future<void> _getDate() async { //function for the date selection
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), //get today's date
        firstDate: DateTime(2000), //DateTime.now() - to not to allow to choose before today.
        lastDate: DateTime(2101)
    );

    if(pickedDate != null ){
        //get the picked date in the format => 2022-07-04 00:00:00.000
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
      //formatted date output using intl package =>  2022-07-04


      setState(() {
        dateController.text = formattedDate; //set formatted date to TextField value.
      });
    }else{
      print("Date is not selected");
    }
  }

  Map<String, int> occurence(String text) { //function to calculate how much of each item they selected.
    List<String> words = text.split(" ");


    Map<String, int> count = {};
    for (var word in words) {
      count.update(word, (value) => value + 1, ifAbsent: () => 1);
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calorie Calc App",
          style: TextStyle(
            fontSize: 30,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 2,
          actions: [
        PopupMenuButton<String>( //three dot menu to access the foodItemsPage
          onSelected: (String value) {
            setState(() async {
              await Navigator.push(
                context,
                MaterialPageRoute( //route to the foodItem page
                  builder: (context) => const foodItemsHomePage(),
                ),
              );
            });
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: '1',
              child: Text('Access Food Items'),
            )
          ],
        )
      ],
      ),
      body:  Padding(
          padding: const EdgeInsets.all(2.0),
          child: Wrap(
          spacing: 0, // to apply margin in the main axis of the wrap
          runSpacing: 0, // to apply margin in the cross axis of the wrap
          children: [TextField(
          controller: dateController, //editing controller of this TextField
          decoration: const InputDecoration(
              icon: Icon(Icons.calendar_today), //icon of text field
              labelText: "Enter Date" //label text of field
          ),
          readOnly: true,  // when true user cannot edit text, we want to use the date selector
          onTap: () async {
            await _getDate(); //when they click get the date

            await filterEntry(); //after getting a date filtering using that date
          }
      ),
      GridView.builder( //build the list of calculations
        shrinkWrap: true,
        padding: const EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( //defining sizes for the "cards" that display the entrys
          crossAxisCount: 1,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.height / 5),
        ),
        itemCount: filtered.isNotEmpty ? filtered.length : 1,
        itemBuilder: (context, index) {

          if(filtered.isNotEmpty){ //checking that the filtering list is NOT empty, other wise send a message
            final calcEntrys = filtered[index]; //get the filtered list entry for the current index
            List<dynamic> itemsData = jsonDecode(calcEntrys.items); //getting the List of Selected items via JSON.

            List<String> itemDisp = itemsData.map((note) => "${foodItem.fromJson(note).name}(${foodItem.fromJson(note).calories})").toList(); //from the JSON get specific food items and calorie info
            String itemText = "Items:${occurence(itemDisp.join(" "))}"; //create a string that holds the list of all the items in the calculation

            return  Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey)
              ),
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  _navigateToCalcScreen(index); //on tap function to edit an entry, passed the "index" of the item.
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date: ${calcEntrys.date}", //box to display the date
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Expanded(
                      child: Text(
                          "Total Calories: ${calcEntrys.total}", //box to display the total calories
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.visible,
                      ),
                    ),const SizedBox(height: 8.0),Expanded(
                      child: Text( //box to display the list of items
                        itemText,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row( //adding the delete button
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteEntryDialog(calcEntrys); //when the delete button is pressed, call the delete function
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );}
          else if (dateController.text.isNotEmpty) { // if the filtered list is empty, display a message to user
            return const Center(
              child: Column(
                children: <Widget>[
                  Text("No Entries Items Found. Try Another Date or add one the database")
                ],
              ),
            );
          }
        },
      ),])), floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () { //creating button to add a new entry to DB
        _navigateToCalcScreen(null);
      },
    ),
    );
  }


  void _navigateToCalcScreen(int? index) async { //function to navigate the calorie Calc Page

    final editedItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => calorieCalcHomePage( //routing the calorie calc page, if editing a entry pass the associated entry
          calc: index != null ? filtered[index] : null,
        ),
      ),
    );

    if (editedItem != null) { //if is evaled when the route returns.

      setState(() {
        if (index != null) { // if dealing with an update to an entry
          _updateEntry(editedItem);

          //items[index] = editedItem;

        } else { //if dealing with a new entry

          _saveEntry(editedItem); // Save notes locally
          //items.add(editedItem);
        }
      });
      await Future.delayed(const Duration(milliseconds: 200)); //waiting to entry the entries have been added to the DB

      await _loadCalcs(); //calling load and filter to update list
      await filterEntry();
    }


  }

  void _deleteEntryDialog(calcEntry item) { //function to show the delete dialog box , and call delete function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            width: 300.0, // Set the desired width
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Delete Item',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Are you sure you want to delete this item?',
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MaterialButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop(); //go back if they don't want to delete
                      },
                    ),
                    const SizedBox(width: 8.0),
                    MaterialButton(
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        setState(() {

                        });
                        _deleteEntry(item); // delete entry
                        Navigator.of(context).pop(); //go back to home page
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/*
class NoteScreen extends StatefulWidget {
  final foodItem? food;

  const NoteScreen({super.key, this.food});

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _textController;
  bool _validate1 = false;
  bool _validate2 = false;
  int? idEdit ;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.food?.name ?? '');
    _textController = TextEditingController(text:"${widget.food?.calories ?? ''}" );
    idEdit = widget.food?.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.food != null ? 'Edit Food Item' : 'Add Food Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  labelText: 'Food Name' ,
                  hintText: 'Food Name',
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                        width: 0.5, color: Colors.grey),
                  ),
                  errorText: _validate1 ? 'Value Cant Be Empty' : null
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              minLines: 1,
              maxLines: null,
              controller: _textController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Calories',
                hintText: 'Enter your food calories here',
                border: InputBorder.none,
                errorText: _validate2 ? 'Value Cant Be Empty' : null,

              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _titleController.text.isEmpty ? _validate1 = true : _validate1 = false;
              _textController.text.isEmpty ? _validate2 = true : _validate2 = false;
            });
            if (!(_validate1 || _validate2)){

              final editedFood = idEdit!=null ? foodItem(name: _titleController.text,calories: int.parse(_textController.text), id: idEdit) : foodItem(name: _titleController.text,calories: int.parse(_textController.text));
              Navigator.pop(context, editedFood);}
          },
          icon: const Icon(Icons.save),
          label: Text(widget.food != null ? 'Save' : 'Add'),
        ),
      ),
    );
  }


}
*/