import 'dart:convert';
//import 'dart:js_util';
//import 'package:flutter/services.dart';
import 'package:mobile_assign_3/foodItem.dart'; //getting all the required packages
import 'package:flutter/material.dart';

import 'package:mobile_assign_3/DatabaseHelper.dart';

class foodItemsHomePage extends StatefulWidget {
  const foodItemsHomePage({super.key});

  @override
  _foodItemsHomePageState createState() => _foodItemsHomePageState();
}

class _foodItemsHomePageState extends State<foodItemsHomePage> {
  List<foodItem> items = []; //defining variable list to store all the items in the DB
  late DatabaseHelper db; //creating variable to store instance od DB

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper.instance;
    _loadItems(); //function to load all the food items from the DB into list
  }
  Future<void> _loadItems() async { //function to get the food items from the DB

    List<dynamic> foodList = await db.queryAllRows(); //querying the db and getting the list of all the food items.

    if(foodList != null){
      setState(() {
        items = foodList.map((note) => foodItem.fromMap(note)).toList(); //getting that food list and mapping it into a list of foodItem models.
      });
    }

  }

  Future<void> _saveItem(foodItem input) async { //function to save a food item into db.

    await db.insert(input); //insert into DB, the food item. Uses a model class to make things easier

    _loadItems(); //call load items again to update the food item list.

  }

  Future<void> _deleteItem(foodItem input) async { //function to delete an item from the db
    await db.delete(input.id!); //delete an entry using its "ID"

    _loadItems(); //call load items again to update the food item list.
  }

  Future<void> _updateItem(foodItem input) async { //function to update an item from the db
    await db.update(input); //update food item, update information by passing model class (id remains the same, so everything else that changed will be updated).
    _loadItems(); //call load items again to update the food item list.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton( //adding a back button
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
        title: const Text(
          "Food Items",
          style: TextStyle(
            fontSize: 30,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 2,
      ),
      body: GridView.builder( //using a grid view builder to make all cards that display the food items
        padding: const EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width ~/ 200,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 3,
        ),
        itemCount: items.isNotEmpty ? items.length : 1, //setting item count size based on the size of the list
        itemBuilder: (context, index) {

          if(items.isNotEmpty){ //checking if the item list is empty, if NOT display the list of food items else display message to user
            final foodItems = items[index];
          return  Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey)
              ),
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {  //when a card is clicked navigate to an edit food item section
                _navigateToFoodScreen(index);
              },
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodItems.name,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: Text(
                        "Calories: ${foodItems.calories}",
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteFoodDialog(foodItems); //if delete icon is pressed display delete dialog
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );}
            else {
            return Container(
              child: const Center(
                child: Column(
                  children: <Widget>[
                    Text("No Food Items Found.")
                  ],
                ),
              ),
            );
          }
          },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _navigateToFoodScreen(null); //if add button pressed navigate to add food page
        },
      ),
    );
  }

  void _navigateToFoodScreen(int? index) async { //function to navigate to the food screen page
    final editedItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodScreen( //routing the add food page, if editing a entry pass the associated entry
          food: index != null ? items[index] : null,
        ),
      ),
    );
    if (editedItem != null) { //if is evaled when the route returns.

      setState(() {
        if (index != null) { // if dealing with an update to an entry
          _updateItem(editedItem);
          //items[index] = editedItem;

        } else { //if dealing with a new entry
          _saveItem(editedItem); // Save item
          //items.add(editedItem);
        }
      });

    }
  }

  void _deleteFoodDialog(foodItem food) { //function to show the delete dialog box , and call delete function
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
                        Navigator.of(context).pop();
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
                        _deleteItem(food); // delete food item
                        Navigator.of(context).pop();//go back if they don't want to delete
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

class FoodScreen extends StatefulWidget { //creating stateful widget for the food screen
  final foodItem? food;

  const FoodScreen({super.key, this.food});

  @override
  _FoodScreenState createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  late TextEditingController _nameController;
  late TextEditingController _textController;  //defining controllers for the program.

  bool _validate1 = false; //global variables used to check of text fields are empty
  bool _validate2 = false;
  int? idEdit ;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.food?.name ?? ''); //defining controllers with data ONLY IF editing existing entry, else leave blank
    _textController = TextEditingController(text:"${widget.food?.calories ?? ''}" );
    idEdit = widget.food?.id; //setting value for idEDIT, can be null
  }

  @override
  void dispose() {
    _nameController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.food != null ? 'Edit Food Item' : 'Add Food Item'), //setting title based on if user is editing or adding a food item.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField( //text field to get name for food item
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Food Name' ,
                hintText: 'Enter The Food Name',
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                      width: 0.5, color: Colors.grey),
                ),
                errorText: _validate1 ? 'Value Cant Be Empty' : null //if user trys to submit with empty field display error
              ),
            ),
            const SizedBox(height: 16.0),
            TextField( //text field to get calories for food item
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
      floatingActionButton: Align( //add button
        alignment: Alignment.bottomRight,
        child: FloatingActionButton.extended(
          onPressed: () { //when add button pressed add to db
            setState(() {
              _nameController.text.isEmpty ? _validate1 = true : _validate1 = false; //checking that fields are not empty
              _textController.text.isEmpty ? _validate2 = true : _validate2 = false;
            });
            if (!(_validate1 || _validate2)){ //only go through if fields are NOT empty
            //creating modelClass to pass back so it can be added to the DB
            final editedFood = idEdit!=null ? foodItem(name: _nameController.text,calories: int.parse(_textController.text), id: idEdit) : foodItem(name: _nameController.text,calories: int.parse(_textController.text));
            Navigator.pop(context, editedFood);}
          },
          icon: const Icon(Icons.save),
          label: Text(widget.food != null ? 'Save' : 'Add'),
        ),
      ),
    );
  }


}
