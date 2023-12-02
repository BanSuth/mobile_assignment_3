class foodItem { //model class that is used for modeling the food items in the DB
  String name;
  int calories;
  int? id;

  foodItem({ //basic constructor
    required this.name,
    required this.calories,
    this.id
  });

  Map<String, dynamic> toJson() { //function to convert class to json
    return {
      'name': name,
      'calories': calories,
    };
  }

  factory foodItem.fromJson(Map<String, dynamic> json) {  //function to create class from json
    return foodItem(
      name: json['name'],
      calories: json['calories'],
    );
  }

  factory foodItem.fromMap(Map<String, dynamic> json){ //function to create class from map
    return foodItem(name: json['name'], calories: json['calories'], id: json['id']);
  }

  Map<String,dynamic> toMap() { //function to convert class to map
    return {
      'name': name,
      'calories': calories
    };
  }

  @override
  String toString() { //to string method, for when an class object is printed
    return "Name:$name\nCalories: $calories";
  }
}
