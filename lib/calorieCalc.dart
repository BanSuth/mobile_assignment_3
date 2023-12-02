import 'dart:convert';
import 'package:mobile_assign_3/foodItem.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:mobile_assign_3/DatabaseHelper.dart';
import 'package:mobile_assign_3/calcEntry.dart';


class calorieCalcHomePage extends StatefulWidget {

  final calcEntry? calc;

  const calorieCalcHomePage({super.key,this.calc});

  @override
  _calorieCalcHomePageState createState() => _calorieCalcHomePageState();
}

class _calorieCalcHomePageState extends State<calorieCalcHomePage> {

  List<foodItem> cartItems = [];
  List<foodItem> filtered = []; //defining variables for the lists used in the program.
  late List<dynamic> foodList= [];
  late List<dynamic> temp= [];

  int totalCal = 0;
  int maxCal = 0; //defining the variables used globally in the program.



  String? itemsJson; //defining string object that holds the JSON of a food item
  TextEditingController myController = TextEditingController(); //defining the text controllers
  TextEditingController dateController = TextEditingController();

  late DatabaseHelper db; //defining DB var, that i used for the whole program

  String _Text1 = "Please select a date and target calorie range"; //defining text variables used to display information to the user
  String _Text2 = "";

  int? idEdit ; //variable used to see if the user it editing or creating a new entry.

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper.instance; //getting the DB

    dateController = TextEditingController(text: widget.calc?.date ?? ''); //defining controllers with data ONLY IF editing existing entry, else leave blank
    myController = TextEditingController(text:"${widget.calc?.total ?? ''}");
    idEdit = widget.calc?.id; //setting value for idEDIT, can be null

    _loadItems(); //loading the food items into the program

    if(idEdit != null){  //if NOT null, then editing an entry else creating an entry
      _Filter(); //call the filter function, as we are editing an existing entry
      totalCal = widget.calc!.total; //Setting totalCal variable
      _Text1="Current Calorie total: $totalCal, Calories Remaining to add: 0"; //setting text to display to user
      _Text2="";
    }


    myController.addListener(_Filter); //creating listener for the program
  }

  Future<void> _resetVal() async{ //function to reset the global values of the program
    setState(() {
    cartItems = [];
    filtered = [];
    totalCal = 0;
    dateController.text = "";
    myController.text = "";
    _Text1 = "Please select a date and calorie range";
    _Text2 = "";
    });
  }


  Future<void> _Filter() async { //function to filter the list of food items based on the user calorie target .

    maxCal = 0; //reseting the target calories
    final text = myController.text;

    if(text.isEmpty){ //ensuring that calorie filed is not empty if it is return
      return;
    }

    await Future.delayed(const Duration(milliseconds: 100)); //waiting 100ms to ensure that DB is updated (used for async calls)

    var filteredList = foodList.where((val) => val["calories"] <= int.parse(text)); //searching the food list to find items that mach the criteria
    setState(() {
      filtered = filteredList.map((note) => foodItem.fromJson(note)).toList(); //create the filtered list based on the search results.
      maxCal = int.parse(text); //setting the max calories
    });


  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    myController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _loadItems()  async { //function to get the food items from the DB

    foodList = await db.queryAllRows() ; //querying the db and getting the list of all the food items.

    if(idEdit != null){ //if for when editing an existing list. populating the items in the "cart"
      List<dynamic> itemsData = jsonDecode(widget.calc!.items);
      setState(() {
        cartItems = itemsData.map((note) => foodItem.fromJson(note)).toList();
      });

    }

  }

  Future<void> _saveCalc() async { //function to save a calc entry into db.
    //creating a calcEntry Model to send back, if editing an existing entry add the ID field if not DONT.
    calcEntry input = idEdit!=null ? calcEntry(date: dateController.text, total: totalCal, items: jsonEncode(cartItems), id: idEdit): calcEntry(date: dateController.text, total: totalCal, items: jsonEncode(cartItems));

    Navigator.pop(context, input); //go back to calc display page to handle saving into the DB

  }

  Future<void> _getDate() async { //function for the date selection
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), //get today's date
        firstDate: DateTime.now(), //DateTime.now() - to not to allow to choose before today.
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

  @override
  Widget build(BuildContext context) {

    var title = widget.calc != null ? 'Edit Existing Calc Entry' : 'Calorie Calculation'; //setting the app bar title based on if editing existing entry or not
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(leading: IconButton( //adding a back button
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
          title: Text(title),
        ),
        body:
        Container(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
        Wrap(
            spacing: 30, // to apply margin in the main axis of the wrap
            runSpacing: 30, // to apply margin in the cross axis of the wrap
            children: [
          TextField(
              controller: dateController, //editing controller of this TextField
              decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today), //icon of text field
                  labelText: "Enter Date" //label text of field
              ),
              readOnly: true,  // when true user cannot edit text
              onTap: () async {
                _resetVal();
                _getDate();//when pressing the date field call function to get the date also reset the values
              }
          ),
        TextField(
          keyboardType: TextInputType.number,decoration: const InputDecoration(
            labelText: "Enter Target Calories", //label text of field
            hintText: "Target Calories"
        ),
          controller: myController, //setting the controller for this field
        ),
          if (filtered.isNotEmpty) ... { //checking that the filtering list is NOT empty, other wise do nothing
            Container(height:300,  child:
            ListView.separated(shrinkWrap: true,
            itemCount: filtered.length, separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemBuilder: (context, index) {
            return  Card(child:ListTile(
            onTap: () {
              setState(() {
                  if((totalCal+filtered[index].calories)<=(maxCal)) {
                    totalCal+=filtered[index].calories;
                    cartItems.add(filtered[index]);
                    int temp = maxCal-totalCal;


                    List<String> itemDisp = cartItems.map((note) => note.name).toList(); //from the JSON get specific food items and calorie info
                    String itemText = "${occurence(itemDisp.join(" "))}"; //create a string that holds the list of all the items in the calculation

                    _Text1="Current Calorie total: $totalCal, Calories budget left: $temp\n Current Meal Plan Items: $itemText";
                    _Text2="";
                  } else{
                    _Text2="${filtered[index].name} can not be added, as it puts the cart over.";
                  }
              });
            },
            title: Text(filtered[index].toString()),
            ));
            },
            ))
          },
            Wrap(children: [Text(_Text1), Text(_Text2), Row(children: [ ElevatedButton( //button to submit entry into TB
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent[600], // Background color
              ),
              onPressed: (filtered.isNotEmpty && dateController.text.isNotEmpty && myController.text.isNotEmpty && cartItems.isNotEmpty) ? ()  { _saveCalc();} : null, //call saveCalc function
              child: const Text("Submit"),
            ),


              ElevatedButton( //button to clear the screen
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent[600], // Background color
                ),
                onPressed: ()  { _resetVal();} , //call reset function
                child: const Text("Clear"),
              ),])])  ,


      ]),
    ))));
  }

  Map<String, int> occurence(String text) { //function to calculate how much of each item they selected.
    List<String> words = text.split(" ");


    Map<String, int> count = {};
    for (var word in words) {
      count.update(word, (value) => value + 1, ifAbsent: () => 1);
    }

    return count;
  }


}